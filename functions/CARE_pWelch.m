function [ data_pwelch ] = CARE_pWelch( cfg, data_trial )
% CARE_PWELCH estimates the power spectral density using Welch's method for
% every condition of every participant
%
% Use as
%   [ data_pwelch ] = CARE_pWelch( cfg, data_trial)
%
% where the input data hast to be the result from CARE_GETTRL
%
% The configuration options are
%   cfg.window  = window length in seconds (default: 30)
%   cfg.overlap = percentage of overlapping (default: 50)
%
% See also CARE_GETTRL

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
window  = CARE_getopt(cfg, 'window', 30);
overlap = CARE_getopt(cfg, 'overlap', 50);

minTrialLength = min(cellfun(@(x) size(x,1), data_trial.sub1.trial));

if window > minTrialLength
  error('Window length is larger than minimal trial lenght!');
end

if overlap < 0 || overlap >= 100
  error('Wrong overlapping definition! Choose value between 0 and 100.');
end

% -------------------------------------------------------------------------
% Estimate general psd settings
% -------------------------------------------------------------------------
fsample = data_trial.sub1.fsample;
window = ceil(window * fsample);
window = window - mod(window, 2);

if overlap == 50
  overlap = [];
else
  overlap = window * overlap / 100;
end

fftLength = 2.^nextpow2(window);

% -------------------------------------------------------------------------
% Estimate power spectral density using Welch's method
% -------------------------------------------------------------------------
numOfTrials = length(data_trial.sub1.trial);
numOfChan   = length(data_trial.sub1.label);
pxx{1,numOfTrials}  = [];
[~, freq] = pwelch(data_trial.sub1.trial{1}(:,1), hanning(window), ...
                    overlap, fftLength, fsample);

fprintf('<strong>Estimate power spectral density using Welch''s method at subject 1...\n</strong>');
for i = 1:1:numOfTrials
  pxx{i} = zeros(length(freq), numOfChan);
  for j = 1:1:numOfChan
    [pxx{i}(:,j), ~] = pwelch(data_trial.sub1.trial{i}(:,j), ...
                             hanning(window), overlap, fftLength, fsample); 
  end
end

data_pwelch.sub1.powspctrm = pxx;
data_pwelch.sub1.freq      = freq';

fprintf('<strong>Estimate power spectral density using Welch''s method at subject 2...\n</strong>');
fprintf('');
for i = 1:1:numOfTrials
  pxx{i} = zeros(length(freq), numOfChan);
  for j = 1:1:numOfChan
    [pxx{i}(:,j), ~] = pwelch(data_trial.sub2.trial{i}(:,j), ...
                             hanning(window), overlap, fftLength, fsample); 
  end
end

data_pwelch.sub2.powspctrm = pxx;
data_pwelch.sub2.freq      = freq';

% -------------------------------------------------------------------------
% Add additional informations to output
% -------------------------------------------------------------------------
data_pwelch.sub1.dimord       = 'rpt_freq_chan';
data_pwelch.sub2.dimord       = 'rpt_freq_chan';
data_pwelch.sub1.label        = data_trial.sub1.label;
data_pwelch.sub2.label        = data_trial.sub2.label;
data_pwelch.sub1.trialinfo    = data_trial.sub1.trialinfo;
data_pwelch.sub2.trialinfo    = data_trial.sub2.trialinfo;
data_pwelch.sub1.fsample      = data_trial.sub1.fsample;
data_pwelch.sub2.fsample      = data_trial.sub2.fsample;
data_pwelch.sub1.cfg.info     = 'Power spectral density using Welch''s method';
data_pwelch.sub2.cfg.info     = 'Power spectral density using Welch''s method';
data_pwelch.sub1.cfg.previous = data_trial.sub1.cfg;
data_pwelch.sub2.cfg.previous = data_trial.sub2.cfg;
