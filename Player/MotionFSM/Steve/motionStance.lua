--Stance state is basically a Walk controller
--Without any torso or feet update
--We share the leg joint generation / balancing code 
--with walk controllers

local state = {}
state._NAME = ...

local Body   = require'Body'
local K      = Body.Kinematics
local vector = require'vector'
local unix   = require'unix'
local util   = require'util'
local moveleg = require'moveleg'
local supportX = Config.walk.supportX

-- Keep track of important times
local t_entry, t_update, t_last_step

-- Save gyro stabilization variables between update cycles
-- They are filtered.  TODO: Use dt in the filters
local angleShift = vector.new{0,0,0,0}

-- bodyHeight bounds
local MIN_BH, MAX_BH = 0.75, Config.walk.bodyHeight


function state.entry()
  print(state._NAME..' Entry' )
  -- Update the time of entry
  local t_entry_prev = t_entry -- When entry was previously called
  t_entry = Body.get_time()
  t_update = t_entry

  mcm.set_walk_bipedal(1)
  mcm.set_walk_steprequest(0)
  mcm.set_motion_state(2)
end

function state.update()
  -- Get the time of update
  local t = Body.get_time()
  local dt = t - t_update
  -- Save this at the last update time
  t_update = t

  local qWaist = Body.get_waist_command_position()
  local qLArm = Body.get_larm_command_position()
  local qRArm = Body.get_rarm_command_position()    
  local uTorso = mcm.get_status_uTorso()  
  local uLeft = mcm.get_status_uLeft()
  local uRight = mcm.get_status_uRight()

  mcm.set_walk_ismoving(0) --We stopped moving

  -- Adjust body height
  local bodyHeight_now = mcm.get_stance_bodyHeight()
  local bodyHeightTarget = Config.walk.bodyHeight
  bodyHeightTarget = math.max(MIN_BH, math.min(bodyHeightTarget, MAX_BH))
  local bodyHeight = util.approachTol(bodyHeight_now, bodyHeightTarget, Config.stance.dHeight, dt)
  mcm.set_stance_bodyHeight(bodyHeight)
  
  -- Compensation
  --[[
  local gyro_rpy = Body.get_gyro()
  supportLeg = 2; --Double support
  local delta_legs
  delta_legs, angleShift = moveleg.get_leg_compensation_simple(supportLeg,0,gyro_rpy, angleShift)
  local uTorsoComp = mcm.get_stance_uTorsoComp()
  local uTorsoCompensated = util.pose_global(
     {uTorsoComp[1],uTorsoComp[2],0},uTorso)
  moveleg.set_leg_positions(uTorsoCompensated,uLeft,uRight,0,0,delta_legs)
  --]]
  local zLeft, zRight = unpack(mcm.get_status_zLeg())
  local uTorsoMid0 = util.se2_interpolate(.5, uLeft, uRight)
  local uTorsoMid  = util.pose_global(vector.new({supportX, 0, 0}), uTorsoMid0)
  --print("uTorso, uLeft, uRight",uTorso, uLeft, uRight)
  --print('uTorsoMid0', uTorsoMid0, 'uTorsoMid', uTorsoMid)
  --moveleg.set_leg_positions_slowly(uTorso, uLeft, uRight, 0, 0, dt) -- just stay
  moveleg.set_leg_positions_slowly(uTorsoMid, uLeft, uRight, zLeft, zRight, dt)
  
	-- Update the Shared memory
	mcm.set_status_uTorso(uTorsoMid)
  mcm.set_status_uTorsoVel({0,0,0})
  local steprequest = mcm.get_walk_steprequest()    
  if steprequest>0 then return "done_step" end
end -- walk.update

function state.exit()
  print(state._NAME..' Exit')
  -- TODO: Store things in shared memory?
  local l_ft, r_ft = Body.get_lfoot(), Body.get_rfoot()
  print('L FT', l_ft)
  print('R FT', r_ft)
end

return state
