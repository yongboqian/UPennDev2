---------------------------------------------------------------------------
-- Vision Communication Module
-- (c) 2013 Stephen McGill
---------------------------------------------------------------------------
local memory = require'memory'
local vector = require'vector'

-- TODO: Use the Config file somehow

-- shared properties
local shared = {}
local shsize = {}

shared.head_camera = {}
-- YUYV uses 4 bytes to represent 2 pixels, meaning there are 2 bytes per pixel
shared.head_camera.image = 2*160*120
-- Look up table is 262144 bytes
shared.head_camera.lut = 262144
shared.head_camera.t = vector.zeros(1)

shared.head_lidar = {}
-- Hokuyo uses a float, which is 4 bytes, to represent each range
shared.head_lidar.scan = 4*1081
shared.head_lidar.t = vector.zeros(1)

shared.chest_lidar = {}
-- Hokuyo uses a float, which is 4 bytes, to represent each range
shared.chest_lidar.scan = 4*1081
shared.chest_lidar.t = vector.zeros(1)

-- Customize the shared memory size, due to using userdata
shsize.head_camera = shared.head_camera.image + shared.head_camera.lut + 2^16
shsize.head_lidar = shared.head_lidar.scan + 2^16
shsize.chest_lidar = shared.chest_lidar.scan + 2^16

-- Initialize the segment
memory.init_shm_segment(..., shared, shsize)