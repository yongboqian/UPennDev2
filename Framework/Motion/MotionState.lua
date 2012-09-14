---------------------------------------------------------
-- Motion State Base Class
---------------------------------------------------------

require('acm')
require('scm')
require('vector')
require('Config')

MotionState = {}
MotionState.__index = MotionState

local joint = Config.joint

function MotionState.new(name)
  o = {_NAME = name}
  -- initialize member data
  o.actuator = acm.new_access_point()
  o.sensor = scm.new_access_point()
  o.running = false
  return setmetatable(o, MotionState)
end

function MotionState:set_joint_access(value, index)
  -- set joint write access privileges
  if value == true then value = 1 end
  if value == false then value = 0 end
  self.actuator:set_joint_write_access(value, index) 
end

function MotionState:get_joint_access(index)
  -- get joint write access privileges
  return self.actuator:get_joint_write_access(index)
end

function MotionState:is_running()
  -- return true if state is executing 
  return self.running 
end

function MotionState:entry()
  -- default entry
  self.running = true
end

function MotionState:update()
  -- default update
end

function MotionState:exit()
  -- default exit
  self.running = false
end

return MotionState
