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
%   cfg.gsePath     = memory location of the *.SD file (default: '/data/pt_01867/fnirsData/DualfNIRS_CARE_generalSettings/')
%
% See also SDgui

% Copyright (C) 2017, Daniel Matthes, MPI CBS
% 
% All subfunctions in this file (functions for coordinate transform of 
% sources and detectors positions) are extracted from 
% NIRx2nirs_probeInfo_rotate (Rev. 2.0) which has been developed by 
% NIRx Medical Technologies in April 2016 

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
SD.nSrcs        = 0;
SD.nDets        = 0;
SD.SpatialUnit  = 'cm';                                                     % Homer2.1 expects the coordinates unit (NIRx: cm)                                                     
SD.xmin         = 0;
SD.xmax         = 0;
SD.ymin         = 0;
SD.ymax         = 0;
SD.MeasListAct  = [];
SD.MeasListVis  = [];

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

% SD.MeasList field
nChan                           = probeInfo.probes.nChannel0;
SD.MeasList(:,1:2)              = repmat(probeInfo.probes.index_c,[2 1]);
SD.MeasList(:, 3)               = 1;                                         % Homer2 user's guide explains that this column is presently unused.
SD.MeasList(1:nChan,4)          = 1;                                         % rows contain data for wavelength 1.
SD.MeasList(1+nChan:2*nChan,4)  = 2;                                         % rows contain data for wavelength 2.

% SD.Lambda field
SD.Lambda                       = Wavelengths;
nsrc                            = probeInfo.probes.nSource0;
ndet                            = probeInfo.probes.nDetector0;

% estimate Homer2 related coords
newcoords                       = estimHomerCoords(probeInfo);               % cluster-based rotation of 3D coords

%SD.SrcPos field
SD.SrcPos                       = zeros([nsrc 3]); 
SD.SrcPos(:,3)                  = newcoords(1:nsrc,3);                      % sources coords
SD.SrcPos(:,1:2)                = -newcoords(1:nsrc,1:2);                   % additional 180? rotation

%SD.DetPos field
SD.DetPos                       = zeros([ndet 3]);
SD.DetPos(:,3)                  = newcoords(nsrc+1:end,3);                  % detectors coords
SD.DetPos(:,1:2)                = -newcoords(nsrc+1:end,1:2);               % additional 180? rotation

%SD.nSrcs and SD.nDets fields
SD.nSrcs = nsrc; 
SD.nDets = ndet;

SD.MeasListAct                  = ones(size(SD.MeasList,1),1);              % this will be used to prune bad channels
SD.MeasListVis                  = ones(size(SD.MeasList,1),1);              %#ok<STRNU>

% -------------------------------------------------------------------------
% Save SD structure
% -------------------------------------------------------------------------
dyad = dyad(isletter(dyad));
filename = strcat(gsePath, dyad, '.SD');
fprintf('Sources/Detectors definitions will be stored in:\n');
fprintf('%s...\n', filename);
save(filename, 'SD', '-mat');
fprintf('Data stored!\n\n');

end

%--------------------------------------------------------------------------
% SUBFUNCTION estimate Homer2 related coordinates
%--------------------------------------------------------------------------
function newcoords = estimHomerCoords(probeInfo)

src = probeInfo.probes.coords_s3;
det = probeInfo.probes.coords_d3;
channels = probeInfo.probes.index_c;
    
pi.nsources = length(src);
pi.ndetectors = length(det);
    
pi.optode_coords = [src; det];                                              % stack src and det 3D coords
    
pi.channel_indices = zeros(length(channels),2);
pi.channel_distances = zeros(length(channels),1);
    
for i=1:length(channels)
  src_i = channels(i,1);
  det_i = channels(i,2);
  pi.channel_indices(i,:) = [src_i (length(src)+det_i)];
  pi.channel_distances(i) = norm(src(src_i,:) - det(det_i,:));
end
    
origin = find_origin(pi);
for i=1:length(pi.optode_coords)
  pi.optode_coords(i,:) = pi.optode_coords(i,:) - origin;
end
    
clusters = cluster_search_mat(pi);
    
newcoords = zeros(size(pi.optode_coords));
    
for i = 1:size(clusters,2)
  idx = clusters{i};
  center = mean(pi.optode_coords(idx',:));
  
  center_phi = atan2(center(2), center(1));                                 % center in spherical coordinates
    
  tangent = [-sin(center_phi) cos(center_phi) 0];                           % phi tangent vector
  angle = acos((center/norm(center))*[0 0 1]');                             % angle between r and z unit vectors
        
  mat = rotmat(center, tangent, -angle);
  coords = ( mat * [pi.optode_coords(idx',:) ones(length(idx),1)]' )';
  newcoords(idx',:) = coords(:,1:3);
end

end
  
%--------------------------------------------------------------------------
% SUBFUNCTION find origin
%--------------------------------------------------------------------------
function origin = find_origin(pi)

origin = fminsearch(@(x) fun(x, pi), [0 0 0]);

end

%--------------------------------------------------------------------------
% SUBFUNCTION estimates standard deviation of vektor norms 
%--------------------------------------------------------------------------
function f = fun(x, pi)

k = ones(length(pi.optode_coords),1);
for i=1:length(k)
  k(i) = norm(pi.optode_coords(i,:) - x);
end
f = std(k);

end     

%--------------------------------------------------------------------------
% SUBFUNCTION find clusters of channels
%--------------------------------------------------------------------------
function found = cluster_search_mat(pi)

index = pi.channel_indices;
k = index(1,1);
source = 1;
cluster = 1;
found{cluster} = k;
found_src(1) = k;
found_det = [];
    
while size(index,1) > 0
  if source
    chn = find(index(:,1) == k);                                            % channels with source = k
    if ~isempty(chn)
      for i=1:size(chn)
        if ~any(found{cluster} == index(chn(i),2))
          found{cluster} = [found{cluster} index(chn(i),2)];
          found_det = [found_det index(chn(i),2)'];                         %#ok<AGROW>
        end
      end
      index(chn,:) = [];                                                    % remove channels from index list
    end
    if isempty(index)
      break;
    end
    found_src(1) = [];                                                      % remove current source index
    if isempty(found_src)                                                   % change to detector indexes
      source = 0;
      if isempty(found_det)
        k = index(1,2);                                                     % if both are empty, re-initialize
        found_det(1) = k;
        cluster = cluster + 1;                                              % go to next cluster
        found{cluster} = k;
      else
        k = found_det(1);
      end
    else
      k = found_src(1);
    end
  else
    chn = find(index(:,2) == k);                                            % channels with detector = k
    if ~isempty(chn)
      for i=1:size(chn)
        if ~any(found{cluster} == index(chn(i),1))
          found{cluster} = [found{cluster} index(chn(i),1)];
          found_src = [found_src index(chn(i),1)];                          %#ok<AGROW>
        end
      end
      index(chn,:) = [];                                                    % remove channels from index list
    end
    if isempty(index)
      break;
    end
    found_det(1) = [];                                                      % remove current source index
    if isempty(found_det)                                                   % change to detector indexes
      source = 1;
      if isempty(found_src)
        k = index(1,1);                                                     % if both are empty, re-initialize
        found_src(1) = k;
        cluster = cluster + 1;                                              % go to next cluster
        found{cluster} = k;
      else
        k = found_src(1);
      end
    else
      k = found_det(1);
    end
  end
end

end

%--------------------------------------------------------------------------
% SUBFUNCTION estimation of rotation matrix
%--------------------------------------------------------------------------
function mat = rotmat(point, direction, theta)

a = point(1); b = point(2); c = point(3);
t = direction/norm(direction);
u = t(1); 
v = t(2); 
w = t(3);

si = sin(theta);
co = cos(theta);

mat = zeros(4);

% rotational part    
mat(1:3, 1:3) = [ (u*u + (v*v + w*w) * co) (u*v*(1-co) - w*si)    (u*w*(1-co) + v*si);
                  (u*v*(1-co) + w*si)      (v*v + (u*u + w*w)*co) (v*w*(1-co) - u*si);
                  (u*w*(1-co) - v*si)      (v*w*(1-co) + u*si)    (w*w + (u*u + v*v)*co) ];

% translational part
mat(1,4) = (a*(v*v+w*w)-u*(b*v+c*w)) * (1-co) + (b*w-c*v)*si;
mat(2,4) = (b*(u*u+w*w)-v*(a*u+c*w)) * (1-co) + (c*u-a*w)*si;
mat(3,4) = (c*(u*u+v*v)-w*(a*u+b*v)) * (1-co) + (a*v-b*u)*si;
mat(4,4) = 1;

end