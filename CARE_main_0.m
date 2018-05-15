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

if ~exist('gsePath', 'var')
  if strcmp(prefix, 'CARE')
    gsePath = '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/';   % general settings path
  else
    gsePath = '/data/pt_01958/fnirsData/DualfNIRS_DCARE_generalSettings/';
  end
end

%% part 0
% generate sources/detectors definiton file and save it in gsePath location

cprintf([0,0.6,0], '<strong>[0] - Build sources/detectors definition</strong>\n');
fprintf('\n');

cfg = [];
cfg.dyad    = [prefix, '_02'];
cfg.srcPath = srcPath;
cfg.gsePath = gsePath;

CARE_createSDfile( cfg );

%% clear workspace
clear cfg