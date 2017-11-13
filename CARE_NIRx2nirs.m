function CARE_NIRx2nirs( cfg )
% CARE_NIRX2NIRS creates a *.nirs file for use in Homer2 from NIRx output
% data files (*.hdr, *.wl1, *.wl2) and a previously build SD file (*.SD), 
% which matches the source-detector layout used in the NIRx acquisition.
%
% To use this script, the user must first create an SD file. This can be
% done using CARE_CREATESDFILE.
%
% Use as:
%   CARE_NIRx2nirs( cfg )
%
% The configuration options are
%   cfg.dyadNum     = dyad description (i.e. 2)
%   cfg.srcPath     = location of NIRx output for both subjects of the dyad 
%   cfg.desPath     = memory location for the NIRS file (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/01_raw_nirs')
%   cfg.SDfile      = memory location of the *.SD file (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/CARE.SD')
%   cfg.sessionStr  = string of current session (default: '000')
%
% See also CARE_CREATESDFILE

% Copyright (C) 2017, Daniel Matthes, MPI CBS
% 
% Most of the code is taken from a function called NIRx2nirs from Rob J 
% Cooper, University College London, August 2013  and an edited version 
% by NIRx Medical Technologies, Apr2016 called NIRx2nirs_probeInfo_rotate.

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad        = CARE_getopt(cfg, 'dyad', []);
srcPath     = CARE_getopt(cfg, 'srcPath', []);
desPath     = CARE_getopt(cfg, 'gsePath', ...
            '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/01_raw_nirs/');
SDfile      = CARE_getopt(cfg, 'SDfile', ...
            '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/CARE.SD');
sessionStr  = CARE_getopt(cfg, 'sessionStr', '000');

if isempty(srcPath)
  error('No source path is specified!');
end

if isempty(dyad)
  error('No file prefix is specified!');
end

% -------------------------------------------------------------------------
% Build filenames
% -------------------------------------------------------------------------
Sub1SrcDir  = strcat(srcPath, sprintf('CARE_%02d', dyad), '/Subject1/');
Sub2SrcDir  = strcat(srcPath, sprintf('CARE_%02d', dyad), '/Subject2/');
Sub1DesFile = strcat(desPath, sprintf('CARE_d%02da_01_raw_nirs_', dyad), ...
                     sessionStr, '.nirs');
Sub2DesFile = strcat(desPath, sprintf('CARE_d%02db_01_raw_nirs_', dyad), ...
                     sessionStr, '.nirs');

% -------------------------------------------------------------------------
% Load SD file
% -------------------------------------------------------------------------
load(SDfile, '-mat', 'SD');

% -------------------------------------------------------------------------
% Check if NIRx output exist
% -------------------------------------------------------------------------
if ~exist(Sub1SrcDir, 'dir')
  error('Directory: %s does not exist', Sub1SrcDir);
else
  Sub1_wl1File = strcat(Sub1SrcDir, sprintf('CARE_%02d', dyad), '.wl1');
  Sub1_wl2File = strcat(Sub1SrcDir, sprintf('CARE_%02d', dyad), '.wl2');
  Sub1_hdrFile = strcat(Sub1SrcDir, sprintf('CARE_%02d', dyad), '.hdr');
  if ~exist(Sub1_wl1File, 'file')
    error('wl1 file: %s does not exist', Sub1_wl1File);
  end
  if ~exist(Sub1_wl2File, 'file')
    error('wl2 file: %s does not exist', Sub1_wl2File);
  end
  if ~exist(Sub1_hdrFile, 'file')
    error('hdr file: %s does not exist', Sub1_hdrFile);
  end
end
                   
if ~exist(Sub2SrcDir, 'dir')
  error('Directory: %s does not exist', Sub2SrcDir);
else
  Sub2_wl1File = strcat(Sub2SrcDir, sprintf('CARE_%02d', dyad), '.wl1');
  Sub2_wl2File = strcat(Sub2SrcDir, sprintf('CARE_%02d', dyad), '.wl2');
  Sub2_hdrFile = strcat(Sub2SrcDir, sprintf('CARE_%02d', dyad), '.hdr');
  if ~exist(Sub2_wl1File, 'file')
    error('wl1 file: %s does not exist', Sub2_wl1File);
  end
  if ~exist(Sub2_wl2File, 'file')
    error('wl2 file: %s does not exist', Sub2_wl2File);
  end
  if ~exist(Sub2_hdrFile, 'file')
    error('hdr file: %s does not exist', Sub2_hdrFile);
  end
end

% -------------------------------------------------------------------------
% Convert and export data
% -------------------------------------------------------------------------
fprintf('Converting data from NIRx to NIRS for dyad %d, subject 1...\n', dyad);
convertData(Sub1DesFile, Sub1_wl1File, Sub1_wl2File, Sub1_hdrFile, SD);
fprintf('Converting data from NIRx to NIRS for dyad %d, subject 2...\n', dyad);
convertData(Sub2DesFile, Sub2_wl1File, Sub2_wl2File, Sub2_hdrFile, SD);

end

function convertData (desFile, wl1File, wl2File, hdrFile, SD)
wl1 = load(wl1File);                                                        % load .wl1 file
wl2 = load(wl2File);                                                        % load .wl2 file

d = [wl1 wl2];                                                              % d matrix from .wl1 and .wl2 files

fid = fopen(hdrFile);
tmp = textscan(fid,'%s','delimiter','\n');                                  % this just reads every line
hdr_str = tmp{1};
fclose(fid);

keyword = 'Sources=';                                                       % find number of sources
tmp = hdr_str{contains(hdr_str, keyword)};
NIRxSources = str2double(tmp(length(keyword)+1:end));

keyword = 'Detectors=';                                                     % find number of detectors
tmp = hdr_str{contains(hdr_str, keyword)};
NIRxDetectors = str2double(tmp(length(keyword)+1:end));

if NIRxSources < SD.nSrcs || NIRxDetectors < SD.nDets                       % Compare number of sources and detectors to SD file
   error('The number of sources and detectors in the NIRx files does not match your SD file...');
end

keyword = 'SamplingRate=';                                                  % find Sample rate
tmp = hdr_str{contains(hdr_str, keyword)};
fs = str2double(tmp(length(keyword)+1:end));

% find Active Source-Detector pairs
keyword = 'S-D-Mask="#';
ind = find(contains(hdr_str,keyword)) + 1 ;                                
ind2 = find(contains(hdr_str(ind+1:end),'#')) - 1;
ind2 = ind + ind2(1);
sd_ind = cell2mat(cellfun(@str2num, hdr_str(ind:ind2), 'UniformOutput', 0));
sd_ind = sd_ind';
sd_ind = logical([sd_ind(:);sd_ind(:)]);
d = d(:, sd_ind);

% find NaN values in the recorded data -> channels should be pruned as 'bad'
for i=1:size(d,2)
    if nonzeros(isnan(d(:,i)))
        SD.MeasListAct(i) = 0;
    end
end

% find event markers and build s vector
keyword = 'Events="#';
ind = find(contains(hdr_str,keyword)) + 1 ;                                
ind2 = find(contains(hdr_str(ind+1:end),'#')) - 1;
ind2 = ind + ind2(1);
events = cell2mat(cellfun(@str2num, hdr_str(ind:ind2), 'UniformOutput', 0));
events = events(:,2:3);
markertypes = unique(events(:,1));
s = zeros(length(d),length(markertypes));
for i = 1:length(markertypes)
    s(events(events(:,1) == markertypes(i), 2), i) = 1;
end

% create t, aux varibles
aux = ones(length(d),1);                                                    %#ok<NASGU>
t = 0:1/fs:length(d)/fs - 1/fs;
t = t';                                                                     %#ok<NASGU>

fprintf('Saving NIRS file: %s...\n', desFile);
save(desFile, 'd', 's', 't', 'aux', 'SD');
fprintf('Data stored!\n\n');

end
