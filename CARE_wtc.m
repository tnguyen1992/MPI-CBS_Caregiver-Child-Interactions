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
%   cfg.eventMarkers = event aarkers extracted from the corresponding *.hdr file (see CARE_EXTRACTEVENTMARKERS)
%   cfg.poi          = period of interest (default: [230 1000])
%
% SEE also CARE_PREPROCESSING, CARE_EXTRACTEVENTMARKERS, WTC

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
eventMarkers = CARE_getopt(cfg, 'eventMarkers', []);
poi          = CARE_getopt(cfg, 'poi', [230 100]);

if isempty(eventMarkers)
  error('No event markers are specified!');
end

if size(eventMarkers, 1) ~= size(data_preproc.sub1.s, 2)
  error('Mismatch: Lenght of eventMarkers and number of columns in data_preproc.s is not similar.');
end

if ~isequal(length(poi), 2)
  error('cfg.poi has wrong size. Define cfg.poi = [begin end]');  
end

% -------------------------------------------------------------------------
% General definitions
% Determine events
% -------------------------------------------------------------------------
colCollaboration  = (eventMarkers == 11);
colIndividual     = (eventMarkers == 12);
colBaseline       = (eventMarkers == 13);
colAll            = colCollaboration | colIndividual | colBaseline;

% define Duration of conditions
durCollaboration  = round(120 * data_preproc.sub1.fs - 1);                  % duration collaboration condition: 120 seconds      
durIndividual     = round(120 * data_preproc.sub1.fs - 1);                  % duration individual condition: 120 seconds 
durBaseline       = round(80 * data_preproc.sub1.fs - 1);                   % duration baseline condition: 80 seconds 

% determine sample points when events occur (start of condition)
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);
evtIndividual     = find(sMatrix(:, colIndividual) > 0);
evtBaseline       = find(sMatrix(:, colBaseline) > 0);

% remove unused events
eventMarkers      = eventMarkers(colAll);
sMatrix           = sMatrix(:, colAll);

% -------------------------------------------------------------------------
% Load hbo data
% -------------------------------------------------------------------------
hboSub1 = data_preproc.sub1.hbo;
hboSub2 = data_preproc.sub2.hbo;

numOfChan = size(hboSub1, 2);

% -------------------------------------------------------------------------
% Estimate periods of interest
% -------------------------------------------------------------------------
pnoi = zeros(2,1);
[~,period,~,~,~] = wtc(hboSub1(:,16), hboSub2(:,16), 'mcc', 0); 

pnoi(1) = find(period > poi(1), 1, 'first');
pnoi(2) = find(period > poi(2), 1, 'first');

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
fprintf('Calculation of the wavelet coherence for all channels...\n');
for i=1:1:numOfChan
  Rsq = wtc(hboSub1(:,i), hboSub2(:,i), 'mcc', 0);                          % r square - measure for coherence
  
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
 
  coherences(i, 1:6) = [collaboration, individual, baseline, CBCI, IBCI,...
                        CICI];
end

% put results into the output data structure
data_wtc.coherences           = coherences;
data_wtc.params               = [11, 12, 13, 1113, 1213, 1112];
data_wtc.paramStrings         = {'Collaboration', 'Individual', ...         % this field describes the columns of the coherences field
                                 'Baseline', 'Collab-Base', ...
                                 'Indiv-Base', 'Collab-Indiv'};
data_wtc.channel              = 1:1:size(hboSub1, 2);                              
data_wtc.eventMarker          = eventMarkers;
data_wtc.s                    = sMatrix;
data_wtc.hboSub1              = hboSub1;
data_wtc.hboSub2              = hboSub2;
data_wtc.cfg.period           = period;
data_wtc.cfg.poi              = poi;
data_wtc.cfg.evtCollaboration = evtCollaboration;
data_wtc.cfg.evtIndividual    = evtIndividual;
data_wtc.cfg.evtRest          = evtBaseline;
data_wtc.cfg.durCollaboration = durCollaboration;
data_wtc.cfg.durIndividual    = durIndividual;
data_wtc.cfg.durRest          = durBaseline;

end
