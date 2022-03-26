% EventDetector
%
% This script detects EG events in the simulated signals provided. A confidence index
% is calculated and used to visualize which event detections have high (green), intermediate (blue)
% or low (red) confidence.
%
% The script also finds the event zero crossings and produces an output file with the results required
% for the homework PART I.
%
% To run the script from the editor using the Run icon on the EDITOR toolbar. The script cycles
% through the signals and a break is set after each display. Click the Continue button on the EDITOR toolbar
% to see the next signal.
%

% Calls to: getSignals, egTemplate, signal processing toolbox

clear
clf
import Utilities.*

% Initializations and hard code.
fn = 'datascientistproblem.csv';
fs = 1000;
fpass = [70 500];  % Nyquist is at 500 Hz. We want to keep as much high end as possible to keep event peaks sharp.
peakThreshold = 0.001;
minPeakDistance = 0.002*fs;
highConfidenceThreshold = 0.9;
lowConfidenceThreshold = 0.5;
warning('off')

verifiedCode = false;  % set to true when ready to output the results
outputFilename = 'EventDetectionOutputs.csv';

% Import data.
S = getSignals(fn);
t = S.t;
s2 = S.s2;
s3 = S.s3;

dt = diff(t(1:2));
fs = 1/dt;

[~,M,P] = size(s3);

C = [{'Row_Col_Event'}, ...
            {'EventTime'},...
            {'ConfidenceIndex'},...
            {'QualityLevel'}];
writecell(C,outputFilename);

% Loop through the signals for visual verification of the performance.
for i = 1:M

    for j = 1:P

        % Remove mean then filter with bpf
        s = s3(:,i,j);
        s = s - mean(s);
        [y,d] = bandpass(s, fpass, fs);

        figure(gcf)
        plot(t,y,'k'); hold on; grid on
        plot(t,y,'k.')
        title(['Signal [Row, Column]:  [ ',int2str(i),' , ',int2str(j),' ]  .'])
        hold on

        % Peak picking on cleaned up signal.
        y0 = y;
        y = y.^2;
        y = y./max(y);

        % Find peaks with low threshold then check for & remove any outliers
        [~,pks] = findpeaks(y,'MinPeakHeight', peakThreshold,'MinPeakDistance',minPeakDistance);

        % For every peak, find the 5 samples of the candidate event
        N = length(y0);
        ev_count = 0;
        for k = 1:length(pks)
            ypk = y0(pks(k));
            if ypk < 0
                ist = max(1,pks(k)-3);
                iend = min(N,pks(k)+1);
                indexes = ist:iend;
                eventWaveform = y0(indexes);
                tWaveform = t(indexes);

            elseif ypk > 0
                ist = max(1,pks(k)-1);
                iend = min(N,pks(k)+3);
                indexes = ist:iend;
                eventWaveform = y0(indexes);
                tWaveform = t(indexes);
            end

            % find the zero crossing
            if(length(tWaveform)<5)
                continue
            else
                xx = tWaveform([2,4]);
                yy = eventWaveform([2,4]);
                p = polyfit(xx,yy,1);
                ztime = -p(2)/p(1);
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

            if qualityIndex > highConfidenceThreshold
                ryg = 'g';
                confLevel = 'High';
            elseif qualityIndex < lowConfidenceThreshold
                ryg = 'r';
                confLevel = 'Low';
            else
                ryg = 'b';
                confLevel = 'Indeterminant';

                % Special case - for these, we want the time of the peak due to their asymmetry.
                [~,ii] = max(abs(eventWaveform));
                ztime = tWaveform(ii);
            end
            plot(tWaveform,eventWaveform,'Color',ryg)
            plot(tWaveform,eventWaveform,'Color',ryg,'Marker','.','MarkerFaceColor',ryg)
            text(t(pks(k)),ypk*1.05,num2str(qualityIndex,2),'color',ryg,'FontSize',10)

            plot(ztime,0,'Color','k','Marker','*','MarkerSize',12)

            % Output results
            if strcmp(confLevel,'High') || strcmp(confLevel, 'Indeterminant')
                ev_count = ev_count +1;
                C = [{['r',int2str(i),'_c',int2str(j),'_ev',int2str(ev_count)]}, ...
                    {num2str(ztime,5)},...
                    {num2str(qualityIndex)},...
                    {confLevel}];
                writecell(C,outputFilename,'WriteMode','append');
            end

        end

        plot(t(pks),y0(pks),'go');
        grid on
        hold off

    end
    %     pause(2)
end
