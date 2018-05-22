function CARE_writeTbl(cfg, data)
% CARE_WRITETBL writes the output of either XuCuiQC or pulseQC of a 
% specific dyad during preprocessimg to the associated files.
%
% Use as
%   CARE_writeTbl( cfg, data )
%
% The input data hast to be either from CARE_PREPROCESSING
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01826/eegData/DualEEG_JAI_processedData/00_settings/')
%   cfg.dyad        = number of dyad
%   cfg.type        = type of documentation file (options: settings, XuCuiQC, pulseQC)
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% SEE also CARE_PREPROCESSING

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = CARE_getopt(cfg, 'desFolder', ...
          '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/00_settings/');
dyad        = CARE_getopt(cfg, 'dyad', []);
type        = CARE_getopt(cfg, 'type', []);
sessionStr  = CARE_getopt(cfg, 'sessionStr', []);

if isempty(dyad)
  error('cfg.dyad has to be specified');
end

if isempty(type)
  error(['cfg.type has to be specified. It could be either ''XuCuiQC'' '...
         'or ''pulseQC''.']);
end

if isempty(sessionStr)
  error('cfg.sessionNum has to be specified');
end

% -------------------------------------------------------------------------
% Determine bad channel numbers
% -------------------------------------------------------------------------
if strcmp(type, 'XuCuiQC')
  badChan_1(1:16) = false;
  if isfield(data.sub1, 'badChannelsCui')
    badChan_1(data.sub1.badChannelsCui) = true;
  end
  badChan_2(1:16) = false;
  if isfield(data.sub2, 'badChannelsCui')
    badChan_2(data.sub2.badChannelsCui) = true;
  end
elseif strcmp(type, 'pulseQC')
  badChan_1(1:16) = false;
  if isfield(data.sub1, 'badChannelsPulse')
    badChan_1(data.sub1.badChannelsPulse) = true;
  end
  badChan_2(1:16) = false;
  if isfield(data.sub2, 'badChannelsPulse')
    badChan_2(data.sub2.badChannelsPulse) = true;
  end
end

% -------------------------------------------------------------------------
% Generate output file, if necessary
% -------------------------------------------------------------------------
file_path = [desFolder sprintf('%s_%s', type, sessionStr) '.xls'];

if ~(exist(file_path, 'file') == 2)                                         % check if file already exist
  cfg = [];
  cfg.desFolder   = desFolder;
  cfg.type        = type;
  cfg.sessionStr  = sessionStr;
  
  CARE_createTbl(cfg);                                                      % create file
end

% -------------------------------------------------------------------------
% Update table
% -------------------------------------------------------------------------
T = readtable(file_path);
delete(file_path);
warning off;
T.dyad(dyad)    = dyad;
T(dyad, 2:end)  = num2cell([badChan_1 badChan_2]);
warning on;
writetable(T, file_path);

end

