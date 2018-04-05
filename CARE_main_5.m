%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '03_glm/';
  cfg.filename  = 'CARE_d02_03_glm';
  sessionStr    = sprintf('%03d', CARE_getSessionNum( cfg ));               % estimate current session number
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';   % destination path for processed data  
end

%% part 5
% Averaging of beta values of glm regression over caregivers and childs

cprintf([0,0.6,0], '<strong>[5] - Averaging beta values over dyads</strong>\n');
fprintf('\n');

cfg = [];
cfg.path = strcat(desPath, '03_glm/');
cfg.session = str2double(sessionStr);

data_betaod = CARE_avgBetaOverSubjects( cfg );


% export the averaged beta values into a *.mat file
cfg             = [];
cfg.desFolder   = strcat(desPath, '05_betaod/');
cfg.filename    = 'CARE_05_betaod';
cfg.sessionStr  = sessionStr;

file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                  '.mat');
                
fprintf('Saving the averaged beta values in:\n'); 
fprintf('%s ...\n', file_path);
CARE_saveData(cfg, 'data_betaod', data_betaod);
fprintf('Data stored!\n\n');
clear data_betaod

%% clear workspace
clear cfg file_path