function CARE_loadData( cfg )
% CARE_LOADDATA loads a specific CARE data files
%
% Use as
%   CARE_loadData( cfg )
%
% The configuration options are
%   cfg.srcFolder   = source folder (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/01_raw_nirs/')
%   cfg.filename    = filename (default: 'CARE_p02a_01_raw_nirs')
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% SEE also LOAD

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
srcFolder   = CARE_getopt(cfg, 'srcFolder', '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/01_raw_nirs/');
filename    = CARE_getopt(cfg, 'filename', 'CARE_d01a_01_raw');
sessionStr  = CARE_getopt(cfg, 'sessionStr', '001');

% -------------------------------------------------------------------------
% Load data and assign it to the base workspace
% -------------------------------------------------------------------------
file_path = strcat(srcFolder, filename, '_', sessionStr, '.nirs');
if ~exist(file_path, 'file')
  file_path = strcat(srcFolder, filename, '_', sessionStr, '.mat');
end

if exist(file_path, 'file')
  newData = load(file_path, '-mat');
  vars = fieldnames(newData);
  for i = 1:length(vars)
    assignin('base', vars{i}, newData.(vars{i}));
  end
else
  error('File %s does not exist.', file_path);
end

end

