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
fsample = data_trial.sub1.fsample;                                          % extract sample frequency from data struct of subject 1
window  = ceil(window * fsample);                                           % convert window length from seconds to number of samples, 
                                                                            % round always to the nearest integer greater than or equal to that element
window  = window - mod(window, 2);                                          % round window length downwards to a multiple of two

if overlap == 50                                                            % convert overlap into number of samples
  overlap = [];                                                             % overlap = 50 is the default value
else
  overlap = window * overlap / 100;
end

fftLength = 2.^nextpow2(window);                                            % estimate fftLength by adjusting the window length to the next power of two

% -------------------------------------------------------------------------
% Estimate power spectral density using Welch's method
% -------------------------------------------------------------------------
numOfTrials = length(data_trial.sub1.trial);                                % estimate number of trials
numOfChan   = length(data_trial.sub1.label);                                % estimate number of channels
pxx{1,numOfTrials}  = [];                                                   % allocate memory for power results
[~, freq] = pwelch(data_trial.sub1.trial{1}(:,1), hanning(window), ...      % estimate frequency vector
                    overlap, fftLength, fsample);

fprintf('<strong>Estimate power spectral density using Welch''s method at subject 1...\n</strong>');
for i = 1:1:numOfTrials                                                     % for all trials
  pxx{i} = zeros(length(freq), numOfChan);
  for j = 1:1:numOfChan                                                     % for all channels   
    if isnan(data_trial.sub1.trial{i}(1,j))
      pxx{i}(:,j) = nan(length(freq), 1);                                   % set result to NaN, if channel is bad
    else
      [pxx{i}(:,j), ~] = pwelch(data_trial.sub1.trial{i}(:,j), ...
                             hanning(window), overlap, fftLength, fsample);
    end
  end
end

data_pwelch.sub1.powspctrm = pxx;
data_pwelch.sub1.freq      = freq';

fprintf('<strong>Estimate power spectral density using Welch''s method at subject 2...\n</strong>');
for i = 1:1:numOfTrials                                                     % for all trials
  pxx{i} = zeros(length(freq), numOfChan);
  for j = 1:1:numOfChan                                                     % for all channels    
    if isnan(data_trial.sub2.trial{i}(1,j))
      pxx{i}(:,j) = nan(length(freq), 1);                                   % set result to NaN, if channel is bad
    else
      [pxx{i}(:,j), ~] = pwelch(data_trial.sub2.trial{i}(:,j), ...
                             hanning(window), overlap, fftLength, fsample);
    end
  end
end

data_pwelch.sub2.powspctrm = pxx;
data_pwelch.sub2.freq      = freq';

% -------------------------------------------------------------------------
% Add additional informations to output
% -------------------------------------------------------------------------
data_pwelch.sub1.dimord       = 'rpt_freq_chan';                            % describes the dimension order of field powspctrm
data_pwelch.sub2.dimord       = 'rpt_freq_chan';                            % describes the dimension order of field powspctrm
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

end

