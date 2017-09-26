% % Managing Data, load them, give names to variables and plot them
data = importdata('..\Logs\Variable_names.xlsx');% ,'Sheet1','B4:C83'
names = data(4:end,1:2);clear data;
%% 1'45s First Operation Duration -->10500 data
data = load('..\Logs\2013_02_05_Short_y.mat');
foe = 10500;
%%
test = data.Test(1,1);
%% time 
ind_Time = find(ismember(names(:,1),'Time'));
str_Time = names(ind_Time,2);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % -----------INPUTS-------------------

%%  Accelerator Pedal, Brake Pedal
acc_brk=figure(100),createFancyPlot(test,names,{'AccelPed_Frac_Cmd','BrakePed_Frac_Cmd'},foe)
%  saveas(acc_brk,'pics/acc_brk.png');
%% Gear and Dir
ger_dir=figure(105),createFancyPlot(test,names,{'Gear_Req','Dir_Cmd'},foe)
%  saveas(ger_dir,'pics/ger_dir.png');





% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % -----------OUTPUTS-------------------

%%  Load Cell
loa=figure(110),createFancyPlot(test,names,{'LoadCell_kg'},foe)
%  saveas(loa,'pics/loa.png');
%% GPS postion data
gp1=figure(120),createFancyPlot(test,names,{'VBSS100_Latitude_deg'},foe)
gp2=figure(125),createFancyPlot(test,names,{'VBSS100_Longitude_deg'},foe)
%  saveas(gp1,'pics/gp1.png');
%  saveas(gp2,'pics/gp2.png');
lambda =test.VBSS100_Longitude_deg(1,1:foe)';
phi    =test.VBSS100_Latitude_deg(1,1:foe)';
% %% Ellipsoid WSG84, Transverse Mercator Projection 
a = 6378137;%%semi-major axis[m]
gps2x = a*lambda*pi/180;% Should I have to divide by deg2rad?YES
gps2y = a/2*log((1+sind(phi))./(1-sind(phi)));
% %% Local Area Translation + Simple Rotating from 3rd to 1st cartesian quadr.
x = ( gps2x-gps2x(1,1) ) * (-1);
y = ( gps2y-gps2y(1,1) ) * (-1);
figure(6378137),plot(x,y)
% Comment : ~78 m in the first 38s?averaged speed=7.4km/h, feasible
% Comment : x,y ready for Bezier Curve in the ChDriverPathFollower
%% Bezier Curve Text File Preparation
x = x(1:3625,1);y = y(1:3625,1);% For Bezier
bez = 1:125:3625;
xcp = x(bez);ycp=y(bez);
CP = [xcp ycp]';%Control Points % Note, nt=400 in Default Code
main = DeCasteObj(CP);% If available, refer to Duccio Mugnaini Matlab Exchange Library
% Note: keep # of CPs low, please.
%% Vehicle vx 
gvl=figure(130),createFancyPlot(test,names,{'Veh_GPSVel_kmh_Act'},foe)
t=test.Time(1,1:foe)';
speed = test.Veh_GPSVel_kmh_Act(1,1:foe)'./3.6;% % km/h->m/s
figure(3600),plot(t,speed)
%  saveas(gvl,'pics/gvl.png');
%% Smoothing Speed Curve
% % Credits to Damien Garcia
sspeed = smoothn(speed,10e3, 'robust');
figure,plot(t,speed,'b',t,sspeed,'r')
mspeed = horzcat(t,sspeed);
% dlmwrite('../WL_DesiredSpeedSmoothed.dat',mspeed,'delimiter','\t','precision',5);
%% Reduced smoothed speed curve
rt = t(900:4900,:)-t(900,1);
rsspeed = sspeed(900:4900,:);
figure,plot(t,speed,'b',t,sspeed,'r',rt,rsspeed,'g*')
mrspeed = horzcat(rt,rsspeed);
dlmwrite('../WL_DesSpeedShort.dat',mrspeed,'delimiter','\t','precision',5);
%% Piston Pressures
psf=figure(140),createFancyPlot(test,names,{'VehLiftArmBot_Pr_bar_Act','VehLiftArmTop_Pr_bar_Act'},foe)
%  saveas(psf,'pics/psf.png');

 
 %% Steering Pump
 stpmp=figure(150),createFancyPlot(test,names,{'SteerPump_Pr_bar_Act'},foe)

 %% Yaw Rate
 yawr=figure(155),createFancyPlot(test,names,{'Veh_YawR_Act','SteerPump_Pr_bar_Act'},foe)
% %  Yaw
dyaw = test.Veh_YawR_Act(1,1:foe)';t=test.Time(1,1:foe)';
yaw= zeros(1,foe)';
for j=1:foe-1
    yaw(j+1)= yaw(j) + dyaw(j)*0.01; 
end
figure(9999),plot(t,yaw)
 %% Lateral Acceleration
 vehlat=figure(160),createFancyPlot(test,names,{'Veh_YAcc_Act'},foe)
 %% Brake Pressure
 brakepress=figure(180),createFancyPlot(test,names,{'BrakeF_Pr_bar_Act','BrakeR_Pr_bar_Act'},foe)
 %% Engine Speed
engine=figure(190),createFancyPlot(test,names,{'ICE_w_rpm_Act','ICE_w_rpm_Req'},foe)
 %% Steering Reconstruction
ddyaw= zeros(1,foe)';
for j=1:foe-1
    ddyaw(j+1)= ( dyaw(j+1) + dyaw(j) )/0.01; 
end

figure,plot(t,ddyaw)
st_pump_press =test.SteerPump_Pr_bar_Act(1,1:foe)';
max(st_pump_press),min(st_pump_press)
re_yaw = 40 .* sign(ddyaw) .* (st_pump_press-min(st_pump_press)) ./ (max(st_pump_press)-min(st_pump_press));
figure,plot(t,re_yaw)
% % This reconstruction is very unstable in Chrono.