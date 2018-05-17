function [ data_glm ] = CARE_glm( cfg, data_preproc )
% CARE_GLM conducts a generalized linear model regression on the induvidual 
% subjects of a specific dyad for every channel and returns a structure
% including the calculated coefficients
%
% Use as
%   [ data_glm ] = CARE_glm( cfg, data_preproc )
%
% The configurations options are
%   cfg.prefix      = CARE or DCARE, defines raw data file prefix (default: CARE)
%
% where the input data has to be the result from CARE_PREPROCESSING
%
% SEE also CARE_PREPROCESSING

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
colStop           = (data_preproc.sub1.eventMarkers == ...
                                  generalDefinitions.stopMarker);

colAll            = colCollaboration | colIndividual | colBaseline;

durCollaboration  = round(generalDefinitions.collabDur * ...                % duration collaboration condition
                                  data_preproc.sub1.fs - 1);
durIndividual     = round(generalDefinitions.indivDur * ...                 % duration individual condition
                                  data_preproc.sub1.fs - 1);
durBaseline       = round(generalDefinitions.baseDur * ...                  % duration baseline condition
                                  data_preproc.sub1.fs - 1);

% -------------------------------------------------------------------------
% Adapt the s matrix
% -------------------------------------------------------------------------
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);
evtIndividual     = find(sMatrix(:, colIndividual) > 0);
evtBaseline       = find(sMatrix(:, colBaseline) > 0);
evtStop           = find(sMatrix(:, colStop) > 0);                          % get sample points of stop markers
if ~isempty(evtStop)
  sort(evtStop);
end

for i = evtCollaboration'
  if isempty(evtStop)
    sMatrix(i:i+durCollaboration, colCollaboration) = 1;
  else
    sMatrix(i:evtStop(find(evtStop > i, 1)), colCollaboration) = 1;
  end
end

for i = evtIndividual'
  if isempty(evtStop)
    sMatrix(i:i+durIndividual, colIndividual) = 1;
  else
    sMatrix(i:evtStop(find(evtStop > i, 1)), colIndividual) = 1;
  end
end

for i = evtBaseline'
  if isempty(evtStop)
    sMatrix(i:i+durBaseline, colBaseline) = 1;
  else
    sMatrix(i:evtStop(find(evtStop > i, 1)), colBaseline) = 1;
  end
end

eventMarkers      = data_preproc.sub1.eventMarkers(colAll);
sMatrix           = sMatrix(:, colAll);

% -------------------------------------------------------------------------
% Adapt the s matrix
% -------------------------------------------------------------------------
fprintf('<strong>Conduct generalized linear model regression for all channels of subject 1...</strong>\n');
data_glm.sub1 = execGLM(eventMarkers, sMatrix, data_preproc.sub1);
fprintf('<strong>Conduct generalized linear model regression for all channels of subject 2...</strong>\n');
data_glm.sub2 = execGLM(eventMarkers, sMatrix, data_preproc.sub2);

end

function data_out = execGLM(evtMark, s, data_in)
    % build output matrix
    beta = zeros(size(data_in.hbo, 2), 4);                                 
  
  for channel = 1:1:size(data_in.hbo, 2)
    % conduct generalized linear model regression
    % beta estimates for a generalized linear regression of the responses 
    % in data_in.hbo(:, channel) on the predictors in the sMatrix
    if ~isnan(data_in.hbo(1, channel))                                      % check if channel was not rejected during preprocessing
      beta(channel,:) = glmfit(s, data_in.hbo(:, channel));
    else
      beta(channel,:) = NaN;
    end
  end
  
  % put results into a structure
  data_out.eventMarkers = evtMark;
  data_out.s            = s;
  data_out.hbo          = data_in.hbo;
  data_out.time         = (1:1:size(data_in.hbo, 1)) / data_in.fs;
  data_out.fsample      = data_in.fs;
  data_out.channel      = 1:1:size(data_in.hbo, 2);
  data_out.beta         = beta(:, 2:end);                                    % for the existing conditions only the columns 2:end are relevant  
end

