/*****************************************************************************
*                                                                            *
*  OpenNI 2.x Alpha                                                          *
*  Copyright (C) 2012 PrimeSense Ltd.                                        *
*                                                                            *
*  This file is part of OpenNI.                                              *
*                                                                            *
*  Licensed under the Apache License, Version 2.0 (the "License");           *
*  you may not use this file except in compliance with the License.          *
*  You may obtain a copy of the License at                                   *
*                                                                            *
*      http://www.apache.org/licenses/LICENSE-2.0                            *
*                                                                            *
*  Unless required by applicable law or agreed to in writing, software       *
*  distributed under the License is distributed on an "AS IS" BASIS,         *
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  *
*  See the License for the specific language governing permissions and       *
*  limitations under the License.                                            *
*                                                                            *
*****************************************************************************/
/*
	Lua Wrapper for some OpenNI2 functionality
	(c) Stephen McGill 2013
*/
#include <stdio.h>
#include <string>
#include <OpenNI.h>
#include <NiTE.h>
#include <lua.hpp>
#define MAX_USERS 2 //10 was used before...

char init = 0;
int use_skeleton = 0;

// Use the right namespace
using namespace openni;

/* User Tracking information */
nite::UserTracker *userTracker;
nite::Status niteRc;
// Keep track of the skeletons
bool g_visibleUsers[MAX_USERS] = {false};
nite::SkeletonState g_skeletonStates[MAX_USERS] = {nite::SKELETON_NONE};
nite::SkeletonJoint g_skeletonJoints[MAX_USERS][NITE_JOINT_COUNT];
unsigned long long g_skeletonTime[MAX_USERS];

/* Cloud information */
// Establish the streams
VideoStream* m_streams;
VideoStream* depth;
VideoStream* color;

VideoFrameRef* dframe;
VideoFrameRef* cframe;

Device device;
Recorder recorder;
Status rc;

// Skeleton Updating function
void updateUserState(const nite::UserData& user, unsigned long long ts) {
	int user_id = user.getId();
	g_visibleUsers[user_id] = user.isVisible();
	g_skeletonStates[user_id] = user.getSkeleton().getState();
	g_skeletonTime[user_id] = ts;
	for(int jj=0;jj<NITE_JOINT_COUNT;jj++)
		g_skeletonJoints[user_id][jj] = 
			user.getSkeleton().getJoint((nite::JointType)jj);
}

static int lua_enable_skeleton(lua_State *L) {
	use_skeleton = 1;
	return 0;
}

static int lua_disable_skeleton(lua_State *L) {
	use_skeleton = 0;
	return 0;
}

static int lua_startup(lua_State *L) {
	
	if(init==1)
		return luaL_error(L, "Two OpenNI devices not supported yet.\n" );
	
	/* Initialize the device*/
	// Should we record? play back? Read from a device?
	const char *file_uri = luaL_optstring(L, 1, NULL);
	const char *logmode = luaL_optstring(L, 2, NULL); // TODO: Add time and date
	
#ifdef DEBUG
	if(file_uri==NULL)
		printf("Accessing a physical device...\n");
	else if( logmode==NULL )
		printf("Accessing log file %s...\n",file_uri);
	else
		printf("Recording a physical device to logfile %s\n",file_uri);
#endif
	
	// Setup device
	rc = OpenNI::initialize();
	if (rc != STATUS_OK)
		return luaL_error(L,"OpenNI failed\n%s\n",OpenNI::getExtendedError());
	if( file_uri!=NULL && logmode==NULL )
		rc = device.open( file_uri );
	else
		rc = device.open(ANY_DEVICE);
	if (rc != STATUS_OK)
		return luaL_error(L,"Device failed\n%s\n",OpenNI::getExtendedError());

	m_streams = new VideoStream[2];
	
	depth = &m_streams[0];
	color = &m_streams[1];
	dframe = new VideoFrameRef;
	cframe = new VideoFrameRef;
	
	// Setup depth
	if (device.getSensorInfo(SENSOR_DEPTH) == NULL)
		return luaL_error(L,"No depth sensor\n%s\n", OpenNI::getExtendedError());
	rc = depth->create(device, SENSOR_DEPTH);
	
	/*
      openni::VideoMode mode = Stream.getVideoMode();
      mode.setResolution(resolution_x, resolution_y);
      mode.setFps(FPS);
      Stream.setVideoMode(mode);
      Stream.setMirroringEnabled(false);
	*/
	
	if (rc != STATUS_OK)
		return luaL_error(L,"Depth create\n%s\n", OpenNI::getExtendedError());
	rc = depth->start();
	if (rc != STATUS_OK){
		depth->destroy();
		return luaL_error(L,"Depth start\n%s\n", OpenNI::getExtendedError());
	}

	// Setup color
	if (device.getSensorInfo(SENSOR_COLOR) == NULL)
		return luaL_error(L,"No color sensor\n%s\n", OpenNI::getExtendedError());
	rc = color->create(device, SENSOR_COLOR);
	if (rc != STATUS_OK)
		return luaL_error(L,"Color create\n%s\n", OpenNI::getExtendedError());
	rc = color->start();
	if (rc != STATUS_OK) {
		color->destroy();
		return luaL_error(L,"Color start\n%s\n", OpenNI::getExtendedError());
	}
	
	// Begin recording
	if(file_uri!=NULL && logmode!=NULL )
		recorder.create( file_uri );
	if( recorder.isValid() ){
		recorder.attach( *depth );
		recorder.attach( *color );
		recorder.start();
	}
	
	/* Initialize the Skeleton Tracking system */
	if(use_skeleton==1){
		nite::NiTE::initialize();
		userTracker = new nite::UserTracker;
		niteRc = userTracker->create(&device);
		if (niteRc != nite::STATUS_OK)
			return luaL_error(L, "Couldn't create user tracker!\n" );
		// Push the number of users to be tracked
		lua_pushinteger( L, MAX_USERS );
	} else{
		lua_pushinteger( L, 0 );
	}

	/*
	VideoMode dmode = depth->getVideoMode();
	int resX = dmode.getResolutionX();
	int resY = dmode.getResolutionY();
	int fps = dmode.getFps();
	printf("Depth %d x %d @ %d\n",resX,resY,fps);
	VideoMode cmode = color->getVideoMode();
	resX = cmode.getResolutionX();
	resY = cmode.getResolutionY();
	fps = cmode.getFps();
	printf("Color %d x %d @ %d\n",resX,resY,fps);
	*/
	init = 1;
	return 1;
}

static int lua_stream_info(lua_State *L) {
	
	// Depth
	VideoMode dmode = depth->getVideoMode();
	int resX = dmode.getResolutionX();
	int resY = dmode.getResolutionY();
	int fps = dmode.getFps();
	lua_newtable(L);
	lua_pushstring(L, "width");
	lua_pushnumber(L,resX);
	lua_rawset(L, -3);
	lua_pushstring(L, "height");
	lua_pushnumber(L,resY);
	lua_rawset(L, -3);
	lua_pushstring(L, "fps");
	lua_pushnumber(L,fps);
	lua_rawset(L, -3);
	
	// Color
	VideoMode cmode = color->getVideoMode();
	resX = cmode.getResolutionX();
	resY = cmode.getResolutionY();
	fps = cmode.getFps();
	lua_newtable(L);
	lua_pushstring(L, "width");
	lua_pushnumber(L,resX);
	lua_rawset(L, -3);
	lua_pushstring(L, "height");
	lua_pushnumber(L,resY);
	lua_rawset(L, -3);
	lua_pushstring(L, "fps");
	lua_pushnumber(L,fps);
	lua_rawset(L, -3);
	
	return 2;
}

static int lua_update_rgbd(lua_State *L) {
	int changedIndex;
	rc = OpenNI::waitForAnyStream( &m_streams, 2, &changedIndex);
	if (rc != STATUS_OK)
		return luaL_error(L, "Wait failed!\n" );

	depth->readFrame( dframe );
	color->readFrame( cframe );
	lua_pushlightuserdata( L, (void*)(dframe->getData()) );
	lua_pushlightuserdata( L, (void*)(cframe->getData()) );
	
	return 2;
}

static int lua_update_skeleton(lua_State *L) {
	nite::UserTrackerFrameRef userTrackerFrame;
	niteRc = userTracker->readFrame(&userTrackerFrame);
	if (niteRc != nite::STATUS_OK)
		return luaL_error(L, "NiTE readFrame failed!\n" );

	const nite::Array<nite::UserData>& users = userTrackerFrame.getUsers();
	for (int i = 0; i < users.getSize(); ++i)
	{
		const nite::UserData& user = users[i];
		updateUserState(user,userTrackerFrame.getTimestamp());
		if (user.isNew())
		{
			userTracker->startSkeletonTracking(user.getId());
		}
		else if (user.getSkeleton().getState() == nite::SKELETON_TRACKED)
		{
#ifdef DEBUG
			const nite::SkeletonJoint& head = user.getSkeleton().getJoint(nite::JOINT_HEAD);
			if (head.getPositionConfidence() > .5)
				printf("%d. (%5.2f, %5.2f, %5.2f)\n", user.getId(), head.getPosition().x, head.getPosition().y, head.getPosition().z);
#endif
		}
	}
	// http://lua-users.org/wiki/SimpleLuaApiExample
	// Begin to return data
	//lua_newtable(L);
	lua_createtable(L, MAX_USERS, 0);
	for(int u = 1; u <= MAX_USERS; u++) {
		//printf("setting %d: %d\n", u, (int)g_visibleUsers[u-1] );
		//lua_pushnumber(L, u);   /* Push the table index */
		lua_pushboolean(L, g_visibleUsers[u-1] ); /* Push the cell value */
		//lua_rawset(L, -3);      /* Stores the pair in the table */
		lua_rawseti(L, -2, u);
	}
	return 1;

}

// Get a single joint
static int lua_retrieve_joint(lua_State *L) {
	int user_id  = luaL_checkint( L, 1 );
	int joint_id = luaL_checkint( L, 2 );
	
	if( joint_id>NITE_JOINT_COUNT || user_id>MAX_USERS ){
#ifdef DEBUG
		printf("User %d. Joint %d.\n",user_id,joint_id);
#endif
		return luaL_error(L, "Joint or user out of range!\n" );
	}

	// Get the joint
	nite::SkeletonJoint j = g_skeletonJoints[user_id-1][joint_id-1];
	nite::Quaternion q = j.getOrientation();

	// Return the result as a single table
	//lua_newtable(L);
	lua_createtable(L, 0, 5);
	
	// Position table (in meters)
	lua_pushstring(L, "position");
	lua_createtable(L, 3, 0);
	lua_pushnumber(L, j.getPosition().x);
	lua_rawseti(L, -2, 1);
	lua_pushnumber(L, j.getPosition().y);
	lua_rawseti(L, -2, 2);
	lua_pushnumber(L, j.getPosition().z);
	lua_rawseti(L, -2, 3);
	lua_settable(L, -3);
	
	// Orientation table (as a quaternion)
	lua_pushstring(L, "orientation");
	lua_createtable(L, 4, 0);
	lua_pushnumber(L, q.x);
	lua_rawseti(L, -2, 1);
	lua_pushnumber(L, q.y);
	lua_rawseti(L, -2, 2);
	lua_pushnumber(L, q.z);
	lua_rawseti(L, -2, 3);
	lua_pushnumber(L, q.w);
	lua_rawseti(L, -2, 4);
	lua_settable(L, -3);
	//lua_rawset(L, -3);
	
	// Confidence
	lua_pushnumber(L,j.getPositionConfidence());
	lua_setfield(L, -2, "position_confidence");
	lua_pushnumber(L, j.getOrientationConfidence());
	lua_setfield(L, -2, "orientation_confidence");
	
	// Timestamp
	//http://www.lua.org/pil/2.3.html
	lua_pushnumber(L,g_skeletonTime[user_id-1]);
	lua_setfield(L, -2, "timestamp");
	
	// Returning a single table
	return 1;
}

static int lua_skeleton_shutdown(lua_State *L) {
	
	if(init==0)
		return luaL_error(L, "Cannot shutdown an uninitialized object!\n" );
	
	// Kill the recorder if being used
	if( recorder.isValid()==1 ){
		recorder.stop();
		recorder.destroy();
	}

	// Shutoff the streams
	color->stop();
	color->destroy();
	depth->stop();
	depth->destroy();
	device.close();
	
	// Shutdown the NiTE and OpenNI systems
	if(use_skeleton==1){
		nite::NiTE::shutdown();
	}
	openni::OpenNI::shutdown();
#ifdef DEBUG
	printf("Done shutting down NiTE and OpenNI\n");
#endif
	init = 0;
	lua_pushboolean(L,1);
	return 1;
}

static const struct luaL_Reg openni_lib [] = {
	{"enable_skeleton", lua_enable_skeleton},
	{"disable_skeleton", lua_disable_skeleton},
	{"startup", lua_startup},
	{"stream_info", lua_stream_info},
	{"update_skeleton", lua_update_skeleton},
	{"update_rgbd", lua_update_rgbd},
	{"joint", lua_retrieve_joint},
	{"shutdown", lua_skeleton_shutdown},
	{NULL, NULL}
};

extern "C" int luaopen_openni(lua_State *L) {
#if LUA_VERSION_NUM == 502
	luaL_newlib( L, openni_lib );
#else
	luaL_register(L, "openni", openni_lib);
#endif
	return 1;
}