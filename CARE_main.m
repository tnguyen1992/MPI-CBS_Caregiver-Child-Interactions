fprintf('------------------------------------------------\n');
fprintf('<strong>Caregiver child interactions project - data processing</strong>\n');
fprintf('Version: 0.1\n');
fprintf('Copyright (C) 2017, Daniel Matthes, Quynh Trinh Nguyen, MPI CBS\n');
fprintf('------------------------------------------------\n');

% -------------------------------------------------------------------------
% General definitions
% -------------------------------------------------------------------------
srcPath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/';
desPath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';
gsePath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/';

clear sessionStr numOfPart part

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
selection = false;

tmpPath = strcat(desPath, '01_raw_nirs/');

sessionList    = dir([tmpPath, 'CARE_d02a_01_raw_nirs_*.nirs']);
sessionList    = struct2cell(sessionList);
sessionList    = sessionList(1,:);
numOfSessions  = length(sessionList);

sessionNum     = zeros(1, numOfSessions);

for i=1:1:numOfSessions
  sessionNum(i) = sscanf(sessionList{i}, 'CARE_d02a_01_raw_nirs_%d.nirs');
end

y = sprintf('%d ', sessionNum);

while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('Please select one session or create a new one:\n');
  fprintf('[0] - Create new session\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      session = x;
      sessionStr = sprintf('%03d', session);
    elseif x == 0  
      selection = true;
      session = x;
      if ~isempty(max(sessionNum))
        sessionStr = sprintf('%03d', max(sessionNum) + 1);
      else
        sessionStr = sprintf('%03d', 1);
      end
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

% -------------------------------------------------------------------------
% General selection of dyads
% -------------------------------------------------------------------------
selection = false;

while selection == false
  fprintf('\nPlease select one option:\n');
  fprintf('[1] - Process all available dyads\n');
  fprintf('[2] - Process all new dyads\n');
  fprintf('[3] - Process specific dyad\n');
  fprintf('[4] - Quit data processing\n\n');
  x = input('Option: ');
  
  switch x
    case 1
      selection = true;
      dyadsSpec = 'all';
    case 2
      selection = true;
      dyadsSpec = 'new';
    case 3
      selection = true;
      dyadsSpec = 'specific';
    case 4
      fprintf('\nData processing aborted.\n');
      clear selection i x y srcPath desPath gsePath session sessionList ...
            sessionNum numOfSessions sessionStr
      return;
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

% -------------------------------------------------------------------------
% General selection of preprocessing option
% -------------------------------------------------------------------------
selection = false;
sdFile = [gsePath 'CARE' '.SD'];

if session == 0 && isempty(dir(sdFile))
  fprintf('\nA sources/detectors definition does not exist, this new session will start with part:\n');
  fprintf('[0] - Build sources/detectors definition\n');
  part = 0;
elseif session == 0
  fprintf('\nA sources/detectors definition already exist, this new session will start with part:\n');
  fprintf('[1] - Import/Convert raw data\n');
  part = 1;
else
  while selection == false
    fprintf('\nPlease select what you want to do:\n');
    fprintf('[0] - Build sources/detectors definition\n');
    fprintf('[1] - Import/Convert raw data\n');
    fprintf('[2] - Data preprocessing\n');
    fprintf('[3] - Conduct a generalized linear model regression with single subjects\n'); 
    fprintf('[4] - Calculation of wavelet coherence\n');
    fprintf('[5] - Quit data processing\n\n');
    x = input('Option: ');
  
    switch x
      case 0
        part = 0;
        selection = true;
      case 1
        part = 1;
        selection = true;
      case 2
        part = 2;
        selection = true;
      case 3
        part = 3;
        selection = true;
      case 4
        part = 4;
        selection = true;
      case 5
        fprintf('\nData processing aborted.\n');
        clear selection i x y srcPath desPath gsePath session ...
              sessionList sessionNum numOfSessions sessionStr sdFile
        return;
      otherwise
        selection = false;
        cprintf([1,0.5,0], 'Wrong input!\n');
    end
  end
end

% -------------------------------------------------------------------------
% Specific selection of dyads
% -------------------------------------------------------------------------
sourceList    = dir([srcPath 'CARE_*']);
sourceList    = struct2cell(sourceList);
sourceList    = sourceList(1,:);
numOfSources  = length(sourceList);
fileNum       = zeros(1, numOfSources);

for i=1:1:numOfSources
  fileNum(i)     = sscanf(sourceList{i}, 'CARE_%d');
end

switch part
  case 0
    fileNamePre = [];
    tmpPath = strcat(desPath, '01_raw_nirs/');
    fileNamePost = strcat(tmpPath, 'CARE_d*b_01_raw_nirs_', sessionStr, ...
                          '.nirs');
  case 1
    fileNamePre = [];
    tmpPath = strcat(desPath, '01_raw_nirs/');
    fileNamePost = strcat(tmpPath, 'CARE_d*b_01_raw_nirs_', sessionStr, ...
                          '.nirs');
  case 2
    tmpPath = strcat(desPath, '01_raw_nirs/');
    fileNamePre = strcat(tmpPath, 'CARE_d*b_01_raw_nirs_', sessionStr, ...
                         '.nirs');
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_02_preproc_', sessionStr, ...
                          '.mat');
  case 3
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePre = strcat(tmpPath, 'CARE_d*_02_preproc_', sessionStr, ...
                         '.mat');
    tmpPath = strcat(desPath, '03_tvalue/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_03_tvalue_', sessionStr, ...
                          '.mat');
  case 4
     tmpPath = strcat(desPath, '02_preproc/');
    fileNamePre = strcat(tmpPath, 'CARE_d*_02_preproc_', sessionStr, ...
                         '.mat');
    tmpPath = strcat(desPath, '04_wtc/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_04_wtc_', sessionStr, '.mat');
  otherwise
    error('Something unexpected happend. part = %d is not defined' ...
          , part);
end

if isempty(fileNamePre)
  numOfPrePart = fileNum;
else
  fileListPre = dir(fileNamePre);
  if isempty(fileListPre)
    cprintf([1,0.5,0], ['\nSelected part [%d] can not be executed, no' ...
          ' input data available. \nPlease choose a previous part.\n'], ...
          part);
    clear desPath fileNamePost fileNamePre fileNum i numOfSources ...
          selection sourceList srcPath x y dyadsSpec fileListPre ... 
          sessionList sessionNum numOfSessions session part sessionStr ...
          tmpPath gsePath sdFile
    return;
  else
    fileListPre = struct2cell(fileListPre);
    fileListPre = fileListPre(1,:);
    numOfFiles  = length(fileListPre);
    numOfPrePart = zeros(1, numOfFiles);
    for i=1:1:numOfFiles
       numOfPrePart(i) = sscanf(fileListPre{i}, strcat('CARE_d%d*', ...
                                sessionStr, '.*'));
    end
  end
end

if strcmp(dyadsSpec, 'all')                                                 % process all participants
  numOfPart = numOfPrePart;
elseif strcmp(dyadsSpec, 'specific')                                        % process specific participants
  y = sprintf('%d ', numOfPrePart);
    
  selection = false;
  while selection == false
    fprintf('\nThe following participants are available: %s\n', y);
    fprintf(['Comma-seperate your selection and put it in squared ' ...
               'brackets!\n']);
    x = input('\nPlease make your choice! (i.e. [1,2,3]): ');
      
    if ~all(ismember(x, numOfPrePart))
      cprintf([1,0.5,0], 'Wrong input!\n');
    else
      selection = true;
      numOfPart = x;
    end
  end
elseif strcmp(dyadsSpec, 'new')                                             % process only new participants
  if session == 0
    numOfPart = numOfPrePart;
  else
    fileListPost = dir(fileNamePost);
    if isempty(fileListPost)
      numOfPostPart = [];
    else
      fileListPost = struct2cell(fileListPost);
      fileListPost = fileListPost(1,:);
      numOfFiles  = length(fileListPost);
      numOfPostPart = zeros(1, numOfFiles);
      for i=1:1:numOfFiles
        numOfPostPart(i) = sscanf(fileListPost{i}, strcat('CARE_d%d*', sessionStr, '.*'));
      end
    end
  
    numOfPart = numOfPrePart(~ismember(numOfPrePart, numOfPostPart));
    if isempty(numOfPart)
      cprintf([1,0.5,0], 'No new dyads available!\n');
      fprintf('Data processing aborted.\n');
      clear desPath fileNamePost fileNamePre fileNum i numOfPrePart ...
          numOfSources selection sourceList srcPath x y dyadsSpec ...
          fileListPost fileListPre numOfPostPart sessionList numOfFiles ...
          sessionNum numOfSessions session numOfPart part sessionStr ...
          dyads tmpPath gsePath sdFile
      return;
    end
  end
end

y = sprintf('%d ', numOfPart);
fprintf(['\nThe following participants will be processed ' ... 
         'in the selected part [%d]:\n'],  part);
fprintf('%s\n\n', y);

clear fileNamePost fileNamePre fileNum i numOfPrePart ...
      numOfSources selection sourceList x y dyads fileListPost ...
      fileListPre numOfPostPart sessionList sessionNum numOfSessions ...
      session dyadsSpec numOfFiles tmpPath sdFile

% -------------------------------------------------------------------------
% Data processing main loop
% -------------------------------------------------------------------------
sessionStatus = true;
sessionPart = part;

clear part;

while sessionStatus == true
  switch sessionPart
    case 0
      CARE_main_0;
      selection = false;
      while selection == false
        fprintf('Continue data processing with:\n');
        fprintf('[1] - Import/Convert raw data\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 1;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 1
      CARE_main_1;
      selection = false;
      while selection == false
        fprintf('Continue data processing with:\n');
        fprintf('[2] - Data preprocessing\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 2;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 2
      CARE_main_2;
      selection = false;
      while selection == false
        fprintf('Continue data processing with:\n');
        fprintf('[3] - Conduct a generalized linear model regression with single subjects\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 3;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 3
      CARE_main_3;
      selection = false;
      while selection == false
        fprintf('Continue data processing with:\n');
        fprintf('[4] - Calculation of wavelet coherence\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 4;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 4
      CARE_main_4;
      sessionStatus = false;
    otherwise
      sessionStatus = false;
  end
  fprintf('\n');
end

fprintf('Data processing finished.\n');
fprintf('Session will be closed.\n');

clear sessionStr numOfPart srcPath desPath gsePath sessionPart ...
      sessionStatus selection x