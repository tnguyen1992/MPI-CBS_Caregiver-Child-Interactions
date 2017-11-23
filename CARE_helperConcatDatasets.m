function CARE_helperConcatDatasets( cfg )
% CARE_HELPERCONCATDATASETS was initially developed to concatenate the data
% in dyad 9, where recording was interrupted. This function can be used 
% with some restrictions for future dyads as well. First, there has to be
% only one interruption. Second, the files produced during the second 
% half of recording has to be labeled with '_2' in addition to the general 
% filename.
%
% IMPORTANT: Please read the guideline below, before calling this function.
%
% Use as
%   CARE_helperConcatDatasets( cfg )
%
% The configuration options are 
%   cfg.dyad = dyad string (default: 'CARE_09');
%
% Guideline:
%   * Copy CARE_XX.hdr to Copy CARE_XX.hdr.org
%   * Rename CARE_XX_2.hdr to CARE_XX_2.hdr.org
%   * Run this function (output will be generated in working directory to
%     avoid the manipulation of the original data)
%   * Copy CARE_XX.nirs.sub1 to /data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/CARE_XX/Subject1/CARE_XX.nirs
%   * Copy CARE_XX.nirs.sub2 to /data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/CARE_XX/Subject2/CARE_XX.nirs
%   * Add the additional events in hdrX.mat into the associated section in 
%     CARE_XX.hdr for both subjects
%   * NOTE: There will be slightly differences in the timestamps for the 
%     first decimal place which can be ignored, since the timestamps from
%     the *.hdr file are not used for the data processing
%
% SEE also CARE_NIRX2NIRS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
dyad = CARE_getopt(cfg, 'dyad', 'CARE_09');                                 
dyadNum = sscanf(dyad, 'CARE_%d');                                          % extract the number of the dyad

% -------------------------------------------------------------------------
% General definitions
% -------------------------------------------------------------------------
srcPath = strcat('/data/pt_01867/fnirsData/DualfNIRS_CARE_rawData/', ...    % specify the source path
          dyad, '/');
SDfile = '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/CARE.SD'; % specify the path to the *.SD file

% -------------------------------------------------------------------------
% Load SD file
% -------------------------------------------------------------------------
load(SDfile, '-mat', 'SD');

% -----------------------------------------------------------------------
% Do NIRx2nirs conversion for both datasets and both subjects
% Generate *.nirs files for the concatenated datasets
% Generate hdr*.mat files which including the complete event values of the 
% whole recording (for *.hdr manipulation)
% -----------------------------------------------------------------------
for i = 1:1:2
  switch i
    case 1
      subject = 'Subject1/';
    case 2
      subject = 'Subject2/';
  end
  
  % -----------------------------------------------------------------------
  % Build filenames
  % -----------------------------------------------------------------------
  wl1File_1 = strcat(srcPath, subject, dyad, '.wl1');
  wl1File_2 = strcat(srcPath, subject, dyad, '_2.wl1');
  wl2File_1 = strcat(srcPath, subject, dyad, '.wl2');
  wl2File_2 = strcat(srcPath, subject, dyad, '_2.wl2');
  hdrFile_1 = strcat(srcPath, subject, dyad, '.hdr.org');
  hdrFile_2 = strcat(srcPath, subject, dyad, '_2.hdr.org');
  
  if ~exist(wl1File_1, 'file')                                              % throw errors if files doesn't exist
    error('wl1 file: %s does not exist', wl1File_1);
  end
  if ~exist(wl1File_2, 'file')
    error('wl1 file: %s does not exist', wl1File_2);
  end
  if ~exist(wl2File_1, 'file')
    error('wl2 file: %s does not exist', wl2File_1);
  end
  if ~exist(wl2File_2, 'file')
    error('wl2 file: %s does not exist', wl2File_2);
  end
  if ~exist(hdrFile_1, 'file')
    error('hdr file: %s does not exist', hdrFile_1);
  end
  if ~exist(hdrFile_2, 'file')
    error('hdr file: %s does not exist', hdrFile_2);
  end
  
  % -----------------------------------------------------------------------
  % Convert data
  % -----------------------------------------------------------------------
  [d1, s1, t1, aux1, m1] = convertData (wl1File_1, wl2File_1, hdrFile_1,... % convert the data of the first recording half
                           SD, dyadNum);
  [d2, s2, t2, aux2, m2] = convertData (wl1File_2, wl2File_2, hdrFile_2,... % convert the data of the second recording half (NIRX2nirs) 
                           SD, dyadNum);
  
  % -----------------------------------------------------------------------
  % Concatenate data
  % -----------------------------------------------------------------------
  d1Length = length(t1);                                                    % estimate the data length of the first half
    
  d = [d1; d2];                                                             % concatenate the data matrices
  t2(:) = t2(:) + t1(d1Length) + t1(1);                                     % add the duration of first half to the timestamps of the second half
  t = [t1; t2];                                                             % concatenate the time vectors
  aux = [aux1; aux2];                                                       %#ok<NASGU> % concatenate the aux matricies
  
  m = unique([m1; m2]);                                                     % estimate unique event markers
  s = zeros(length(d), length(m));                                          % generate a empty s matrix
  
  for j=1:1:length(m1)                                                      % put the columns of s1 matrix into the combined s matrix
    s(1:d1Length, ismember(m, m1(j))) = s1(:,j);
  end
  
  for j=1:1:length(m2)                                                      % put the columns of s2 matrix into the combined s matrix
    s(d1Length+1:end, ismember(m, m2(j))) = s2(:,j);
  end
  
  [row, col] = find(ismember(s,1));                                         % estimate locations of event markers in the combined s matrix
  [row,idx] = sort(row);                                                    % sort rows in ascending order
  col = col(idx);                                                           % adapt the order of the columns
  
  event = {length(row), 3};                                                 % build a empty event cell table
  for j=1:1:length(row)
    event{j,1} = sprintf('%.2f', round(t(row(j)), 2));                      % add the timestamps of the events to the first column
    event{j,2} = sprintf('%.2d', m(col(j)));                                % add the event numbers to the second column
    event{j,3} = sprintf('%.2d', row(j));                                   % add the sample numbers of the events to the third column
  end
  
  t1max = sprintf('%.2f', max(t1));                                         %#ok<NASGU>
  
  % -----------------------------------------------------------------------
  % Export data
  % -----------------------------------------------------------------------
  switch i
    case 1
      desFile = strcat(dyad, '.nirs', '.sub1');
      save(desFile, 'd', 's', 't', 'aux', 'SD');                            % save the concatenated dataset
      save('hdr1.mat', 'event', 'd1Length', 't1max');                       % save the event marker table
    case 2
      desFile = strcat(dyad, '.nirs', '.sub2');
      save(desFile, 'd', 's', 't', 'aux', 'SD');                            % save the concatenated dataset
      save('hdr2.mat', 'event', 'd1Length', 't1max');                       % save the event marker table
  end  
end

end

% -------------------------------------------------------------------------
% SUBFUNCTION data convertion (adapted from CARE_NIRS2NIRS)
% -------------------------------------------------------------------------
function [d, s, t, aux, markertypes] = convertData (wl1File, wl2File, hdrFile, SD, num)
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
if num < 7                                                                  %  correction of markers for dyads until number 6
  events = correctEvents( events );
end
markertypes = unique(events(:,1));
s = zeros(length(d),length(markertypes));
for i = 1:length(markertypes)
    s(events(events(:,1) == markertypes(i), 2), i) = 1;
end

% create t, aux varibles
aux = ones(length(d),1);
t = 0:1/fs:length(d)/fs - 1/fs;
t = t';

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