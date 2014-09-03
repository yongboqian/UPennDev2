dofile'../../include.lua'
local vector = require'vector'
local K = require'THOROPKinematics'
local T = require'Transform'
local K2 = require'fk2'
local torch = require'torch'
local util = require'util'

print()
print('================')
print()

print'Kinematics Functions and variables'
for k,v in pairs(K) do print(k,v) end

print()
print('================')
print()

-- Test forward left
-- 6 DOF arm, with angles given in qLArm
local qLArm = vector.new({0,0,0, 0, 0,0,0})
local qLArm2 = vector.new({90,0,0, -90, 0,0,0})*DEG_TO_RAD
local fL2_t, fL2a_t = torch.eye(4), torch.eye(4)
-- Hack to make super fast (don't go to C ever)
if jit then
	fL2_d = fL2_t:data()
	fL2a_d = fL2a_t:data()
end

dt_all = vector.zeros(6)
local n = 1000
for i=1,n do
	t0 = unix.time()
	fL = K.l_arm_torso_7(qLArm, 0, {0,0}, 0,0,0)
	t1 = unix.time()
	fL2 = K2.fk(qLArm)
	t2 = unix.time()
	if fL2_d then K2.fk_t(fL2_d, qLArm) end
	t3 = unix.time()
	fLa = K.l_arm_torso_7(qLArm2, 0, {0,0}, 0,0,0)
	t4 = unix.time()
	fL2a = K2.fk(qLArm2)
	t5 = unix.time()
	if fL2a_d then K2.fk_t(fL2a_d, qLArm2) end
	t6 = unix.time()
	dt = vector.new{t1-t0, t2-t1,t3-t2,t4-t3,t5-t4,t6-t5}
	dt_all = dt_all + dt
end
print('Times:',dt_all)

-- Find the forward kinematics
fL[2] = fL[2] - K.shoulderOffsetY
fL[3] = fL[3] - K.shoulderOffsetZ
fLa[2] = fLa[2] - K.shoulderOffsetY
fLa[3] = fLa[3] - K.shoulderOffsetZ

--print('Left end effector x,y,z, roll, pitch, yaw')

-- Test other FK
print()
print('Left Angles', qLArm)
print(vector.new(fL))
print(T.position6D(fL2))
print(T.position6D(fL2_t))
print()
print('Left Angles', qLArm2)
print(vector.new(fLa))
print(T.position6D(fL2a))
print(T.position6D(fL2a_t))