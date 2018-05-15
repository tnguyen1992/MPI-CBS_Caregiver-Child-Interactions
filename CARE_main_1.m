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

if ~exist('gsePath', 'var')
  if strcmp(prefix, 'CARE')
    gsePath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/';   % general settings path
  else
    gsePath = '/data/pt_01958/fnirsData/DualfNIRS_DCARE_generalSettings/';
  end
end

if ~exist('sessionStr', 'var')
  cfg           = []; 
  cfg.desFolder = desPath;
  cfg.subFolder = '01_raw_nirs/';
  cfg.filename  = [prefix, '_d02b_01_raw_nirs'];
  sessionStr    = sprintf('%03d', CARE_getSessionNum( cfg ) + 1);           % calculate next session number
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, prefix, '_*']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart       = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, [prefix, '_%d']);
  end
end

%% part 1
% import data
% If no *.nirs file is existent, NIRx data will be imported, converted 
% into a homer2 compatible format and exported into an *.nirs file.
% Otherwise the *.nirs file will simply be copied to 'desPath'/01_raw_nirs

cprintf([0,0.6,0], '<strong>[1] - Import/convert raw data</strong>\n');
fprintf('\n');

for i = numOfPart
  srcFolder   = strcat(srcPath, sprintf([prefix, '_%02d/'], i));
  srcNirsSub1 = sprintf(['Subject1/', prefix, '_%02d.nirs'], i);
  srcNirsSub2 = sprintf(['Subject2/', prefix, '_%02d.nirs'], i);
  fileSub1    = strcat(srcFolder, srcNirsSub1);
  fileSub2    = strcat(srcFolder, srcNirsSub2);
  desFolder   = strcat(desPath, '01_raw_nirs/'); 
  
  if exist(fileSub1, 'file') && exist(fileSub1, 'file')
    fileDesSub1 = strcat(desFolder, sprintf([prefix, ...
                        '_d%02da_01_raw_nirs_'], i), sessionStr, '.nirs');
    fprintf('<strong>Copying NIRS data for dyad %d, subject 1...</strong>\n', i);
    copyfile(fileSub1, fileDesSub1);
    fprintf('Data copied!\n\n');
    fileDesSub2 = strcat(desFolder, sprintf([prefix, ...
                        '_d%02db_01_raw_nirs_'], i), sessionStr, '.nirs');
    fprintf('<strong>Copying NIRS data for dyad %d, subject 2...</strong>\n', i);
    copyfile(fileSub2, fileDesSub2);
    fprintf('Data copied!\n\n');
  else
    cfg = [];
    cfg.dyadNum     = i;
    cfg.srcPath     = srcPath;
    cfg.desPath     = desFolder;
    cfg.SDfile      = strcat(gsePath, prefix, '.SD');
    cfg.sessionStr  = sessionStr;
    
    CARE_NIRx2nirs( cfg );
  end
end

%% clear workspace
clear cfg i desFolder srcFolder srcNirsSub1 srcNirsSub2 fileSub1 ...
      fileSub2 fileDesSub1 fileDesSub2
