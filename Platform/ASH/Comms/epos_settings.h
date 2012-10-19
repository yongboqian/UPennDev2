#ifndef EPOS_SETTINGS_H
#define EPOS_SETTINGS_H

#include "epos_slave.h"
#include "config.h"

// epos_settings : sdo and pdo configuration settings for epos controllers 
// author : Mike Hopkins
///////////////////////////////////////////////////////////////////////////

#define TORQUE_P_GAIN      160000
#define TORQUE_D_GAIN      300000
#define TORQUE_FF_CONSTANT 6493421

#define POSITION_P_GAIN    23
#define POSITION_I_GAIN    20
#define POSITION_D_GAIN    145
#define POSITION_VEL_FF    0
#define POSITION_ACC_FF    0

#define EPOS_FORCE_TORQUE_CONSTANT 6553.6

static const int epos_node_id[N_MOTOR] = {
  1, 2, 3, 4, 5, 6,   // l_leg
  7, 8, 9, 10, 11, 12 // r_leg
};

static const double motor_position_ratio[N_MOTOR] = {
  99313, 3149608, 3149608, 3149608, 3149608, 3149608, // l_leg
  99313, 3149608, 3149608, 3149608, 3149608, 3149608  // r_leg
};

static const double motor_position_sign[N_MOTOR] = {
  -1, 1, 1, 1, 1, 1, // l_leg
  -1, 1, 1, 1, 1, 1  // r_leg
};

static const double motor_force_ratio[N_MOTOR] = {
  EPOS_FORCE_TORQUE_CONSTANT, EPOS_FORCE_TORQUE_CONSTANT,
  EPOS_FORCE_TORQUE_CONSTANT, EPOS_FORCE_TORQUE_CONSTANT,
  EPOS_FORCE_TORQUE_CONSTANT, EPOS_FORCE_TORQUE_CONSTANT, // l_leg
  EPOS_FORCE_TORQUE_CONSTANT, EPOS_FORCE_TORQUE_CONSTANT,
  EPOS_FORCE_TORQUE_CONSTANT, EPOS_FORCE_TORQUE_CONSTANT,
  EPOS_FORCE_TORQUE_CONSTANT, EPOS_FORCE_TORQUE_CONSTANT  // r_leg
};

static const double motor_force_sign[N_MOTOR] = {
  1, 1, 1, 1, 1, 1, // l_leg
  1, 1, 1, 1, 1, 1  // r_leg
};

static const co_sdo_setting epos_custom_settings[N_MOTOR][20] = {
  { // motor 0 : l_hip_yaw
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -16000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 45000},
    {DSP402_HOMING_METHOD, 0x00, -3},
    {DSP402_HOME_OFFSET, 0x00, -43333},
    {DSP402_HOMING_SPEEDS, 0x01, 60},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x01, 70},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x02, 70},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x03, 145},
    {CO_SENTINEL}
  },
  { // motor 1 : l_hip_inner
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -150000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 150000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, -45669},
    {DSP402_HOMING_SPEEDS, 0x01, 60},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 2 : l_hip_outer
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -150000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 150000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, -23325},
    {DSP402_HOMING_SPEEDS, 0x01, 60},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 3 : l_knee_pitch
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -200000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 300000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, -95000},
    {DSP402_HOMING_SPEEDS, 0x01, 150},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {DSP402_MOTOR_DATA, 0x01, 5000},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x01, 20},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x02, 15},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x03, 50},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 4 : l_ankle_inner
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -200000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 200000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, 28800},
    {DSP402_HOMING_SPEEDS, 0x01, 100},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 5 : l_ankle_outer
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -200000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 200000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, 28800},
    {DSP402_HOMING_SPEEDS, 0x01, 100},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 6 : r_hip_yaw
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -45000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 16000},
    {DSP402_HOMING_METHOD, 0x00, -4},
    {DSP402_HOME_OFFSET, 0x00, 43333},
    {DSP402_HOMING_SPEEDS, 0x01, 60},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x01, 70},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x02, 70},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x03, 145},
    {CO_SENTINEL}
  },
  { // motor 7 : r_hip_inner
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -150000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 150000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, -45669},
    {DSP402_HOMING_SPEEDS, 0x01, 60},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 8 : r_hip_outer
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -150000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 150000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, -23325},
    {DSP402_HOMING_SPEEDS, 0x01, 60},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 9 : r_knee_pitch
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -200000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 300000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, -95000},
    {DSP402_HOMING_SPEEDS, 0x01, 150},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {DSP402_MOTOR_DATA, 0x01, 5000},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x01, 20},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x02, 15},
    {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x03, 50},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 10 : r_ankle_inner
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -200000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 200000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, 28800},
    {DSP402_HOMING_SPEEDS, 0x01, 100},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  },
  { // motor 11 : r_ankle_outer
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -200000},
    {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 200000},
    {DSP402_HOMING_METHOD, 0x00, 23},
    {DSP402_HOME_OFFSET, 0x00, 28800},
    {DSP402_HOMING_SPEEDS, 0x01, 100},
    {DSP402_HOMING_SPEEDS, 0x02, 20},
    {EPOS_ANALOG_OUTPUT_1, 0x00, 10000},
    {EPOS_TARGET_TORQUE, 0x00, 0},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x01, TORQUE_P_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x02, TORQUE_D_GAIN},
    {EPOS_TORQUE_CONTROL_PARAMETER_SET, 0x03, TORQUE_FF_CONSTANT},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x01, 728},
    {EPOS_ANALOG_TORQUE_FEEDBACK_CONFIGURATION, 0x02, 0},
    {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x0007},
    {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0080},
    {CO_SENTINEL}
  }
};

static const co_sdo_setting epos_default_settings[] = {
  {EPOS_CAN_BITRATE, 0x00, 0x00},
  {EPOS_SENSOR_CONFIGURATION, 0x01, 1000},
  {EPOS_SENSOR_CONFIGURATION, 0x02, 1},
  {EPOS_SENSOR_CONFIGURATION, 0x04, 0},
  {EPOS_CONFIGURATION_OF_DIGITAL_INPUTS, 0x04, 0x03},
  {EPOS_CONFIGURATION_OF_DIGITAL_INPUTS, 0x05, 0x04},
  {EPOS_CONFIGURATION_OF_DIGITAL_INPUTS, 0x06, 0x05},
  {EPOS_CONFIGURATION_OF_DIGITAL_INPUTS, 0x01, 0x02},
  {EPOS_CONFIGURATION_OF_DIGITAL_INPUTS, 0x02, 0x00},
  {EPOS_CONFIGURATION_OF_DIGITAL_INPUTS, 0x03, 0x01},
  {EPOS_DIGITAL_INPUT_FUNCTIONALITIES, 0x02, 0xE3C7},
  {EPOS_DIGITAL_INPUT_FUNCTIONALITIES, 0x03, 0x0000},
  {EPOS_DIGITAL_INPUT_FUNCTIONALITIES, 0x04, 0x000B},
  {EPOS_DIGITAL_OUTPUT_FUNCTIONALITIES, 0x01, 0x0000},
  {EPOS_DIGITAL_OUTPUT_FUNCTIONALITIES, 0x02, 0x1800},
  {EPOS_DIGITAL_OUTPUT_FUNCTIONALITIES, 0x03, 0x0000},
  {EPOS_CONFIGURATION_OF_DIGITAL_OUTPUTS, 0x01, 0x0F},
  {EPOS_CONFIGURATION_OF_DIGITAL_OUTPUTS, 0x02, 0x0E},
  {EPOS_CONFIGURATION_OF_DIGITAL_OUTPUTS, 0x03, 0x0D},
  {EPOS_CONFIGURATION_OF_DIGITAL_OUTPUTS, 0x04, 0x0C},
  {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x01, 0x000F},
  {EPOS_CONFIGURATION_OF_ANALOG_INPUTS, 0x02, 0x000E},
  {EPOS_ANALOG_INPUT_FUNCTIONALITIES_EXECUTION_MASK, 0x00, 0x0000},
  {EPOS_CURRENT_MODE_SETTING_VALUE, 0x00, 0},
  {EPOS_VELOCITY_MODE_SETTING_VALUE, 0x00, 0},
  {EPOS_POSITION_MODE_SETTING_VALUE, 0x00, 0},
  {DSP402_MODES_OF_OPERATION, 0x00, -1},
  {DSP402_FOLLOWING_ERROR_WINDOW, 0x00, 10000},
  {DSP402_POSITION_WINDOW, 0x00, 1e9},
  {DSP402_POSITION_WINDOW_TIME, 0x00, 0},
  {DSP402_TARGET_POSITION, 0x00, 0},
  {DSP402_TARGET_VELOCITY, 0x00, 0},
  {DSP402_MOTION_PROFILE_TYPE, 0x00, 0},
  {DSP402_PROFILE_VELOCITY, 0x00, 12000},
  {DSP402_PROFILE_ACCELERATION, 0x00, 50000},
  {DSP402_PROFILE_DECELERATION, 0x00, 50000},
  {DSP402_QUICK_STOP_DECELERATION, 0x00, 10000},
  {DSP402_MAX_PROFILE_VELOCITY, 0x00, 12000},
  {DSP402_MAX_ACCELERATION, 0x00, 100000},
  {DSP402_TORQUE_CONTROL_PARAMETER_SET, 0x01, 300},
  {DSP402_TORQUE_CONTROL_PARAMETER_SET, 0x02, 100},
  {DSP402_VELOCITY_CONTROL_PARAMETER_SET, 0x01, 1200},
  {DSP402_VELOCITY_CONTROL_PARAMETER_SET, 0x02, 40},
  {DSP402_VELOCITY_CONTROL_PARAMETER_SET, 0x04, 0},
  {DSP402_VELOCITY_CONTROL_PARAMETER_SET, 0x05, 0},
  {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x01, POSITION_P_GAIN},
  {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x02, POSITION_I_GAIN},
  {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x03, POSITION_D_GAIN},
  {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x04, POSITION_VEL_FF},
  {DSP402_POSITION_CONTROL_PARAMETER_SET, 0x05, POSITION_ACC_FF},
  {DSP402_MOTOR_TYPE, 0x00, 10},
  {DSP402_MOTOR_DATA, 0x01, 4500},
  {DSP402_MOTOR_DATA, 0x02, 10000},
  {DSP402_MOTOR_DATA, 0x03, 2},
  {DSP402_MOTOR_DATA, 0x04, 12500},
  {DSP402_MOTOR_DATA, 0x05, 40},
  // actuator specific settings 
  {EPOS_HOME_POSITION, 0x00, 0},
  {EPOS_CURRENT_THRESHOLD_FOR_HOMING_MODE, 0x00, 1000},
  {DSP402_HOME_OFFSET, 0x00, 0},
  {DSP402_HOMING_METHOD, 0x00, 23},
  {DSP402_HOMING_SPEEDS, 0x01, 100},
  {DSP402_HOMING_SPEEDS, 0x02, 20},
  {DSP402_HOMING_ACCELERATION, 0x00, 1000},
  {DSP402_SOFTWARE_POSITION_LIMIT, 0x01, -100000},
  {DSP402_SOFTWARE_POSITION_LIMIT, 0x02, 100000},
  {CO_SENTINEL}
};

static const co_pdo_parameter epos_pdo_parameters[] = {
  {CO_RPDO1, CO_SYNCHRONOUS + 1, 0, 0},
  {CO_RPDO2, CO_SYNCHRONOUS + 1, 0, 0},
  {CO_RPDO3, CO_SYNCHRONOUS + 1, 0, 0},
  {CO_RPDO4, CO_SYNCHRONOUS + 1, 0, 0},
  {CO_TPDO1, CO_SYNCHRONOUS + 1, 0, 0},
  {CO_TPDO2, CO_ASYNCHRONOUS, 1000, 0},
  {CO_TPDO3, CO_ASYNCHRONOUS, 0, 0},
  {CO_TPDO4 | CO_INVALID, CO_RTR_UPDATE, 0, 0},
  {CO_SENTINEL}
};

static const co_pdo_mapping epos_pdo_mappings[] = {
  {CO_RPDO1, 2,
    {CO_ENTRY(DSP402_CONTROLWORD, 0x00),
     CO_ENTRY(EPOS_POSITION_MODE_SETTING_VALUE, 0x00)}
  },
  {CO_RPDO2, 2,
    {CO_ENTRY(DSP402_CONTROLWORD, 0x00),
     CO_ENTRY(EPOS_TARGET_TORQUE, 0x00)}
  },
  {CO_RPDO3, 1,
    {CO_ENTRY(DSP402_CONTROLWORD, 0x00)}
  },
  {CO_RPDO4, 1,
    {CO_ENTRY(DSP402_MODES_OF_OPERATION, 0x00)}
  },
  {CO_TPDO1, 3,
    {CO_ENTRY(DSP402_STATUSWORD, 0x00),
     CO_ENTRY(DSP402_POSITION_ACTUAL_VALUE, 0x00),
     CO_ENTRY(EPOS_ANALOG_INPUTS, 0x01)}
  },
  {CO_TPDO2, 1,
    {CO_ENTRY(DSP402_CURRENT_ACTUAL_VALUE, 0x00)}
  },
  {CO_TPDO3, 1,
    {CO_ENTRY(DSP402_MODES_OF_OPERATION_DISPLAY, 0x00)}
  },
  {CO_TPDO4, 0},
  {CO_SENTINEL}
};

#endif
