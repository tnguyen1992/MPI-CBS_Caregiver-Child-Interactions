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
%   cfg.prefix      = CARE or DCARE, defines raw data file prefix (default: CARE)
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
dyadNum     = CARE_getopt(cfg, 'dyadNum', []);
prefix      = CARE_getopt(cfg, 'prefix', 'CARE');
srcPath     = CARE_getopt(cfg, 'srcPath', []);
desPath     = CARE_getopt(cfg, 'desPath', ...
            '/data/pt_01867/fnirsData/DualfNIRS_CARE_processedData/01_raw_nirs/');
SDfile      = CARE_getopt(cfg, 'SDfile', ...
            '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/CARE.SD');
sessionStr  = CARE_getopt(cfg, 'sessionStr', '000');

if isempty(srcPath)
  error('No source path is specified!');
end

if isempty(dyadNum)
  error('No file prefix is specified!');
end

if ~(strcmp(prefix, 'CARE') || strcmp(prefix, 'DCARE'))
  error('cfg.prefix have to be either CARE or DCARE');
end

% -------------------------------------------------------------------------
% Build filenames
% -------------------------------------------------------------------------
Sub1SrcDir  = strcat(srcPath, sprintf([prefix, '_%02d'], dyadNum), '/Subject1/');
Sub2SrcDir  = strcat(srcPath, sprintf([prefix, '_%02d'], dyadNum), '/Subject2/');
Sub1DesFile = strcat(desPath, sprintf([prefix, '_d%02da_01_raw_nirs_'], ...
                      dyadNum), sessionStr, '.nirs');
Sub2DesFile = strcat(desPath, sprintf([prefix, '_d%02db_01_raw_nirs_'], ...
                      dyadNum), sessionStr, '.nirs');

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
  Sub1_wl1File = strcat(Sub1SrcDir, sprintf([prefix, '_%02d'], dyadNum), '.wl1');
  Sub1_wl2File = strcat(Sub1SrcDir, sprintf([prefix, '_%02d'], dyadNum), '.wl2');
  Sub1_hdrFile = strcat(Sub1SrcDir, sprintf([prefix, '_%02d'], dyadNum), '.hdr');
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
  Sub2_wl1File = strcat(Sub2SrcDir, sprintf([prefix, '_%02d'], dyadNum), '.wl1');
  Sub2_wl2File = strcat(Sub2SrcDir, sprintf([prefix, '_%02d'], dyadNum), '.wl2');
  Sub2_hdrFile = strcat(Sub2SrcDir, sprintf([prefix, '_%02d'], dyadNum), '.hdr');
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
fprintf('<strong>Converting data from NIRx to NIRS for dyad %d, subject 1...</strong>\n',...
        dyadNum);
convertData(Sub1DesFile, Sub1_wl1File, Sub1_wl2File, Sub1_hdrFile, SD,...
            prefix, dyadNum);
fprintf('<strong>Converting data from NIRx to NIRS for dyad %d, subject 2...</strong>\n',...
        dyadNum);
convertData(Sub2DesFile, Sub2_wl1File, Sub2_wl2File, Sub2_hdrFile, SD,...
            prefix, dyadNum);

end

% -------------------------------------------------------------------------
% SUBFUNCTION data convertion
% -------------------------------------------------------------------------
function convertData (desFile, wl1File, wl2File, hdrFile, SD, pf, num)
wl1 = load(wl1File);                                                        % load .wl1 file
wl2 = load(wl2File);                                                        % load .wl2 file

d = [wl1 wl2];                                                              % d matrix from .wl1 and .wl2 files

fid = fopen(hdrFile);
tmp = textscan(fid,'%s','delimiter','\n');                                  % this just reads every line
hdr_str = tmp{1};
fclose(fid);

keyword = 'Sources=';                                                       % find number of sources
tmp = hdr_str{strncmp(hdr_str, keyword, length(keyword))};
NIRxSources = str2double(tmp(length(keyword)+1:end));

keyword = 'Detectors=';                                                     % find number of detectors
tmp = hdr_str{strncmp(hdr_str, keyword, length(keyword))};
NIRxDetectors = str2double(tmp(length(keyword)+1:end));

if NIRxSources < SD.nSrcs || NIRxDetectors < SD.nDets                       % Compare number of sources and detectors to SD file
   error('The number of sources and detectors in the NIRx files does not match your SD file...');
end

keyword = 'SamplingRate=';                                                  % find Sample rate
tmp = hdr_str{strncmp(hdr_str, keyword, 13)};
fs = str2double(tmp(length(keyword)+1:end));

% find Active Source-Detector pairs
keyword = 'S-D-Mask="#';
ind = find(strncmp(hdr_str, keyword, length(keyword))) + 1;
ind2 = find(strncmp(hdr_str(ind+1:end), '#', 1)) - 1;
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
ind = find(strncmp(hdr_str, keyword, length(keyword))) + 1;
ind2 = find(strncmp(hdr_str(ind+1:end), '#', 1)) - 1;
ind2 = ind + ind2(1);
events = cell2mat(cellfun(@str2num, hdr_str(ind:ind2), 'UniformOutput', 0));
events = events(:,2:3);
if strcmp(pf, 'CARE')
  if num < 7                                                                %  correction of markers for dyads until number 6
    events = correctEvents( events );
  end
end
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

% -------------------------------------------------------------------------
% SUBFUNCTION adapts the markers for dyads until number 6 to the current
% definition (CARE specific)
% -------------------------------------------------------------------------
function events = correctEvents( events )

events = events((events(:,1) ~= 13),:);                                     % remove all markers 13 from the list

for i = 2:1:size(events, 1)
  if(events(i,1) == 10)
    events(i-1, 2) = events(i, 2);                                          % events 11, 12 are starting when the following marker 10 appears
  elseif(events(i,1) > 13)
    events(i,1) = events(i,1) - 1;                                          % substitute marker 14 and 15 with 13 and 14
  end
end

events = events((events(:,1) ~= 10),:);                                     % remove all markers 10 from the list

end
