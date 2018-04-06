%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg         = [];
  cfg.subFolder = '02a_preproc/';
  cfg.filename  = 'CARE_d02_02a_preproc';
  sessionStr  = sprintf('%03d', CARE_getSessionNum( cfg ));                 % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/';         % source path to raw data
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';   % destination path for processed data  
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
                    strcat('CARE_d%d_02a_preproc_', sessionStr, '.mat'));
  end
end

%% part 5
% 1. Estimation of a wavelet transform coherence. Wavelet coherence is 
%    useful for analyzing nonstationary signals. The coherence is computed 
%    using the analytic Morlet wavelet.  
% 2. Estimation of a magnitude-squared coherence using Welch’s overlapped 
%    averaged periodogram method.

cprintf([0,0.6,0], '<strong>[5] - Calculation of coherence using different approaches</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wavelet transform coherence
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02a_preproc/');
  cfg.filename    = sprintf('CARE_d%02d_02a_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  % load continuous preprocessed data
  fprintf('Load preprocessed data...\n');
  CARE_loadData( cfg );
  
  % estimate wavelet coherence
  cfg = [];
  cfg.poi          = [23 100];                                              % period of interest in seconds, master thesis settings: [30 136] 
  
  data_wtc = CARE_wtc(cfg, data_preproc);
  
  % save wavelet coherence data
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05a_wtc/');
  cfg.filename    = sprintf('CARE_d%02d_05a_wtc', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The wavelet transform coherence data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_wtc', data_wtc);
  fprintf('Data stored!\n\n');
  clear data_wtc data_preproc 
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% magnitude-squared coherence
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02b_trial/');
  cfg.filename    = sprintf('CARE_d%02d_02b_trial', i);
  cfg.sessionStr  = sessionStr;
  
  % load trial-based preprocessed data
  fprintf('Load trial-based preprocessed data...\n');
  CARE_loadData( cfg );
  
  % estimate wavelet coherence
  cfg = [];
  cfg.poi          = [23 100];                                              % period of interest in seconds
  
  data_msc = CARE_msc(cfg, data_trial);
  
  % save wavelet coherence data
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '05b_msc/');
  cfg.filename    = sprintf('CARE_d%02d_05b_msc', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The magnitude-squared coherence data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_msc', data_msc);
  fprintf('Data stored!\n\n');
  clear data_msc data_trial 
  
end

%% clear workspace
clear cfg i file_path
