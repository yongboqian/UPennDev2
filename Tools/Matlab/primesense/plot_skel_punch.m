%% Plot the skeleton
%clear all;

%load('primeLogs_sym.mat'); % Symmetric
%load('primeLogs_asym.mat'); % Asymmetric
%load('primeLogs_twist.mat'); % Twist
% Twistmove: left twist, right twist, forward bend,
% forward bend w/ left twist, forward bend w/ right twist
load('primeLogs_20120505T105418.mat');
fps = 30;
tperiod = 1/fps;
debug = 0;

joint2track = 'ElbowL';
index2track = find(ismember(jointNames, joint2track)==1);

%% For quick calculations
%const double upperArmLength = .060;  //OP, spec
%const double lowerArmLength = .129;  //OP, spec
op_arm_len = .189;
indexTorso = find(ismember(jointNames, 'Torso')==1);
indexHead = find(ismember(jointNames, 'Head')==1);
indexShoulderL = find(ismember(jointNames, 'ShoulderL')==1);
indexElbowL = find(ismember(jointNames, 'ElbowL')==1);
indexHandL = find(ismember(jointNames, 'HandL')==1);
indexFootL = find(ismember(jointNames, 'FootL')==1);
indexShoulderR = find(ismember(jointNames, 'ShoulderR')==1);
indexElbowR = find(ismember(jointNames, 'ElbowR')==1);
indexHandR = find(ismember(jointNames, 'HandR')==1);
indexFootR = find(ismember(jointNames, 'FootR')==1);

nLogs = numel(jointLog);
nJoints = numel(jointNames);
positions = jointLog(1).positions;
rots = jointLog(1).rots;
confs = jointLog(1).confs;
axis_angles_loc = zeros(nJoints,4);
rpy_loc = zeros(nJoints,3);
[ local_rots ] = abs2local_rot( rots );

% Velocity vars
log_xhand = [0];
log_yhand = [0];
log_vxhand = [0];
log_vyhand = [0];

%{
for j=1:nJoints
    axis_angles_loc(j,:) = vrrotmat2vec(local_rots(:,:,j));
end
%}

pc = confs(:,1)>0;
rc = confs(:,2)>0;
ci = center_idx & pc;
li = left_idx & pc;
ri = right_idx & pc;
f = figure(1);
clf;
p_left=plot3( positions(li,1), positions(li,2), positions(li,3),'o', ...
    'MarkerEdgeColor','k', 'MarkerFaceColor', 'r', 'MarkerSize',10 );
hold on;
p_right=plot3( positions(ri,1), positions(ri,2), positions(ri,3),'o', ...
    'MarkerEdgeColor','k', 'MarkerFaceColor', 'g', 'MarkerSize',10 );
p_center=plot3( positions(ci,1), positions(ci,2), positions(ci,3),'o', ...
    'MarkerEdgeColor','k', 'MarkerFaceColor', 'b', 'MarkerSize',10 );

% Front view
view(0,90);
% Side view
%view(-90,0);
% Top View
%view(0,0);
axis([-1 1 -1.2 1.5 -1 1]);
xlabel('X');
ylabel('Y');
zlabel('Z');

% Show hand velocities
figure(2);
clf;
h_vxhand = plot(log_vxhand,'ko');
hold on;
h_xhand  = plot(log_xhand,'r*');

for i=1:nLogs-1
    tstart=tic;
    
    % Check data limits
    if( isempty(jointLog(i).t) )
        break;
    end
    if( isempty(jointLog(i+1).t) )
        twait = 0;
    else
        twait = jointLog(i+1).t - jointLog(i).t;
    end
    %% Get data
    positions = jointLog(i).positions - ...
        repmat(jointLog(i).positions(indexTorso,:), nJoints,1);
    positions = positions / 1000;
    rots = jointLog(i).rots;
    confs = jointLog(i).confs;
    [ local_rots ] = abs2local_rot( rots );
    for j=1:nJoints
        rpy_loc(j,:) = dcm2angle( local_rots(:,:,j) ) * 180/pi;
    end
    
    %% Arm calculations
    e2h = positions(indexElbowL,:) - positions(indexHandL,:);
    s2e = positions(indexShoulderL,:) - positions(indexElbowL,:);
    s2h = positions(indexShoulderL,:) - positions(indexHandL,:);
    arm_lenL = sqrt(norm(e2h)) + sqrt(norm(s2e));
    offsetL = s2h * (op_arm_len / arm_lenL);
    left_hand = [ s2h(3),s2h(1),s2h(2) ] / arm_lenL;
    
    e2h = positions(indexElbowR,:) - positions(indexHandR,:);
    s2e = positions(indexShoulderR,:) - positions(indexElbowR,:);
    s2h = positions(indexShoulderR,:) - positions(indexHandR,:);
    arm_lenR = sqrt(norm(e2h)) + sqrt(norm(s2e));
    offsetR = s2h * (op_arm_len / arm_lenR);
    right_hand = [ s2h(3),s2h(1),s2h(2) ];
    
    %% Punch calculations
    %left_hand  = [ offsetL(3),offsetL(1),offsetL(2) ];
    %right_hand  = [ offsetL(3),offsetL(1),offsetL(2) ];
    if( i>1 )
        dt = jointLog(i).t - jointLog(i-1).t;
    else
        dt = 0;
    end
    %disp(dt)
    dframes = round( dt/tperiod );
    %disp(dframes)
    if( dt>0 )
        left_hand = left_hand / arm_lenL;
        filtered_ball = mexBall([left_hand(1),left_hand(3)],dframes);
        %filtered_ball [x y vx vy ep evp]
        xhand = filtered_ball(1);
        yhand = filtered_ball(2);
        vx_hand = filtered_ball(3) * 30; % Per frame to per second
        vy_hand = filtered_ball(4) * 30;
        %{
            fprintf('\nReading\n======\n')
            fprintf('Raw: (%.3f, %.3f)\n', left_hand(1), left_hand(3) );
            fprintf('hand @ (%.3f, %.3f) m going at (%.3f %.3f) m/s\n',...
                xhand,yhand,vx_hand,vy_hand);
        %}
        % Signs are mixed in the y direction...
        if( vy_hand<-1 && yhand<0 ) %% Above should and rising
            fprintf('\n^^left uppercut!^^ %f\n',jointLog(i).t);
        end
        if( vx_hand>.4 && xhand>.25 )
            fprintf('\n**left punch! %f**\n',jointLog(i).t);
        end
        log_xhand = [log_xhand xhand];
        log_yhand = [log_yhand yhand];
        log_vxhand = [log_vxhand vx_hand];
        log_vyhand = [log_vyhand vy_hand];
    end
    
    %% Update Figure
    % Update plot3
    pc = confs(:,1)>0;
    rc = confs(:,2)>0;
    ci = center_idx & pc;
    li = left_idx & pc;
    ri = right_idx & pc;
    set(p_left, 'XData', positions( li, 1), ...
        'YData', positions( li, 2), ...
        'ZData', positions( li, 3) ...
        );
    set(p_right, 'XData', positions( ri, 1), ...
        'YData', positions( ri, 2), ...
        'ZData', positions( ri, 3));
    set(p_center, 'XData', positions( ci, 1), ...
        'YData', positions( ci, 2), ...
        'ZData', positions( ci, 3));
    
    % Update Velocity plot
    set(h_vxhand,'XData',[1:numel(log_vyhand)]);
    set(h_vxhand,'YData',log_vyhand(:) );
    set(h_xhand,'XData',[1:numel(log_yhand)]);
    set(h_xhand,'YData',log_yhand(:));
    
    %% Timing
    tf = toc(tstart);
    % Realistic pause
    pause( max(twait-tf,0) );
    % Arbitrary pause:
    %pause(.2);
end