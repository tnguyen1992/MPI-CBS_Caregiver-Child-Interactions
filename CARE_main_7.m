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

%% part 7
% Averaging over dyads

cprintf([0,0.6,0], '<strong>[7] - Averaging over dyads</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Averaging of beta values of glm regression over caregivers and childs
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging of beta values of glm regression over caregivers and childs?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    avgOverDyads = true;
  elseif strcmp('n', x)
    choise = true;
    avgOverDyads = false;
  else
    choise = false;
  end
end
fprintf('\n');

if avgOverDyads == true
  cfg = [];
  cfg.path = strcat(desPath, '03_glm/');
  cfg.session = str2double(sessionStr);

  data_betaod = CARE_avgBetaOverSubjects( cfg );


  % export the averaged beta values into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07a_betaod/');
  cfg.filename    = 'CARE_07a_betaod';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                    '.mat');

  fprintf('Saving the averaged beta values in:\n'); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_betaod', data_betaod);
  fprintf('Data stored!\n\n');
  clear data_betaod
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Averaging of wavelet coherence values over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging of wavelet coherence values over dyads?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    avgOverDyads = true;
  elseif strcmp('n', x)
    choise = true;
    avgOverDyads = false;
  else
    choise = false;
  end
end
fprintf('\n');

if avgOverDyads == true
  cfg = [];
  cfg.path = strcat(desPath, '05a_wtc/');
  cfg.session = str2double(sessionStr);

  data_wcod = CARE_avgCohOverDyads( cfg );


  % export the averaged beta values into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_wcod/');
  cfg.filename    = 'CARE_07b_wcod';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                    '.mat');

  fprintf('Saving the averaged coherence values in:\n'); 
  fprintf('%s ...\n', file_path);
  CARE_saveData(cfg, 'data_wcod', data_wcod);
  fprintf('Data stored!\n');
  clear data_wcod
end

%% clear workspace
clear cfg file_path x choise avgOverDyads