% PreprocessArrayData
%
% This script detects preprocesses the signals and saves them in as a 3D array in .mat file format. 
%
%

% Calls to: getSignals, signal processing toolbox

clear
import Utilities.*

% Initializations and hard code.
fn = 'datascientistproblem.csv';
fs = 1000;
fpass = [70 fs/2];  % Nyquist is at 500 Hz. We want to keep as much high end as possible to keep event peaks sharp.
warning('off')

% Import data.
S = getSignals(fn);
t = S.t;
s2 = S.s2;
s3 = S.s3;

dt = diff(t(1:2));
fs = 1/dt;

% Loop through the signals following the array configuration
M = size(s3,2);
P = size(s3,3);

arraySignals = zeros(size(s3));
for i = 1:M
    for j = 1:P
        s = s3(:,i,j);
        s = s - mean(s);
        [y,d] = bandpass(s,fpass,fs);

        arraySignals(:,i,j) = y;
    end
end

save("ArraySignals.mat","arraySignals","t")

