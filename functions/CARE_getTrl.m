function [ data_trial ] = CARE_getTrl( data_preproc )
% CARE_GETTRL this function extracts trials specified through event markers 
% from the continuous data stream.
%
% Use as
%   [ data_trial ] = CARE_getTrl( data_preproc )
%
% where the input data has to be the result from CARE_PREPROCESSING
%
% SEE also CARE_PREPROCESSING, CARE_EXTRACTEVENTMARKERS

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% General definitions
% -------------------------------------------------------------------------
colCollaboration  = (data_preproc.sub1.eventMarkers == 11);
colIndividual     = (data_preproc.sub1.eventMarkers == 12);
colBaseline       = (data_preproc.sub1.eventMarkers == 13);
colAll            = colCollaboration | colIndividual | colBaseline;

durCollaboration  = round(120 * data_preproc.sub1.fs - 1);                  % duration collaboration condition: 120 seconds      
durIndividual     = round(120 * data_preproc.sub1.fs - 1);                  % duration individual condition: 120 seconds 
durBaseline       = round(80 * data_preproc.sub1.fs - 1);                   % duration baseline condition: 80 seconds 

% -------------------------------------------------------------------------
% Generate trialinfo and sampleinfo
% -------------------------------------------------------------------------
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);                 % get sample points of collaboration markers
evtIndividual     = find(sMatrix(:, colIndividual) > 0);                    % get sample points of individual markers
evtBaseline       = find(sMatrix(:, colBaseline) > 0);                      % get sample points of baseline markers
[evtAll, ~]       = find(sMatrix(:, colAll) > 0);                           % get sample points of all markers
sampleinfo        = sort(evtAll);                                           % bring sample points in an ascending order
sampleinfo(:,2)   = sampleinfo(:,1);                                          
trialinfo         = zeros(size(sampleinfo, 1), 1);

for i=1:1:size(sampleinfo, 1)                                               % estimate end points of conditions  
  if ismember(sampleinfo(i,1), evtCollaboration)
    sampleinfo(i,2) = sampleinfo(i,2) + durCollaboration;
    trialinfo(i) = 11;
  elseif ismember(sampleinfo(i,1), evtIndividual)
    sampleinfo(i,2) = sampleinfo(i,2) + durIndividual;
    trialinfo(i) = 12;
  elseif ismember(sampleinfo(i,1), evtBaseline)
    sampleinfo(i,2) = sampleinfo(i,2) + durBaseline;
    trialinfo(i) = 13;
  end
end

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

data_trial.sub1.dimord = 'rpt_time_chan';
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
