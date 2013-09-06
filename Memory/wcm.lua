--------------------------------
-- World Communication Module
-- (c) 2013 Stephen McGill
--------------------------------
local vector = require'vector'
local memory = require'memory'

-- shared properties
local shared = {}
local shsize = {}

shared.robot = {}
-- SLAM pose
shared.robot.pose = vector.zeros(3)
-- Sensor readings
shared.robot.rpy = vector.zeros(3)

--[[
shared.robot.team_ball = vector.zeros(3);
shared.robot.team_ball_score = vector.zeros(1);
-- Auto detected objects
shared.ball = {};
shared.ball.x = vector.zeros(1);
shared.ball.y = vector.zeros(1);
shared.ball.t = vector.zeros(1);
shared.ball.velx = vector.zeros(1);
shared.ball.vely = vector.zeros(1);
shared.ball.dodge = vector.zeros(1);
shared.ball.locked_on = vector.zeros(1);
shared.ball.p = vector.zeros(1);
--]]

-- Call the initializer
memory.init_shm_segment(..., shared, shsize)
