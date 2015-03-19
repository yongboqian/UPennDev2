assert(Config, 'Need a pre-existing Config table!')
local vector = require'vector'

------------------------------------
-- For the arm FSM
local arm = {}

-- Default init position
arm.trLArm0 = {0.0, 0.30, -0.25,0,0,0}
arm.trRArm0 = {0.0, -0.30, -0.25,0,0,0}


--Gripper end position offsets (Y is inside)
arm.handoffset = {}
--0.130 + 0.60+0.50
--arm.handoffset.gripper = {0.241,0,0} --Default gripper
arm.handoffset.gripper = {0.23,0,0} --Default gripper (VT)
--0.130+0.139+0.80-0.10
arm.handoffset.outerhook = {0.339,0,0.060} --Single hook (for door)
--0.130 + 0.140+0.80-0.10
--arm.handoffset.chopstick = {0.340,0,0} --Two rod (for valve)
--FROM EMPIRICAL DATA
arm.handoffset.chopstick = {0.440,0,0} --Two rod (for valve)
--New 3 finger gripper
arm.handoffset.gripper3 = {0.28,-0.05,0}



-- Export
Config.arm = arm

return Config