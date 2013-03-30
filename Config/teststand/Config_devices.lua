module(..., package.seeall)

devices = {
  'joint',
  'motor',
  'force_torque',
  'ahrs',
  'battery',
}

-- joint config
---------------------------------------------------------------------------

joint = {}

joint.id = { 
  -- device ids
  [1] = 'l_knee_pitch',

  -- group ids
  l_hip = {
  },
  r_hip = {
  },
  hips = {
  },
  l_knee = {
    'l_knee_pitch',
  },
  r_knee = {
  },
  knees = {
    'l_knee_pitch',
  },
  l_ankle = {
  },
  r_ankle = {
  },
  ankles = {
  },
  l_leg = {
    'l_knee_pitch',
  },
  r_leg = {
  },
  legs = {
    'l_knee_pitch',
  },
  torso = {
  },
  l_arm = {
  },
  r_arm = {
  },
  arms = {
  },
  head = {
  },
}

-- motor config
---------------------------------------------------------------------------

motor = {}

motor.id = { 
  -- device ids
  [1] = 'l_knee_pitch',

  -- group ids
  l_hip = {
  },
  r_hip = {
  },
  hips = {
  },
  l_knee = {
    'l_knee_pitch',
  },
  r_knee = {
  },
  knees = {
    'l_knee_pitch',
  },
  l_ankle = {
  },
  r_ankle = {
  },
  ankles = {
  },
  l_leg = {
    'l_knee_pitch',
  },
  r_leg = {
  },
  legs = {
    'l_knee_pitch',
  },
  torso = {
  },
  l_arm = {
  },
  r_arm = {
  },
  arms = {
  },
  head = {
  },
}

-- force_torque config
---------------------------------------------------------------------------

force_torque.id = {
  -- device ids
  [1] = 'l_foot_force_x',
  [2] = 'l_foot_force_y',
  [3] = 'l_foot_force_z',
  [4] = 'l_foot_torque_x',
  [5] = 'l_foot_torque_y',
  [6] = 'l_foot_torque_z',
  [7] = 'r_foot_force_x',
  [8] = 'r_foot_force_y',
  [9] = 'r_foot_force_z',
  [10] = 'r_foot_torque_x',
  [11] = 'r_foot_torque_y',
  [12] = 'r_foot_torque_z',
  [13] = 'l_hand_force_x',
  [14] = 'l_hand_force_y',
  [15] = 'l_hand_force_z',
  [16] = 'l_hand_torque_x',
  [17] = 'l_hand_torque_y',
  [18] = 'l_hand_torque_z',
  [19] = 'r_hand_force_x',
  [20] = 'r_hand_force_y',
  [21] = 'r_hand_force_z',
  [22] = 'r_hand_torque_x',
  [23] = 'r_hand_torque_y',
  [24] = 'r_hand_torque_z',
  
  -- group ids
  l_foot = {
    'l_foot_force_x',
    'l_foot_force_y',
    'l_foot_force_z',
    'l_foot_torque_x',
    'l_foot_torque_y',
    'l_foot_torque_z',
  },
  r_foot = {
    'r_foot_force_x',
    'r_foot_force_y',
    'r_foot_force_z',
    'r_foot_torque_x',
    'r_foot_torque_y',
    'r_foot_torque_z',
  },
  l_hand = {
    'l_hand_force_x',
    'l_hand_force_y',
    'l_hand_force_z',
    'l_hand_torque_x',
    'l_hand_torque_y',
    'l_hand_torque_z',
  },
  r_hand = {
    'r_hand_force_x',
    'r_hand_force_y',
    'r_hand_force_z',
    'r_hand_torque_x',
    'r_hand_torque_y',
    'r_hand_torque_z',
  },
}

-- ahrs config
---------------------------------------------------------------------------

ahrs = {}

ahrs.id = {
  -- device ids
  [1] = 'x_accel',
  [2] = 'y_accel',
  [3] = 'z_accel',
  [4] = 'x_gyro',
  [5] = 'y_gyro',
  [6] = 'z_gyro',
  [7] = 'x_euler',
  [8] = 'y_euler',
  [9] = 'z_euler',
  
  -- group ids
  accel = { 
    'x_accel',
    'y_accel',
    'z_accel',
  },
  gyro = { 
    'x_gyro',
    'y_gyro',
    'z_gyro',
  },
  euler = { 
    'x_euler',
    'y_euler',
    'z_euler',
  }
}

-- battery config
---------------------------------------------------------------------------

battery = {}

battery.id = {
  -- device ids
  [1] = 'lower_body',
  [2] = 'upper_body',
  [3] = 'computing',
}

-- initialize device indices
----------------------------------------------------------------------------

function create_device_index(device)
  -- create device string index
  device.all = {}
  for i = 1,#device.id do
    device[device.id[i]] = i
    device.all[i] = i
  end
  for k,v in pairs(device.id) do
    if (type(k) == 'string') then
      device[k] = {}
      for i,id in pairs(v) do
         device[k][i] = device[id]
      end
    end
  end
end

for i = 1,#devices do  
  create_device_index(getfenv()[devices[i]])
end
