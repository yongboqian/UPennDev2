--------------------------------------------------------
--One Legged Balance Controller
--------------------------------------------------------
dofile('../include.lua')

require('acm')
require('scm')
require('pid')
require('unix')
require('util')
require('Body')
require('walk')
require('curses')
require('Config')
require('vector')
require('Kinematics')
require('matrix')
require('filter')
require('filter_2order')
require('Transform')
require('integrator')
require('derivative')
require('butter_filter')

local joint = Config.joint
local filewritepos=assert(io.open("write_filepos.txt","w"))
local filewritevel=assert(io.open("write_filevel.txt","w"))
local filewriteacc=assert(io.open("write_fileacc.txt","w"))
local filewriteahrs=assert(io.open("write_fileahrs.txt","w"))

if not string.match(Config.platform.name, 'Webots') then
  return
end

--------------------------------------------------------------------
-- Parameters
--------------------------------------------------------------------
--local stats = util.loop_stats(100)
local t, dt = Body.get_time(), 0
local COG_ratio = 1.182 --m_total/(m_torso+2*leg_length_ratio*m_leg)-- tune this and just set it instead
local qt = {} --desired joint angles 
local joint_pos = vector.new{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} --current joint positions
local joint_pos_old = vector.new{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local joint_vel = vector.new{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} --current joint velocity
local joint_vel2 = vector.new{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} --current joint velocity
local joint_acc = vector.new{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local joint_torques = vector.new{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} --desired joint torques
local foot_state = {[5] = 1, [6] = 1, [11] = 1, [12] = 1} --left foot, right foot on ground? 1 = yes, 0 = no
local ahrs = {}
local ahrs_filt = {}
local COP_filt = {0, 0} --filtered COP location wrt torso projection
local COG = {0, 0}
local ft_filt = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} --filtered force torque data
local l_leg_offset = vector.new{0, 0, 0} --pos at beginning of move
local r_leg_offset = vector.new{0, 0, 0}
local ankle_offset = 0
local hip_offset = 0
local state_t = 0 --keps record of time in each state
local state = 0 --keeps record of which state program is in
local run = true --boolean to quit program
local move_leg = vector.new{0, 0, 0} 
local torso_position = vector.new{0, 0, 0}
local step = 1
local left_cop = {}
local right_cop = {}
local force_torque = {}
local printdata = false
local inc = 2
local temp_acc = 0
local temp_vel = 0
local temp_torque = 0

------------------------------------------------------------------
--Control objects:
------------------------------------------------------------------

local filter_b = {0.013251, 0.026502, 0.013251} --10 break freq, ts=0.004, chsi=0.7
local filter_a = {-1.6517, 0.70475}
local COP_filters = {filter_2order.new(filter_b, filter_a), filter_2order.new(filter_b, filter_a)}

filter_b = {0.0851, 0.1702, 0.0851} --30 break freq, ts=0.004, chsi=0.7
filter_a = {-1.0275, 0.3679}
local pgain, igain, dgain = 300, 0, 50  --need to change eventually for different gains in different joints
local position_pids = {}
local torque_filters = {}
for i, index in pairs(joint.index['ankles']) do
  position_pids[index] = pid.new(pgain, igain, dgain)
  position_pids[index]:set_filter_constant(0.05)
  torque_filters[index] = filter_2order.new(filter_b, filter_a)
end

local pos_filters = {}
local filter_b = { 0.0179,    0.0715,    0.1072,    0.0715,    0.0179} --40 break freq, 4 order butter
local filter_a = {1.0000,   -1.5980,    1.3040,   -0.4987,    0.0787}
for i, index in pairs(joint.index['all']) do
  pos_filters[index] = butter_filter.new(filter_b, filter_a)
end

local vel_filters = {}
local filter_b = { 1.0402,    2.0804,         0,   -2.0804,   -1.0402} --20 break freq, 4 order butter, 1 derivative
local filter_a = {1.0000,   -2.7189,    2.9160,   -1.4357,    0.2719}
for i, index in pairs(joint.index['all']) do
  vel_filters[index] = butter_filter.new(filter_b, filter_a)
end

local acc_filters = {}
local filter_b = { 15.4240,         0,  -30.8480,         0,   15.4240} --7.5 break freq,  4 order butter, 2 derivative
local filter_a = {1.0000,   -3.5092,    4.6446,   -2.7458,    0.6114}
for i, index in pairs(joint.index['all']) do
  acc_filters[index] = butter_filter.new(filter_b, filter_a)
end

--[[filter_b = {42.5, 0, -42.5} --30 break freq, ts=0.004, chsi=0.7
filter_a = {-1.0275, 0.3679}
local acc_filter2 = filter_2order.new(filter_b, filter_a)]]

--[[local vel_filters2 = {}
local filter_b = {0.0001832, 0.0007328, 0.001099, 0.0007328, 0.0001832} --10 break freq, ts=0.004, chsi=0.7
local filter_a = {1, -3.34406, 4.23886, -2.40934, 0.51747}
for i, index in pairs(joint.index['all']) do
  vel_filters2[index] = butter_filter.new(filter_b, filter_a)
end]]

local ft_filters = {}
local filter_b = {0.013251, 0.026502, 0.013251} --10 break freq, ts=0.004, chsi=0.7
local filter_a = {-1.6517, 0.70475}
for i = 1, 12 do
  ft_filters[i] = filter_2order.new(filter_b, filter_a)
end

local ahrs_filters = {}
local filter_b = {0.0002,    0.0007,    0.0011,    0.0007,    0.0002} --10 break freq, butterworth
local filter_a = {1.0000,   -3.3441,    4.2389,   -2.4093,    0.5175}
for i = 1, 9 do
  ahrs_filters[i] = butter_filter.new(filter_b, filter_a)
end

------------------------------------------------------------------
--Utilities:
------------------------------------------------------------------

function cop(ft)  -- finds the x and y position of the COP under the foot
  local cop_left, cop_right = {}, {}
  if (ft[3]~=0) then
    cop_left[1] = -ft[5]/ft[3] --+ 0.0185 --0.0185 term adjusts COP wrt xy position of ankle joint 
    cop_left[2] = ft[4]/ft[3]
    foot_state[5], foot_state[6] = 1, 1
  else
    cop_left[1] = 999
    cop_left[2] = 999
    foot_state[5], foot_state[6] = 0, 0
  end
  if (ft[9]~=0) then
    cop_right[1] = -ft[11]/ft[9] --+ 0.0185 
    cop_right[2] = ft[10]/ft[9]
    foot_state[11], foot_state[12] = 1, 1
  else
    cop_right[1] = 999
    cop_right[2] = 999
    foot_state[11], foot_state[12] = 0, 0
  end
  return cop_left, cop_right
end

function robot_cop(ft, cop_left, cop_right)
  --returns the center of pressure for the whole robot
  local cop_robot = {}
  local l_foot_pos, r_foot_pos = foot_rel_torso_proj()
  if not(ft[3] == 0 and ft[9] == 0) then
    cop_robot[1] = ((cop_left[1] + l_foot_pos[1])*ft[3] + (cop_right[1] + r_foot_pos[1])*ft[9])/(ft[3]+ft[9])
    cop_robot[2] = ((cop_left[2] + l_foot_pos[2])*ft[3] + (cop_right[2] + r_foot_pos[2])*ft[9])/(ft[3]+ft[9])
  else
     cop_robot = {0, 0}
  end
  return cop_robot
end

function COP_update()
  force_torque = scm:get_force_torque()
  left_cop, right_cop = cop(force_torque) --compute COP
  COP = robot_cop(force_torque, left_cop, right_cop) 
  COP_filt[1] = COP_filters[1]:update(COP[1])
  COP_filt[2] = COP_filters[2]:update(COP[2])
end

function foot_rel_torso_proj()
  --computes foot position relative to the torso coord frame projection on ground
  --requires updated matrix.lua file
  local left_foot_transform = Kinematics.forward_l_leg(joint_pos)
  local right_foot_transform = Kinematics.forward_r_leg(joint_pos)
  local left_foot_pos = matrix.new(3, 1, 0)
  local right_foot_pos = matrix.new(3, 1, 0)
  local transform=matrix.new(3,3,0)
  local torso_rpy = {0, 0, 0, ahrs[7], ahrs[8], ahrs[9]}
  local torso_transform = Transform.transform6D(torso_rpy)
  for i1 = 1, 3 do
    for i2 = 1, 3 do
      transform[i1][i2]=torso_transform[i1][i2]
    end
    left_foot_pos[i1]=left_foot_transform[i1][4] --copy position vectors
    right_foot_pos[i1]=right_foot_transform[i1][4]
  end
  left_foot_pos = matrix.mul(transform, left_foot_pos)
  right_foot_pos = matrix.mul(transform, right_foot_pos)
  for i1 = 1, 3 do  --convert fromm matrix to vector
    left_foot_pos[i1]=left_foot_pos[i1][1]
    right_foot_pos[i1]=right_foot_pos[i1][1]
  end
  return left_foot_pos, right_foot_pos
end

function trajectory_percentage(final_pos,time_final,time)
  local velocity = 5/4*final_pos/time_final
  local accel = velocity/(time_final/5)
  local percent = 0
  if (time <= time_final/5) then
    percent = 1/2*time^2*accel
  elseif (time <= time_final*4/5) then
    percent = 1/2*time_final/5*velocity + velocity*(time-time_final/5)
  elseif (time < time_final) then
    percent = 7/10*time_final*velocity + velocity*(time-time_final*4/5) - 1/2*accel*(time-4/5*time_final)^2
  else
    percent = 1
  end
  return percent
end

function update_joint_torques(foot_state_l)
  -- update force commands
  local torques=vector.new{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} --current joint velocity
  local temp=0
  local max = {[5] = 13, [6] = 13, [11] = 13, [12] = 13 } --max torques in x, y for l and r feet
  local min = {[5] = -13, [6] = -13, [11] = -13, [12] = -13 }
  for i, pid_loop in pairs(position_pids) do
    temp = pid_loop:update(qt[i], joint_pos[i], dt) --qt[i] --need to update
    temp = math.min(temp, (foot_state_l[i] + 1)*max[i] )
    temp = math.max(temp, (foot_state_l[i] + 1)*min[i] )
    if (i == 5 or i == 6) then --turns act to 0 if foot is off grnd
       if (force_torque[3] < 60) then temp = 0 end
    end
    if (i == 11 or i == 12) then
       if (force_torque[9] < 60) then temp = 0 end
    end
    temp = torque_filters[i]:update(temp)
    if (temp < 1) and (temp > -1) then temp = 0 end
    torques[i] = temp
  end
  return torques
end


function update_joint_data()
local raw_pos = scm:get_joint_position()
--position filters
  for i, filter_loop in pairs(pos_filters) do
    joint_pos[i] = filter_loop:update(raw_pos[i])
  end
--velocity filters
  for i, filter_loop in pairs(vel_filters) do
    joint_vel[i] = filter_loop:update(raw_pos[i])
  end
--acceleration filters
  for i, filter_loop in pairs(acc_filters) do
    joint_acc[i] = filter_loop:update(raw_pos[i]) 
  end
    
end

function update_force_torque()
--filters the force torque data for use
  local ft = scm:get_force_torque() --debuggin
  for i = 1, 12 do
    ft_filt[i] = ft_filters[i]:update(ft[i])
  end 
end

function COG_update()
  local l5, l3, l9 = 0.05300, 0.00574, 0.00242
  local c5, c3, c9 = 14.055, 0.5480, 2.3036
  local fx = ft_filt[1] + ft_filt[7]
  COG = COP[1] + fx*(l5*joint_acc[5] + l3*joint_acc[3] + l9*joint_acc[9])/(c5*joint_acc[5] + c3*joint_acc[3] + c9*joint_acc[9])
end

function ahrs_update()
  ahrs = scm:get_ahrs()
  for i = 1, 9 do
    ahrs_filt[i] = ahrs_filters[i]:update(ahrs[i])
  end 
end
--------------------------------------------------------------------
--Motion Functions:
--------------------------------------------------------------------

function move_legs(torso)
--returns joint angle required to move the torso origin to given location
--(negative torso z motion moves torso down)
--fix to incorporate foot pos wrt torso coordinate center 
  local x_offset = l_leg_offset[1]
  local y_offset = l_leg_offset[2]
  local z_offset = l_leg_offset[3]
  local l_foot_pos = {x_offset-torso[1], y_offset-torso[2], z_offset-torso[3], 0, 0, 0} 
  local r_foot_pos = {x_offset-torso[1],-y_offset-torso[2], z_offset-torso[3], 0, 0, 0} 
  local torso_pos = {0, 0, 0, 0, 0, 0}

  local qStance = Kinematics.inverse_legs(l_foot_pos, r_foot_pos, torso_pos)
  return qStance  
end

function move_r_leg(r_leg)
  local temp = r_leg_offset + r_leg
  local l_foot_pos = {l_leg_offset[1], l_leg_offset[2], l_leg_offset[3], 0, 0, 0} 
  local r_foot_pos = {temp[1], temp[2], temp[3], 0, 0, 0}  --use vector here to improve syntax
  local torso_pos = {0, 0, 0, 0, 0, 0} 

  local qLeg = Kinematics.inverse_legs(l_foot_pos, r_foot_pos, torso_pos)
  return qLeg
end

function desired_cop_location(COG_shift_x, COG_shift_y)
  local torso_shift = vector.new{0,0,0}
  torso_shift[1] = COG_shift_x*COG_ratio
  torso_shift[2] = COG_shift_y*1.30--COG_ratio
  return torso_shift
end

local acc_integ = integrator.new(0.004)
local vel_integ = integrator.new(0.004)

function sagital_balance(offset) --controls pitch axes
  local gains = vector.new{337.7, -58.8, 13.5, -2.7}
  local states = vector.new{joint_pos[5]-offset[1], joint_pos[3]-offset[2], joint_vel[5], joint_vel[3]}
  local acc = vector.mul(gains, states)
  --print('s1 2 3 4', joint_pos[5]-offset[1], joint_pos[3]-offset[2], joint_vel[5], joint_vel[3], acc)
  return acc
end

function swing_balance()
  --local 
end

------------------------------------------------------------------------
--State machine
------------------------------------------------------------------------

function state_machine(t) 
  if (state == 0) then
    --put in low ready
    --compute initial offsets and set torso movement
    local left_leg_position = Kinematics.forward_l_leg(joint_pos)
    l_leg_offset = {left_leg_position[1][4], left_leg_position[2][4], left_leg_position[3][4]}
    torso = vector.new{0, 0, -0.05}
    printdata = true
    if state_t >=0.5 then
      state = 8
      state_t = 0
    end
  elseif (state == 1) then 
    --move to ready position
    local percent = trajectory_percentage(1, 2, state_t)
    qt = move_legs(percent*torso)
    if (percent >= 1) then  --when movement is complete, advance state
      state = 2
      state_t = 0
    end
  elseif (state == 2) then
    --wait specified time
    if (state_t > 0.5) then  
      --print('state = 3')
      state = 8
      state_t = 0
    end
  elseif (state == 3) then 
    --measure COG
    print('state = 3')
    local left_foot_xy, right_foot_xy = foot_rel_torso_proj()  --foot locations
    --print('left foot pos')  
    --util.ptable(left_foot_xy)
    COG_shift = {left_foot_xy[1] - COP_filt[1], left_foot_xy[2] - COP_filt[2], 0}
    --util.ptable(COP_filt)
    --print('cog_shift')
    --util.ptable(COG_shift)
    torso = desired_cop_location(COG_shift[1], COG_shift[2])
    local left_leg_position = Kinematics.forward_l_leg(joint_pos)  
    l_leg_offset = {left_leg_position[1][4], left_leg_position[2][4], left_leg_position[3][4]}
    --print('torso')
    --util.ptable(torso)
    state = 4
    state_t = 0
  elseif (state == 4) then
    --move to over COG
    local percent = trajectory_percentage(1, 2, state_t)
    local left_foot_xy, right_foot_xy = foot_rel_torso_proj()
    qt = move_legs(percent*torso)
    --print('ft fx cop', force_torque[5], force_torque[3], left_cop[1])
    --print('COP', COP_filt[1], left_cop[1], left_foot_xy[1], state_t)
    if (percent >= 1) then  --when movement is complete, advance state
      state = 5
      state_t = 0
    end
  elseif (state == 5) then
    --
    local left_foot_xy, right_foot_xy = foot_rel_torso_proj()
    --print('COP', COP_filt[1], left_cop[1], left_foot_xy[1])
    if (state_t > 0.7) then
      --print('state = 5')
      left_foot_xy, right_foot_xy = foot_rel_torso_proj()
      --print('COP')  --cop is in relation to foot, not torso, need to fix
      --util.ptable(COP_filt)
      --print('left foot')
      --util.ptable(left_foot_xy)
      --print('left foot ft')
      --util.ptable(left_cop)
      state = 6
      state_t = 0
    end
  elseif (state == 6) then
    -- prepare to lift left foot
    print('state = 6')
    --make function for next 4 lines
    local left_leg_position = Kinematics.forward_l_leg(joint_pos)  
    l_leg_offset = {left_leg_position[1][4], left_leg_position[2][4], left_leg_position[3][4]}
    local right_leg_position = Kinematics.forward_r_leg(joint_pos)  
    r_leg_offset = {right_leg_position[1][4], right_leg_position[2][4], right_leg_position[3][4]}
    move_leg =vector.new{0, 0.02, 0.05}
    state = 7
    state_t = 0
  elseif (state == 7) then
    --lift left leg
    local percent = trajectory_percentage(1, 1, state_t)
    qt = move_r_leg(percent*move_leg)
    if (percent >= 1) then
      print('state = 9')
      --printdata = true
      state = 9
      state_t = 0
      ankle_offset = joint_pos[5]
      print('ankle_offset', ankle_offset)
    end
  elseif (state == 8) then
    --enables force control in ankles
    --printdata = true
    acm:set_joint_enable(0, 'ankles')
    acm:set_joint_mode(1, 'ankles')
    acm:set_joint_force({1,0,1,0},'ankles')
    acm:set_joint_enable(1, 'ankles')
    if state_t > 1 then
      state_t = 0
      state = 10
    end
  elseif (state == 9) then
    -- move individual joints
    local percent = trajectory_percentage(1, 2, state_t)
    local qd = vector.new{0,0,0,0,0.1,0,0,0,0,0,0.1,0}
    --joint_torques = vector.new{0,0,0,0,0,1,0,0,0,0,0,1}
    qt[5] = ankle_offset + percent*0.05
    --qt = percent * qd
    print('qt5 pos5', qt[6], joint_pos[6])
    if (percent >= 1) then
      --printdata = true
      --run = falsetorque_offset
      state = 10
      state_t = 0
      torque_offset = joint_torques[5]
      print('torque offset', torque_offset)
    end
  elseif (state == 10) then
    --apply disturbance
    printdata = true
    local dur = .7
    local mag = -4
    if (state_t < dur) then
      temp_torque = mag-- + torque_offset
    else
      run = false --added for testing
      state_t = 0
      state = 11
      print('state = 11')
      qt[5] = ankle_offset
      ankle_offset = {joint_pos[5], joint_pos[3]} --used for 
      hip_offset = joint_pos[3]
    end
  elseif (state == 11) then
  --turn on balance controller
    if state_t > 0.02 then
      temp_acc = sagital_balance(ankle_offset)
      temp_vel = acc_integ:update(temp_acc)
      temp_pos = vel_integ:update(temp_vel)
      temp_hip = temp_pos + hip_offset
      qt[3] = temp_hip
      --print('acc vel pos', temp_acc, temp_vel, temp_pos, temp_hip)
    end
  end
end

--------------------------------------------------------------------
--Initialize
--------------------------------------------------------------------
Body.entry()
acm:set_joint_enable(0,'all')
local set_values = acm:get_joint_position('all') --records original joint pos
acm:set_joint_mode(0, 'all') -- position control
--acm:set_joint_mode(1, 'ankles')
acm:set_joint_force({0, 0, 0, 0},'ankles')
acm:set_joint_enable(1, 'all')
qt = set_values

--------------------------------------------------------------------
--Main
--------------------------------------------------------------------

while run do   --run step<20
  --update run parameters
  Body.update()
  dt = Body.get_time() - t --
  t = t + dt --simulation time
  state_t = state_t + dt --time used in state machine
  step = step + 1  --step number
  local mod_print = step - math.modf(step/5)*5  --modulo of step for printing

  update_joint_data()
  ahrs_update()
  update_force_torque()
  COP_update()
  COG_update()
  state_machine(t) 
  acm:set_joint_position(qt,'all')
 
  --joint_torques = update_joint_torques(foot_state) --updates PID loops
  if (state == 10) then --if in state 10, apply disturbance torque
     joint_torques[5] = temp_torque 
     joint_torques[11] = temp_torque
  end 
  acm:set_joint_force(-1*joint_torques, 'all') --watch out for this negative sign 
  
  if (printdata) then -- mod_print == 0 and
    filewritepos:write(ahrs_filt[8], ", ", joint_pos[5], "\n")
    filewritevel:write(ahrs_filt[2], ", ",joint_vel[5], "\n")
    filewriteacc:write(ahrs_filt[4], ", ", joint_acc[5], "\n")
    filewriteahrs:write(ahrs_filt[1], ", ",ahrs_filt[2], ", ",ahrs_filt[3], ", ",ahrs_filt[4], ", ",ahrs_filt[5], ", ",ahrs_filt[6], ", ",ahrs_filt[7], ", ",ahrs_filt[8], ", ", ahrs_filt[9], "\n")

    print('vel', joint_vel[5])
    if state == 11 then 
      --print('acc vel pos', temp_acc, temp_vel, temp_pos)
    elseif state == 10 then
      --print('tor ahrs pos vel', joint_torques[5], ahrs[8], joint_pos[5], joint_vel[5], state_t)
    end
  end
  --end
end
Body.exit()


