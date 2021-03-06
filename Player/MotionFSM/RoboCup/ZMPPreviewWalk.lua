----------------------------------------------------
-- Walk controller based on ZMP preview control
----------------------------------------------------


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

-- Save gyro stabilization variables between update cycles
-- They are filtered.  TODO: Use dt in the filters
local angleShift = vector.new{0,0,0,0}

-- What foot trajectory are we using?
local foot_traj_func  
if Config.walk.foot_traj==1 then foot_traj_func = moveleg.foot_trajectory_base
else foot_traj_func = moveleg.foot_trajectory_square end

local uLeft_now, uRight_now, uTorso_now, uLeft_next, uRight_next, uTorso_next
local iStep, iStep_new
local t, t_discrete

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

  uLeft_now, uRight_now, uTorso_now, uLeft_next, uRight_next, uTorso_next=
      step_planner:init_stance()

  zmp_solver:init_preview_queue(uLeft_now,uRight_now, uTorso_now, Body.get_time(), step_planner)
   
  mcm.set_walk_bipedal(1)
  mcm.set_walk_stoprequest(0) --cancel stop request flag
  mcm.set_walk_ismoving(1) --declare that we are moving

  t = Body.get_time()
  t_discrete = t
end

function walk.update()
  -- Get the time of update
  local t = Body.get_time()
  local t_diff = t - t_update
  t_update = t   -- Save this at the last update time
  local stoprequest = mcm.get_walk_stoprequest()
  local discrete_updated = false
  local com_pos

  --Check if the torso stopped to move
  if stoprequest>0 and zmp_solver:can_stop() then
    return "done"
  end

  while t_discrete<t do    
    --Get step information
    uLeft_now, uRight_now, uLeft_next, uRight_next,
      supportLeg, ph, iStep_new = zmp_solver:get_current_step_info(t_discrete)
    com_pos = zmp_solver:update_state() --Get the current COM position

    zmp_solver:update_preview_queue_velocity(step_planner,t_discrete, stoprequest)
    t_discrete = t_discrete + zmp_solver.preview_tStep
    discrete_updated = true
  end

  if discrete_updated then
    local uTorso = {com_pos[1],com_pos[2],0}
    uTorso[3] = ph*(uLeft_next[3]+uRight_next[3])/2 + (1-ph)*(uLeft_now[3]+uRight_now[3])/2

    --Calculate Leg poses 
    local phSingle = moveleg.get_ph_single(ph,Config.walk.phSingle[1],Config.walk.phSingle[2])
    local uLeft, uRight, zLeft, zRight = uLeft_now, uRight_now, 0,0
    if supportLeg == 0 then  -- Left support    
      uRight,zRight = foot_traj_func(phSingle,uRight_now,uRight_next,stepHeight)    
    elseif supportLeg==1 then   -- Right support    
      uLeft,zLeft = foot_traj_func(phSingle,uLeft_now,uLeft_next,stepHeight)    
    end
    step_planner:save_stance(uLeft,uRight,uTorso)  


  -- Grab gyro feedback for these joint angles
    local gyro_rpy = moveleg.get_gyro_feedback( uLeft, uRight, uTorso, supportLeg )
    delta_legs, angleShift = moveleg.get_leg_compensation(supportLeg,ph,gyro_rpy, angleShift)

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
  mcm.set_walk_ismoving(0) --We stopped moving
end

return walk
