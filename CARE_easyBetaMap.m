function CARE_easyBetaMap( cfg, data )
% CARE_EASYBETAMAP is a function, which makes it easier to plot the 
% condition- and subject-specific beta values (estimated through a 
% generalized linear model regression) of all channels in a 2D map.
%
% Use as
%   CARE_easyBetaMap( cfg, data )
%
% where the input data has to be a result of CARE_GLM.
%
% The configuration options are
%   cfg.subject   = number of subject (1 or 2, default: 1)
%   cfg.condition = condition value (default: 13 or 'Baseline', see CARE_DATASTRUCTURE)
%
% See also CARE_GLM, CARE_CHECKCONDITION and CARE_DATASTRUCTURE

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
subject     = ft_getopt(cfg, 'subject', 1);
condition   = ft_getopt(cfg, 'condition', 13);

if subject < 1 || subject > 2                                                  % check cfg.subject definition
  error('cfg.subject has to be 1 or 2');
end

if subject == 1                                                             % get subject's data
  data = data.sub1;
elseif subject == 2
  data = data.sub2;
end

condition    = CARE_checkCondition( condition );                            % check cfg.condition definition
if ~any(ismember(data.eventMarker, condition))
  error('The selected dataset contains no parameter %d.', condition);
else
  column = find(ismember(data.eventMarker, condition));
end

% -------------------------------------------------------------------------
% Generate title cell array
% ------------------------------------------------------------------------
figTitle{1, 1} = 'Beta topomap of collaboration condition';
figTitle{1, 2} = 'Beta topomap of individual condition';
figTitle{1, 3} = 'Beta topomap of baseline condition';

% -------------------------------------------------------------------------
% Extract data and generate a beta topomap
% -------------------------------------------------------------------------
map(7,7) = 0;                                                               % initialize map of channels

map(1,2) = data.beta(1, column);                                            % insert the sensor data into the map  
map(2,1) = data.beta(2, column);
map(2,3) = data.beta(3, column);
map(3,2) = data.beta(4, column);

map(1,6) = data.beta(5, column);
map(2,5) = data.beta(6, column);
map(2,7) = data.beta(7, column);
map(3,6) = data.beta(8, column);

map(5,2) = data.beta(9, column);
map(6,1) = data.beta(10, column);
map(6,3) = data.beta(11, column);
map(7,2) = data.beta(12, column);

map(5,6) = data.beta(13, column);
map(6,5) = data.beta(14, column);
map(6,7) = data.beta(15, column);
map(7,6) = data.beta(16, column);

map(1,1) = (data.beta(1, column) + data.beta(2, column)) / 2;               % interpolate neigbours of sensors
map(3,1) = (data.beta(2, column) + data.beta(4, column)) / 2;
map(1,3) = (data.beta(1, column) + data.beta(3, column)) / 2;
map(3,3) = (data.beta(3, column) + data.beta(4, column)) / 2;

map(1,5) = (data.beta(5, column) + data.beta(6, column)) / 2;
map(3,5) = (data.beta(6, column) + data.beta(8, column)) / 2;
map(1,7) = (data.beta(5, column) + data.beta(7, column)) / 2;
map(3,7) = (data.beta(7, column) + data.beta(8, column)) / 2;

map(5,1) = (data.beta(9, column) + data.beta(10, column)) / 2;
map(7,1) = (data.beta(10, column) + data.beta(12, column)) / 2;
map(5,3) = (data.beta(9, column) + data.beta(11, column)) / 2;
map(7,3) = (data.beta(11, column) + data.beta(12, column)) / 2;

map(5,5) = (data.beta(13, column) + data.beta(14, column)) / 2;
map(7,5) = (data.beta(14, column) + data.beta(16, column)) / 2;
map(5,7) = (data.beta(13, column) + data.beta(15, column)) / 2;
map(7,7) = (data.beta(15, column) + data.beta(16, column)) / 2;

map(2,2) = (data.beta(1, column) + data.beta(2, column) ... 
            + data.beta(3, column) + data.beta(4, column)) ...
            / 4;
map(2,6) = (data.beta(5, column) + data.beta(6, column) ...
            + data.beta(7, column) + data.beta(8, column)) ...
            / 4;
map(6,2) = (data.beta(9, column) + data.beta(10, column) ...
            + data.beta(11, column) + data.beta(12, column))...
            / 4;
map(6,6) = (data.beta(13, column) + data.beta(14, column) ...
            + data.beta(15, column) + data.beta(16, column))...
            / 4;

mapIP = interp2(map, 8, 'spline');                                          % conduct spline interpolation

% -------------------------------------------------------------------------
% Plot map
% -------------------------------------------------------------------------
imagesc(mapIP);
axis off;
title(figTitle{column});
colormap(jet);
colorbar;

% -------------------------------------------------------------------------
% Insert sensor labels
% -------------------------------------------------------------------------
mapSize = size(mapIP, 1) - 1;
sensPos = 1/8 * [1,2,3,5,6,7] * mapSize;

text(sensPos(2), sensPos(1), '\bullet 1', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(1), sensPos(2), '\bullet 2', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(3), sensPos(2), '\bullet 3', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(2), sensPos(3), '\bullet 4', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(1), '\bullet 5', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(4), sensPos(2), '\bullet 6', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(6), sensPos(2), '\bullet 7', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(3), '\bullet 8', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(2), sensPos(4), '\bullet 9', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(1), sensPos(5), '\bullet 10', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(3), sensPos(5), '\bullet 11', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(2), sensPos(6), '\bullet 12', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(4), '\bullet 13', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(4), sensPos(5), '\bullet 14', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(6), sensPos(5), '\bullet 15', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');
text(sensPos(5), sensPos(6), '\bullet 16', 'FontSize', 12, ...
     'FontWeight', 'bold', 'Color', 'black');

end

