function [data] = CARE_preprocessing( data )
% CARE_PREPROCESSING does the general preprocessing of the fnirs data. The
% function includes the following steps
%   * Conversion from wavelength data to optical density
%   * Removing of bad channels
%   * Wavlet-based motion correction
%   * Bandpass filtering
%   * Conversion from optical density to changes in concentration (HbO, HbR and HbT)
%   * Xu Cui's bad channel check
%
% Use as
%   CARE_PREPROCESSING( data )
%
% SEE also HMRINTENSITY2OD, ENPRUNECHANNELS, HMRMOTIONCORRECTWAVELET,
% HMRMOTIONARTIFACT, HMRBANDPASSFILT, HMROD2CONC, CARE_XUCHECKDATAQUALITY

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Preprocessing
% -------------------------------------------------------------------------
fprintf('Preproc subject 1...\n');
data.sub1 = preproc( data.sub1 );
fprintf('Preproc subject 2...\n');
data.sub2 = preproc( data.sub2 );

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function data = preproc( data )

% convert the wavelength data to optical density
data.dod = hmrIntensity2OD( data.d );                           

% checking for bad channels and removing them (SD.MeasListAct has zeros 
% input for bad channels)
data.tInc      = ones(size(data.aux,1),1);                                                 
data.dRange    = [0 10000000];
data.SNRthresh = 2;
data.resetFlag = 0;
data.SD        = enPruneChannels(data.d, data.SD, data.tInc, data.dRange,...
                                 data.SNRthresh, data.resetFlag);

% correcting for motion artifacts using Wavelet-based motion correction.                                
data.iQr      = 1.5;
[~, data.dod_corr] = evalc(...                                              % evalc supresses annoying fprintf output of hmrMotionCorrectWavelet
                'hmrMotionCorrectWavelet(data.dod, data.SD, data.iQr);');

% identifies motion artifacts in an input data matrix d. If any active
% data channel exhibits a signal change greater than std_thresh or
% amp_thresh, then a segment of data around that time point is marked as a
% motion artifact.
data.fs             = 1/(data.t(2)-data.t(1));                              % sampling frequency of the data
data.tMotion        = 0.5;
data.tMask          = 1;
data.stdevThreshold = 50;
data.ampThreshold   = 5;
data.tIncAuto       = hmrMotionArtifact(data.dod_corr, data.fs, data.SD,...
                                        data.tInc, data.tMotion,...
                                        data.tMask, data.stdevThreshold,...
                                        data.ampThreshold);
                                      
% bandpass filtering
data.lpf            = 0.5;                                                  % in Hz
data.hpf            = 0.01;                                                 % in Hz
data.dod_corr_filt  = hmrBandpassFilt(data.dod_corr, data.fs, data.hpf, ...
                                      data.lpf);

% convert changes in OD to changes in concentrations (HbO, HbR, and HbT)
data.ppf  = [6 6];                                                          % partial pathlength factors for each wavelength.
data.dc   = hmrOD2Conc(data.dod_corr_filt, data.SD, data.ppf);

% run Xu's bad channel check
data.hbo = squeeze(data.dc(:,1,:));
data.hbr = squeeze(data.dc(:,2,:));

data.badChannelsCui = CARE_XuCheckDataQuality(data.hbo, data.hbr);          % run quality check on all channels

data = rmfield(data, 'aux');                                                % remove field aux from data structure

end
