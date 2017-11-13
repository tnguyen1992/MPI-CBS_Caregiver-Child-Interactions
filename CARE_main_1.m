%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg         = [];                                                         
  sessionStr  = sprintf('%03d', CARE_getSessionNum( cfg ) + 1);             % calculate next session number
end

if ~exist('srcPath', 'var')
  srcPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/';         % source path to raw data
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/';   % destination path for processed data  
end

if ~exist('gsePath', 'var')
  gsePath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/'; % general settings path
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath 'CARE_*']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart       = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, 'CARE_%d');
  end
end

%% import data
%  If no *.nirs file is existent, NIRx data will be imported, converted 
%  into a homer2 compatible format and exported into an *.nirs file.
%  Otherwise the *.nirs file will simply be copied to 'desPath'/01_raw_nirs

for i = numOfPart
  srcFolder   = strcat(srcPath, sprintf('CARE_%02d/', i));
  srcNirsSub1 = sprintf('Subject1/CARE_%02d.nirs', i);
  srcNirsSub2 = sprintf('Subject2/CARE_%02d.nirs', i);
  fileSub1    = strcat(srcFolder, srcNirsSub1);
  fileSub2    = strcat(srcFolder, srcNirsSub2);
  desFolder   = strcat(desPath, '01_raw_nirs/'); 
  
  if exist(fileSub1, 'file') && exist(fileSub1, 'file')
    fileDesSub1 = strcat(desFolder, sprintf('CARE_d%02da_01_raw_nirs_', ...
                         i), sessionStr, '.nirs');
    fprintf('Copying NIRS data for dyad %d, subject 1...\n', i);
    copyfile(fileSub1, fileDesSub1);
    fprintf('Data copied!\n\n');
    fileDesSub2 = strcat(desFolder, sprintf('CARE_d%02db_01_raw_nirs_', ...
                         i), sessionStr, '.nirs');
    fprintf('Copying NIRS data for dyad %d, subject 2...\n', i);
    copyfile(fileSub2, fileDesSub2);
    fprintf('Data copied!\n\n');
  else
    cfg = [];
    cfg.dyad        = i;
    cfg.srcPath     = srcPath;
    cfg.desPath     = desFolder;
    cfg.SDfile      = strcat(gsePath, 'CARE.SD');
    cfg.sessionStr  = sessionStr;
    
    CARE_NIRx2nirs( cfg );
  end
end

%% clear workspace
clear cfg i desFolder srcFolder srcNirsSub1 srcNirsSub2 fileSub1 ...
      fileSub2 fileDesSub1 fileDesSub2
