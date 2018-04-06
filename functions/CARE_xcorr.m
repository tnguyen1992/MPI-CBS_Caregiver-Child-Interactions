function [ data_xcorr ] = CARE_xcorr( cfg, data_trial )
% CARE_XCORR estimates cross-correlation values between all associated
% channels of caregiver and child in a range which is specified by 
% cfg.shift and for each trial. 
%
% Use as
%   [ data_xcorr ] = CARE_xcorr( data_trial )
%
% % The configurations options are
%   cfg.maxlag = limits the lag range (in seconds) from –maxlag to maxlag. (default: 30)
%
% where the input data has to be the result from CARE_GETTRL
%
% SEE also CARE_GETTRL

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config option and convert maxlag into number of samples
% -------------------------------------------------------------------------
maxlag = CARE_getopt(cfg, 'maxlag', 30);

maxlag = ceil(data_trial.sub1.fsample * maxlag);                            % convert maxlag into number of samples, round always to to the nearest integer greater than or equal to that element 


% -------------------------------------------------------------------------
% Estimate cross-correlation between associated channels of caregiver and 
% child
% -------------------------------------------------------------------------
numOfTrials = length(data_trial.sub1.trial);
numOfChan   = length(data_trial.sub1.label);
numOfValues = 2*maxlag + 1;
data_xcorr.xcorr{1,numOfTrials} = [];
data_xcorr.lag{1,numOfTrials}   = [];

fprintf('<strong>Estimate channel-wise cross-correlation between caregiver and child...</strong>\n');
for i = 1:1:numOfTrials
  data_xcorr.xcorr{i} = zeros(numOfValues, numOfChan);
  data_xcorr.lag{i} = zeros(numOfValues, numOfChan);
  for j = 1:1:numOfChan
    [data_xcorr.xcorr{i}(:,j), data_xcorr.lag{i}(:,j)] = xcorr(...
              data_trial.sub1.trial{i}(:,j), ...
              data_trial.sub2.trial{i}(:,j), maxlag);
  end
end

% -------------------------------------------------------------------------
% Add additional informations to output
% -------------------------------------------------------------------------
data_xcorr.dimord           = 'rpt_xcorr_chan';
data_xcorr.label            = data_trial.sub1.label;
data_xcorr.trialinfo        = data_trial.sub1.trialinfo;
data_xcorr.fsample          = data_trial.sub1.fsample;
data_xcorr.cfg.info         = 'Channel-wise cross-correlation between caregiver and child';
data_xcorr.cfg.previous{1}  = data_trial.sub1.cfg;
data_xcorr.cfg.previous{2}  = data_trial.sub2.cfg;

end

