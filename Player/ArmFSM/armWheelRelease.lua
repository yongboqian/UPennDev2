local state = {}
state._NAME = ...
require'hcm'
local vector = require'vector'
local util   = require'util'
local movearm = require'movearm'

local handle_pos, handle_yaw, handle_pitch, handle_radius, turnAngle=0,0,0,0,0
local lShoulderYaw, rShoulderYaw = 0,0
local stage = 1;

local qLArmTarget = Config.arm.qLArmInit[3]
local qRArmTarget = Config.arm.qRArmInit[3]
local trLArmTarget = Body.get_forward_larm(qLArmTarget)
local trRArmTarget = Body.get_forward_rarm(qRArmTarget)

local dqArmMax = Config.arm.slow_limit
local dpArmMax = Config.arm.linear_slow_limit
local dturnAngleMax = 3*math.pi/180 -- 3 deg per sec

function state.entry()
  print(state._NAME..' Entry' )
  -- Update the time of entry
  local t_entry_prev = t_entry
  t_entry = Body.get_time()
  t_update = t_entry
  
  -- Let's store wheel data here
  local wheel   = hcm.get_wheel_model()
  turnAngle = hcm.get_wheel_turnangle()
  handle_pos    = vector.slice(wheel,1,3)
  handle_yaw    = wheel[4]
  handle_pitch  = wheel[5]
  handle_radius = wheel[6]

  lShoulderYaw = hcm.get_joints_qlshoulderyaw()
  rShoulderYaw = hcm.get_joints_qrshoulderyaw()

  --open gripper
  Body.set_lgrip_percent(0)
  Body.set_rgrip_percent(0)

-- Inner and outer radius
  handle_radius0 = handle_radius 
  handle_radius1 = handle_radius + 0.08

  stage = 1;
end

function state.update()
--  print(state._NAME..' Update' )
  -- Get the time of update
  local t  = Body.get_time()
  local dt = t - t_update
  -- Save this at the last update time
  t_update = t
  --if t-t_entry > timeout then return'timeout' end

  if stage==1 then --return to arm side-by-side position
    turnAngle,doneA = util.approachTol(turnAngle,0,dturnAngleMax, dt )
    ret = movearm.setArmToWheelPosition(
      handle_pos, handle_yaw, handle_pitch,
      handle_radius0, turnAngle,dt,
      lShoulderYaw, rShoulderYaw)
    if ret==1 and doneA then stage=stage+1; 
    end
  elseif stage==2 then --Now spread arms apart
    ret = movearm.setArmToWheelPosition(
      handle_pos, handle_yaw, handle_pitch,
      handle_radius1, turnAngle,dt,
      lShoulderYaw, rShoulderYaw)
    if ret==1 then stage=stage+1; end
  else --Now lower the arm to position #2 using IK
    ret = movearm.setArmToPosition(
      trLArmTarget,
      trRArmTarget,
      dt,
      lShoulderYaw,rShoulderYaw
      )
    if ret==1 then return'done'
    end  
  end
end

function state.exit()
  print(state._NAME..' Exit' )
end

return state