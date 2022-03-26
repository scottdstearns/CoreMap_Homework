%VisualizeInTime

% Initializations
captureFlag = false;

% Load the preprocessed signals
load ArraySignals


% Define spatial coordinates for the array.
dx = 20;
dy = 20;

N = size(arraySignals,1);
M = size(arraySignals,2);
P = size(arraySignals,3);

x = 0:dx:(P-1)*dx;
y = 0:dy:(M-1)*dy;

[X,Y] = meshgrid(x,y);

% Display the signals over time and across the array
clf
figPosition = [-1163 163 1102 854];
axLimits = [0 160 0 250 -0.3 0.3];
set(gcf,'Position',figPosition)

if captureFlag
    Video = VideoWriter('Images/Video02','MPEG-4');
    open(Video);
%     MovieFrames(50) = struct('cdata',[],'colormap',[]);
end

for n = 50:900 %1:N

    Z = squeeze(arraySignals(n,:,:));
    edgeColor = 'none';
    faceColor = 'interp';
    s = surf(X,Y,Z,'EdgeColor',edgeColor,'FaceColor',faceColor);
    axis(axLimits)
    set(gca,'CameraPosition',[-220.9271 -1.2791e+03 3.7909])
    caxis([-0.2 0.2])
    colorbar
    shading interp
    title(['ELAPSED TIME:  ', num2str(t(n),4),'  seconds.'],'FontSize',18)

%     pause(0.001)
    drawnow

    if captureFlag
        writeVideo(Video,getframe(gcf));
%         MovieFrames(n) = getframe(gcf);
    end


end

if captureFlag
%     save("Images/Animation01.mat", "MovieFrames","figPosition","axLimits")
    close(Video);
end
