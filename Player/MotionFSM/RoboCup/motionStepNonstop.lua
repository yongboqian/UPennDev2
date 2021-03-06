--Step controller based on preview ZMP walking
require'Config'

local walk = {}
walk._NAME = ...

local Body   = require'Body'
local vector = require'vector'
local util   = require'util'
local moveleg = require'moveleg'
local libZMP = require'libPreviewZMP'
local zmp_solver

local libStep = require'libStep'
local step_planner

require'mcm'

-- Keep track of important times
local t_entry, t_update, t_last_step

--Gait parameters
local tStep
local stepHeight  = Config.walk.stepHeight

local zLeft,zRight --Step landing heights

-- Save gyro stabilization variables between update cycles
-- They are filtered.  TODO: Use dt in the filters
local angleShift = vector.new{0,0,0,0}

local iStep

-- What foot trajectory are we using?
local foot_traj_func  
--foot_traj_func = moveleg.foot_trajectory_base
--foot_traj_func = moveleg.foot_trajectory_square
foot_traj_func = moveleg.foot_trajectory_square_stair
local t, t_discrete

local t0
---------------------------
-- State machine methods --
---------------------------
function walk.entry()
  print(walk._NAME..' Entry' )
  -- Update the time of entry
  local t_entry_prev = t_entry -- When entry was previously called
  t_entry = Body.get_time()
  t_update = t_entry
 
  mcm.set_walk_vel({0,0,0})--reset target speed

  tStep = Config.walk.tStep

  -- Initiate the ZMP solver
  zmp_solver = libZMP.new_solver({
    ['tStep'] = Config.walk.tStep,
    ['tZMP']  = Config.walk.tZMP,    
  })
  zmp_solver:precompute()

  step_planner = libStep.new_planner()

  zLeft, zRight = 0,0
  uLeft_now, uRight_now, uTorso_now, uLeft_next, uRight_next, uTorso_next=
      step_planner:init_stance()

  zmp_solver:init_preview_queue(uLeft_now,uRight_now, uTorso_now, Body.get_time(), step_planner)
  
  iStep = 1   -- Initialize the step index  
  mcm.set_walk_bipedal(1)
  mcm.set_walk_stoprequest(0) --cancel stop request flag

  --initialize torso velocity correctly
  local torsoVel = mcm.get_status_uTorsoVel()
  zmp_solver.x[2][1] = torsoVel[1]
  zmp_solver.x[2][2] = torsoVel[2]

  local tSlope1 = Config.walk.tStep*Config.walk.phSingle[1]
  local tSlope2 = Config.walk.tStep*(1-Config.walk.phSingle[2])

  local uTorsoVelLocal = util.pose_relative(mcm.get_status_uTorsoVel(), {0,0,uTorso_now[3]})
  if uTorsoVelLocal[2]>0 then --Torso moving to left
    supportLeg = 1

  step_planner:step_enque_trapezoid(
    {0.10,0,0},1,    tSlope1, Config.walk.tStep-tSlope1-tSlope2,tSlope2, {0,0.0,0}, {0,0.05,0}) --LS  
  step_planner:step_enque_trapezoid(
    {0.10,0,0},0,    tSlope1, Config.walk.tStep-tSlope1-tSlope2,tSlope2, {0,0.0,0}, {0,0.05,0}) --LS  
  step_planner:step_enque_trapezoid(
    {0,0,0},2,    1, 3,1,    {0,0.0,0}, {0,0.05,0}) --DS  



  else
    supportLeg = 0

    step_planner:step_enque_trapezoid(
    {0.10,0,0},0,    tSlope1, Config.walk.tStep-tSlope1-tSlope2,tSlope2, {0,0.0,0}, {0,0.05,0}) --LS  
  step_planner:step_enque_trapezoid(
    {0.10,0,0},1,    tSlope1, Config.walk.tStep-tSlope1-tSlope2,tSlope2, {0,0.0,0}, {0,0.05,0}) --LS  
  step_planner:step_enque_trapezoid(
    {0,0,0},2,    1, 3,1,    {0,0.0,0}, {0,0.05,0}) --DS  
  end


  t = Body.get_time()
  time_discrete_shift = zmp_solver:trim_preview_queue(step_planner,t )  
  t_discrete = t 
  t0 = t
 
end

function walk.update()
  -- Get the time of update
  local t = Body.get_time()
  local t_diff = t - t_update
  t_update = t   -- Save this at the last update time
  local discrete_updated = false
  local com_pos

  while t_discrete<t do
    zmp_solver:update_preview_queue_steps(step_planner,t_discrete + time_discrete_shift)
    t_discrete = t_discrete + zmp_solver.preview_tStep
    discrete_updated = true

    --Get step information
    uLeft_now, uRight_now, uLeft_next, uRight_next,
      supportLeg, ph, ended, walkParam, is_last = zmp_solver:get_current_step_info(t_discrete + time_discrete_shift)

    if is_last and ph>0.5 then      
      local com_vel=zmp_solver.x[2]
      print("Torso velocity:", unpack(com_vel))
      mcm.set_status_uTorsoVel({com_vel[1],com_vel[2],0})
      return "towalk"      
    end

    if ended and zmp_solver:can_stop() then return "done"  end
  
    --Get the current COM position
    com_pos,zmp_pos = zmp_solver:update_state()

  end

  if discrete_updated then
    local uTorso = {com_pos[1],com_pos[2],0}
    uTorso[3] = ph*(uLeft_next[3]+uRight_next[3])/2 + (1-ph)*(uLeft_now[3]+uRight_now[3])/2

    --Calculate Leg poses 
    local phSingle = moveleg.get_ph_single(ph,Config.walk.phSingle[1],Config.walk.phSingle[2])
    local uLeft, uRight = uLeft_now, uRight_now
    
    if supportLeg == 0 then  -- Left support    
      uRight,zRight = foot_traj_func(phSingle,uRight_now,uRight_next,stepHeight,walkParam)    
--      if walkParam then print(unpack(walkParam))end
    elseif supportLeg==1 then    -- Right support    
      uLeft,zLeft = foot_traj_func(phSingle,uLeft_now,uLeft_next,stepHeight,walkParam)    
--      if walkParam then print(unpack(walkParam))end
    elseif supportLeg == 2 then --Double support
    end
    step_planner:save_stance(uLeft,uRight,uTorso)  

  -- Grab gyro feedback for these joint angles
    local gyro_rpy = moveleg.get_gyro_feedback( uLeft, uRight, uTorso, supportLeg )
    delta_legs, angleShift = moveleg.get_leg_compensation(supportLeg,phSingle,gyro_rpy, angleShift)

    --Move legs
    moveleg.set_leg_positions(uTorso,uLeft,uRight,zLeft,zRight,delta_legs)

      --For external monitoring
    local uZMP = zmp_solver:get_zmp()
    mcm.set_status_uTorso(uTorso)
    mcm.set_status_uZMP(uZMP)
    mcm.set_status_t(t)
  end
end -- walk.update

function walk.exit()
  print(walk._NAME..' Exit')  
end

return walk
