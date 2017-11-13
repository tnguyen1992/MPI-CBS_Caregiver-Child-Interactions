function CARE_saveData( cfg, varargin )
% CARE_SAVEDATA stores the data of various structure elements (generally the
% CARE-datastructures) into a MAT_File.
%
% Use as
%   CARE_saveData( cfg, varargin )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/02_preproc/')
%   cfg.filename    = filename (default: 'CARE_d02_02_preproc')
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% SEE also SAVE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = CARE_getopt(cfg, 'desFolder', '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/02_preproc/');
filename    = CARE_getopt(cfg, 'filename', 'CARE_d02_02_preproc');
sessionStr  = CARE_getopt(cfg, 'sessionStr', '001');

% -------------------------------------------------------------------------
% Save data
% -------------------------------------------------------------------------
file_path = strcat(desFolder, filename, '_', sessionStr, '.mat');
inputElements = length(varargin);

if inputElements == 0
  error('No elements to save!');
elseif mod(inputElements, 2)
  error('Numbers of input are not even!');
else
  for i = 1:2:inputElements-1
    if ~isvarname(varargin{i})
      error('varargin{%d} is not a valid varname');
    else
      str = [varargin{i}, ' = varargin{i+1};'];
      eval(str);
    end
  end
end

if (~isempty(who('-regexp', '^data')))
  save(file_path, '-regexp','^data', '-v7.3');
elseif (~isempty(who('-regexp', '^cfg_')))
  save(file_path, '-regexp','^cfg_', '-v7.3');
end

end

