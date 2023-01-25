clear; close all; clc;

flight1 = fullfile("Flight 1_21_2023/", "flight1_empty.mat");
flight2 = fullfile("Flight 1_21_2023/", "flight2_1ft_antenna.mat");
flight3 = fullfile("Flight 1_21_2023/", "flight3_2ft_antenna_crash.mat");

load(flight1);
load(flight2);
load(flight3);

array = table2array(flight2_1ft_antenna);
columnNum = size(array,2);

voltage_raw = array(:,1);
current_raw = array(:,2);
airspeed_raw = array(:,3);
time = array(:,4)/1000; % transfer from ms to seconds
throttle = array(:,5);  %Code now only works on flights with throttle data

% translate voltage from 10-bit value to voltage
voltage = (((voltage_raw/1023)*5)/0.06369427);

%translate current from 10-bit value to current
current = (((current_raw/1023)*5)/0.0366);

% translate airspeed from 10-bit value to analog voltage value
airspeed_v = ((airspeed_raw/1023)*5);

% analog voltage to diff pressue (Note: 2.7175 is used as the estimated
% center voltage at zero airspeed)
airspeed_diff = (airspeed_v - 2.7175);

% remove any values that are less than zero
for i = 1:length(airspeed_diff)
    if (airspeed_diff(i,1) < 0) % if value is less than zero, then replace value with 0
        airspeed_diff(i,1) = 0;
    end
end

densityOfAir = 1.24257; %kg/m^2 on January 14th, 2023

% translate diff pressure to airspeed (m/s) (Note: Bernoulli's equation
% rearranged to solve for velocity)
airspeed = sqrt((2*airspeed_diff*1000)/densityOfAir);

voltage = rescale(voltage, 0, 10); %Scale all data to be within the same range for easy comparison (and possible future statistical analysis)
current = rescale(current, 0, 10);
throttle = rescale(throttle, 0, 10);
airspeed = rescale(airspeed, 0, 10);

disp('Max Current (A)');
disp(max(current));
disp('Max Airspeed (m/s)')
disp(max(airspeed));

x = throttle(~isnan(throttle)); %remove any NaN values from the data
y = airspeed(~isnan(airspeed));
z = current(~isnan(current));
time = time(~isnan(current));

markerSize = 10;
colormap("jet")

scatter3(throttle, airspeed, current.*voltage, markerSize, [time; 0], 'filled'); %this chart shows how power input falls as airspeed increases. This is because the propeller is no longer able to output significant thrust as it is rpm limited, so angle of attack is approaching zero.
xlabel("throttle")
ylabel("airspeed")
zlabel("power")
colorbar


%Key finding!!: the weird values in the throttle vs. power graph are
%explained by low airspeed (power is higher than it should be at that
%throttle setting because no airspeed has built up yet. Looking at the
%airspeed vs. power axis it's pretty clear higher airspeed universally
%leads to lower power output.