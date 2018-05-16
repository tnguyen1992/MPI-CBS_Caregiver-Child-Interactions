function CARE_createTbl( cfg )
% CARE_CREATETBL generates '*.xls' files for the documentation of the data 
% processing process. Currently only one type of doc file is supported.
%
% Use as
%   CARE_createTbl( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/00_settings/')
%   cfg.type        = type of documentation file (options: 'settings')
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% Explanation:
%   type settings - holds information about the selectable value: CohPOI

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = CARE_getopt(cfg, 'desFolder', ...
          '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/00_settings/');
type        = CARE_getopt(cfg, 'type', []);
sessionStr  = CARE_getopt(cfg, 'sessionStr', []);

if isempty(type)
  error('cfg.type has to be specified. It could only be ''settings''.');
end

if isempty(sessionStr)
  error('cfg.sessionStr has to be specified');
end

% -------------------------------------------------------------------------
% Create table
% -------------------------------------------------------------------------
switch type
  case 'settings'
    T = table(1,{'unknown'}, {'unknown'}, {'unknown'}, {'unknown'});
    T.Properties.VariableNames = {'dyad', 'XuCuiQC', 'pulseQC', 'CohPOI', 'ConsCOI'};
    filepath = [desFolder type '_' sessionStr '.xls'];
    writetable(T, filepath);
  otherwise
    error('cfg.type is not valid. Please use ''settings''.');
end

end
