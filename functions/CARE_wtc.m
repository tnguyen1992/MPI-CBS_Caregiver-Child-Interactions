function [ data_wtc ] = CARE_wtc( cfg, data_preproc )
% CARE_WTC estimates the wavelet transform coherence between two subjects 
% of one dyad. The coherence is computed using the analytic Morlet wavelet.
%
% Use as
%   [ data_wtc ] = CARE_wtc( cfg, data_preproc )
%
% where the input data has to be the result from CARE_PREPROCESSING
%
% The configuration options are
%   cfg.prefix      = CARE or DCARE, defines raw data file prefix (default: CARE)
%   cfg.poi         = period of interest in seconds (default: [23 100])
%   cfg.considerCOI = true or false, if true the values below the cone of
%                     interest will be set to NaN
%
% SEE also CARE_PREPROCESSING, WTC

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
prefix      = CARE_getopt(cfg, 'prefix', 'CARE');
poi         = CARE_getopt(cfg, 'poi', [10 50]);
considerCOI = CARE_getopt(cfg, 'considerCOI', true);

if ~isequal(length(poi), 2)
  error('cfg.poi has wrong size. Define cfg.poi = [begin end]');  
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf(['%s/../general/', prefix, '_generalDefinitions.mat'], ...
              filepath), 'generalDefinitions');

% -------------------------------------------------------------------------
% Basic variable
% Determine events
% -------------------------------------------------------------------------
colCollaboration  = (data_preproc.sub1.eventMarkers == ...
                                  generalDefinitions.collabMarker);
colIndividual     = (data_preproc.sub1.eventMarkers == ...
                                  generalDefinitions.indivMarker);
colBaseline       = (data_preproc.sub1.eventMarkers == ...
                                  generalDefinitions.baseMarker);
colTalk           = (data_preproc.sub1.eventMarkers == ...
                                  generalDefinitions.talkMarker);
colStop           = (data_preproc.sub1.eventMarkers == ...
                                  generalDefinitions.stopMarker);
colPreschoolForm  = (data_preproc.sub1.eventMarkers == ...
                                  generalDefinitions.preschoolMarker);

colAll            = colCollaboration | colIndividual | colBaseline;

% define Duration of conditions
durCollaboration  = round(generalDefinitions.collabDur * ...                % duration collaboration condition
                                  data_preproc.sub1.fs - 1);
durIndividual     = round(generalDefinitions.indivDur * ...                 % duration individual condition
                                  data_preproc.sub1.fs - 1);
durBaseline       = round(generalDefinitions.baseDur * ...                  % duration baseline condition
                                  data_preproc.sub1.fs - 1);
durTalk           = round(generalDefinitions.talkDur * ...                  % duration talk condition (currently only used for plotting purpose)
                                  data_preproc.sub1.fs - 1);
durPreschoolForm  = round(generalDefinitions.preschoolDur * ...             % duration preschool form condition (currently only used for plotting purpose)
                                  data_preproc.sub1.fs - 1);

% determine sample points when events occur (start of condition)
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);
evtIndividual     = find(sMatrix(:, colIndividual) > 0);
evtBaseline       = find(sMatrix(:, colBaseline) > 0);
evtTalk           = find(sMatrix(:, colTalk) > 0);                          % currently only used for plotting purpose (See CARE_easyCohPlot)
evtStop           = find(sMatrix(:, colStop) > 0);
if ~isempty(evtStop)
  sort(evtStop);
end
evtPreschoolForm  = find(sMatrix(:, colPreschoolForm) > 0);                 % currently only used for plotting purpose (See CARE_easyCohPlot)

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
i = numOfChan;
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
coherences  = zeros(numOfChan, 8);
meanCohCollab = zeros(1, length(evtCollaboration));                         % mean coherence in a defined spectrum for condition collaboration  
meanCohIndiv  = zeros(1, length(evtIndividual));                            % mean coherence in a defined spectrum for condition individual
meanCohBase   = zeros(1, length(evtBaseline));                              % mean coherence in a defined spectrum for condition baseline
meanCohTalk   = zeros(1, length(evtTalk));                                  % mean coherence in a defined spectrum for condition talk
meanCohPreschoolForm   = zeros(1, length(evtPreschoolForm));                % mean coherence in a defined spectrum for condition preschool form
Rsq{numOfChan} = [];
Rsq(:) = {NaN(length(period), length(t))};

% -------------------------------------------------------------------------
% Calculate Coherence increase between conditions for every channel of the 
% dyad
% -------------------------------------------------------------------------
fprintf('<strong>Estimation of the wavelet transform coherence for all channels...</strong>\n');
for i=1:1:numOfChan
  if ~isnan(hboSub1(1, i)) && ~isnan(hboSub2(1, i))                         % check if this channel was not rejected in both subjects during preprocessing
    sigPart1 = [t, hboSub1(:,i)];
    sigPart2 = [t, hboSub2(:,i)];
    [Rsq{i}, ~, ~, coi, ~] = wtc(sigPart1, sigPart2, 'mcc', 0);                % r square - measure for coherence
  
    if considerCOI
      for j=1:1:length(coi)
        Rsq{i}(period >= coi(j), j) = NaN;
      end
    end
    
    % calculate mean activation in frequency band of interest
    % collaboration condition
    for j=1:1:length(evtCollaboration)
      if isempty(evtStop)
        meanCohCollab(j)  = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtCollaboration(j):evtCollaboration(j) + ...
                            durCollaboration)));
      else
        meanCohCollab(j)  = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtCollaboration(j):evtStop(find(evtStop > ...
                            evtCollaboration(j), 1)))));
      end
    end
 
    % individual condition
    for j=1:1:length(evtIndividual)
      if isempty(evtStop)
        meanCohIndiv(j)   = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtIndividual(j):evtIndividual(j) + ...
                            durIndividual)));
      else
        meanCohIndiv(j)   = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtIndividual(j):evtStop(find(evtStop > ...
                            evtIndividual(j), 1)))));
      end
    end
 
    % baseline
    for j=1:1:length(evtBaseline)
      if isempty(evtStop)
        meanCohBase(j)    = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtBaseline(j):evtBaseline(j) + ...
                            durBaseline)));
      else
        meanCohBase(j)    = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtBaseline(j):evtStop(find(evtStop > ...
                            evtBaseline(j), 1)))));
      end
    end
    
    
    if prefix=='CARE'
    % talk
    for j=1:1:length(evtTalk)
      if isempty(evtStop)
        meanCohTalk(j)    = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtTalk(j):evtTalk(j) + ...
                            durTalk)));
      else
        meanCohTalk(j)    = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtTalk(j):evtStop(find(evtStop > ...
                            evtTalk(j), 1)))));
      end
    end
    
    elseif prefix=='DCARE'
     % preschool form
    for j=1:1:length(evtPreschoolForm)
      if isempty(evtStop)
        meanCohPreschoolForm(j)    = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtPreschoolForm(j):evtPreschoolForm(j) + ...
                            durPreschoolForm)));
      else
        meanCohPreschoolForm(j)    = nanmean(nanmean(Rsq{i}(pnoi(1):pnoi(2), ...
                            evtPreschoolForm(j):evtStop(find(evtStop > ...
                            evtPreschoolForm(j), 1)))));
      end
    end
    end
    
%    collaboration  = nanmean(meanCohCollab);                                % average mean coherences over trials
%    individual     = nanmean(meanCohIndiv);
%    baseline       = nanmean(meanCohBase);
 
    if prefix=='CARE'
    coherences(i, 1:6) = [meanCohCollab, meanCohIndiv, meanCohBase, ...
                          meanCohTalk];
    elseif prefix=='DCARE'
        coherences(i, 1:6) = [meanCohCollab, meanCohIndiv, meanCohBase, ...
                          meanCohPreschoolForm];
    else
    coherences(i, :) = NaN;
  end
end

% put results into the output data structure
data_wtc.coherences           = coherences;
data_wtc.Rsq                  = Rsq;
data_wtc.params               = [generalDefinitions.collabMarker, ...
                                 generalDefinitions.indivMarker, ...
                                 generalDefinitions.baseMarker, ...
                                 str2double([...
                                 num2str(generalDefinitions.collabMarker) ...
                                 num2str(generalDefinitions.baseMarker)]), ...
                                 str2double([...
                                 num2str(generalDefinitions.indivMarker) ...
                                 num2str(generalDefinitions.baseMarker)]), ...
                                 str2double([...
                                 num2str(generalDefinitions.collabMarker) ...
                                 num2str(generalDefinitions.indivMarker)])];
data_wtc.paramStrings         = {'C1', 'C2', 'I1', 'I2', ...         % this field describes the columns of the coherences field
                                 'R1','R2','R3', 'T'};
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
data_wtc.cfg.evtStop          = evtStop;
data_wtc.cfg.evtPreschoolForm = evtPreschoolForm;
data_wtc.cfg.durCollaboration = durCollaboration;
data_wtc.cfg.durIndividual    = durIndividual;
data_wtc.cfg.durRest          = durBaseline;
data_wtc.cfg.durTalk          = durTalk;
data_wtc.cfg.durPreschoolForm = durPreschoolForm;

end
