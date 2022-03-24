%
%Name : getSignals
%
%Usage:
%
%Description:
%
%Inputs:
%
%Outputs:
%
%Calls To:
%
%See Also: 
%
function S = getSignals(fn)

M = readmatrix(fn);

t = M(:,1);
S = struct('t',t,'s2',M(:,2:end),'s3',reshape(M(:,2:end),size(M,1),12,9));

end