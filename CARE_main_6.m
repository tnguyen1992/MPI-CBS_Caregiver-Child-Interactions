%% check if basic variables are defined
if ~exist('prefix', 'var')
  prefix = 'CARE';
end

if ~exist('srcPath', 'var')
  if strcmp(prefix, 'CARE')
    srcPath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/';           % source path to raw data
  else
    srcPath = '/data/pt_01958/fnirsData/DualfNIRS_DCARE_rawData/';
  end
end

if ~exist('desPath', 'var')
  if strcmp(prefix, 'CARE')
    desPath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';     % destination path to preprocessed data
  else
    desPath = '/data/pt_01958/fnirsData/DualfNIRS_DCARE_processedData/';
  end
end

if ~exist('sessionStr', 'var')
  cfg           = []; 
  cfg.desFolder = desPath;
  cfg.subFolder = '02a_preproc/';
  cfg.filename  = [prefix, '_d02_02a_preproc'];
  sessionStr    = sprintf('%03d', CARE_getSessionNum( cfg ));               % calculate current session number
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in preprocessed data folder
  sourceList    = dir([strcat(desPath, '02a_preproc/'), ...
                       strcat('*02a_preproc_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat(prefix, '_d%d_02a_preproc_', sessionStr, ...
                    '.mat'));
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
  cfg.filename    = sprintf([prefix, '_d%02d_02b_trial'], i);
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
  cfg.filename    = sprintf([prefix, '_d%02d_06a_pwelch'], i);
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
