local
--typedef enum {
	NITE_JOINT_HEAD,
	NITE_JOINT_NECK,

	NITE_JOINT_LEFT_SHOULDER,
	NITE_JOINT_RIGHT_SHOULDER,
	NITE_JOINT_LEFT_ELBOW,
	NITE_JOINT_RIGHT_ELBOW,
	NITE_JOINT_LEFT_HAND,
	NITE_JOINT_RIGHT_HAND,

	NITE_JOINT_TORSO,

	NITE_JOINT_LEFT_HIP,
	NITE_JOINT_RIGHT_HIP,
	NITE_JOINT_LEFT_KNEE,
	NITE_JOINT_RIGHT_KNEE,
	NITE_JOINT_LEFT_FOOT,
	NITE_JOINT_RIGHT_FOOT = 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
--} NiteJointType;

local skeleton = require 'skeleton'
-- Get the number of users being tracked
local n_users = skeleton.open()
print( "Number of Skeletons:", n_users )

--for n=1,10 do
while true do
  local visible = skeleton.update()
	if visible and type(visible)=="table" and #visible==n_users then
		for u,v in pairs(visible) do
			if v then
				local head = skeleton.joint(u,NITE_JOINT_HEAD);
				for j,stats in pairs(head)do
					if type(stats)=="table" then
						print( j, unpack(stats) )
					else
						print( j, stats )
					end
				end
				print()
			end
		end
	else
		print("Bad user tracking!",rc)
	end
end
-- Shutdown the skeleton
skeleton.shutdown()