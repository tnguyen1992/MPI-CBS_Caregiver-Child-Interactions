%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '04_wtc/';
  cfg.filename  = 'CARE_d02_04_wtc';
  sessionStr    = sprintf('%03d', CARE_getSessionNum( cfg ));               % estimate current session number
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';   % destination path for processed data  
end

%% part 6
% Averaging of coherence values over dyads

cprintf([0,0.6,0], '<strong>[6] - Averaging coherences over dyads</strong>\n');
fprintf('\n');

cfg = [];
cfg.path = strcat(desPath, '04_wtc/');
cfg.session = str2double(sessionStr);

data_cohod = CARE_avgCohOverDyads( cfg );


% export the averaged beta values into a *.mat file
cfg             = [];
cfg.desFolder   = strcat(desPath, '06_cohod/');
cfg.filename    = 'CARE_06_cohod';
cfg.sessionStr  = sessionStr;

file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                  '.mat');
                
fprintf('Saving the averaged coherence values in:\n'); 
fprintf('%s ...\n', file_path);
CARE_saveData(cfg, 'data_cohod', data_cohod);
fprintf('Data stored!\n');
clear data_cohod

%% clear workspace
clear cfg file_path