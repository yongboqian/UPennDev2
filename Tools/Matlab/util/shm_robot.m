function h = shm_robot(teamNumber, playerID)
% function create the same struct as the team message from
% shared memory. for local debugging use

global MONITOR %for sending the webots check information

  h.teamNumber = teamNumber;
  h.playerID = playerID;
  h.user = getenv('USER');

%List of shms



% create shm wrappers (in alphabetic order)
  h.gcmFsm  = shm(sprintf('gcmFsm%d%d%s',  h.teamNumber, h.playerID, h.user));
  %  h.gcmGame 
  h.gcmTeam  = shm(sprintf('gcmTeam%d%d%s',  h.teamNumber, h.playerID, h.user));

  h.vcmBall  = shm(sprintf('vcmBall%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmBoundary = shm(sprintf('vcmBoundary%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmCamera = shm(sprintf('vcmCamera%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmDebug  = shm(sprintf('vcmDebug%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmFreespace = shm(sprintf('vcmFreespace%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmGoal  = shm(sprintf('vcmGoal%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmImage = shm(sprintf('vcmImage%d%d%s', h.teamNumber, h.playerID, h.user));
  h.vcmLandmark  = shm(sprintf('vcmLandmark%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmLine  = shm(sprintf('vcmLine%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmCorner  = shm(sprintf('vcmCorner%d%d%s',  h.teamNumber, h.playerID, h.user));

  h.wcmBall  = shm(sprintf('wcmBall%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmGoal  = shm(sprintf('wcmGoal%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.wcmParticle  = shm(sprintf('wcmParticle%d%d%s',  h.teamNumber, h.playerID, h.user));
  %h.wcmKick


  h.wcmTeamdata  = shm(sprintf('wcmTeamdata%d%d%s',  h.teamNumber, h.playerID, h.user));
  h.vcmRobot  = shm(sprintf('vcmRobot%d%d%s',  h.teamNumber, h.playerID, h.user)); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SJ - reading Occmap SHM from robot kills matlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %h.wcmOccmap = shm(sprintf('wcmOccmap%d%d%s', h.teamNumber, h.playerID, h.user));
  h.wcmRobot = shm(sprintf('wcmRobot%d%d%s', h.teamNumber, h.playerID, h.user));

% set function pointers
  h.update = @update;
  h.get_team_struct = @get_team_struct;
  h.get_monitor_struct = @get_monitor_struct;
  h.get_yuyv = @get_yuyv;
  h.get_yuyv2 = @get_yuyv2;
  h.get_yuyv3 = @get_yuyv3;
  h.get_rgb = @get_rgb;
  h.get_labelA = @get_labelA;
  h.get_labelB = @get_labelB;
  h.get_particle = @get_particle;

  h.set_yuyv = @set_yuyv;
  h.set_labelA = @set_labelA;

  h.updated=0;
  h.tLastUpdate=0;

  h.get_team_struct_wireless = @get_team_struct_wireless;
  h.get_monitor_struct_wireless = @get_monitor_struct_wireless;


  function update()
      % do nothing
  end

  function r = get_team_struct()
    % returns the robot struct (in the same form as the team messages)
    r = [];
%    disp('get team struct');
    try
        r.teamNumber = h.gcmTeam.get_number();
        r.teamColor = h.gcmTeam.get_color();
        r.id = h.gcmTeam.get_player_id();
        r.role = h.gcmTeam.get_role();
        
        pose = h.wcmRobot.get_pose();
        r.pose = struct('x', pose(1), 'y', pose(2), 'a', pose(3));
        
 	gpspose = h.wcmRobot.get_gpspose();
        r.gpspose = struct('x', gpspose(1), 'y', gpspose(2), 'a', gpspose(3));

        ballx = h.wcmBall.get_x();
	bally = h.wcmBall.get_y();
        ballt = h.wcmBall.get_t();
        ballvelx = h.wcmBall.get_velx();
        ballvely = h.wcmBall.get_vely();

        r.ball = struct('x', ballx, 'y', bally, 't', ballt, ...
            'vx', ballvelx, 'vy', ballvely );

        r.attackBearing = h.wcmGoal.get_attack_bearing();
        r.time=h.wcmRobot.get_time();
        r.battery_level = h.wcmRobot.get_battery_level();

        goal = h.vcmGoal.get_detect();
        if goal==1 
          r.goal = h.vcmGoal.get_type()+1;
          r.goalv1 = h.vcmGoal.get_v1();
          r.goalv2 = h.vcmGoal.get_v2();
        else
          r.goal=0;
        end

        r.landmark=h.vcmLandmark.get_detect();
        r.landmarkv=h.vcmLandmark.get_v();

        corner=h.vcmCorner.get_detect();
        if corner>0
         r.corner=h.vcmCorner.get_type();
         r.cornerv=h.vcmCorner.get_v();
        end

        r.fall = h.wcmRobot.get_is_fall_down();
        r.time = h.wcmRobot.get_time();
        r.penalty = h.wcmRobot.get_penalty();



        r.tReceive = 0;
%TODO: monitor timeout    
        if r.time>h.tLastUpdate 
	  h.updated=1;
	  h.tLastUpdate=r.time;
	end
 
    catch
    end
  end

  function r = get_team_struct_wireless(id)
    r = [];
    try
      r.teamNumber = h.gcmTeam.get_number();
      teamColor = h.wcmTeamdata.get_teamColor();
      robotId = h.wcmTeamdata.get_robotId();
      role = h.wcmTeamdata.get_role();
      time= h.wcmTeamdata.get_time();
      posex= h.wcmTeamdata.get_posex();
      posey= h.wcmTeamdata.get_posey();
      posea= h.wcmTeamdata.get_posea();
      ballx= h.wcmTeamdata.get_ballx();
      bally= h.wcmTeamdata.get_bally();
      ballt= h.wcmTeamdata.get_ballt();
      attackBearing= h.wcmTeamdata.get_attackBearing();
      fall=h.wcmTeamdata.get_fall();
      penalty=h.wcmTeamdata.get_penalty();
      battery_level=h.wcmTeamdata.get_battery_level();

      goal=h.wcmTeamdata.get_goal();
      goalv11=h.wcmTeamdata.get_goalv11();
      goalv12=h.wcmTeamdata.get_goalv12();
      goalv21=h.wcmTeamdata.get_goalv21();
      goalv22=h.wcmTeamdata.get_goalv22();

      landmark=h.wcmTeamdata.get_landmark();
      landmarkv=h.wcmTeamdata.get_landmarkv();

      r.teamColor=teamColor(id);
      r.id = robotId(id);
      r.role = role(id);
      r.time = time(id);
        
      r.pose = {};
      r.pose.x= posex(id);
      r.pose.y= posey(id);
      r.pose.a= posea(id);

      r.ball={};
      r.ball.x= ballx(id);
      r.ball.y= bally(id);
      r.ball.vx= 0;
      r.ball.vy= 0;
      r.ball.t= ballt(id);

      r.attackBearing= attackBearing(id);

      r.fall=fall(id);
      r.penalty=penalty(id);
      r.battery_level=battery_level(id);

      r.goal=goal(id);
      r.goalv1=[goalv11(id) goalv12(id)];
      r.goalv2=[goalv21(id) goalv22(id)];

      r.landmark=landmark(id);
      r.landmarkv=[landmarkv1(id) landmarkv2(id)];

    catch
    end
  end



  function r = get_monitor_struct()
    % returns the monitor struct (in the same form as the monitor messages)
    r = [];
    try
      r.team = struct(...
          'number', h.gcmTeam.get_number(),...
          'color', h.gcmTeam.get_color(),...
          'player_id', h.gcmTeam.get_player_id(),...
          'role', h.gcmTeam.get_role()...
          );

      r.fsm = struct(...
	 'body', h.gcmFsm.get_body_state(),...
	 'head', h.gcmFsm.get_head_state(),...
	 'motion', h.gcmFsm.get_motion_state(),...
	 'game', h.gcmFsm.get_game_state()...
	);
   
      pose = h.wcmRobot.get_pose();
      r.robot = {};
      r.robot.pose = struct('x', pose(1), 'y', pose(2), 'a', pose(3));

    %Camera info

      width = h.vcmImage.get_width();
      height = h.vcmImage.get_height();
      bodyHeight=h.vcmCamera.get_bodyHeight();
      bodyTilt=h.vcmCamera.get_bodyTilt();
      headAngles=h.vcmImage.get_headAngles();
      rollAngle=h.vcmCamera.get_rollAngle();
      r.camera = struct('width',width,'height',height,...
	'bodyHeight',bodyHeight,'bodyTilt',bodyTilt,...
	'headAngles',headAngles,'rollAngle',rollAngle);

    %Image FOV boundary
          
      fovC=h.vcmImage.get_fovC();
      fovTL=h.vcmImage.get_fovTL();
      fovTR=h.vcmImage.get_fovTR();
      fovBL=h.vcmImage.get_fovBL();
      fovBR=h.vcmImage.get_fovBR();
      r.fov= struct('C',fovC, 'TL',fovTL, 'TR',fovTR, 'BL',fovBL, 'BR', fovBR);

   %ball info
      ballx = h.wcmBall.get_x();
      bally = h.wcmBall.get_y();
      ballt = h.wcmBall.get_t();
      ballvelx = h.wcmBall.get_velx();
      ballvely = h.wcmBall.get_vely();

      ball = {};
      ball.detect = h.vcmBall.get_detect();
      ball.centroid = {};
      centroid = h.vcmBall.get_centroid();
      ball.centroid.x = centroid(1);
      ball.centroid.y = centroid(2);
      ball.axisMajor = h.vcmBall.get_axisMajor();
      r.ball = struct('x', ballx, 'y', bally, 't', ballt, ...
          'centroid', ball.centroid, 'axisMajor', ball.axisMajor, ...
          'detect', ball.detect,'vx',ballvelx,'vy',ballvely);
  %goal info
      r.goal = {};
      r.goal.detect = h.vcmGoal.get_detect();
      r.goal.type = h.vcmGoal.get_type();
      r.goal.color = h.vcmGoal.get_color();
          
      % Add the goal positions
      goalv1 = h.vcmGoal.get_v1();
      r.goal.v1 = struct('x',goalv1(1), 'y',goalv1(2), 'z',goalv1(3), 'scale',goalv1(4));
      goalv2 = h.vcmGoal.get_v2();
      r.goal.v2 = struct('x',goalv2(1), 'y',goalv2(2), 'z',goalv2(3), 'scale',goalv2(4));
          
      r.goal.postStat1 = struct('x',0,'y',0, 'a',0, 'b',0,'o',0,...
	'gbx1',0,'gbx2',0,'gby1',0,'gby2',0);
      r.goal.postStat2 = struct('x',0,'y',0, 'a',0, 'b',0,'o',0,...
	'gbx1',0,'gbx2',0,'gby1',0,'gby2',0);

      if r.goal.detect==1 
         %add goal post stats
        gc1 = h.vcmGoal.get_postCentroid1();
        gc2 = h.vcmGoal.get_postCentroid2();
        ga1 = h.vcmGoal.get_postAxis1();
        ga2 = h.vcmGoal.get_postAxis2();
        go1 = h.vcmGoal.get_postOrientation1();
        go2 = h.vcmGoal.get_postOrientation2();

        % Add the goal bounding boxes
        gbb1 = h.vcmGoal.get_postBoundingBox1();
        gbb2 = h.vcmGoal.get_postBoundingBox2();

        r.goal.postStat1 = struct('x',gc1(1), 'y',gc1(2), 'a',ga1(1), 'b',ga1(2),'o',go1(1), ...
	   'gbx1',gbb1(1), 'gbx2',gbb1(2), 'gby1',gbb1(3), 'gby2',gbb1(4) );
        r.goal.postStat2 = struct('x',gc2(1), 'y',gc2(2), 'a',ga2(1), 'b',ga2(2),'o',go2(1),...
	   'gbx1',gbb2(1), 'gbx2',gbb2(2), 'gby1',gbb2(3), 'gby2',gbb2(4) );
      end

  %landmark info
      r.landmark = {};
      r.landmark.detect = h.vcmLandmark.get_detect();
      r.landmark.color = h.vcmLandmark.get_color();
      r.landmark.v = h.vcmLandmark.get_v();
      r.landmark.centroid1 = h.vcmLandmark.get_centroid1();
      r.landmark.centroid2 = h.vcmLandmark.get_centroid2();
      r.landmark.centroid3 = h.vcmLandmark.get_centroid3();

  %Vision debug message
      r.debug={};
      r.debug.message = char(h.vcmDebug.get_message());

  %Particle info
      r.particle={};
      r.particle.x=h.wcmParticle.get_x();
      r.particle.y=h.wcmParticle.get_y();
      r.particle.w=h.wcmParticle.get_w();
      r.particle.a=h.wcmParticle.get_a();

  %line info
      r.line = {};
      r.line.detect = h.vcmLine.get_detect();
      r.line.nLines = h.vcmLine.get_nLines();
      r.line.v1 = {};
      r.line.v2 = {};
      r.line.endpoint={};

      v1x=h.vcmLine.get_v1x();
      v1y=h.vcmLine.get_v1y();
      v2x=h.vcmLine.get_v2x();
      v2y=h.vcmLine.get_v2y();
      endpoint11=h.vcmLine.get_endpoint11();
      endpoint12=h.vcmLine.get_endpoint12();
      endpoint21=h.vcmLine.get_endpoint21();
      endpoint22=h.vcmLine.get_endpoint22();

      for i=1:r.line.nLines
	r.line.v1{i}=[v1x(i) v1y(i)];
	r.line.v2{i}=[v2x(i) v2y(i)];
        r.line.endpoint{i}=[endpoint11(i) endpoint21(i) ...
			    endpoint12(i) endpoint22(i)];
      end

  %corner info
      r.corner = {};
      r.corner.detect = h.vcmCorner.get_detect();

      r.corner.type = h.vcmCorner.get_type();
      r.corner.vc0 = h.vcmCorner.get_vc0();
      r.corner.v10 = h.vcmCorner.get_v10();
      r.corner.v20 = h.vcmCorner.get_v20();

      r.corner.v = h.vcmCorner.get_v();
      r.corner.v1 = h.vcmCorner.get_v1();
      r.corner.v2 = h.vcmCorner.get_v2();

%{
  %robot map info
      r.robot={};
      r.robot.map=h.vcmRobot.get_map();
      r.robot.lowpoint=h.vcmRobot.get_lowpoint();
%}
  % Add freespace boundary
      r.free = {};
      freeCol = h.vcmFreespace.get_nCol();
%		   freeValueA = h.vcmFreespace.get_pboundA();
      freeValueB = h.vcmFreespace.get_pboundB();
      labelAm = h.vcmImage.get_width()/2;
      labelBm = labelAm/4;
%      r.free = struct('Ax',freeValueA(1:labelAm),
%                      'Ay',freeValueA(labelAm+1:2*labelAm),
      r.free = struct('Bx',freeValueB(1:labelBm),...
                      'By',freeValueB(labelBm+1:2*labelBm),...
                      'nCol',freeCol,...
                      'detect',h.vcmFreespace.get_detect());
      % Add visible boundary        

      
      r.bd = {};
      bdTop = h.vcmBoundary.get_top();
	    bdBtm = h.vcmBoundary.get_bottom();
      bdCol = size(bdTop,2)/2;
      r.bd = struct('detect',h.vcmBoundary.get_detect(),...
                    'nCol',bdCol,...
                    'topy',bdTop(1,1:bdCol),...
                    'topx',-bdTop(1,bdCol+1:2*bdCol),...
                    'btmy',bdBtm(1,1:bdCol),...
                    'btmx',-bdBtm(1,bdCol+1:2*bdCol));
      % Add occupancy map
%{
      r.occ = {};
      div = size(h.wcmOccmap.get_r(),2);
      interval = 2*pi/div;
      r.occ = struct('div',div,'interval',interval,...
                     'halfInter',interval/2,...
                     'r',h.wcmOccmap.get_r(),...
                     'theta',zeros(div*4,1),...
                     'rho',zeros(div*4,1),...
                     'x',zeros(div*4,1),...
                     'y',zeros(div*4,1));
%}

      % add horizon line
      r.horizon = {};
      labelAm = h.vcmImage.get_width()/2;
      labelBm = labelAm/4;
	    horizonDir = h.vcmImage.get_horizonDir();
      horizonA = h.vcmImage.get_horizonA();
      horizonB = h.vcmImage.get_horizonB();
      horizonAx = 1 : labelAm;
      horizonBx = 1 : labelBm;
      horizonAy = (horizonAx - horizonAx(end)/2) .* tan(horizonDir) + horizonA;
      horizonBy = (horizonBx - horizonBx(end)/2) .* tan(horizonDir) + horizonB;
      r.horizon = struct('hYA',horizonAy,...
                         'hYB',horizonBy,...
                         'hXA',horizonAx,...
                         'hXB',horizonBx);
    catch
    end 
  end

  function yuyv = get_yuyv()  
% returns the raw YUYV image
    width = h.vcmImage.get_width()/2;
    height = h.vcmImage.get_height();
    rawData = h.vcmImage.get_yuyv();
    yuyv = raw2yuyv(rawData, width, height); %for Nao, double for OP
  end

  function set_yuyv(yuyv) 
    rawData=yuyv2raw(yuyv);
    h.vcmImage.set_yuyv(rawData);
  end

  function yuyv2 = get_yuyv2() 
% returns the half-size raw YUYV image
    width = h.vcmImage.get_width()/4;
    height = h.vcmImage.get_height()/2;
    rawData = h.vcmImage.get_yuyv2();
    yuyv2 = raw2yuyv(rawData, width, height); %for Nao, double for OP
  end

  function yuyv3 = get_yuyv3() 
% returns the quater-size raw YUYV image
    width = h.vcmImage.get_width()/8;
    height = h.vcmImage.get_height()/4;
    rawData = h.vcmImage.get_yuyv3();
    yuyv3 = raw2yuyv(rawData, width, height); 
  end

  function rgb = get_rgb() 
% returns the raw RGB image (not full size)
    yuyv = h.get_yuyv();
    rgb = yuyv2rgb(yuyv);
  end

  function labelA = get_labelA()  % returns the labeled image
    rawData = h.vcmImage.get_labelA();
    width = h.vcmImage.get_width()/2;
    height = h.vcmImage.get_height()/2;

    %Webots vision check 
    %for webots with non-subsampling vision code, use full width/height 
    scale= length(rawData)*2/width/height;
    if scale==1
      width = h.vcmImage.get_width();
      height = h.vcmImage.get_height();
      MONITOR.is_webots=1;
    end
    labelA = raw2label(rawData, width, height)';
  end

  function set_labelA(label)
    rawData=label2raw(label');
    h.vcmImage.set_labelA(rawData);
  end



  function labelB = get_labelB()
    % returns the bit-ored labeled image
    width = h.vcmImage.get_width()/8;
    height = h.vcmImage.get_height()/8;
    rawData = h.vcmImage.get_labelB();

    %Webots vision check 
    %for webots with non-subsampling vision code, use 2x width/height 
    scale= length(rawData)*2/width/height;
    if scale==1 % TODO: check with webots
      width = h.vcmImage.get_width()/4;
      height = h.vcmImage.get_height()/4;
      MONITOR.is_webots=1;
    end
    labelB = raw2label(rawData, width, height)';
  end
end

