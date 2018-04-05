function [ data ] = CARE_avgCohOverDyads( cfg )
% CARE_AVGCOHOVERDYADS estimates the average of the coherence values within
% the different conditions over dyads.
%
% Use as
%   [ data ] = CARE_avgCohOverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/04_wtc/')
%   cfg.session   = session number (default: 1)
%
% See also CARE_WTC

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/04_wtc/');
            
session   = ft_getopt(cfg, 'session', 1);

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------
dyadsList   = dir([path, sprintf('CARE_d*_05a_wtc_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['CARE_d%d_05a_wtc_'...
                                   sprintf('%03d.mat', session)]);          %#ok<AGROW>
end

y = sprintf('%d ', listOfDyads);
selection = false;

while selection == false
  fprintf('The following dyads are available: %s\n', y);
  x = input('Which dyads should be included into the averaging? (i.e. [1,2,3]):\n');
  if ~all(ismember(x, listOfDyads))
    cprintf([1,0.5,0], 'Wrong input!\n');
  else
    selection = true;
    listOfDyads = x;
  end
end
fprintf('\n');

% -------------------------------------------------------------------------
% Load and organize data
% -------------------------------------------------------------------------
numOfDyads = length(listOfDyads);
coherences = zeros(16, 6, numOfDyads);

for i=1:1:length(listOfDyads)
  filename = sprintf('CARE_d%02d_05a_wtc_%03d.mat', listOfDyads(i), ...
                    session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_wtc');
  coherences(:,:,i) = data_wtc.coherences;
  if i == 1
    params = data_wtc.params;
    paramStrings = data_wtc.paramStrings;
    channel = data_wtc.channel;
  end
  clear data_wtc
end
fprintf('\n');

% -------------------------------------------------------------------------
% Estimate averaged beta values
% -------------------------------------------------------------------------
fprintf('<strong>Averaging of coherence values over dyads...</strong>\n\n');
data.coherences = nanmean(coherences, 3);

data.params = params;
data.paramStrings = paramStrings;
data.channel = channel;
data.dyads = listOfDyads;

end
