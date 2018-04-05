function CARE_easyCohMap( cfg, data )
% CARE_EASYCOHMAP is a function, which makes it easier to plot the 
% coherence of all channels in a specific condition or between specific 
% conditions in a 2D map.
%
% Use as
%   CARE_easyCohMap( cfg, data )
%
% where the input data has to be a result of CARE_WTC.
%
% The configuration options are
%   cfg.condition = condition value (default: 1113 or 'Collab-Base', see CARE_DATASTRUCTURE)
%
% See also CARE_WTC, CARE_CHECKCONDITION and CARE_DATASTRUCTURE

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
condition   = ft_getopt(cfg, 'condition', 1113);

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

condition    = CARE_checkCondition( condition );                            % check cfg.condition definition
if ~any(ismember(data.params, condition))
  error('The selected dataset contains no condition %d.', condition);
else
  column = find(ismember(data.params, condition));
end

% -------------------------------------------------------------------------
% Generate title cell array
% ------------------------------------------------------------------------
figTitle{1, 1} = 'Coherence in collaboration condition';
figTitle{1, 2} = 'Coherence in individual condition';
figTitle{1, 3} = 'Coherence in baseline condition';
figTitle{1, 4} = 'Coherence increase between collaboration and baseline condition';
figTitle{1, 5} = 'Coherence increase between individual and baseline condition';
figTitle{1, 6} = 'Coherence increase between collaboration and individual condition';

% -------------------------------------------------------------------------
% Extract data and generate a coherence map
% -------------------------------------------------------------------------
map(7,7) = 0;                                                               % initialize map of channels

map(1,2) = data.coherences(1, column);                                      % insert the sensor data into the map  
map(2,1) = data.coherences(2, column);
map(2,3) = data.coherences(3, column);
map(3,2) = data.coherences(4, column);

map(1,6) = data.coherences(5, column);
map(2,5) = data.coherences(6, column);
map(2,7) = data.coherences(7, column);
map(3,6) = data.coherences(8, column);

map(5,2) = data.coherences(9, column);
map(6,1) = data.coherences(10, column);
map(6,3) = data.coherences(11, column);
map(7,2) = data.coherences(12, column);

map(5,6) = data.coherences(13, column);
map(6,5) = data.coherences(14, column);
map(6,7) = data.coherences(15, column);
map(7,6) = data.coherences(16, column);

map(1,1) = (data.coherences(1, column) + data.coherences(2, column)) / 2;   % interpolate neigbours of sensors
map(3,1) = (data.coherences(2, column) + data.coherences(4, column)) / 2;
map(1,3) = (data.coherences(1, column) + data.coherences(3, column)) / 2;
map(3,3) = (data.coherences(3, column) + data.coherences(4, column)) / 2;

map(1,5) = (data.coherences(5, column) + data.coherences(6, column)) / 2;
map(3,5) = (data.coherences(6, column) + data.coherences(8, column)) / 2;
map(1,7) = (data.coherences(5, column) + data.coherences(7, column)) / 2;
map(3,7) = (data.coherences(7, column) + data.coherences(8, column)) / 2;

map(5,1) = (data.coherences(9, column) + data.coherences(10, column)) / 2;
map(7,1) = (data.coherences(10, column) + data.coherences(12, column)) / 2;
map(5,3) = (data.coherences(9, column) + data.coherences(11, column)) / 2;
map(7,3) = (data.coherences(11, column) + data.coherences(12, column)) / 2;

map(5,5) = (data.coherences(13, column) + data.coherences(14, column)) / 2;
map(7,5) = (data.coherences(14, column) + data.coherences(16, column)) / 2;
map(5,7) = (data.coherences(13, column) + data.coherences(15, column)) / 2;
map(7,7) = (data.coherences(15, column) + data.coherences(16, column)) / 2;

map(2,2) = (data.coherences(1, column) + data.coherences(2, column) ... 
            + data.coherences(3, column) + data.coherences(4, column)) ...
            / 4;
map(2,6) = (data.coherences(5, column) + data.coherences(6, column) ...
            + data.coherences(7, column) + data.coherences(8, column)) ...
            / 4;
map(6,2) = (data.coherences(9, column) + data.coherences(10, column) ...
            + data.coherences(11, column) + data.coherences(12, column))...
            / 4;
map(6,6) = (data.coherences(13, column) + data.coherences(14, column) ...
            + data.coherences(15, column) + data.coherences(16, column))...
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

