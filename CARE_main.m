clc;
CARE_init;

cprintf([0,0.6,0], '<strong>--------------------------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Caregiver child interactions project - data processing</strong>\n');
cprintf([0,0.6,0], '<strong>Version: 0.2</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, Quynh Trinh Nguyen, MPI CBS\n');
cprintf([0,0.6,0], '<strong>--------------------------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
srcPath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/';               % location of raw data
desPath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';         % memory space for processed data
gsePath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/';       % path to CARE.SD

fprintf('\nThe default paths are:\n');
fprintf('Source: %s\n',srcPath);
fprintf('Destination: %s\n',desPath);
fprintf('Location of CARE.SD: %s\n',gsePath);

selection = false;
while selection == false
  fprintf('\nDo you want to select the default paths?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    newPaths = false;
  elseif strcmp('n', x)
    selection = true;
    newPaths = true;
  else
    selection = false;
  end
end

if newPaths == true
  srcPath = uigetdir(pwd, 'Select Source Folder...');
  desPath = uigetdir(strcat(srcPath,'/..'), ...
                      'Select Destination Folder...');
  gsePath = uigetdir(strcat(srcPath,'/..'), ...
                      'Select Folder containing CARE.SD...');
  srcPath = strcat(srcPath, '/');
  desPath = strcat(desPath, '/');
  gsePath = strcat(gsePath, '/');
end

if ~exist(strcat(desPath, '00_settings'), 'dir')
  mkdir(strcat(desPath, '00_settings'));
end
if ~exist(strcat(desPath, '01_raw_nirs'), 'dir')
  mkdir(strcat(desPath, '01_raw_nirs'));
end
if ~exist(strcat(desPath, '02a_preproc'), 'dir')
  mkdir(strcat(desPath, '02a_preproc'));
end
if ~exist(strcat(desPath, '02b_trial'), 'dir')
  mkdir(strcat(desPath, '02b_trial'));
end
if ~exist(strcat(desPath, '03_glm'), 'dir')
  mkdir(strcat(desPath, '03_glm'));
end
if ~exist(strcat(desPath, '04_xcorr'), 'dir')
  mkdir(strcat(desPath, '04_xcorr'));
end
if ~exist(strcat(desPath, '05a_wtc'), 'dir')
  mkdir(strcat(desPath, '05a_wtc'));
end
if ~exist(strcat(desPath, '05b_msc'), 'dir')
  mkdir(strcat(desPath, '05b_msc'));
end
if ~exist(strcat(desPath, '06a_pwelch'), 'dir')
  mkdir(strcat(desPath, '06a_pwelch'));
end
if ~exist(strcat(desPath, '07a_betaod'), 'dir')
  mkdir(strcat(desPath, '07a_betaod'));
end
if ~exist(strcat(desPath, '07b_wcod'), 'dir')
  mkdir(strcat(desPath, '07b_wcod'));
end

clear sessionStr numOfPart part newPaths

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
selection = false;

tmpPath = strcat(desPath, '01_raw_nirs/');

sessionList    = dir([tmpPath, 'CARE_d*a_01_raw_nirs_*.nirs']);
sessionList    = struct2cell(sessionList);
sessionList    = sessionList(1,:);
numOfSessions  = length(sessionList);

sessionNum     = zeros(1, numOfSessions);
sessionListCopy = sessionList;

for i=1:1:numOfSessions
  sessionListCopy{i} = strsplit(sessionList{i}, '01_raw_nirs_');
  sessionListCopy{i} = sessionListCopy{i}{end};
  sessionNum(i) = sscanf(sessionListCopy{i}, '%d.nirs');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(sessionListCopy, sprintf('%03d.nirs', i)), 1, 'first');
  filePath = [tmpPath, sessionList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
   fprintf('The session owners are:\n');
  for i=1:1:length(userList)
    fprintf('%d - %s\n', i, userList{i});
  end
  fprintf('\n');
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

clear tmpPath sessionListCopy userList match filePath cmdout attrib

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
    fprintf('[1] - Import/convert raw data\n');
    fprintf('[2] - Data preprocessing\n');
    fprintf('[3] - Conduct a generalized linear model regression with single subjects\n'); 
    fprintf('[4] - Estimation of cross-correlation\n');
    fprintf('[5] - Calculation of coherence using different approaches\n');
    fprintf('[6] - Power analysis (pWelch)\n');
    fprintf('[7] - Averaging over dyads\n');
    fprintf('[8] - Quit data processing\n\n');
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
        part = 5;
        selection = true;
      case 6
        part = 6;
        selection = true;
      case 7
        part = 7;
        selection = true;
      case 8
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
    tmpPath = strcat(desPath, '02b_trial/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_02b_trial_', sessionStr, ...
                          '.mat');
  case 3
    tmpPath = strcat(desPath, '02a_preproc/');
    fileNamePre = strcat(tmpPath, 'CARE_d*_02a_preproc_', sessionStr, ...
                         '.mat');
    tmpPath = strcat(desPath, '03_glm/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_03_glm_', sessionStr, ...
                          '.mat');
  case 4
    tmpPath = strcat(desPath, '02b_trial/');
    fileNamePre = strcat(tmpPath, 'CARE_d*_02b_trial_', sessionStr, ...
                         '.mat');
    tmpPath = strcat(desPath, '04_xcorr/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_04_xcorr_', sessionStr, '.mat');
  case 5
    tmpPath = strcat(desPath, '02a_preproc/');
    fileNamePre = strcat(tmpPath, 'CARE_d*_02a_preproc_', sessionStr, ...
                         '.mat');
    tmpPath = strcat(desPath, '05b_msc/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_05b_msc_', sessionStr, '.mat');
  case 6
    tmpPath = strcat(desPath, '02b_trial/');
    fileNamePre = strcat(tmpPath, 'CARE_d*_02b_trial_', sessionStr, ...
                         '.mat');
    tmpPath = strcat(desPath, '06a_pwelch/');
    fileNamePost = strcat(tmpPath, 'CARE_d*_06a_pwelch_', sessionStr, '.mat');
  case 7
    fileNamePre = 0;
  otherwise
    error('Something unexpected happend. part = %d is not defined' ...
          , part);
end

if ~isequal(fileNamePre, 0)
  if isempty(fileNamePre)
    numOfPrePart = fileNum;
  else
    fileListPre = dir(fileNamePre);
    if isempty(fileListPre)
      cprintf([1,0.5,0], ['\nSelected part [%d] can not be executed, no' ...
            ' input data available. \nPlease choose a previous part.\n'],...
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

  if strcmp(dyadsSpec, 'all')                                               % process all participants
    numOfPart = numOfPrePart;
  elseif strcmp(dyadsSpec, 'specific')                                      % process specific participants
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
  elseif strcmp(dyadsSpec, 'new')                                           % process only new participants
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
              fileListPost fileListPre numOfPostPart sessionList ...
              numOfFilessessionNum numOfSessions session numOfPart ...
              part sessionStr dyads tmpPath gsePath sdFile
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
else
  fprintf('\n');
  clear fileNamePost fileNamePre fileNum i numOfSources selection ...
        sourceList x y dyads sessionList sessionNum numOfSessions ...
        session dyadsSpec numOfFiles tmpPath sdFile
end

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
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[1] - Import/Convert raw data?</strong>\n');
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
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[2] - Data preprocessing?</strong>\n');
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
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[3] - Conduct a generalized linear model regression with single subjects?</strong>\n');
        fprintf('<strong>[4] - Estimation of cross-correlation?</strong>\n');
        fprintf('<strong>[5] - Calculation of coherence using different approaches?</strong>\n');
        fprintf('<strong>[6] - Power analysis (pWelch)?</strong>\n');
        fprintf('<strong>[7] - Averaging over dyads?</strong>\n');
        fprintf('<strong>[8] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 3
            selection = true;
            sessionStatus = true;
            sessionPart = 3;
          case 4
            selection = true;
            sessionStatus = true;
            sessionPart = 4;
          case 5
            selection = true;
            sessionStatus = true;
            sessionPart = 5;
          case 6
            selection = true;
            sessionStatus = true;
            sessionPart = 6;
          case 7
            selection = true;
            sessionStatus = true;
            sessionPart = 7;
          case 8
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 3
      CARE_main_3;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[4] - Estimation of cross-correlation?</strong>\n');
        fprintf('<strong>[5] - Calculation of coherence using different approaches?</strong>\n');
        fprintf('<strong>[6] - Power analysis (pWelch)?</strong>\n');
        fprintf('<strong>[7] - Averaging over dyads?</strong>\n');
        fprintf('<strong>[8] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 4
            selection = true;
            sessionStatus = true;
            sessionPart = 4;
          case 5
            selection = true;
            sessionStatus = true;
            sessionPart = 5;
          case 6
            selection = true;
            sessionStatus = true;
            sessionPart = 6;
          case 7
            selection = true;
            sessionStatus = true;
            sessionPart = 7;
          case 8
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 4
      CARE_main_4;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[5] - Calculation of coherence using different approaches?</strong>\n');
        fprintf('<strong>[6] - Power analysis (pWelch)?</strong>\n');
        fprintf('<strong>[7] - Averaging over dyads?</strong>\n');
        fprintf('<strong>[8] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 5
            selection = true;
            sessionStatus = true;
            sessionPart = 5;
          case 6
            selection = true;
            sessionStatus = true;
            sessionPart = 6;
          case 7
            selection = true;
            sessionStatus = true;
            sessionPart = 7;
          case 8
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 5
      CARE_main_5;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[6] - Power analysis (pWelch)?</strong>\n');
        fprintf('<strong>[7] - Averaging over dyads?</strong>\n');
        fprintf('<strong>[8] - Quit data processing?</strong>\n');
        x = input('\nSelect one of these options: ');
        switch x
          case 6
            selection = true;
            sessionStatus = true;
            sessionPart = 6;
          case 7
            selection = true;
            sessionStatus = true;
            sessionPart = 7;
          case 8
            selection = true;
            sessionStatus = false;
          otherwise
            selection = false;
            cprintf([1,0.5,0], 'Wrong input!\n');
        end
      end
    case 6
      CARE_main_6;
      selection = false;
      while selection == false
        fprintf('<strong>Continue data processing with:</strong>\n');
        fprintf('<strong>[7] - Averaging over dyads?</strong>\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 7;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end  
    case 7
      CARE_main_7;
      sessionStatus = false;
    otherwise
      sessionStatus = false;
  end
  fprintf('\n');
end

fprintf('<strong>Data processing finished.</strong>\n');
fprintf('<strong>Session will be closed.</strong>\n');

clear sessionStr numOfPart srcPath desPath gsePath sessionPart ...
      sessionStatus selection x
