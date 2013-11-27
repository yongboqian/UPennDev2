/* 
(c) 2013 Seung Joon Yi
7 DOF
*/

#include <lua.hpp>
#include "THOROPKinematics.h"

/* Copied from lua_unix */
struct def_info {
  const char *name;
  double value;
};

void lua_install_constants(lua_State *L, const struct def_info constants[]) {
  int i;
  for (i = 0; constants[i].name; i++) {
    lua_pushstring(L, constants[i].name);
    lua_pushnumber(L, constants[i].value);
    lua_rawset(L, -3);
  }
}

static void lua_pushvector(lua_State *L, std::vector<double> v) {
	int n = v.size();
	lua_createtable(L, n, 0);
	for (int i = 0; i < n; i++) {
		lua_pushnumber(L, v[i]);
		lua_rawseti(L, -2, i+1);
	}
}

static std::vector<double> lua_checkvector(lua_State *L, int narg) {
	/*
	if (!lua_istable(L, narg))
	luaL_typerror(L, narg, "vector");
	*/
	if ( !lua_istable(L, narg) )
		luaL_argerror(L, narg, "vector");

#if LUA_VERSION_NUM == 502
	int n = lua_rawlen(L, narg);
#else	
	int n = lua_objlen(L, narg);
#endif
	std::vector<double> v(n);
	for (int i = 0; i < n; i++) {
		lua_rawgeti(L, narg, i+1);
		v[i] = lua_tonumber(L, -1);
		lua_pop(L, 1);
	}
	return v;
}

static void lua_pushtransform(lua_State *L, Transform t) {
	lua_createtable(L, 4, 0);
	for (int i = 0; i < 4; i++) {
		lua_createtable(L, 4, 0);
		for (int j = 0; j < 4; j++) {
			lua_pushnumber(L, t(i,j));
			lua_rawseti(L, -2, j+1);
		}
		lua_rawseti(L, -2, i+1);
	}
}

static int forward_joints(lua_State *L)
{
	/* forward kinematics to convert servo positions to joint angles */
	std::vector<double> r = lua_checkvector(L, 1);
	std::vector<double> q = THOROP_kinematics_forward_joints(&r[0]);
	lua_pushvector(L, q);
	return 1;
}

static int forward_head(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = THOROP_kinematics_forward_head(&q[0]);
	lua_pushtransform(L, t);
	return 1;
}

/*
static int forward_l_arm(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = THOROP_kinematics_forward_l_arm(&q[0]);
	lua_pushtransform(L, t);
	return 1;
}

static int forward_r_arm(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = THOROP_kinematics_forward_r_arm(&q[0]);
	lua_pushtransform(L, t);
	return 1;
}
*/

static int forward_l_leg(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = THOROP_kinematics_forward_l_leg(&q[0]);
	lua_pushtransform(L, t);
	return 1;
}

static int forward_r_leg(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = THOROP_kinematics_forward_r_leg(&q[0]);
	lua_pushtransform(L, t);
	return 1;
}


static int l_arm_torso_7(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	double bodyPitch = luaL_optnumber(L, 2,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 3);

	//Now we can use custom hand x/y offset (for claws)
	double handOffsetXNew = luaL_optnumber(L, 4,handOffsetX);
	double handOffsetYNew = luaL_optnumber(L, 5,handOffsetY);
	double handOffsetZNew = luaL_optnumber(L, 6,handOffsetZ);
	

	Transform t = THOROP_kinematics_forward_l_arm_7(&q[0],bodyPitch,&qWaist[0],
		handOffsetXNew, handOffsetYNew, handOffsetZNew);
	lua_pushvector(L, position6D(t));
	return 1;
}

static int r_arm_torso_7(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	double bodyPitch = luaL_optnumber(L, 2,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 3);

	//Now we can use custom hand x/y offset (for claws)
	double handOffsetXNew = luaL_optnumber(L, 4,handOffsetX);
	double handOffsetYNew = luaL_optnumber(L, 5,handOffsetY);
	double handOffsetZNew = luaL_optnumber(L, 6,handOffsetZ);
	

	Transform t = THOROP_kinematics_forward_r_arm_7(&q[0],bodyPitch,&qWaist[0], 
		handOffsetXNew, handOffsetYNew, handOffsetZNew);
	lua_pushvector(L, position6D(t));
	return 1;
}

static int l_wrist_torso(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	double bodyPitch = luaL_optnumber(L, 2,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 3);	

	Transform t = THOROP_kinematics_forward_l_wrist(&q[0],bodyPitch,&qWaist[0]);
	lua_pushvector(L, position6D(t));	
	return 1;
}

static int r_wrist_torso(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	double bodyPitch = luaL_optnumber(L, 2,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 3);
	

	Transform t = THOROP_kinematics_forward_r_wrist(&q[0],bodyPitch,&qWaist[0]);
	lua_pushvector(L, position6D(t));	
	return 1;
}


static int inverse_l_arm_7(lua_State *L) {
	std::vector<double> qArm;
	std::vector<double> pArm = lua_checkvector(L, 1);
	std::vector<double> qArmOrg = lua_checkvector(L, 2);
	double shoulderYaw = luaL_optnumber(L, 3,0.0);
	double bodyPitch = luaL_optnumber(L, 4,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 5);

	//Now we can use custom hand x/y offset (for claws)
	double handOffsetXNew = luaL_optnumber(L, 6,handOffsetX);
	double handOffsetYNew = luaL_optnumber(L, 7,handOffsetY);
	double handOffsetZNew = luaL_optnumber(L, 8,handOffsetZ);
	
	int flip_shoulderroll = luaL_optnumber(L, 9,0);

	Transform trArm = transform6D(&pArm[0]);		
	qArm = THOROP_kinematics_inverse_l_arm_7(trArm,&qArmOrg[0],shoulderYaw,bodyPitch,&qWaist[0],
		handOffsetXNew, handOffsetYNew, handOffsetZNew, flip_shoulderroll);
	lua_pushvector(L, qArm);
	return 1;
}

static int inverse_r_arm_7(lua_State *L) {
	std::vector<double> qArm;
	std::vector<double> pArm = lua_checkvector(L, 1);	
	std::vector<double> qArmOrg = lua_checkvector(L, 2);
	double shoulderYaw = luaL_optnumber(L, 3,0.0);
	double bodyPitch = luaL_optnumber(L, 4,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 5);

//Now we can use custom hand x/y/z offset (for claws)
	double handOffsetXNew = luaL_optnumber(L, 6,handOffsetX);
	double handOffsetYNew = luaL_optnumber(L, 7,handOffsetY);
	double handOffsetZNew = luaL_optnumber(L, 8,handOffsetZ);
	
	int flip_shoulderroll = luaL_optnumber(L, 9,0);

	Transform trArm = transform6D(&pArm[0]);
	qArm = THOROP_kinematics_inverse_r_arm_7(trArm,&qArmOrg[0],shoulderYaw,bodyPitch,&qWaist[0],
		handOffsetXNew, handOffsetYNew, handOffsetZNew, flip_shoulderroll);
	lua_pushvector(L, qArm);
	return 1;
}


static int inverse_l_wrist(lua_State *L) {
	std::vector<double> qArm;
	std::vector<double> pArm = lua_checkvector(L, 1);
	std::vector<double> qArmOrg = lua_checkvector(L, 2);
	double shoulderYaw = luaL_optnumber(L, 3,0.0);
	double bodyPitch = luaL_optnumber(L, 4,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 5);
	

	Transform trArm = transform6D(&pArm[0]);
	qArm = THOROP_kinematics_inverse_l_wrist(trArm,&qArmOrg[0],shoulderYaw,bodyPitch,&qWaist[0]);
	lua_pushvector(L, qArm);
	return 1;
}

static int inverse_r_wrist(lua_State *L) {
	std::vector<double> qArm;
	std::vector<double> pArm = lua_checkvector(L, 1);
	std::vector<double> qArmOrg = lua_checkvector(L, 2);	
	double shoulderYaw = luaL_optnumber(L, 3,0.0);
	double bodyPitch = luaL_optnumber(L, 4,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 5);
	

	Transform trArm = transform6D(&pArm[0]);
	qArm = THOROP_kinematics_inverse_r_wrist(trArm,&qArmOrg[0],shoulderYaw,bodyPitch,&qWaist[0]);
	lua_pushvector(L, qArm);
	return 1;
}

static int inverse_arm_given_wrist(lua_State *L) {
	std::vector<double> qArm;
	std::vector<double> pArm = lua_checkvector(L, 1);
	std::vector<double> qArmOrg = lua_checkvector(L, 2);
	double bodyPitch = luaL_optnumber(L, 3,0.0);
	std::vector<double> qWaist = lua_checkvector(L, 4);


	Transform trArm = transform6D(&pArm[0]);	
	qArm = THOROP_kinematics_inverse_arm_given_wrist(trArm,&qArmOrg[0],bodyPitch,&qWaist[0]);
	lua_pushvector(L, qArm);
	return 1;
}









static int l_leg_torso(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = THOROP_kinematics_forward_l_leg(&q[0]);
	lua_pushvector(L, position6D(t));
	return 1;
}

static int torso_l_leg(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = inv(THOROP_kinematics_forward_l_leg(&q[0]));
	lua_pushvector(L, position6D(t));
	return 1;
}

static int r_leg_torso(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = THOROP_kinematics_forward_r_leg(&q[0]);
	lua_pushvector(L, position6D(t));
	return 1;
}

static int torso_r_leg(lua_State *L) {
	std::vector<double> q = lua_checkvector(L, 1);
	Transform t = inv(THOROP_kinematics_forward_r_leg(&q[0]));
	lua_pushvector(L, position6D(t));
	return 1;
}

static int inverse_joints(lua_State *L)
{
	/* inverse kinematics to convert joint angles to servo positions */
	std::vector<double> q = lua_checkvector(L, 1);
	std::vector<double> r = THOROP_kinematics_inverse_joints(&q[0]);
	lua_pushvector(L, r);
	return 1;
}



static int com_upperbody(lua_State *L) {
	std::vector<double> qWaist = lua_checkvector(L, 1);
	std::vector<double> qLArm = lua_checkvector(L, 2);
	std::vector<double> qRArm = lua_checkvector(L, 3);
	double bodyPitch = luaL_optnumber(L, 4,0.0);
	double mLHand = luaL_optnumber(L, 5,0.0);
	double mRHand = luaL_optnumber(L, 6,0.0);


	std::vector<double> r = THOROP_kinematics_com_upperbody(
		&qWaist[0],&qLArm[0],&qRArm[0],bodyPitch, mLHand, mRHand);
	lua_pushvector(L, r);
	return 1;
}

static int calculate_support_torque(lua_State *L) {
	std::vector<double> qWaist = lua_checkvector(L, 1);
	std::vector<double> qLArm = lua_checkvector(L, 2);
	std::vector<double> qRArm = lua_checkvector(L, 3);
	std::vector<double> qLLeg = lua_checkvector(L, 4);
	std::vector<double> qRLeg = lua_checkvector(L, 5);
	double bodyPitch = luaL_optnumber(L, 6,0.0);
	int supportLeg = (int) luaL_optnumber(L, 7,0.0);
	std::vector<double> uTorsoAcc = lua_checkvector(L, 8);
	double mLHand = luaL_optnumber(L, 9,0.0);
	double mRHand = luaL_optnumber(L, 10,0.0);


	std::vector<double> r = THOROP_kinematics_calculate_support_torque(
		&qWaist[0],&qLArm[0],&qRArm[0],&qLLeg[0],&qRLeg[0],
		bodyPitch,supportLeg,&uTorsoAcc[0], mLHand, mRHand);
	lua_pushvector(L, r);
	return 1;
}

static int calculate_knee_height(lua_State *L) {
	std::vector<double> qLeg = lua_checkvector(L, 1);
	double trKnee = THOROP_kinematics_calculate_knee_height(&qLeg[0]);
	lua_pushnumber(L, trKnee);
	return 1;
}



static int inverse_l_leg(lua_State *L) {
	std::vector<double> qLeg;
	std::vector<double> pLeg = lua_checkvector(L, 1);
	Transform trLeg = transform6D(&pLeg[0]);
	qLeg = THOROP_kinematics_inverse_r_leg(trLeg);
	lua_pushvector(L, qLeg);
	return 1;
}

static int inverse_r_leg(lua_State *L) {
	std::vector<double> qLeg;
	std::vector<double> pLeg = lua_checkvector(L, 1);
	Transform trLeg = transform6D(&pLeg[0]);
	qLeg = THOROP_kinematics_inverse_l_leg(trLeg);
	lua_pushvector(L, qLeg);
	return 1;
}

static int inverse_legs(lua_State *L) {
	std::vector<double> qLLeg(12), qRLeg;
	std::vector<double> pLLeg = lua_checkvector(L, 1);
	std::vector<double> pRLeg = lua_checkvector(L, 2);
	std::vector<double> pTorso = lua_checkvector(L, 3);

	Transform trLLeg = transform6D(&pLLeg[0]);
	Transform trRLeg = transform6D(&pRLeg[0]);
	Transform trTorso = transform6D(&pTorso[0]);
	Transform trTorso_LLeg = inv(trTorso)*trLLeg;
	Transform trTorso_RLeg = inv(trTorso)*trRLeg;

	qLLeg = THOROP_kinematics_inverse_l_leg(trTorso_LLeg);
	qRLeg = THOROP_kinematics_inverse_r_leg(trTorso_RLeg);
	qLLeg.insert(qLLeg.end(), qRLeg.begin(), qRLeg.end());

	lua_pushvector(L, qLLeg);
	return 1;
}

static const struct luaL_Reg kinematics_lib [] = {
	{"forward_head", forward_head},
//	{"forward_larm", forward_l_arm},
//	{"forward_rarm", forward_r_arm},
	{"forward_lleg", forward_l_leg},
	{"forward_rleg", forward_r_leg},
	{"forward_joints", forward_joints},
  
	{"lleg_torso", l_leg_torso},
	{"torso_lleg", torso_l_leg},
	{"rleg_torso", r_leg_torso},
	{"torso_rleg", torso_r_leg},	
	
	{"inverse_l_leg", inverse_l_leg},
	{"inverse_r_leg", inverse_r_leg},
	{"inverse_legs", inverse_legs},

	{"calculate_knee_height",calculate_knee_height},
		
	{"inverse_joints", inverse_joints},

  /* 7 DOF specific */
	{"l_arm_torso_7", l_arm_torso_7},
	{"r_arm_torso_7", r_arm_torso_7},
	{"inverse_l_arm_7", inverse_l_arm_7},
	{"inverse_r_arm_7", inverse_r_arm_7},

  /* Wrist specific */
    {"l_wrist_torso", l_wrist_torso},
	{"r_wrist_torso", r_wrist_torso},
	{"inverse_l_wrist", inverse_l_wrist},
	{"inverse_r_wrist", inverse_r_wrist},

	{"inverse_arm_given_wrist", inverse_arm_given_wrist},

 /* COM calculation */
    
	{"com_upperbody", com_upperbody},
	{"calculate_support_torque", calculate_support_torque},

	{NULL, NULL}
};

static const def_info kinematics_constants[] = {
  {"neckOffsetX", neckOffsetX},
  {"neckOffsetZ", neckOffsetZ},
  {"shoulderOffsetX", shoulderOffsetX},
  {"shoulderOffsetY", shoulderOffsetY},
  {"shoulderOffsetZ", shoulderOffsetZ},
  {"upperArmLength", upperArmLength},
  {"lowerArmLength", lowerArmLength},
  {"elbowOffsetX", elbowOffsetX},
  {"handOffsetX", handOffsetX},
  {"handOffsetY", handOffsetY},
  {"handOffsetZ", handOffsetZ},
  {NULL, 0}
};

extern "C"
int luaopen_THOROPLongarmKinematics (lua_State *L) {
#if LUA_VERSION_NUM == 502
	luaL_newlib(L, kinematics_lib);
#else
	luaL_register(L, "Kinematics", kinematics_lib);
#endif
	lua_install_constants(L, kinematics_constants);
	return 1;
}
