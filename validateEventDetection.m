% validateEventDetection
%
% This script reads the output file from the EventDetector script, plots the signals and visualizes the
% event times found. 
%
% To run the script from the editor using the Run icon on the EDITOR toolbar. The script cycles 
% through the signals and a break is set after each display. Click the Continue button on the EDITOR toolbar
% to see the next signal. 
%

% Calls to: getSignals

clear
clf
import Utilities.*

% Initializations and hard code.
fn = 'EventDetectionOutputs.csv';
warning('off')

% Import data.
load ArraySignals.mat

Tc = readcell(fn);
Tx = readmatrix(fn);

% Loop through the signals (ignoring array configuration) for visual verification of the performance. 
for i = 2:size(Tc,1)

    tag = Tc{i,1};
    sp = split(tag,'_');
    r = str2num(sp{1}(end));
    c = str2num(sp{2}(end));
    ev = str2num(sp{3}(end));

    s = arraySignals(:,r,c);

    t_event = Tx(i-1,2);

    plot(t,s,'k'); grid on
    xline(t_event,'Color','g')

    pause(2)
end
