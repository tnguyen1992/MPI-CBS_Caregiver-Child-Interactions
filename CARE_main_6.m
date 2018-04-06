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

%% part 6
% power analysis
% estimation of power spectral density

cprintf([0,0.6,0], '<strong>[6] - Power analysis (pWelch)</strong>\n');
fprintf('\n');

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  % load trial-based preprocessed data
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02b_trial/');
  cfg.filename    = sprintf('CARE_d%02d_02b_trial', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load trial-based preprocessed data...\n');
  CARE_loadData( cfg );
  
  % estimate the power spectral density using Welch's method
  cfg = [];
  cfg.window  = 30;                                                         % window size in seconds
  cfg.overlap = 50;                                                         % overlapping in percent
  
  data_pwelch = CARE_pWelch( cfg, data_trial );
  
   % save cross-correlation values
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_pwelch/');
  cfg.filename    = sprintf('CARE_d%02d_06a_pwelch', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The cross-correlation values of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_pwelch', data_pwelch);
  fprintf('Data stored!\n\n');
  clear data_pwelch data_trial
  
end

%% clear workspace
clear cfg i file_path