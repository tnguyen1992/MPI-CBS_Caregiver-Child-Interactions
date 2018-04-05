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

%% part 3
% conduct a generalized linear model regression for all channels of the single objects
% export the estimated beta coefficients into a *.mat file

cprintf([0,0.6,0], '<strong>[3] - Conduct a generalized linear model regression with single subjects</strong>\n');
fprintf('\n');

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  % load preprocessed data
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('CARE_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load preprocessed data...\n');
  CARE_loadData( cfg );
  
  % extract markers
  cfg = [];
  cfg.dyad    = sprintf('CARE_%02d', i);
  cfg.srcPath = srcPath;
  
  eventMarkers = CARE_extractEventMarkers( cfg );
  
  % conduct the generalized linear model regression
  cfg = [];
  cfg.eventMarkers = eventMarkers;
  
  data_glm = CARE_glm(cfg, data_preproc);
  
  % save beta values of glm regression
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03_glm/');
  cfg.filename    = sprintf('CARE_d%02d_03_glm', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The generalized linear model coefficients of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_glm', data_glm);
  fprintf('Data stored!\n\n');
  clear data_glm data_preproc 
  
end

%% clear workspace
clear cfg i file_path eventMarkers