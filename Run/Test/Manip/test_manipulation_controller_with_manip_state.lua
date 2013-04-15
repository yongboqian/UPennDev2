dofile('../../include.lua')

manip_state = require('Manipulation_state')

--manip_state = manip_state.new()
manip_state.update()
--manip_state.update()

function set_real_T_array_from_table(real_T_array, array_offset, number_array)
	for count=1, #number_array 
		do manipulation_controller.real_T_setitem(real_T_array,array_offset-1+count,number_array[count])
	end
end

function real_T_array_to_table(real_T_array, array_first, array_last)
	v = {}
	for index=array_first, array_last
		do 
			local val = manipulation_controller.real_T_getitem(real_T_array,index)
			n = index-array_first+1
			v[n] = val
			
				
	end
	return v
end


inputs = manipulation_controller.THOR_MC_U
outputs = manipulation_controller.THOR_MC_Y


--val = 0.01
inputs.TimeStep = 0.01

print(inputs.TimeStep)

inputs.JointSpaceGoalEnabled = true
inputs.JointSpaceGoalType = false

set_real_T_array_from_table(inputs.JointSpaceVelocityGoal,0,{0.1,0.2,0.3,0.4,0.5,0.6})

manipulation_controller.THOR_MC_step()

if  manipulation_controller.THOR_MC_Y.Faulted == true then
	--handle faults and pass manipulation_controller.THOR_MC_Y.ErrorCode
	print("faulted")
end

t= real_T_array_to_table(outputs.JointVelocityCmds,0,13)

--mcm:set_desired_r_hand_pose(t,
print("end")

manipulation_controller.THOR_MC_terminate()
