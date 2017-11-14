%% check if basic variables are defined
if ~exist('srcPath', 'var')
  srcPath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/';         % source path to raw data
end

if ~exist('gsePath', 'var')
  gsePath     = '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/'; % general settings path
end

%% generate sources/detectors definiton file and save it in gsePath location

cfg = [];
cfg.dyad    = 'CARE_02';
cfg.srcPath = srcPath;
cfg.gsePath = gsePath;

CARE_createSDfile( cfg );

%% clear workspace
clear cfg