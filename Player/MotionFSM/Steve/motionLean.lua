local state = {}
state._NAME = ...

local Body   = require'Body'
local vector = require'vector'
local moveleg = require'moveleg'
local util = require'util'
require'mcm'

-- Keep track of important times
local t_entry, t_update, t_last_step

-- Local tracking
local uTorso, uLeft, uRight
local zLeft, zRight
local side
local supportDir, supportFoot, supportPoint
local uTorso, dTorso

-- Config tuning
-- TODO: Ensure all are in Config files
local dTorsoScale = 0.001
local supportX, supportY = Config.walk.supportX, Config.walk.supportY
-- Override based on testing
supportY = 0.5

function state.entry()
  print(state._NAME..' Entry' )
  -- Update the time of entry
  local t_entry_prev = t_entry
  t_entry = Body.get_time()
  t_update = t_entry
	-- Shared variables
  uTorso = mcm.get_status_uTorso()
  uLeft, uRight = mcm.get_status_uLeft(), mcm.get_status_uRight()
  zLeft, zRight = unpack(mcm.get_status_zLeg())
  side = mcm.get_teach_sway()
	-- Local vairables
	side = side=='none' and 'left' or side
  supportDir = side=='left' and 1 or -1
  supportFoot = side=='left' and uLeft or uRight
  supportPoint = util.pose_global({supportX, supportDir*supportY, 0}, supportFoot)
	--
	print(state._NAME, side, 'foot. SUPPORT POINT:', supportPoint, uTorso)
  local l_ft, r_ft = Body.get_lfoot(), Body.get_rfoot()
	print(state._NAME, 'L/R FT:', l_ft, r_ft)
end

function state.update()
  -- Get the time of update
  local t = Body.get_time()
  local dt = t - t_update
  -- Save this at the last update time
  t_update = t
  
  -- Where is our offset?
  local relTorso = util.pose_relative(uTorso, supportPoint)
  local drTorso = math.sqrt(relTorso.x^2 + relTorso.y^2)
  print('relTorso', supportPoint, relTorso, uTorso)
  if drTorso<1e-3 and math.abs(relTorso.a)<DEG_TO_RAD then
    return'done'
  end
  
  -- How spread are our feet?
  local dX = dTorsoScale * relTorso.x / drTorso
  local dY = dTorsoScale * relTorso.y / drTorso
  -- TODO: Add the angle
  -- Move toward the support point
  uTorso = uTorso - vector.pose{dX, dY, 0}
  
  mcm.set_status_uTorso(uTorso)
  moveleg.set_leg_positions_slowly(uTorso, uLeft, uRight, zLeft, zRight, dt)
end

function state.exit()
  print(state._NAME..' Exit')
  local l_ft, r_ft = Body.get_lfoot(), Body.get_rfoot()
  print('L FT', l_ft)
  print('R FT', r_ft)
end

return state
