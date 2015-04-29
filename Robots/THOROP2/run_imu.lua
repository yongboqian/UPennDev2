#!/usr/bin/env luajit

-- DCM is a thread or standalone
local CTX, metadata = ...
-- Still need our library paths set
dofile'include.lua'
--assert(ffi, 'IMU | Please use LuaJIT :). Lua support in the near future')
-- Going to be threading this
local si = require'simple_ipc'
-- Import the context
local parent_ch, IS_THREAD
if CTX and not arg then
	IS_THREAD = true
	si.import_context(CTX)
	-- Communicate with the master thread
	parent_ch = si.new_pair(metadata.ch_name)
end
imu_ch = si.new_subscriber'imu!'
-- Reset the metadata, since only one imu on file
metadata = Config.imu
-- Fallback on undefined metadata
assert(metadata, 'IMU | No metadata found!')
local running = true
local function shutdown()
	running = false
end
if not IS_THREAD then
  signal = require'signal'
  signal.signal("SIGINT", shutdown)
  signal.signal("SIGTERM", shutdown)
end

local USE_MAG = false
local OVERRIDE_YAW = true
local CALIBRATE_GYRO_BIAS = true
local CALIBRATION_THRESHOLD = 0.01

-- Modules
require'dcm'
local lM = require'libMicrostrain'
local vector = require'vector'

-- Cache the typical commands quickly
local get_time = unix.time
local acc_ptr  = dcm.sensorPtr.accelerometer
local gyro_ptr = dcm.sensorPtr.gyro
local rpy_ptr  = dcm.sensorPtr.rpy
local mag_ptr  = dcm.sensorPtr.magnetometer
local acc, gyro, mag, rpy = vector.zeros(3), vector.zeros(3), vector.zeros(3), vector.zeros(3)
local read_count, last_read_count = 0,0 --to get hz
local sformat = string.format

-- Local variables
local yaw = 0 --this is generated by integrating yaw gyro
-- -1 degree every 7 seconds
local gyro_yaw_bias = vector.zeros(3)
local uptime, kb, fps = 0, 0, 0
local t0, t_debug, t, t_read, t_last_read
local microstrain

-- Collect garbage before starting
collectgarbage()

local function do_read()
	-- Get the accelerometer, gyro, magnetometer, and euler angles
	local a, g, dg, e, m = microstrain:read_ahrs()
  t_read = get_time()
	if not a then return end

	-- Quickly set in shared memory
	acc_ptr[0], acc_ptr[1], acc_ptr[2] = a[1], a[2], -a[0]
	gyro_ptr[0], gyro_ptr[1], gyro_ptr[2] =
    g[1] - gyro_yaw_bias[1], g[2] - gyro_yaw_bias[2], -g[0] - gyro_yaw_bias[3]
  if USE_MAG then
	  mag_ptr[0], mag_ptr[1], mag_ptr[2] = m[1], m[2], -m[0]
  end
  -- delta yaw in that episode, less the initial offset
  local del_yaw = -dg[0]
  --yaw = yaw + (del_yaw - gyro_yaw_bias[3] * (t_read - t_last_read) )
  -- NOTE: Assume a 100Hz update rate, as timestamps may be inaccurate
  yaw = yaw + (del_yaw - gyro_yaw_bias[3] * 0.01 )
  
  -- Overwrite the RPY value
  if OVERRIDE_YAW then
  	rpy_ptr[0], rpy_ptr[1], rpy_ptr[2] = e[1], e[2], yaw
  else
    rpy0_yaw = rpy0_yaw or -e[0]
  	rpy_ptr[0], rpy_ptr[1], rpy_ptr[2] = e[1], e[2], -e[0] - rpy0_yaw
  end

  -- Save the time and count
  read_count = read_count + 1
  t_last_read = t_read
  return t_read
end

-- Open the device
microstrain = lM.new_microstrain('/dev/ttyACM0', OPERATING_SYSTEM~='darwin' and 921600)
-- Turn it on
microstrain:ahrs_on()
--microstrain:ahrs_and_nav_on()
t0 = get_time()
t_debug, t_last, t = t0, t0, t0
t_last_read = t0


--SJ: We need to add check to see whether the robot was not moving
--TODO

if CALIBRATE_GYRO_BIAS then
  local n = 1
  print("Calibrating the gyro bias for "..n.." seconds")
  local gyro_accumulated, count_accumulated = vector.zeros(3), 0
  local t_diff, cur_reading, max_reading
  repeat
    t = do_read()
    if not t then break end
    t_diff = t - t0
    cur_reading = dcm.get_sensor_gyro()
    max_reading = math.abs(math.max(unpack(cur_reading)))
    if max_reading > CALIBRATION_THRESHOLD then
      print("\n!!! Bad calibration !!")
      print("Please run IMU again")
      print(string.format("Value %f exceeds %f limit\n", max_reading, CALIBRATION_THRESHOLD))
      running = false
    end
    gyro_accumulated = gyro_accumulated + cur_reading
    count_accumulated = count_accumulated + 1
  until t_diff > n or not running
  yaw = 0
  gyro_yaw_bias = gyro_accumulated / count_accumulated
  print("BIAS:", gyro_yaw_bias, gyro_accumulated)
end

-- Run the main loop
while running do
	-----------------
	-- Read Values --
	-----------------
	t = do_read()
	--------------------
	-- Periodic Debug --
	--------------------
  if t - t_debug > 1 then
    os.execute('clear')
		kb = collectgarbage('count')
    uptime = t - t0
    fps = (read_count-last_read_count) / (t-t_debug)
    last_read_count = read_count
    local acc = dcm.get_sensor_accelerometer()
    local gyro = dcm.get_sensor_gyro()
    local mag = dcm.get_sensor_magnetometer()
    local rpy = dcm.get_sensor_rpy()
		local debug_str = {
			sformat('\nIMU | Uptime %.2f sec, Mem: %d kB', t-t0, kb),
			sformat('Acc (g): %.2f %.2f %.2f', unpack(acc)),
			sformat('Gyro (rad/s): %.2f %.2f %.2f', unpack(gyro)),
			sformat('RPY:  %.2f %.2f %.2f', unpack(RAD_TO_DEG * rpy)),
--      sformat('Yaw: %.2f, Integration: %.2f', RAD_TO_DEG * rpy[3], RAD_TO_DEG * yaw),
		}
    if USE_MAG then
      table.insert(debug_str, sformat('Mag (Gauss): %.2f %.2f %.2f', unpack(mag)))
    end
    debug_str = table.concat(debug_str, '\n')
    if parent_ch then
      parent_ch:send(debug_str)
    else
  		print(debug_str)
    end
    t_debug = t
  end
	---------------------
	-- Parent Commands --
	---------------------
  if parent_ch then
  	local parent_msgs = parent_ch:receive(true)
  	if parent_msgs then
  		for _, msg in ipairs(parent_msgs) do
  			if msg=='exit' then
  				shutdown()
  			end
  		end
  	end
  end
	collectgarbage('step')
end

print("Stopping...")
microstrain:ahrs_off()
microstrain:close()
if IS_THREAD then parent_ch:send'done' end
print('IMU | Exit')
