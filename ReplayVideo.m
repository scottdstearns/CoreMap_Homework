%ReplayMovie

% load Animation01.mat
% figure
% axis('off')
% movie(MovieFrames)

videoReader = VideoReader('Images/Video01.avi');
videoPlayer = vision.VideoPlayer;

while hasFrame(videoReader)
    frame = readFrame(videoReader);
    step(videoPlayer,frame)
end

release(videoPlayer);