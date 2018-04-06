function eventMarkers = CARE_extractEventMarkers( cfg )
% CARE_EXTRACTMARKERS extract the available markers for a dyad from a *.hdr 
% file.
%
% Use as
%   eventMarkers = CARE_extractEventMarkers( cfg )
%
% The configurations options are
%   cfg.dyad    = dyad description (i.e. 'CARE_02')
%   cfg.srcPath = location of NIRx output for both subjects of the dyad
%
% SEE also CARE_NIRX2NIRS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad        = CARE_getopt(cfg, 'dyad', []);
srcPath     = CARE_getopt(cfg, 'srcPath', []);

if isempty(srcPath)
  error('No source path is specified!');
end

if isempty(dyad)
  error('No file prefix is specified!');
end

% -------------------------------------------------------------------------
% Check if *.hdr-Files are existing
% -------------------------------------------------------------------------
Sub1SrcDir  = strcat(srcPath, dyad, '/Subject1/');
Sub2SrcDir  = strcat(srcPath, dyad, '/Subject2/');

if ~exist(Sub1SrcDir, 'dir')
  error('Directory: %s does not exist', Sub1SrcDir);
else
  Sub1_hdrFile = strcat(Sub1SrcDir, dyad, '.hdr');
  if ~exist(Sub1_hdrFile, 'file')
    error('hdr file: %s does not exist', Sub1_hdrFile);
  end
end

if ~exist(Sub2SrcDir, 'dir')
  error('Directory: %s does not exist', Sub2SrcDir);
else
  Sub2_hdrFile = strcat(Sub2SrcDir, dyad, '.hdr');
  if ~exist(Sub2_hdrFile, 'file')
    error('hdr file: %s does not exist', Sub2_hdrFile);
  end
end

% -------------------------------------------------------------------------
% Extract event markers
% -------------------------------------------------------------------------
dyadString = strsplit(dyad, '_');
dyadNum = str2double(dyadString{2});

eM1 = getEvtMark( Sub1_hdrFile, dyadNum );
eM2 = getEvtMark( Sub2_hdrFile, dyadNum );

if isequal(eM1, eM2)
  eventMarkers = eM1;
else
  error('Error: The Markers of both Subjects of dyad %s are not similar', dyad);
end

end

% -------------------------------------------------------------------------
% SUBFUNCTION get event markers from *.hdr file
% -------------------------------------------------------------------------
function evtMarker = getEvtMark( hdrFile, num )
fid = fopen(hdrFile);
tmp = textscan(fid,'%s','delimiter','\n');                                  % this just reads every line
hdr_str = tmp{1};
fclose(fid);

keyword = 'Events="#';
ind = find(contains(hdr_str,keyword)) + 1 ;                                
ind2 = find(contains(hdr_str(ind+1:end),'#')) - 1;
ind2 = ind + ind2(1);
events = cell2mat(cellfun(@str2num, hdr_str(ind:ind2), 'UniformOutput', 0));
events = events(:,2:3);
if num < 7                                                                  %  correction of markers for dyads until number 6
  events = correctEvents( events );
end
evtMarker = unique(events(:,1));

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
