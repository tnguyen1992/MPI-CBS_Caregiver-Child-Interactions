function [ data ] = CARE_avgBetaOverSubjects( cfg )
% CARE_AVGBETAOVERSUBJECTS estimates the average of the beta values within
% the different conditions over caregivers and over childs.
%
% Use as
%   [ data ] = CARE_avgBetaOverSubjects( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/03_glm/')
%   cfg.session   = session number (default: 1)
%
% See also CARE_GLM

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/03_glm/');
            
session   = ft_getopt(cfg, 'session', 1);

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------
dyadsList   = dir([path, sprintf('CARE_d*_03_glm_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['CARE_d%d_03_glm_'...
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
caregiverBeta = zeros(16, 3, numOfDyads);
childBeta = zeros(16, 3, numOfDyads);

for i=1:1:length(listOfDyads)
  filename = sprintf('CARE_d%02d_03_glm_%03d.mat', listOfDyads(i), ...
                    session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_glm');
  caregiverBeta(:,:,i) = data_glm.sub1.beta;
  childBeta(:,:,i) = data_glm.sub2.beta;
  if i == 1
    eventMarker = data_glm.sub1.eventMarker;
    channel = data_glm.sub1.channel;
  end
  clear data_glm
end
fprintf('\n');

% -------------------------------------------------------------------------
% Estimate averaged beta values
% -------------------------------------------------------------------------
fprintf('Averaging of beta values over caregivers and over childs...\n\n');
data.sub1.beta = mean(caregiverBeta, 3);
data.sub2.beta = mean(childBeta, 3);

data.sub1.eventMarker = eventMarker;
data.sub1.channel = channel;
data.sub2.eventMarker = eventMarker;
data.sub2.channel = channel;
data.dyads = listOfDyads;

end
