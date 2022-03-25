%
%Name : getSignals
%
%Usage: S = getSignals(fn);
%
%Description:  Reads .csv file and returns data in a structure. No frills, or error handling, etc. 
%
%Inputs: fn - Expecting full path to .csv formatted file with rectangular set of data.  
%
%Outputs: S - data structure with fields:
%               t: Nx1 double sample times
%               s2: NxK double signal data. K is MxP where M and P are row & col dimensions of sensor array. 
%               s3: NxMxP double signal data. Same data in 3d matrix. 
%
%Calls To: None.
%

%See Also: readmatrix.
%
function S = getSignals(fn)

M = readmatrix(fn);

t = M(:,1);
S = struct('t',t,'s2',M(:,2:end),'s3',reshape(M(:,2:end),size(M,1),12,9));

end