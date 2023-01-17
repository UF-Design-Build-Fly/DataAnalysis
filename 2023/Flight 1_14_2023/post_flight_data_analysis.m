load("flight1_no_antenna.mat");
load("flight2_1ft_antenna.mat");
load("flight3_1ft_antenna.mat");
load("flight4_2ft_antenna.mat");
load("flight5_2ft_antenna_counterweight.mat");
load("flight7_package_weight_5_53lb.mat");

array = table2array(flight1_no_antenna);

voltage_raw = array(:,1);
current_raw = array(:,2);
airspeed_raw = array(:,3);
time = array(:,4)/1000; % transfer from ms to seconds

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

a= 1;
b = [1/4 1/4 1/4 1/4]; % moving average filter

voltage_filt = filter(b,a,voltage);

%voltage vs current
subplot(1,2,1);
yyaxis left
plot(time, voltage, 'Color', 'blue');
hold on;
yyaxis right
plot(time, current, 'Color', 'red');
hold off;

yyaxis left
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Voltage vs Current');
legend('voltage', 'current');
ylim([18 30]) % good voltage range

yyaxis right
ylabel('Current (A)');
ylim([0 70]) % good current range

%airspeed vs current
subplot(1,2,2);
yyaxis left
plot(time, airspeed, 'Color', 'magenta');
hold on;
yyaxis right
plot(time, current, 'Color', 'red');
hold off;

yyaxis left
xlabel('Time (s)');
ylabel('Airspeed (m/s)');
title('Airspeed vs Current');
legend('airspeed', 'current');
ylim([0 45]) %good airspeed range

yyaxis right
ylabel('Current (A)');
ylim([0 70]) % good current range

disp('Max Current (A)');
disp(max(current));
disp('Max Airspeed (m/s)')
disp(max(airspeed));
