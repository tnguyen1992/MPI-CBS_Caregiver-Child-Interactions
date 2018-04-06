function [ data_wtc ] = CARE_wtc( cfg, data_preproc )
% CARE_WTC estimates the wavelet coherence between two subjects of one
% dyad.
%
% Use as
%   [ data_wtc ] = CARE_wtc( cfg, data_preproc )
%
% where the input data has to be the result from CARE_PREPROCESSING
%
% The configuration options are
%   cfg.poi          = period of interest (default: [230 1000])
%
% SEE also CARE_PREPROCESSING, WTC

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
poi          = CARE_getopt(cfg, 'poi', [23 100]);

if ~isequal(length(poi), 2)
  error('cfg.poi has wrong size. Define cfg.poi = [begin end]');  
end

% -------------------------------------------------------------------------
% General definitions
% Determine events
% -------------------------------------------------------------------------
colCollaboration  = (data_preproc.sub1.eventMarkers == 11);
colIndividual     = (data_preproc.sub1.eventMarkers == 12);
colBaseline       = (data_preproc.sub1.eventMarkers == 13);
colTalk           = (data_preproc.sub1.eventMarkers == 14);
colAll            = colCollaboration | colIndividual | colBaseline;

% define Duration of conditions
durCollaboration  = round(120 * data_preproc.sub1.fs - 1);                  % duration collaboration condition: 120 seconds      
durIndividual     = round(120 * data_preproc.sub1.fs - 1);                  % duration individual condition: 120 seconds 
durBaseline       = round(80 * data_preproc.sub1.fs - 1);                   % duration baseline condition: 80 seconds 
durTalk           = round(240 * data_preproc.sub1.fs - 1);                  % duration talk condition: 240 seconds (currently only used for plotting purpose)     

% determine sample points when events occur (start of condition)
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);
evtIndividual     = find(sMatrix(:, colIndividual) > 0);
evtBaseline       = find(sMatrix(:, colBaseline) > 0);
evtTalk           = find(sMatrix(:, colTalk) > 0);                          % currently only used for plotting purpose (See CARE_easyCohPlot)

% remove unused events
eventMarkers      = data_preproc.sub1.eventMarkers(colAll);
sMatrix           = sMatrix(:, colAll);

% -------------------------------------------------------------------------
% Load hbo data create time vector
% -------------------------------------------------------------------------
hboSub1 = data_preproc.sub1.hbo;
hboSub2 = data_preproc.sub2.hbo;

t = (0:(1/data_preproc.sub1.fs):((size(data_preproc.sub1.hbo, 1) - 1) / ...
    data_preproc.sub1.fs))';

numOfChan = size(hboSub1, 2);

% -------------------------------------------------------------------------
% Estimate periods of interest
% -------------------------------------------------------------------------
pnoi = zeros(2,1);
i = 16;
while (isnan(hboSub1(1, i)) || isnan(hboSub2(1, i)))                        % check if 16 th channel was not rejected in both subjects during preprocessing
  i = i - 1;                                                                % if 16th channel was rejected in at least on subject
  if i == 0                                                                 % search for next channel which was not rejected  
    break;
  end
end
if i ~= 0
  sigPart1 = [t, hboSub1(:,i)];
  sigPart2 = [t, hboSub2(:,i)];
  [~,period,~,~,~] = wtc(sigPart1, sigPart2, 'mcc', 0); 
  pnoi(1) = find(period > poi(1), 1, 'first');
  pnoi(2) = find(period < poi(2), 1, 'last');
else
  period = NaN;                                                             % if all channel were rejected, the value period cannot be extimated and will be therefore set to NaN
end                                                                       

% -------------------------------------------------------------------------
% Allocate memory
% -------------------------------------------------------------------------
coherences  = zeros(numOfChan, 6);
meanCohCollab = zeros(1, length(evtCollaboration));                         % mean coherence in a defined spectrum for condition collaboration  
meanCohIndiv  = zeros(1, length(evtIndividual));                            % mean coherence in a defined spectrum for condition individual
meanCohBase   = zeros(1, length(evtBaseline));                              % mean coherence in a defined spectrum for condition baseline

% -------------------------------------------------------------------------
% Calculate Coherence increase between conditions for every channel of the 
% dyad
% -------------------------------------------------------------------------
fprintf('<strong>Calculation of the wavelet coherence for all channels...</strong>\n');
for i=1:1:numOfChan
  if ~isnan(hboSub1(1, i)) && ~isnan(hboSub2(1, i))                         % check if this channel was not rejected in both subjects during preprocessing
    sigPart1 = [t, hboSub1(:,i)];
    sigPart2 = [t, hboSub2(:,i)];
    Rsq = wtc(sigPart1, sigPart2, 'mcc', 0);                                % r square - measure for coherence
  
    % calculate mean activation in frequency band of interest
    % collaboration condition
    for j=1:1:length(evtCollaboration)
      meanCohCollab(j)  = mean(mean(Rsq(pnoi(1):pnoi(2), ...
                          evtCollaboration(j):evtCollaboration(j) + ...
                          durCollaboration)));
    end
 
    % individual condition
    for j=1:1:length(evtIndividual)
      meanCohIndiv(j)   = mean(mean(Rsq(pnoi(1):pnoi(2), ...
                          evtIndividual(j):evtIndividual(j) + ...
                          durIndividual)));
    end
 
    % baseline
    for j=1:1:length(evtBaseline)
      meanCohBase(j)    = mean(mean(Rsq(pnoi(1):pnoi(2), ...
                          evtBaseline(j):evtBaseline(j) + ...
                          durBaseline)));
    end

    collaboration  = mean(meanCohCollab);                                     % average mean coherences over trials
    individual     = mean(meanCohIndiv);
    baseline       = mean(meanCohBase);
 
    CBCI   = collaboration - baseline;                                        % coherence increase between collaboration and baseline
    IBCI   = individual - baseline;                                           % coherence increase between individual and baseline
    CICI   = collaboration - individual;                                      % coherence increase between collaboration and individual
 
    coherences(i, 1:6) = [collaboration, individual, baseline, CBCI, ...
                          IBCI, CICI];
  else
    coherences(i, :) = NaN;
  end
end

% put results into the output data structure
data_wtc.coherences           = coherences;
data_wtc.params               = [11, 12, 13, 1113, 1213, 1112];
data_wtc.paramStrings         = {'Collaboration', 'Individual', ...         % this field describes the columns of the coherences field
                                 'Baseline', 'Collab-Base', ...
                                 'Indiv-Base', 'Collab-Indiv'};
data_wtc.channel              = 1:1:size(hboSub1, 2);                              
data_wtc.eventMarkers         = eventMarkers;
data_wtc.s                    = sMatrix;
data_wtc.t                    = t;
data_wtc.hboSub1              = hboSub1;
data_wtc.hboSub2              = hboSub2;
data_wtc.cfg.period           = period;
data_wtc.cfg.poi              = poi;
data_wtc.cfg.evtCollaboration = evtCollaboration;
data_wtc.cfg.evtIndividual    = evtIndividual;
data_wtc.cfg.evtRest          = evtBaseline;
data_wtc.cfg.evtTalk          = evtTalk;
data_wtc.cfg.durCollaboration = durCollaboration;
data_wtc.cfg.durIndividual    = durIndividual;
data_wtc.cfg.durRest          = durBaseline;
data_wtc.cfg.durTalk          = durTalk;

end
