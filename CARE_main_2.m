%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg         = [];
  cfg.subFolder = '01_raw_nirs/';
  cfg.filename  = 'CARE_d02b_01_raw_nirs';
  sessionStr  = sprintf('%03d', CARE_getSessionNum( cfg ));                 % estimate current session number
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';   % destination path for processed data  
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
                    strcat('CARE_d%db_01_raw_nirs_', sessionStr, '.nirs'));
  end
end

%% part 2
% preprocess the raw data
% export the preprocessed data into a *.mat file

cprintf([0,0.6,0], '<strong>[2] - Data preprocessing</strong>\n');
fprintf('\n');

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  % load raw data of subject 1
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01_raw_nirs/');
  cfg.filename    = sprintf('CARE_d%02da_01_raw_nirs', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load raw nirs data of subject 1...\n');
  CARE_loadData( cfg );
  
  data_raw.sub1.SD  = SD;
  data_raw.sub1.d   = d;
  data_raw.sub1.s   = s;
  data_raw.sub1.aux = aux;
  data_raw.sub1.t   = t;
  
  clear SD d s aux t
  
  % load raw data of subject 2
  cfg             = [];
  cfg.filename    = sprintf('CARE_d%02db_01_raw_nirs', i);
  
  fprintf('Load raw nirs data of subject 2...\n');
  CARE_loadData( cfg );
  
  data_raw.sub2.SD  = SD;
  data_raw.sub2.d   = d;
  data_raw.sub2.s   = s;
  data_raw.sub2.aux = aux;
  data_raw.sub2.t   = t;
  
  clear SD d s aux t
  
  % preprocess raw data of poth subjects
  data_preproc = CARE_preprocessing(data_raw);
  
  % save preprocessed data
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('CARE_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_preproc', data_preproc);
  fprintf('Data stored!\n\n');
  clear data_preproc data_raw  
  
end

%% clear workspace
clear cfg i file_path
