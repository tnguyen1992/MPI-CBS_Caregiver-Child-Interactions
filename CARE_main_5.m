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

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to use the default period of interest ([23 100]) for the coherence estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    poi = [23 100];                                                         % period of interest in seconds, master thesis settings: [30 136]
  elseif strcmp('n', x)
    selection = true;
    poi = [];
  else
    selection = false;
  end
end
fprintf('\n');

if isempty(poi)
  selection = false;
  while selection == false
    cprintf([0,0.6,0], 'Specify a period of interest in a range between 1 and 150 seconds!\n');
    cprintf([0,0.6,0], 'Caution: The minimum period must be <= 32 seconds!\n');
    cprintf([0,0.6,0], 'Put your selection in squared brackets!\n');
    x = input('Value: ');
    if isnumeric(x)
      if (min(x) < 1 || max(x) > 150)
        cprintf([1,0.5,0], 'Wrong input!\n');
        selection = false;
      elseif (min(x) > 32)                                                  % otherwise the mscohere estimation would fail
        cprintf([1,0.5,0], 'Wrong input!\n');
        selection = false;
      else
        poi = x;
        selection = true;
      end
    else
      cprintf([1,0.5,0], 'Wrong input!\n');
      selection = false;
    end
  end
fprintf('\n');  
end

selection = false;
while selection == false
  cprintf([0,0.6,0], 'WTC: Do you want to set all values below cone of interest to NaN?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    considerCOI = true;                                                     % consider cone of interest
  elseif strcmp('n', x)
    selection = true;
    considerCOI = false;
  else
    selection = false;
  end
end
fprintf('\n');

% Write selected settings to settings file
file_path = [desPath '00_settings/' sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(file_path, 'file') == 2)                                         % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  CARE_createTbl(cfg);                                                      % create settings file
end

T = readtable(file_path);                                                   % update settings table
warning off;
T.dyad(numOfPart)     = numOfPart;
T.CohPOI(numOfPart)   = {vec2str(poi, [], [], 1)};
T.ConsCOI(numOfPart)  = { x };
warning on;
delete(file_path);
writetable(T, file_path);

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
  cfg.poi          = poi; 
  cfg.considerCOI  = considerCOI;
  
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
  cfg.poi          = poi;
  
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
clear cfg i file_path selection x poi considerCOI T
