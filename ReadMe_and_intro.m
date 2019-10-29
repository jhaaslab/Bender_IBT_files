% extract_from_ibt pulls only the sweeps and the sampling timestep from an
% "ibt" file.  Give it a valid filename, and a flag to plot or not to plot.

% First, download the file to your folder (eg C:\users\Julie\data_analysis_scripts\), then 
% in Matlab's main window Home tab, go to "Set Path" and add that folder to it. 

% Next, tell Matlab where your data are.  Must be in single quotes and end in backslash 
folder= 'C:\Data\All_My_Data\';
filename = '102319_JSH4.ibt';
fullname=[folder filename];

% do the thing; 
[D,dt]=extract_from_ibt(fullname,1);
% ....... .......................1 for plotting, 0 for no plot.
% D is a structure, where each sweep is in the 'data' field, 
% eg, D(1).data is your first sweep.
% dt is the timestep (assumes it's all at the same rate)

% make a time array for every trace.
time = dt*(1:size( D(1).data));
plot(time, D(1).data)
% or 
figure; clf; hold on;
for i=1:length(D)
plot(time,D(i).data);
end

% annotation:
xlabel('ms')
ylabel('mV')
title('Stuff')
text(.2, 30, 'Hello!')

%To take & work with only the first 5 sweeps:
N=5;  % 5 steps from -100 to 0.
subset=D(1:N);

for i=1:N
    sweep=subset(i).data;
    baseline_voltage(i) = mean( sweep( time<.05 ));
    deflection (i) = mean( sweep (time>.4 & time<.5));
end

dv = deflection - baseline_voltage;
dI=20;  % current steps for f/i protocol
current_input= dI *( -(N-1):0);    

set_one=D(1:16);  % this was my first set of f/i data.
figure(12); clf; 
subplot(121);hold on;
for i=1:length(set_one)
plot(time,set_one(i).data);
end

subplot(2,2,2); hold on;
plot(current_input, dv, 'ko:')

%fit a line to the dv - di plot to get input resistance
%see help menu for fit for the details ... 
fit_R_in=fit(current_input', dv', 'poly1');
plot(fit_R_in);legend off;
xlabel('pA');ylabel('mV');
% In MOhm, 
R_in = 1000 * fit_R_in.p1

text(-70, -10, ['R_{in} = ',num2str(R_in,3), ' M\Omega'])

subplot(224);
for i=1:length(set_one)
    spike_rate(i)= sum(pointp(set_one(i).data',0)) / .5 ;  %stim on for 0.5 s
end
stim = dI*( -4 : 11);  %same current step as before, 16 runs total
plot(stim, spike_rate,'k*-')
xlabel('Input (pA)');ylabel('Spiking (Hz)')



