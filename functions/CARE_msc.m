function [ data_msc ] = CARE_msc( cfg, data_trial )
% CARE_MSC estimates the magnitude-squared coherence between two subjects 
% of one dyad by using Welch’s overlapped averaged periodogram method
%
% Use as
%   [ data_msc ] = CARE_msc( cfg, data_trial )
%
% where the input data has to be the result from CARE_GETTRL
%
% The configuration options are
%   cfg.window  = window length in seconds (default: 30)
%   cfg.overlap = percentage of overlapping (default: 50)
%   cfg.poi     = period of interest in seconds (default: [23 100])
%
% SEE also CARE_GETTRL, MSCOHERE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
window  = CARE_getopt(cfg, 'window', 30);
overlap = CARE_getopt(cfg, 'overlap', 50);
poi      = CARE_getopt(cfg, 'poi', [23 100]);

minTrialLength = min(cellfun(@(x) size(x,1), data_trial.sub1.trial));

if window > minTrialLength
  error('Window length is larger than minimal trial lenght!');
end

if overlap < 0 || overlap >= 100
  error('Wrong overlapping definition! Choose value between 0 and 100.');
end

if ~isequal(length(poi), 2)
  error('cfg.poi has wrong size. Define cfg.poi = [begin end]');  
end

% -------------------------------------------------------------------------
% Estimate general magnitude-squared coherence settings
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
% Estimate periods of interest
% -------------------------------------------------------------------------
[~, freq] = mscohere(data_trial.sub1.trial{1}(:,1), ...                     % estimate frequency vector                    
                     data_trial.sub2.trial{1}(:,1), ...
                     hanning(window), overlap, fftLength, fsample);
                   
foi    = zeros(2,1);
foi(1) = find(freq > 1./poi(2), 1, 'first');                                % estimate lower frequency
foi(2) = find(freq < 1./poi(1), 1, 'last');                                 % estimate upper frequency

% -------------------------------------------------------------------------
% Estimate magnitude-squared coherence
% -------------------------------------------------------------------------
numOfTrials = length(data_trial.sub1.trial);                                % estimate number of trials
numOfChan   = length(data_trial.sub1.label);                                % estimate number of channels
cxy{1,numOfTrials}  = [];                                                   % allocate memory for coherence results
                   
fprintf('<strong>Estimation of magnitude-squared coherence for all channels...\n</strong>');
for i = 1:1:numOfTrials                                                     % for all trials
  cxy{i} = zeros(length(freq), numOfChan);
  for j = 1:1:numOfChan                                                     % for all channels
    if isnan(data_trial.sub1.trial{i}(1,j)) || isnan(data_trial.sub2.trial{i}(1,j))
      cxy{i}(:,j) = nan(length(freq), 1);                                   % set coherence to NaN, if at least one channel is bad
    else
      [cxy{i}(:,j), ~] = mscohere(data_trial.sub1.trial{i}(:,j), ...
                                  data_trial.sub2.trial{i}(:,j), ...
                             hanning(window), overlap, fftLength, fsample);
    end
  end
end

data_msc.mscohere = cxy;
data_msc.freq     = freq';

% -------------------------------------------------------------------------
% Calculate averaged coherence for frequencies of interest
% -------------------------------------------------------------------------
for i = 1:1:numOfTrials                                                     % for all trials
  cxy{i} = mean(cxy{i}(foi(1):foi(2),:), 1);                                % extract the frequencies of interests and average over frequencies
end

cxy = cat(1, cxy{:})';                                                      % put all trials in on matrix, rows = channels, columns = trials

trialinfo           = data_trial.sub1.trialinfo;                            % extract trialinfo from source data
conditions          = unique(trialinfo);                                    % determine unique conditions
numOfCond           = length(conditions);                                   % determine number of conditions
data_msc.coherences = zeros(numOfChan, numOfCond*2);                        % allocate memory for the result of averaging over conditions

for i=1:1:numOfCond
  data_msc.coherences(:,i) = nanmean(cxy(:,ismember(trialinfo, ...          % average the coherence values for collaboration, individual
                                        conditions(i))), 2);                % and baseline condition
end

data_msc.coherences(:,4) = data_msc.coherences(:,1) ...                     % estimate coherence increase between collaboration - baseline
                            - data_msc.coherences(:,3);
data_msc.coherences(:,5) = data_msc.coherences(:,2) ...                     % estimate coherence increase between individual - baseline
                            - data_msc.coherences(:,3);
data_msc.coherences(:,6) = data_msc.coherences(:,1) ...
                            - data_msc.coherences(:,2);                     % estimate coherence increase between collaboration - individual

% -------------------------------------------------------------------------
% Add additional informations to output
% -------------------------------------------------------------------------
data_msc.dimord       = 'rpt_freq_chan';                                    % describes the dimension order of field mscohere
data_msc.label        = data_trial.sub1.label;
data_msc.trialinfo    = data_trial.sub1.trialinfo;
data_msc.fsample      = data_trial.sub1.fsample;
data_msc.params       = [11, 12, 13, 1113, 1213, 1112];
data_msc.paramStrings = {'Collaboration', 'Individual', ...                 % this field describes the columns of the coherences field
                         'Baseline', 'Collab-Base', ...
                         'Indiv-Base', 'Collab-Indiv'};
data_msc.cfg.info     = 'Magnitude-squared coherence';
data_msc.cfg.previous = data_trial.sub1.cfg;

end