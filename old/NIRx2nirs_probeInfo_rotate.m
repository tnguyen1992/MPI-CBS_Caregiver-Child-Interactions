function NIRx2nirs_probeInfo_rotate(NIRx_foldername, SD_filename)

% NIRx2nirs.m version 1.0
% #####################################################
% This script takes a folder (NIRx_foldername) containing the NIRx output
% data files (.hdr, .wl1, .wl2) and a pre-defined SD file (SD_filename) 
% (built using the Homer2 SDgui), which matches the source-detector layout 
% used in the NIRx acquisition and creates a .nirs file for use in Homer2

% To use this script, the user must first create an SD file which matches
% their NIRx probe layour using the SDgui function of Homer2.  It is 
% essential that the SD file loaded matches the NIRx acquisition layout as 
% this is assumed to be correct by this script.  This includes maintaining 
% the real-world NIRx source and detector numbers in the SD file, which may
% necessitate padding the SD file if consecutively numbered sources and
% detectors, starting from 1, were not used.

% This code was written and debugged using data from the NIRx NIRSCOUT, it
% may not be applicable to other models.

% Rob J Cooper, University College London, August 2013
% robert.cooper@ucl.ac.uk

% #########################################################################

% This code has been edited by NIRx Medical Technologies, Apr2016 (Rev2.0),
% so one can use the probeInfo.mat file for the SD geometry (lines 37-79).
% Any questions on this new version, please forward to: support@nirx.net

% Additional revision notes:
% A) Lines 142-147 added to automatically prune 'bad' channels (NaN);
% B) Lines 174-334 added to rotate 3D coordinates for better display.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Select NIRx folder containing .wl1, .wl2 and .hr files
if ~exist('NIRx_foldername','var');
NIRx_foldername = uigetdir(pwd,'Select NIRx Data Folder...');
end

% Load SD_file
[filename1, pathname1] = uigetfile('*_probeInfo.mat', 'Pick _probeInfo file');
probe_path = [pathname1, filename1];
comms = ['load ' probe_path '  probeInfo'];
eval(comms); %loading probeInfo file

%SD.MeasList field
nchan = probeInfo.probes.nChannel0;
SD.MeasList = zeros([2*nchan 4]);
SD.MeasList(:,3) = 1; %The Homer user's guide explains that this column is presently unused.
SD.MeasList(1:nchan,4) = 1; %These rows contain data for wavelength 1.
SD.MeasList(1+nchan:2*nchan,4) = 2; %These rows contain data for wavelength 2.
SD.MeasList(:,1:2) = repmat(probeInfo.probes.index_c,[2 1]);

%SD.Lambda field
SD.Lambda = [760 850]; %wavelengths used on standard NIRx measurements
nsrc = probeInfo.probes.nSource0;
ndet = probeInfo.probes.nDetector0;

newcoords = rotate_clusters(probeInfo); %cluster-based rotation of 3D coords

%SD.SrcPos field
SD.SrcPos = zeros([nsrc 3]); 
SD.SrcPos(:,3) = newcoords(1:nsrc,3); %src coords
SD.SrcPos(:,1:2) = -newcoords(1:nsrc,1:2); %additional 180º rotation

%SD.DetPos field
SD.DetPos = zeros([ndet 3]);
SD.DetPos(:,3) = newcoords(nsrc+1:end,3); %det coords
SD.DetPos(:,1:2) = -newcoords(nsrc+1:end,1:2); %additional 180º rotation

%SD.nSrcs and SD.nDets fields
SD.nSrcs = nsrc; SD.nDets = ndet; 

SD.SpatialUnit = 'cm'; %Homer2.1 expects the coordinates unit (NIRx: cm)
SD.xmin = 0; SD.xmax = 0; SD.ymin = 0; SD.ymax = 0;
SD.MeasListAct = ones(size(SD.MeasList,1),1); %This will be used to prune bad channels
SD.MeasListVis = ones(size(SD.MeasList,1),1); 

%SD sructure array completed.

% Load wavelength d
% #######################################################################
wl1_dir = dir([NIRx_foldername '/*.wl1']);
if length(wl1_dir) == 0; error('ERROR: Cannot find NIRx .wl1 file in selected directory...'); end;
wl1 = load([NIRx_foldername '/' wl1_dir(1).name]);
wl2_dir = dir([NIRx_foldername '/*.wl2']);
if length(wl2_dir) == 0; error('ERROR: Cannot find NIRx .wl2 file in selected directory...'); end;
wl2 = load([NIRx_foldername '/' wl2_dir(1).name]);

d=[wl1 wl2]; % d matrix from .wl1 and .wl2 files

% Read and interpret .hdr d ############################################
% #########################################################################
hdr_dir = dir([NIRx_foldername '/*.hdr']);
if length(hdr_dir) == 0; error('ERROR: Cannot find NIRx header file in selected directory...'); end;
fid = fopen([NIRx_foldername '/' hdr_dir(1).name]);
tmp = textscan(fid,'%s','delimiter','\n');%This just reads every line
hdr_str = tmp{1};
fclose(fid);

%Find number of sources
keyword = 'Sources=';
tmp = strfind(hdr_str,keyword);
ind = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
tmp = hdr_str{ind};
NIRx_Sources = str2num(tmp(length(keyword)+1:end));

%Find number of sources
keyword = 'Detectors=';
tmp = strfind(hdr_str,keyword);
ind = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
tmp = hdr_str{ind};
NIRx_Detectors = str2num(tmp(length(keyword)+1:end));

%Compare to SD file for checking...
if NIRx_Sources < SD.nSrcs || NIRx_Detectors < SD.nDets;
   error('The number or sources and detectors in the NIRx files does not match your SD file...');
end

%Find Sample rate
keyword = 'SamplingRate=';
tmp = strfind(hdr_str,keyword);
ind = find(~cellfun(@isempty,tmp)); %This gives cell of hdr_str with keyword
tmp = hdr_str{ind};
fs = str2num(tmp(length(keyword)+1:end));

%Find Active Source-Detector pairs (these will just be ordered by source,
%then detector (so, for example d(:,1) = source 1, det 1 and d(:,2) =
%source 1 det 2 etc.
keyword = 'S-D-Mask="#';
tmp = strfind(hdr_str,keyword);
ind = find(~cellfun(@isempty,tmp)) + 1; %This gives cell of hdr_str with keyword
tmp = strfind(hdr_str(ind+1:end),'#');
ind2 = find(~cellfun(@isempty,tmp)) - 1;
ind2 = ind + ind2(1);
sd_ind = cell2mat(cellfun(@str2num,hdr_str(ind:ind2),'UniformOutput',0));
sd_ind = sd_ind';
sd_ind = find([sd_ind(:);sd_ind(:)]);
d = d(:,sd_ind);

%Find NaN values in the recorded data -> channels should be pruned as 'bad'
for i=1:size(d,2)
    if nonzeros(isnan(d(:,i)))
        SD.MeasListAct(i) = 0;
    end
end

%Find Event Markers and build S vector
keyword = 'Events="#';
tmp = strfind(hdr_str,keyword);
ind = find(~cellfun(@isempty,tmp)) + 1; %This gives cell of hdr_str with keyword
tmp = strfind(hdr_str(ind+1:end),'#');
ind2 = find(~cellfun(@isempty,tmp)) - 1;
ind2 = ind + ind2(1);
events = cell2mat(cellfun(@str2num,hdr_str(ind:ind2),'UniformOutput',0));
events = events(:,2:3);
markertypes = unique(events(:,1));
s = zeros(length(d),length(markertypes));
for i = 1:length(markertypes);
    s(events(find(events(:,1)==markertypes(i)),2),i) = 1;
end

%Create t, aux varibles
aux = zeros(length(d),8);
t = 0:1/fs:length(d)/fs - 1/fs;

[filename, pathname] = uiputfile('*.nirs','Save .nirs file ...');

fprintf('Saving as %s in %s ...\n',filename,pathname);
save([pathname filename],'d','s','t','aux','SD');


function newcoords = rotate_clusters(probeInfo)

    src = probeInfo.probes.coords_s3;
    det = probeInfo.probes.coords_d3;
    channels = probeInfo.probes.index_c;
    
    pi.nsources = length(src);
    pi.ndetectors = length(det);
    
    pi.optode_coords = [src; det]; %stack src and det 3D coords
    
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
        
        %center in spherical coordinates
        center_r = norm(center);
        center_phi = atan2(center(2), center(1));
        center_theta = acos(center(3)/center_r);
        
        %phi tangent vector
        tangent = [-sin(center_phi) cos(center_phi) 0];
        
        %angle between r and z unit vectors
        angle = acos((center/norm(center))*[0 0 1]');
        
        mat = rotmat(center, tangent, -angle);
        
        coords = ( mat * [pi.optode_coords(idx',:) ones(length(idx),1)]' )';
        
        newcoords(idx',:) = coords(:,1:3);
        
    end

    
function origin = find_origin(pi)
    
    origin = fminsearch(@(x) fun(x, pi), [0 0 0]);
    
    function f = fun(x, pi)
        
        k = ones(length(pi.optode_coords),1);
        for i=1:length(k)
            k(i) = norm(pi.optode_coords(i,:) - x);
        end
        f = std(k);
     
        
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
            chn = find(index(:,1) == k); %channels with source = k
            if ~isempty(chn)
                for i=1:size(chn)
                    if ~any(found{cluster} == index(chn(i),2))
                        found{cluster} = [found{cluster} index(chn(i),2)];
                        found_det = [found_det index(chn(i),2)'];
                    end
                end
                index(chn,:) = []; %remove channels from index list
            end
            if isempty(index)
                break;
            end
            found_src(1) = []; %remove current source index
            if isempty(found_src) %change to detector indexes
                source = 0;
                if isempty(found_det)
                    k = index(1,2); %if both are empty, re-initialize
                    found_det(1) = k;
                    cluster = cluster + 1; %go to next cluster
                    found{cluster} = k;
                else
                    k = found_det(1);
                end
            else
                k = found_src(1);
            end
        else
            chn = find(index(:,2) == k); %channels with detector = k
            if ~isempty(chn)
                for i=1:size(chn)
                    if ~any(found{cluster} == index(chn(i),1))
                        found{cluster} = [found{cluster} index(chn(i),1)];
                        found_src = [found_src index(chn(i),1)];
                    end
                end
                index(chn,:) = []; %remove channels from index list
            end
            if isempty(index)
                break;
            end
            found_det(1) = []; %remove current source index
            if isempty(found_det) %change to detector indexes
                source = 1;
                if isempty(found_src)
                    k = index(1,1); %if both are empty, re-initialize
                    found_src(1) = k;
                    cluster = cluster + 1; %go to next cluster
                    found{cluster} = k;
                else
                    k = found_src(1);
                end
            else
                k = found_det(1);
            end
        end
    end


function mat = rotmat(point, direction, theta)

    a = point(1); b = point(2); c = point(3);
    
    t = direction/norm(direction);
    u = t(1); v = t(2); w = t(3);

    si = sin(theta);
    co = cos(theta);

    mat = zeros(4);

    % rotational part    
    mat(1:3, 1:3) = [ (u*u + (v*v + w*w) * co) (u*v*(1-co) - w*si)     (u*w*(1-co) + v*si);
                      (u*v*(1-co) + w*si)      (v*v + (u*u + w*w)*co)  (v*w*(1-co) - u*si);
                      (u*w*(1-co) - v*si)      (v*w*(1-co) + u*si)     (w*w + (u*u + v*v)*co) ];

    % translational part
    mat(1,4) = (a*(v*v+w*w)-u*(b*v+c*w)) * (1-co) + (b*w-c*v)*si;
    mat(2,4) = (b*(u*u+w*w)-v*(a*u+c*w)) * (1-co) + (c*u-a*w)*si;
    mat(3,4) = (c*(u*u+v*v)-w*(a*u+b*v)) * (1-co) + (a*v-b*u)*si;
    mat(4,4) = 1;