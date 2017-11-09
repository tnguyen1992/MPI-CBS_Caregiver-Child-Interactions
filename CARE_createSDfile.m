function CARE_createSDfile( cfg )
% CARE_CREATESDFILE creates a sources/detectors definition file (SD-File)
% without using SDgui
%
% Use as
%   CARE_createSDfile( cfg )
%
% The configuration options are
%   cfg.srcPath     = path to *_probeInfo.mat and *_config.txt
%   cfg.dyad        = dyad description (i.e. 'CARE_02')
%   cfg.gsePath     = memory location of *.SD file
%
% ToDo: Transform coordinates from probeInfo to homer2 compatible
% coordinate system
%
% See also SDgui

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
srcPath = CARE_getopt(cfg, 'srcPath', []);

gsePath = CARE_getopt(cfg, 'gsePath', ...
          '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/');

dyad  = CARE_getopt(cfg, 'dyad', []);
        
if isempty(srcPath)
  error('No source path is specified!');
end

if isempty(dyad)
  error('No file prefix is specified!');
end

% -------------------------------------------------------------------------
% Create empty SD structure
% -------------------------------------------------------------------------
SD              = struct;
SD.MeasList     = [];
SD.Lambda       = [];
SD.SrcPos       = [];
SD.DetPos       = [];
SD.DummyPos     = [];
SD.nSrcs        = 0;
SD.nDets        = 0;
SD.nDummys      = 0;
SD.SpringList   = [];
SD.AnchorList   = cell(0,0);
SD.SrcMap       = [];
SD.SpatialUnit  = 'mm';
SD.xmin         = 0;
SD.xmax         = 0;
SD.ymin         = 0;
SD.ymax         = 0;
SD.MeasListAct  = [];
SD.MeasListVis  = [];
SD.auxChannels  = [];
SD.vrnum        = {2.3, 0};

% -------------------------------------------------------------------------
% Import probeInfo.mat and config.txt
% -------------------------------------------------------------------------
probeFile = strcat(srcPath, dyad, '/Subject1/', dyad, ...
                  '_probeInfo.mat');
txtFile   = strcat(srcPath, dyad, '/Subject1/', dyad, ...
                  '_config.txt');

if ~exist(probeFile, 'file')
  error('%s_probeInfo.mat not found. Check cfg.srcPath and cfg.dyad definition', ...
        dyad);
else
  load(probeFile, 'probeInfo');
end

if ~exist(txtFile, 'file')
  error('%s_config.txt not found. Check cfg.srcPath and cfg.dyad definition', ...
        dyad);
else
  configTxt = fileread(txtFile);
  begchar = strfind(configTxt, 'Wavelengths');
  endchar = strfind(configTxt, ';');
  number  = find(endchar > begchar, 1, 'first');
  endchar = endchar(number);
  eval(configTxt(begchar:endchar));
end

% -------------------------------------------------------------------------
% Fill SD structure
% -------------------------------------------------------------------------
fprintf('Sources/Detectors definitions will be created...\n');
n = probeInfo.probes.nDetector0;

SD.Lambda               = Wavelengths;
SD.SrcPos               = probeInfo.probes.coords_s3;
SD.DetPos               = probeInfo.probes.coords_d3;
SD.nSrcs                = probeInfo.probes.nSource0;
SD.nDets                = probeInfo.probes.nDetector0;
SD.SrcMap(1, 1:n)       = 1:2:2*n-1;
SD.SrcMap(2, 1:n)       = 2:2:2*n;
SD.MeasListAct          = ones(32,1);
SD.MeasListVis          = ones(32,1);
SD.MeasList(1:4*n, 1:2) = [probeInfo.probes.index_c; probeInfo.probes.index_c];
SD.MeasList(1:4*n, 3)   = ones(4*n, 1);
SD.MeasList(1:4*n, 4)   = [ones(2*n, 1); 2*ones(2*n, 1)];                   %#ok<STRNU>

% -------------------------------------------------------------------------
% Save SD structure
% -------------------------------------------------------------------------
dyad = dyad(isletter(dyad));
filename = strcat(gsePath, dyad, '.SD');
fprintf('Sources/Detectors definitions will be stored in:\n');
fprintf('%s...\n', filename);
save(filename, 'SD', '-mat');
fprintf('Data stored!\n\n');
