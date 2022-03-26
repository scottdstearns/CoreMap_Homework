% StackplotSubarray

% Should refactor as a function ... pretty nice. 

load ArraySignals
clf
warning off

% No frills UI. Edit the subarray you want to see, save and run. 
% Array dimensions are 12 x 9. 

% Set row to 0 to see column subarray. Set column to 0 to see row subarray. 
%    Example: [0,9] to see subarray in column 9;
%
row_col = [6,0]; 

if (not(any(row_col == 0)))
    error('Incorrect parameter setting row_col: Expecting to find a zero.')
else
    if row_col(1)
        K = row_col(1);
        if K > 12
            error('Incorrect parameter: Max row index is 12.')
        end
        s = squeeze(arraySignals(:,K,:));
        tstr = ['Row  ',num2str(K)];
    else
        K = row_col(2);
        if K > 9
            error('Incorrect parameter: Max col index is 9.')
        end
        s = squeeze(arraySignals(:,:,K));
        tstr = ['Column  ',num2str(K)];
    end
end

[~,n] = size(s);

for k = 1:n
    h(k) = subplot(n,1,k);
    h(k).Visible = 'off';
    plot(t,s(:,k));
    axis([0 max(t) -0.2 0.2])

    h(k).YLabel.String = ['Ch ',num2str(k)];
    h(k).YLabel.FontWeight = 'bold';
    h(k).YTick = [];
    xt = h(k).XTick;
    h(k).XTick = [];
    h(k).XColor = 'none';
    h(k).Box = 'off';
end
h(n).XColor = 'k';
h(n).XTick = xt;
h(n).Box = 'off';
h(n).XLabel.String = 'Time (s)';
linkaxes(h,'x');

d = h(1).Position(2) - h(2).Position(2) - h(2).Position(4);
shiftup = d;
h(1).Position(2) = h(1).Position(2) - shiftup/2;
h(1).Position(4) = h(1).Position(4) + shiftup/2;
h(1).Title.String = tstr;
h(1).Visible = 'on';
for k = 2:n
    h(k).Position(4) = h(k).Position(4) + shiftup;
    h(k).Visible = 'on';
end

warning on