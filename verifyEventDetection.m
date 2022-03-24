% verifyEventDetection
%
% This script detects EG events in the simulated signals provided. A confidence index
% is calculated and used to visualize which event detections have high (green), intermediate (blue)
% or low (red) confidence. 
%
% To run the script from the editor using the Run icon on the EDITOR toolbar. The script cycles 
% through the signals and a break is set after each display. Click the Continue button on the EDITOR toolbar
% to see the next signal. 
%

% Calls to: getSignals, egTemplate, signal processing toolbox

clear
import Utilities.*

% Initializations and hard code.
fn = 'datascientistproblem.csv';
fs = 1000;
fpass = [70 500];  % Nyquist is at 500 Hz. We want to keep as much high end as possible to keep event peaks sharp.
peakThreshold = 0.001;
minPeakDistance = 0.002*fs;
warning('off')

% Import data.
S = getSignals(fn);
t = S.t;
s2 = S.s2;
s3 = S.s3;

dt = diff(t(1:2));
fs = 1/dt;

% Loop through the signals (ignoring array configuration) for visual verification of the performance. 
for i = 1:size(s2,2)

    % Remove mean then filter with bpf
    s = s2(:,i);
    s = s - mean(s);
    [y,d] = bandpass(s, fpass, fs);

    figure(gcf)
    plot(t,y,'k'); hold on; grid on
    plot(t,y,'k.')
    title(['Signal S2  -  ',int2str(i),' .'])
    hold on

    % Peak picking on cleaned up signal. 
    y0 = y;
    y = y.^2;
    y = y./max(y);

    % Find peaks with low threshold then check for & remove any outliers
    [~,pks] = findpeaks(y,'MinPeakHeight', peakThreshold,'MinPeakDistance',minPeakDistance);

    % For every peak, find the 5 samples of the candidate event
    N = length(y0);
    for j = 1:length(pks)
        ypk = y0(pks(j));
        if ypk < 0 
            ist = max(1,pks(j)-3);
            iend = min(N,pks(j)+1);
            indexes = ist:iend;
            eventWaveform = y0(indexes);
            tWaveform = t(indexes);
        elseif ypk > 0 
            ist = max(1,pks(j)-1);
            iend = min(N,pks(j)+3);
            indexes = ist:iend;
            eventWaveform = y0(indexes);
            tWaveform = t(indexes);
        end

        % Check the quality of the candidate event
        %
        % Get a template / matched filter
        A = abs(ypk);
        cct = egTemplate(A);
        if length(eventWaveform) ~= length(cct)
            qualityIndex = 0;
        else
            r = corrcoef(cct,eventWaveform);
            qualityIndex = r(1,2);
        end
        
        if qualityIndex >0.9  %sds could add to hardcode / parameterize.
            ryg = 'g';
        elseif qualityIndex <0.5
            ryg = 'r';
        else
            ryg = 'b';
        end
        plot(tWaveform,eventWaveform,'Color',ryg)
        plot(tWaveform,eventWaveform,'Color',ryg,'Marker','.','MarkerFaceColor',ryg)
        text(t(pks(j)),ypk*1.05,num2str(qualityIndex,2),'color',ryg,'FontSize',10)

    end

    plot(t(pks),y0(pks),'go');
    grid on
    hold off

%     pause(2)
end
