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

%% estimate wavelet coherence for dyads
% export the estimated data into a *.mat file

for i = numOfPart
  % load preprocessed data
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('CARE_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preprocessed data...\n');
  CARE_loadData( cfg );
  
  % extract markers
  cfg = [];
  cfg.dyad    = sprintf('CARE_%02d', i);
  cfg.srcPath = srcPath;
  
  eventMarkers = CARE_extractEventMarkers( cfg );
  
  % estimate wavelet coherence
  cfg = [];
  cfg.eventMarkers = eventMarkers;
  
  data_wtc = CARE_wtc(cfg, data_preproc);
  
  % save wavelet coherence data
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04_wtc/');
  cfg.filename    = sprintf('CARE_d%02d_04_wtc', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The wavelet coherence data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_wtc', data_wtc);
  fprintf('Data stored!\n\n');
  clear data_wtc data_preproc 
  
end

%% clear workspace
clear cfg i file_path eventMarkers