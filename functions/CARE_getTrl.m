function [ data_trial ] = CARE_getTrl( cfg, data_preproc )
% CARE_GETTRL this function extracts trials specified through event markers 
% from the continuous data stream.
%
% Use as
%   [ data_trial ] = CARE_getTrl( cfg, data_preproc )
%
% The configurations options are
%   cfg.prefix      = CARE or DCARE, defines raw data file prefix (default: CARE)
%
% where the input data has to be the result from CARE_PREPROCESSING
%
% SEE also CARE_PREPROCESSING, CARE_EXTRACTEVENTMARKERS

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
prefix      = CARE_getopt(cfg, 'prefix', 'CARE');

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf(['%s/../general/', prefix, '_generalDefinitions.mat'], ...
              filepath), 'generalDefinitions');

% -------------------------------------------------------------------------
% Basic variables
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
                                
colAll            = colCollaboration | colIndividual | colBaseline | ...
                    colTalk | colPreschoolForm;

durCollaboration  = round(generalDefinitions.collabDur * ...                % duration collaboration condition
                                  data_preproc.sub1.fs - 1);
durIndividual     = round(generalDefinitions.indivDur * ...                 % duration individual condition
                                  data_preproc.sub1.fs - 1);
durBaseline       = round(generalDefinitions.baseDur * ...                  % duration baseline condition
                                  data_preproc.sub1.fs - 1);
durTalk           = round(generalDefinitions.talkDur * ...                  % duration talk condition
                                  data_preproc.sub1.fs - 1);
durPreschoolForm  = round(generalDefinitions.preschoolDur * ...             % duration preschool form condition
                                  data_preproc.sub1.fs - 1);

numOfSample       = length(data_preproc.sub1.t);                                 
                                
% -------------------------------------------------------------------------
% Generate trialinfo and sampleinfo
% -------------------------------------------------------------------------
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);                 % get sample points of collaboration markers
evtIndividual     = find(sMatrix(:, colIndividual) > 0);                    % get sample points of individual markers
evtBaseline       = find(sMatrix(:, colBaseline) > 0);                      % get sample points of baseline markers
evtTalk           = find(sMatrix(:, colTalk) > 0);                          % get sample points of talk markers
evtStop           = find(sMatrix(:, colStop) > 0);                          % get sample points of stop markers
if ~isempty(evtStop)
  sort(evtStop);
end
evtPreschoolForm  = find(sMatrix(:, colPreschoolForm) > 0);                 % get sample points of preschool form markers

[evtAll, ~]       = find(sMatrix(:, colAll) > 0);                           % get sample points of all markers
sampleinfo        = sort(evtAll);                                           % bring sample points in an ascending order
sampleinfo(:,2)   = sampleinfo(:,1);                                          
trialinfo         = zeros(size(sampleinfo, 1), 1);

for i=1:1:size(sampleinfo, 1)                                               % estimate end points of conditions  
  if ismember(sampleinfo(i,1), evtCollaboration)
    if isempty(evtStop)
      sampleinfo(i,2) = sampleinfo(i,2) + durCollaboration;
    else
      sampleinfo(i,2) = evtStop(find(evtStop > sampleinfo(i,1), 1));
    end
    trialinfo(i) = generalDefinitions.collabMarker;
  elseif ismember(sampleinfo(i,1), evtIndividual)
    if isempty(evtStop)
      sampleinfo(i,2) = sampleinfo(i,2) + durIndividual;
    else
      sampleinfo(i,2) = evtStop(find(evtStop > sampleinfo(i,1), 1));
    end
    trialinfo(i) = generalDefinitions.indivMarker;
  elseif ismember(sampleinfo(i,1), evtBaseline)
    if isempty(evtStop)
      sampleinfo(i,2) = sampleinfo(i,2) + durBaseline;
    else
      sampleinfo(i,2) = evtStop(find(evtStop > sampleinfo(i,1), 1));
    end
    trialinfo(i) = generalDefinitions.baseMarker;
  elseif ismember(sampleinfo(i,1), evtTalk)
    if isempty(evtStop)
      sampleinfo(i,2) = sampleinfo(i,2) + durTalk;
    else
      sampleinfo(i,2) = evtStop(find(evtStop > sampleinfo(i,1), 1));
    end
    trialinfo(i) = generalDefinitions.talkMarker;
  elseif ismember(sampleinfo(i,1), evtPreschoolForm)
    if isempty(evtStop)
      sampleinfo(i,2) = sampleinfo(i,2) + durPreschoolForm;
    else
      sampleinfo(i,2) = evtStop(find(evtStop > sampleinfo(i,1), 1));
    end
    trialinfo(i) = generalDefinitions.preschoolMarker;
  end
end

sampleinfo(sampleinfo(:,2) > numOfSample, 2) = numOfSample;                 % correct sampleinfo if not enough samples are collected    

% -------------------------------------------------------------------------
% Extract trials from continuous data stream
% -------------------------------------------------------------------------
fprintf('<strong>Extract trials of subject 1...</strong>\n');
for i=1:1:size(sampleinfo, 1)
  data_trial.sub1.trial{i} = data_preproc.sub1.hbo(sampleinfo(i,1):sampleinfo(i,2),:);
  data_trial.sub1.time{i} = data_preproc.sub1.t(sampleinfo(i,1):sampleinfo(i,2));
end

fprintf('<strong>Extract trials of subject 2...</strong>\n');
for i=1:1:size(sampleinfo, 1)
  data_trial.sub2.trial{i} = data_preproc.sub2.hbo(sampleinfo(i,1):sampleinfo(i,2),:);
  data_trial.sub2.time{i} = data_preproc.sub2.t(sampleinfo(i,1):sampleinfo(i,2));
end

% -------------------------------------------------------------------------
% Add additional informations to output
% -------------------------------------------------------------------------
label = {'Chn01'; 'Chn02'; 'Chn03'; 'Chn04'; 'Chn05'; 'Chn06'; 'Chn07'; ...
         'Chn08'; 'Chn09'; 'Chn10'; 'Chn11'; 'Chn12'; 'Chn13'; 'Chn14'; ...
         'Chn15'; 'Chn16'};

data_trial.sub1.dimord = 'rpt_time_chan';                                   % describes the dimension order of field trial
data_trial.sub2.dimord = 'rpt_time_chan';
data_trial.sub1.label = label;
data_trial.sub2.label = label;
data_trial.sub1.trialinfo = trialinfo;
data_trial.sub2.trialinfo = trialinfo;
data_trial.sub1.sampleinfo = sampleinfo;
data_trial.sub2.sampleinfo = sampleinfo;
data_trial.sub1.fsample = data_preproc.sub1.fs;
data_trial.sub2.fsample = data_preproc.sub2.fs;
data_trial.sub1.cfg.info = 'Trials from continuous data stream extracted';
data_trial.sub2.cfg.info = 'Trials from continuous data stream extracted';
data_trial.sub1.cfg.previous = data_preproc.sub1.cfg;
data_trial.sub2.cfg.previous = data_preproc.sub2.cfg;

end
