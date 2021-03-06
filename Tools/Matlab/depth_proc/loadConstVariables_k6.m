DEPTH_W = 512;
DEPTH_H = 424;
DEPTH_MAX = 4500; %8000;
DEPTH_MIN = 400;
IMCX = 255.8;%422487561914693 ;% DEPTH_W/2;
IMCY = 203.7; %.487139940005989;% DEPTH_H/2;
fx =  364.7;% 457362485643273; % DEPTH_W/2/tan(70.6/2*pi/180);
fy =  366.1;% 4.542810626989194; % DEPTH_H/2/tan(60/2*pi/180);

IMCX = 258.422487561914693 ; 
IMCY = 202.487139940005989 ;
fx = 364.457362485643273; 
fy = 364.542810626989194 ;

Sx = IMCX/fx;
Sy = IMCY/fy;

Xind = kron(1:DEPTH_W,ones(1,DEPTH_H)); 
Yind = repmat(1:DEPTH_H,1,DEPTH_W); %repmat(1:DEPTH_W,1,DEPTH_H); % index in 1D array 

Xind_ = (Xind/IMCX-1); % index in 2D array representation
Yind_ = (Yind/IMCY-1); 

Xind_c = (reshape(Xind,DEPTH_H,DEPTH_W)-IMCX)/IMCX; % index in 2D array representation
Yind_c = (reshape(Yind,DEPTH_H,DEPTH_W)-IMCY)/IMCY; 

% kinect default pose info
%angles__ = [10 0 0];
%T_kh = eye(4);% kinect to head joint 
tr_kinect2head = zeros(3,1); % [-0.03; 0.06; -0.08];





