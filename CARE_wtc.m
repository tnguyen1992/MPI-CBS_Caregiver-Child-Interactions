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
%
% SEE also CARE_PREPROCESSING, CARE_EXTRACTEVENTMARKERS, WTC

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
eventMarkers = CARE_getopt(cfg, 'eventMarkers', []);

if isempty(eventMarkers)
  error('No event markers are specified!');
end

if size(eventMarkers, 1) ~= size(data_preproc.sub1.s, 2)
  error('Mismatch: Lenght of eventMarkers and number of columns in data_preproc.s is not similar.');
end

% -------------------------------------------------------------------------
% General definitions
% Determine events
% -------------------------------------------------------------------------
colCollaboration  = (eventMarkers == 11);
colIndividual     = (eventMarkers == 12);
colRest           = (eventMarkers == 13);
colAll            = colCollaboration | colIndividual | colRest;

% define Duration of conditions
durCollaboration  = round(120 * data_preproc.sub1.fs - 1);                  % duration collaboration condition: 120 seconds      
durIndividual     = round(120 * data_preproc.sub1.fs - 1);                  % duration individual condition: 120 seconds 
durRest           = round(80 * data_preproc.sub1.fs - 1);                   % duration rest condition: 80 seconds 

% determine sample points when events occur (start of condition)
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);
evtIndividual     = find(sMatrix(:, colIndividual) > 0);
evtRest           = find(sMatrix(:, colRest) > 0);

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
poi = zeros(4,1);
[~,period,~,~,~] = wtc(hboSub1(:,16), hboSub2(:,16), 'mcc', 0); 

poi(1) = find(period > 32, 1, 'first');
poi(2) = find(period > 128, 1, 'first');
poi(3) = find(period > 256, 1, 'first');
poi(4) = find(period > 1000, 1, 'first');

% -------------------------------------------------------------------------
% Allocate memory
% -------------------------------------------------------------------------
cohin         = zeros(numOfChan, 6);
meanActCollab = zeros(1, length(evtCollaboration) * (length(poi)/2));  
meanActIndiv  = zeros(1, length(evtIndividual) * (length(poi)/2));
meanActRest   = zeros(1, length(evtRest) * (length(poi)/2));

% -------------------------------------------------------------------------
% Calculate CI, CSI and CCI for every channel of the dyad
% -------------------------------------------------------------------------
fprintf('Calculation of the wavelet coherence for all channels...\n');
for i=1:1:numOfChan
  Rsq = wtc(hboSub1(:,i), hboSub2(:,i), 'mcc', 0);
  
% calculate mean activation in frequency band of interest
% collaboration condition
 for j=1:1:length(evtCollaboration)
   meanActCollab(2*j-1) = mean(mean(Rsq(poi(1):poi(2), ...
                          evtCollaboration(j):evtCollaboration(j) + ...
                          durCollaboration)));
   meanActCollab(2*j)   = mean(mean(Rsq(poi(3):poi(4), ...
                          evtCollaboration(j):evtCollaboration(j) + ... 
                          durCollaboration)));
 end
 
 % individual condition
 for j=1:1:length(evtIndividual)
   meanActIndiv(2*j-1)  = mean(mean(Rsq(poi(1):poi(2), ...
                          evtIndividual(j):evtIndividual(j) + ...
                          durIndividual)));
   meanActIndiv(2*j)    = mean(mean(Rsq(poi(3):poi(4), ...
                          evtIndividual(j):evtIndividual(j) + ... 
                          durIndividual)));
 end
 
 % baseline
 for j=1:1:length(evtRest)
   meanActRest(2*j-1)   = mean(mean(Rsq(poi(1):poi(2), ...
                          evtRest(j):evtRest(j) + ...
                          durRest)));
   meanActRest(2*j)     = mean(mean(Rsq(poi(3):poi(4), ...
                          evtRest(j):evtRest(j) + ... 
                          durRest)));
 end

 collaboration  = (meanActCollab(2) + meanActCollab(4))/2;
 individual     = (meanActIndiv(2) + meanActIndiv(4))/2;
 baseline       = (meanActRest(2) + meanActRest(4) + meanActRest(6))/3;
 
 CI   = collaboration - baseline;
 CSI  = individual - baseline;
 CCI  = collaboration - individual;
 
 cohin(i, 1:6) = [collaboration, individual, baseline, CI,CSI, CCI];
end

% put results into the output data structure
data_wtc.eventMarker      = eventMarkers;
data_wtc.s                = sMatrix;
data_wtc.hboSub1          = hboSub1;
data_wtc.hboSub2          = hboSub2;
data_wtc.cohin            = cohin;
data_wtc.period           = period;
data_wtc.poi              = [period(poi(3)), period(poi(4))];
data_wtc.evtCollaboration = evtCollaboration;
data_wtc.evtIndividual    = evtIndividual;
data_wtc.evtRest          = evtRest;
data_wtc.evtCollaboration = evtCollaboration;
data_wtc.durIndividual    = durIndividual;
data_wtc.durRest          = durRest;
data_wtc.cohinCol         = {'Coll', 'Indi', 'Base', 'CI', 'CSI', 'CCI'};

end
