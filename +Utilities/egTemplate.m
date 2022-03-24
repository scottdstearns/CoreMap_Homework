function s = egTemplate(varargin)
%
%Name : egTemplate();   
%
%Usage: y = egTemplate({A}); 
%
%Description: Returns a simple model electrogram waveform of length 5. 
%
%Inputs: A - optional. Amplitude of waveform pulse. Default is 1.
%        
%Outputs: y - simulated eg model waveform.
%
%   Example: y = egTemplate(0.5); plot(y);
%

%Calls To: None.
%
%See Also: 
%
if nargin ==0
    A = 1;

elseif nargin ==1
    A = varargin{1};

else
    warning('egTemplate: Incorrect syntax.')
end

% Template (not needed for the simplest eg waveform, but is a model for creating future waveform types.)
s = [0,1,0,-1,0] .* A; % Template

end