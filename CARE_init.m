% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/:%s/easyplot:%s/external:%s/functions:%s/general:%s/utilities', ...
        filepath, filepath, filepath, filepath, filepath, filepath));

clear filepath