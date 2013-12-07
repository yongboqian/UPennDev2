local state = {}
state._NAME = ...
require'hcm'
local vector = require'vector'
local util   = require'util'
local movearm = require'movearm'
local libArmPlan = require 'libArmPlan'
local arm_planner = libArmPlan.new_planner()

--Door opening state using HOOK

local rhand_rpy0 = Config.armfsm.dooropen.rhand_rpy


local rollTarget = Config.armfsm.dooropen.rollTarget
local yawTargetInitial = Config.armfsm.dooropen.yawTargetInitial
local yawTarget1 = Config.armfsm.dooropen.yawTarget1
local yawTarget2 = Config.armfsm.dooropen.yawTarget2


local trLArm0, trRArm0, trLArm1, trRArm1, trRArm2
local stage


local debugdata

function state.entry()
  print(state._NAME..' Entry' )
  -- Update the time of entry
  local t_entry_prev = t_entry
  t_entry = Body.get_time()
  t_update = t_entry

  mcm.set_arm_lhandoffset(Config.arm.handoffset.outerhook)
  mcm.set_arm_rhandoffset(Config.arm.handoffset.outerhook)
  local qLArm = Body.get_larm_command_position()
  local qRArm = Body.get_rarm_command_position()

  qLArm0 = qLArm
  qRArm0 = qRArm
  trLArm0 = Body.get_forward_larm(qLArm0)
  trRArm0 = Body.get_forward_rarm(qRArm0)  

  qLArm1 = qLArm
  qRArm1 = Body.get_inverse_arm_given_wrist( qRArm, {0,0,0, unpack(rhand_rpy0)})
  trLArm1 = Body.get_forward_larm(qLArm1)
  trRArm1 = Body.get_forward_rarm(qRArm1)

  qRArm2 = Body.get_inverse_arm_given_wrist( qRArm, Config.armfsm.dooropen.rhand_release[4])  
  trRArm2 = Body.get_forward_rarm(qRArm2)

  -- Default shoulder yaw angle: (-5,5)
  arm_planner:set_shoulder_yaw_target(qLArm0[3],nil) --Lock left shoulder yaw
  local wrist_seq = {{'wrist',nil,trRArm1}}
  if arm_planner:plan_arm_sequence2(wrist_seq) then 
    stage = "wristyawturn"
    hcm.set_state_proceed(1)
  end
 
  hcm.set_door_model(Config.armfsm.dooropen.default_model)
  hcm.set_door_yaw(0)
  debugdata=''

  hcm.set_state_tstartactual(unix.time()) 
  hcm.set_state_tstartrobot(Body.get_time())

end

local function update_model()
  local trRArmCurrent = hcm.get_hands_right_tr()
  local trRArmTarget = hcm.get_hands_right_tr_target()
  local door_model = hcm.get_door_model()
  door_model[1],door_model[2],door_model[3] = 
    trRArmTarget[1] - trRArmCurrent[1] + door_model[1],
    trRArmTarget[2] - trRArmCurrent[2] + door_model[2],
    trRArmTarget[3] - trRArmCurrent[3] + door_model[3]

  print(string.format("Door model update: hinge %.3f %.3f %.3f",
    door_model[1],door_model[2],door_model[3]))

  hcm.set_door_model(door_model)  
  hcm.set_state_proceed(0) 
end

function state.update()
--  print(state._NAME..' Update' )
  -- Get the time of update
  if plan_failed then return "planfail" end
  local t  = Body.get_time()
  local dt = t - t_update
  -- Save this at the last update time
  t_update = t
  local door_yaw = hcm.get_door_yaw()
  local cur_cond = arm_planner:load_boundary_condition()
  local qLArm = cur_cond[1]
  local qRArm = cur_cond[2]
  local trLArm = Body.get_forward_larm(cur_cond[1])
  local trRArm = Body.get_forward_rarm(cur_cond[2])  

  if stage=="wristyawturn" then --Turn wrist angles without moving arms
    if arm_planner:play_arm_sequence(t) then 
      if hcm.get_state_proceed()==1 then        
        local trArmTarget1 = movearm.getDoorHandlePosition({0,0,0}, 0, door_yaw)
        local arm_seq = {{'move',nil, trArmTarget1}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "hookknob"  end
      elseif hcm.get_state_proceed()==-1 then
        arm_planner:set_shoulder_yaw_target(qLArm0[3],qRArm0[3])
        local wrist_seq = {{'wrist',nil,trRArm0}}
        if arm_planner:plan_arm_sequence2(wrist_seq) then stage = "armbacktoinitpos" end   
      end
    end  

--[[    
  elseif stage=="placehook" then --Move the hook below the door knob
    if arm_planner:play_arm_sequence(t) then 
      if hcm.get_state_proceed()==1 then        
        local trArmTarget1 = movearm.getDoorHandlePosition(
          Config.armfsm.dooropen.handle_clearance1, 0, door_yaw)
        local trArmTarget2 = movearm.getDoorHandlePosition({0,0,0}, 0, door_yaw)
        local arm_seq = {{'move',nil, trArmTarget1},{'move',nil, trArmTarget2}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "hookknob"  end
      elseif hcm.get_state_proceed()==-1 then
        local arm_seq = {{'move',nil,trRArm1}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "wristyawturn" end        
      elseif hcm.get_state_proceed()==2 then        
        update_model()
        local trRArmTarget1 = movearm.getDoorHandlePosition(
          Config.armfsm.dooropen.handle_clearance0, 0, door_yaw)
        local arm_seq = {{'move',nil,trRArmTarget1}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "placehook"  end
      end      
    end    
    hcm.set_state_proceed(0) --Stop here for a bit
--]]
  elseif stage=="hookknob" then --Move up the hook to make it touch the knob
    if arm_planner:play_arm_sequence(t) then 
      if hcm.get_state_proceed()==1 then --Open the door
        arm_planner:save_doorparam({{0,0,0},0*Body.DEG_TO_RAD,0,0})
        local dooropen_seq =         {
            {'door',{0,0,0}, rollTarget,door_yaw},
            {'door',{0,0,0}, rollTarget,yawTargetInitial},
            {'door',{0,0,0},  0*Body.DEG_TO_RAD,yawTargetInitial}   
          }
        if arm_planner:plan_arm_sequence2(dooropen_seq) then stage = "opendoor"  end
      elseif hcm.get_state_proceed()==-1 then --Lower the hook
        local trRArmTarget1 = movearm.getDoorHandlePosition(Config.armfsm.dooropen.handle_clearance1, 0, door_yaw)
        local trRArmTarget2 = movearm.getDoorHandlePosition(Config.armfsm.dooropen.handle_clearance0, 0, door_yaw)
        local arm_seq = {{'move',nil,trRArmTarget1},{'move',nil,trRArmTarget2}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "wristyawturn"  
          else hcm.set_state_proceed(0) end

      elseif hcm.get_state_proceed()==2 then --adjust hook position
        update_model()
        local trRArmTarget1 = movearm.getDoorHandlePosition({0,0,0}, 0, door_yaw)
        local arm_seq = {{'move',nil,trRArmTarget1}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "hookknob"  end
      end
    end
    if hcm.get_state_proceed()==1 then hcm.set_state_proceed(0) end --stop here and wait
  elseif stage=="opendoor" then --Move the arm forward using IK now     
    if arm_planner:play_arm_sequence(t) then 
      if hcm.get_state_proceed()==1 then
        local dooropen_seq ={
          {'door',{0,0,0},  0*Body.DEG_TO_RAD,yawTarget1},
          {'door',{0,0,0},  0*Body.DEG_TO_RAD,yawTarget2},
        }
        if arm_planner:plan_arm_sequence2(dooropen_seq) then stage = "opendoor2"  end
      elseif hcm.get_state_proceed()==-1 then --Re-hook
          local doorclose_seq={ 
            {'door',Config.armfsm.dooropen.handle_clearance1,  0,yawTargetInitial},
            {'door',Config.armfsm.dooropen.handle_clearance1,  0*Body.DEG_TO_RAD,0*Body.DEG_TO_RAD},   
            {'door',{0,0,0}, 0,0},
          }
          if arm_planner:plan_arm_sequence2(doorclose_seq) then stage = "hookknob"  end
      end
    end
    hcm.set_state_proceed(0)
  elseif stage=="opendoor2" then 
    if arm_planner:play_arm_sequence(t) then 
      if hcm.get_state_proceed()==1 then --Unhook
        local doorparam = arm_planner.init_doorparam
        local trRArmTarget1 = movearm.getDoorHandlePosition(Config.armfsm.dooropen.handle_clearance2, 0, doorparam[3])
        local arm_seq = {{'move',nil,trRArmTarget1}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "hookrelease"  
        else hcm.set_state_proceed(0) end
      elseif hcm.get_state_proceed()==-1 then --Fully close the door
          local doorclose_seq={{'door',{0,0,0},  0,0}}
          if arm_planner:plan_arm_sequence2(doorclose_seq) then stage = "hookknob"  end
      elseif hcm.get_state_proceed()==2 then 
        update_model()
        local trRArmTarget1 = movearm.getDoorHandlePosition({0,0,0}, 0, yawTarget, rhand_rpy0)
        local arm_seq = {{'move',nil,trRArmTarget1}}
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "opendoor2"  end
      end
    end
  elseif stage=="hookrelease" then     
    if arm_planner:play_arm_sequence(t) then 
      if hcm.get_state_proceed()==1 then        
--        arm_planner:set_shoulder_yaw_target(qLArm0[3], qRArm[3]) 
        arm_planner:set_shoulder_yaw_target(qLArm0[3], nil) 
        local trArmRelease0 = Config.armfsm.dooropen.rhand_release
        trArmRelease0[6] = trRArm[6]
        
        local wrist_seq = {
          {'wrist',nil, trRArmRelease0},
          {'wrist',nil, Config.armfsm.dooropen.rhand_release[2]},
          {'wrist',nil, Config.armfsm.dooropen.rhand_release[3]},
        }        

        if arm_planner:plan_arm_sequence2(wrist_seq) then stage = "hookrollback"  
        else hcm.set_state_proceed(0) end
      elseif hcm.get_state_proceed()==2 then
        update_model()
        local doorparam = arm_planner.init_doorparam
        local dooropen_seq ={{'door',Config.armfsm.dooropen.handle_clearance2,0*Body.DEG_TO_RAD,doorparam[3]},}
        if arm_planner:plan_arm_sequence2(dooropen_seq) then stage = "hookrelease"  end
      end
    end    
  elseif stage=="hookrollback" then
    if arm_planner:play_arm_sequence(t) then       
      if hcm.get_state_proceed()==1 then
--print("trRArm:",arm_planner.print_transform(trRArm))
        arm_planner:set_shoulder_yaw_target(qLArm0[3], qRArm0[3]) 
        local arm_seq={
          {'move',nil,{trRArm[1]-0.10,trRArm[2],trRArm[3],trRArm[4],trRArm[5],trRArm[6]}},
          {'wrist',nil, Config.armfsm.dooropen.rhand_release[4]},
          {'move',nil,trRArm2},          
        }
        if arm_planner:plan_arm_sequence2(arm_seq) then stage = "hookforward" end      
        hcm.set_state_proceed(0)
      end
    end
  elseif stage=="hookforward" then    
    if arm_planner:play_arm_sequence(t) then      
      if hcm.get_state_proceed()==1 then
        local wrist_seq = {
          {'wrist',nil, Config.armfsm.dooropen.rhand_forward[1]},
          {'wrist',nil, Config.armfsm.dooropen.rhand_forward[2]},          
        }
        if arm_planner:plan_arm_sequence2(wrist_seq) then stage = "sidepush" end
      end
    end    
  elseif stage=="sidepush" then        
    if arm_planner:play_arm_sequence(t) then      
      if hcm.get_state_proceed()==1 then
        print("trRArm:",arm_planner.print_transform(trRArm))        
        local wrist_seq = {         
          {'wrist',nil, Config.armfsm.dooropen.rhand_sidepush[1]},
--          {'wrist',nil, Config.armfsm.dooropen.rhand_sidepush[2]},
--          {'wrist',nil, Config.armfsm.dooropen.rhand_sidepush[3]},          
        }
        if arm_planner:plan_arm_sequence2(wrist_seq) then stage = "sidepush2" end
      end
    end
 elseif stage=="sidepush2" then        
    if arm_planner:play_arm_sequence(t) then      
      if hcm.get_state_proceed()==1 then
        local wrist_seq = {{'wrist',nil, trRArm0}}
        if arm_planner:plan_arm_sequence2(wrist_seq) then stage = "armbacktoinitpos" end
      end
    end
  elseif stage=="armbacktoinitpos" then
    if arm_planner:play_arm_sequence(t) then return "done" end
  end
end

local function log_debugdata(qRArm)
  debugdata = debugdata..string.format("%.3f,  %.3f,%.3f,%.3f\n",
    t-t_entry,
    qRArm[5]*Body.RAD_TO_DEG,
    qRArm[6]*Body.RAD_TO_DEG,
    qRArm[7]*Body.RAD_TO_DEG
    )
end

local function flush_debugdata()
  local savefile = string.format("Log/debugdata_%s",os.date());
  local debugfile=assert(io.open(savefile,"w")); 
  debugfile:write(debugdata);
  debugfile:flush();
  debugfile:close();  
end

function state.exit()  
  hcm.set_state_success(1) --Report success
--  flush_debugdata()
  print(state._NAME..' Exit' )
end



return state
