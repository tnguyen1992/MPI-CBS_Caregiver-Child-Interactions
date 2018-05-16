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
  cfg.subFolder = '01_raw_nirs/';
  cfg.filename  = [prefix, '_d02b_01_raw_nirs'];
  sessionStr    = sprintf('%03d', CARE_getSessionNum( cfg ));               % calculate current session number
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([strcat(desPath, '01_raw_nirs/'), ...
                       strcat('*b_01_raw_nirs_', sessionStr, '.nirs')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat(prefix, '_d%d_01_raw_nirs_', sessionStr, ...
                    '.nirs'));
  end
end

%% part 2
% preprocess the raw data

cprintf([0,0.6,0], '<strong>[2] - Data preprocessing</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to apply the data quality check of Xu Cui?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    XuCui = x;
    XuCuiCfg = 'yes';
  elseif strcmp('n', x)
    selection = true;
    XuCui = x;
    XuCuiCfg = 'no';
  else
    selection = false;
  end
end
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to apply the visual pulse quality check?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    pulse = x;
    pulseCfg = 'yes';
  elseif strcmp('n', x)
    selection = true;
    pulse = x;
    pulseCfg = 'no';
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
T.XuCuiQC(numOfPart)  = { XuCui };
T.pulseQC(numOfPart)  = { pulse };
warning on;
delete(file_path);
writetable(T, file_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocessing
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  % extract event markers
  cfg = [];
  cfg.dyad    = sprintf([prefix, '_%02d'], i);
  cfg.srcPath = srcPath;
  
  fprintf('Extract event markers from hdr file...\n');
  eventMarkers = CARE_extractEventMarkers( cfg );
  
  % load raw data of subject 1
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01_raw_nirs/');
  cfg.filename    = sprintf([prefix, '_d%02da_01_raw_nirs'], i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load raw nirs data of subject 1...\n');
  CARE_loadData( cfg );
  
  if ~isequal(length(eventMarkers), size(s, 2))
    error('Loaded event markers and raw data of subject 1 doesn''t match!');
  end
  
  data_raw.sub1.SD            = SD;
  data_raw.sub1.d             = d;
  data_raw.sub1.s             = s;
  data_raw.sub1.aux           = aux;
  data_raw.sub1.t             = t;
  data_raw.sub1.eventMarkers  = eventMarkers;
  
  clear SD d s aux t
  
  % load raw data of subject 2
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01_raw_nirs/');
  cfg.filename    = sprintf([prefix, '_d%02db_01_raw_nirs'], i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load raw nirs data of subject 2...\n');
  CARE_loadData( cfg );
  
  if ~isequal(length(eventMarkers), size(s, 2))
    error('Loaded event markers and raw data of subject 2 doesn''t match!');
  end
  
  data_raw.sub2.SD            = SD;
  data_raw.sub2.d             = d;
  data_raw.sub2.s             = s;
  data_raw.sub2.aux           = aux;
  data_raw.sub2.t             = t;
  data_raw.sub2.eventMarkers  = eventMarkers;
  
  clear SD d s aux t eventMarkers
  
  % preprocess raw data of both subjects
  cfg = [];
  cfg.XuQualityCheck    = XuCuiCfg;
  cfg.pulseQualityCheck = pulseCfg;

  data_preproc = CARE_preprocessing(cfg, data_raw);
  
  % save preprocessed data
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02a_preproc/');
  cfg.filename    = sprintf([prefix, '_d%02d_02a_preproc'], i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_preproc', data_preproc);
  fprintf('Data stored!\n\n');
  clear data_raw
  
  % extract data of conditions from continuous data stream
  data_trial = CARE_getTrl(data_preproc);
  
  % save trial-based data
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02b_trial/');
  cfg.filename    = sprintf([prefix, '_d%02d_02b_trial'], i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The extracted trials of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_trial', data_trial);
  fprintf('Data stored!\n\n');
  clear data_preproc data_trial  
  
end

%% clear workspace
clear cfg i file_path XuCui XuCuiCfg pulse pulseCfg T
