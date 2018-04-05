%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg         = [];
  cfg.subFolder = '02_preproc/';
  cfg.filename  = 'CARE_d02_02_preproc';
  sessionStr  = sprintf('%03d', CARE_getSessionNum( cfg ));                 % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/';         % source path to raw data
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';   % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in preprocessed data folder
  sourceList    = dir([strcat(desPath, '02_preproc/'), ...
                       strcat('*02_preproc_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('CARE_d%d_02_preproc_', sessionStr, '.mat'));
  end
end

%% part 4
% estimate cross-correlation between the channels of caregiver and child

cprintf([0,0.6,0], '<strong>[4] - Estimation of cross-correlation</strong>\n');
fprintf('\n');

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
end

%% clear workspace
clear cfg i file_path
