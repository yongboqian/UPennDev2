#!/usr/bin/env luajit
-----------------------------------
-- Camera manager
-- (c) Stephen McGill, 2014
-----------------------------------
-- Something there is non-reentrant
dofile'../include.lua'
local si = require'simple_ipc'
local mp = require'msgpack.MessagePack'
local jpeg = require'jpeg'
local Body = require'Body'
require'hcm'
require'wcm'

-- Cleanly exit on Ctrl-C
local running = true
local function shutdown()
  running = false
end
local signal = require'signal'
signal.signal("SIGINT", shutdown)
signal.signal("SIGTERM", shutdown)

local metadata
if not arg or type(arg[1])~='string' then
	-- TODO: Find the next available camera
	metadata = Config.camera[1]
else
	local cam_id = arg[1]
	if tonumber(cam_id) then
		metadata = assert(Config.camera[tonumber(cam_id)], 'Bad # ID')
	else
		for _, c in ipairs(Config.camera) do
			if c.name ==cam_id then
				metadata = c
				break
			end
		end
		assert(metadata, 'Bad camera name')
	end
end

local ENABLE_NET, SEND_INTERVAL, t_send
local ENABLE_LOG, LOG_INTERVAL, t_log
local FROM_LOG, LOG_DATE = false

if Config.enable_monitor then
  ENABLE_NET, SEND_INTERVAL, t_send = true, 1/hcm.get_monitor_fps(), 0
end
if Config.enable_log then
  ENABLE_LOG, LOG_INTERVAL, t_log = true, 1 / 5, 0
end

if Config.from_log then
  FROM_LOG, LOG_DATE = true, ''
end

local libLog, logger


-- Extract metadata information
local w = metadata.w
local h = metadata.h
local name = metadata.name
-- Who to send to
local operator
if Config.net.use_wireless then
	operator = Config.net.operator.wireless
else
	operator = Config.net.operator.wired_broadcast
end


-- Form the detection pipeline
local pipeline = {}
for _, d in ipairs(metadata.detection_pipeline) do
	local detect = require(d)
	-- Send which camera we are using
	detect.entry(metadata, Body)
	pipeline[d] = detect
end

-- Channels
-- UDP Sending
--local camera_ch = si.new_publisher('camera0')
if FROM_LOG then 
	operator = 'localhost' 
	print('operator IP:', operator)
end
print('UDP',operator, metadata.udp_port)
local udp_ch = metadata.udp_port and si.new_sender(operator, metadata.udp_port)

-- Metadata for the operator
local meta = {
	t = 0,
	n = 0,
	sz = 0,
	w = w,
	h = h,
	id = name..'_camera',
	c = 'jpeg',
}

-- JPEG Compressor
local c_yuyv = jpeg.compressor('yuyv')
-- Downsampling...
c_yuyv:downsampling(2)
local c_grey = jpeg.compressor('gray')

-- Garbage collection before starting
collectgarbage()
local t_debug = unix.time()

if FROM_LOG then

	local libLog = require'libLog'
	local replay = libLog.open(HOME..'/Logs/', LOG_DATE, 'yuyv')
	local metadata = replay:unroll_meta()
	local util = require'util'
	print('Unlogging', #metadata, 'images from', LOG_DATE)
	local logged_data = replay:log_iter()
	for i, m, yuyv_t in logged_data do
		assert(m.w==w, 'Bad width')
		assert(m.h==h, 'Bad height')
    
    -- Flag to toggle on/off obstacle detection
    if m.obs then 
    	--wcm.set_obstacle_enable(m.obs) 
    end
    
		local t = unix.time()
		-- Check if we are sending to the operator
		if ENABLE_NET then
			local c_img = c_yuyv:compress(yuyv_t, w, h)
			meta.sz = #c_img
			local udp_ret, err = udp_ch:send( mp.pack(meta)..c_img )
      if err then print(err) end
		end

		-- Update the vision routines
		for pname, p in pairs(pipeline) do
			p.update(yuyv_t:data())
      
  		if ENABLE_NET and p.send then
  			for _,v in ipairs(p.send()) do
  				if v[2] then
  					udp_data = mp.pack(v[1])..v[2]
  				else
  					udp_data = mp.pack(v[1])
  				end
  				udp_ret, udp_err = udp_ch:send(udp_data)
  			end
  		end
		end

		-- Debugging
		if t-t_debug>1 then
			t_debug = t
    	print('Obstacle enable?:', wcm.get_obstacle_enable())
		end
		-- Collect garbage every cycle
		collectgarbage()
		-- Sleep a little
		unix.usleep(2e5)
	end
	-- Finish
	os.exit()
end

local uvc = require'uvc'
-- LOGGING
if ENABLE_LOG then
	libLog = require'libLog'
	-- Make the logger
	logger = libLog.new('yuyv', true)
end

-- Open the camera
local camera = uvc.init(metadata.dev, w, h, metadata.format, 1, metadata.fps)
-- Set the params
for i, param in ipairs(metadata.auto_param) do
	local name, value = unpack(param)
	camera:set_param(name, value)
	unix.usleep(1e5)
	local now = camera:get_param(name)
	assert(now==value, string.format('Failed to set %s: %d -> %d',name, value, now))
end
-- Set the params
for i, param in ipairs(metadata.param) do
	local name, value = unpack(param)
	camera:set_param(name, value)
	unix.usleep(1e5)
	local now = camera:get_param(name)
	-- TODO: exposure
	local count = 0
	while count<5 and now~=value do
		camera:set_param(name, value)
		unix.usleep(1e6)
		count = count + 1
		now = camera:get_param(name)
	end
	assert(now==value, string.format('Failed to set %s: %d -> %d',name, value, now))
end

local nlog = 0
local udp_ret, udp_err, udp_data
local t0 = unix.time()
while running do
	SEND_INTERVAL = 1 / hcm.get_monitor_fps()
	-- Grab and compress
	local img, sz, cnt, t = camera:get_image()
	-- Update metadata
	meta.t = t
	meta.n = cnt

	-- Check if we are sending to the operator
	if ENABLE_NET and t-t_send > SEND_INTERVAL then
		local c_img = c_yuyv:compress(img, w, h)
		meta.sz = #c_img
		udp_data = mp.pack(meta)..c_img
		udp_ret, udp_err = udp_ch:send(udp_data)
	end

	-- Do the logging if we wish
	if ENABLE_LOG and t - t_log > LOG_INTERVAL then
		meta.rsz = sz
    meta.obs = wcm.get_obstacle_enable()
    meta.head = Body.get_head_command_position()
    meta.head = Body.get_head_position() --TODO: which one?
    meta.rpy = Body.get_rpy()
    meta.pose = wcm.get_robot_pose()
    --TODO: log joint angles
		for pname, p in pairs(pipeline) do meta[pname] = p.get_metadata() end
		logger:record(meta, img, sz)
		t_log = t
		nlog = nlog + 1
	end

	-- Update the vision routines
	for pname, p in pairs(pipeline) do
		p.update(img)
		if ENABLE_NET and p.send and t-t_send>SEND_INTERVAL then
			for _,v in ipairs(p.send()) do
				if v[2] then
					udp_data = mp.pack(v[1])..v[2]
				else
					udp_data = mp.pack(v[1])
				end
				udp_ret, udp_err = udp_ch:send(udp_data)
			end
			t_send = t
		end
	end

	if t-t_debug>1 then
		t_debug = t
		local kb = collectgarbage('count')
		local debug_str = {
			string.format("Camera | %s Uptime: %.2f Mem: %d kB", name, t-t0, kb),
			"# logs: "..nlog
		}
		print(table.concat(debug_str,'\n'))
	end

	-- Collect garbage every cycle
	collectgarbage('step')
end