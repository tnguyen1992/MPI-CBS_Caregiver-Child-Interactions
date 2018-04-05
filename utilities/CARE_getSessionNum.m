function [ num ] = CARE_getSessionNum( cfg )
% CARE_GETSESSIONNUM determines the highest session number of a specific 
% data file 
%
% Use as
%   [ num ] = CARE_getSessionNum( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/')
%   cfg.subFolder   = name of subfolder (default: '01_raw_nirs/')
%   cfg.filename    = filename (default: 'CARE_d01b_01_raw_nirs')

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = CARE_getopt(cfg, 'desFolder', '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/');
subFolder   = CARE_getopt(cfg, 'subFolder', '01_raw_nirs/');
filename    = CARE_getopt(cfg, 'filename', 'CARE_d01b_01_raw_nirs');

% -------------------------------------------------------------------------
% Estimate highest session number
% -------------------------------------------------------------------------
file_path = strcat(desFolder, subFolder, filename, '_*.*');

sessionList    = dir(file_path);
if isempty(sessionList)
  num = 0;
else
  sessionList   = struct2cell(sessionList);
  sessionList   = sessionList(1,:);
  numOfSessions = length(sessionList);

  sessionNum    = zeros(1, numOfSessions);
  filenameStr   = strcat(filename, '_%d.*');
  
  for i=1:1:numOfSessions
    sessionNum(i) = sscanf(sessionList{i}, filenameStr);
  end

  num = max(sessionNum);
end

end

