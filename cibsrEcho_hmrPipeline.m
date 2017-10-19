function cibsrEcho_hmrPipeline(nirsFile,tId,groupSavePath)
%% Load the nirsFile
load(nirsFile, '-mat');

%% Convert the wavelength data to Optical Density
dod = hmrIntensity2OD(d);

%% checking for bad channels and removing them (SD.MeasListAct has 0s in put for bad channels)
tInc = ones(size(aux,1),1);
dRange = [0  10000000];
SNRthresh = 2;
resetFlag = 0;
SD = enPruneChannels(d, SD, tInc, dRange, SNRthresh, resetFlag);

%% correcting for motion artifacts using Wavelet-based motion correction.
iQr = 1.5;
[dod_corr] = hmrMotionCorrectWavelet(dod, SD, iQr); 

% Identifies motion artifacts in an input data matrix d. If any active
% data channel exhibits a signal change greater than std_thresh or
% amp_thresh, then a segment of data around that time point is marked as a
% motion artifact.
fs = 1/(t(2)-t(1));  % sampling frequency of the data
tMotion = 0.5;
tMask = 1;
stdevThreshold = 50;
ampThreshold = 5;
tIncAuto = hmrMotionArtifact(dod_corr, fs, SD, tInc, tMotion, tMask, stdevThreshold, ampThreshold);

%% Band-pass filtering
lpf = 0.5; % in Hz
hpf = 0.01; % in Hz
dod_corr_filt = hmrBandpassFilt(dod_corr, fs, hpf, lpf);

%% Convert changes in OD to changes in concentrations (HbO, HbR, and HbT)
ppf = [6 6]; % partial pathlength factors for each wavelength.
dc = hmrOD2Conc(dod_corr_filt, SD, ppf);

%% Set dc to odd_hbo_filt if strcmp(nirsFile,'18554.nirs')
% This file is weird... running it through the Homer functions clip
% many channels, even though all data is present and don't seem too
% odd... In an effort to salvage these data for the paper, I'm electing
% to convert the time series to hbo, then simply bandpass filter them. 
% if strcmp(nirsFile,'18554.nirs')
%     oddData = hmrOD2Conc(dod, SD, ppf);
%     % Remove the last observation in oddData because its NaN... I have no
%     % idea why its NaN, as d and dod do not contain any NaN values...
%     % Also, reduce odd_hbo down to only hbo data.
%     oddData = oddData(1:end-1,:,:);       
%     odd_hbo_filt = hmrBandpassFilt(oddData, fs, hpf, lpf);
%     dc = odd_hbo_filt;
% end;

%% Run Xu's bad channel check
hbo = squeeze(dc(:,1,:));
hbr = squeeze(dc(:,2,:));

badChannelsCui= checkDataQuality(hbo,hbr); %Run quality check on all channels

%% Visual quality check
% To go through all channels visually 
for ii=1:16; wt(hbo(:,ii)); pause; 
end
% dqPlotPath = strcat(plotPath,'dataQualityPlots/');
%if ~isdir('dataQualityPlots')
    % Make a directory for the quality plots
%    mkdir('dataQualityPlots')
%   dqPlotPath = [pwd '/dataQualityPlots/'];
    % Run 	
    %qualityCheck(dod, dc, SD, ppf, dqPlotPath, nirsFile);
%else
%    disp('Data quality plots already exist');
%end;

%% Wavelet plots
%waveletPlotPath = strcat(plotPath,'waveletPlots/');
%mkdir(waveletPlotPath,strcat(nirsFile(1:end-5),'_wavelet'));
%waveletPlotPath = strcat(waveletPlotPath,nirsFile(1:end-5),'_wavelet/');
%     plotWaveletDecomp(hbo, t), [tempName 'waveletPlot'], waveletPlotPath);

save(['CARE_fNIRS_',tId,'.mat'],...
    'd', 'dod', 'tInc', 'dRange', 'SNRthresh', 'SD', 'iQr', ...
    'dod_corr', 'fs', 'tMotion', 'stdevThreshold', 'ampThreshold', ...  
    'tIncAuto', 'lpf', 'hpf', 'dod_corr_filt', 'ppf', 'dc', ...
    's', 't', 'badChannelsCui');
    
%% Save the data to the group folder too
save([groupSavePath 'CARE_fNIRS_',tId,'.mat'],...
    'd', 'dod', 'tInc', 'dRange', 'SNRthresh', 'SD', 'iQr', ...
    'dod_corr', 'fs', 'tMotion', 'stdevThreshold', 'ampThreshold', ...  
    'tIncAuto', 'lpf', 'hpf', 'dod_corr_filt', 'ppf', 'dc', ...
    's', 't', 'badChannelsCui');

%% Save hbo and hbr time series
save(['hbo_',tId,'.mat'],'hbo')

end