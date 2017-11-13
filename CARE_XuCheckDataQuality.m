function badChannels = CARE_XuCheckDataQuality(hbo, hbr)
% CARE_XUCHECKDATAQUALITY check data quality using correlation between hbo 
% and hbr as indicator. If the correlation is strictly -1 or > 0.5, then 
% the channel is declared as bad.
%
% Use as
%   badChannels = CARE_XuCheckDataQuality(hbo, hbr)
%
% where hbo and hbr are NxM matrices with N the number of scans and M the 
% number ofchannels. The output array holds the bad channels

% Copyright (C) 2009/11/25, Xu Cui
%
% adapted for the CARE project in 2017 by Daniel Matthes, MPI CBS

n = size(hbo,2);
c = zeros(1,n);

for ii=1:n
    tmp = corrcoef(hbo(:,ii), hbr(:,ii));
    c(ii) = tmp(2);
end

pos = find(c == -1);
if ~isempty(pos)
    cprintf([1,0.5,0], 'Channels with -1 correlation: %d\n', pos)
end

pos2 = find(c > 0.5);
if ~isempty(pos2)
    cprintf([1,0.5,0], 'Channels with > 0.5 correlation: %d\n', pos2)
end

badChannels = [pos pos2];
