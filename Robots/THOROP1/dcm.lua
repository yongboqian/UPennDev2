--------------------------------
-- Joint Communication Module
-- (c) 2013 Stephen McGill
--------------------------------
local Config = Config or require'Config'
assert(Config, 'JCM requires a config, since it defines joints!')
local nJoint = Config.nJoint
local memory = require'memory'
local vector = require'vector'
local lD = require'libDynamixel'

local shared_data = {}
local shared_data_sz = {}

-- Sensors from the robot
shared_data.sensor = {}
-- Setup from libDynamixel the read only sensor values
for _, sensor in ipairs(lD.registers_sensor) do
  shared_data.sensor[sensor] = vector.zeros(nJoint)
end

-- Force Torque
shared_data.sensor.lfoot = vector.zeros(6)
shared_data.sensor.rfoot = vector.zeros(6)
shared_data.sensor.lzmp = vector.zeros(2)
shared_data.sensor.rzmp = vector.zeros(2)

-- These should not be tied in with the motor readings,
-- so they come after the read/tread setup
-- Raw inertial readings
shared_data.sensor.accelerometer = vector.zeros(3)
shared_data.sensor.gyro          = vector.zeros(3)
shared_data.sensor.magnetometer  = vector.zeros(3)
shared_data.sensor.imu_t  = vector.zeros(1) --we timestamp IMU so that we can run IMU later than state wizard
shared_data.sensor.imu_t0  = vector.zeros(1) --run_imu start time
-- Filtered Roll/Pitch/Yaw
shared_data.sensor.rpy           = vector.zeros(3)
-- Battery level (in volts)
shared_data.sensor.battery       = vector.zeros(1)
shared_data.sensor.compass       = vector.zeros(3)

-- Sensors from the robot
shared_data.tsensor = {}
-- Setup from libDynamixel the read only sensor values
for name, vec in pairs(shared_data.sensor) do
  shared_data.tsensor[name] = vector.zeros(#vec)
end

--  Write to the motors
shared_data.actuator = {}
-- Setup from libDynamixel every write item
-- TODO: Separate parameters? RAM/ROM
for reg, v in pairs(lD.nx_registers) do
  -- Check that it is not a sensor
  local is_sensor
  for _, s in ipairs(lD.registers_sensor) do
    if s==reg then is_sensor = true; break; end
  end
  if not is_sensor then
    shared_data.actuator[reg] = vector.zeros(nJoint)
  end
end

------------------------
-- Call the initializer
memory.init_shm_segment(..., shared_data, shared_data_sz)
