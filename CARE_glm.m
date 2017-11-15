function [ data_glm ] = CARE_glm( cfg, data_preproc )
% CARE_GLM conducts a generalized linear model regression on the induvidual 
% subjects of a specific dyad for every channel and returns a structure
% including the calculated coefficients
%
% Use as
%   [ data_glm ] = CARE_glm( cfg, data_preproc )
%
% where the input data has to be the result from CARE_PREPROCESSING
%
% The configuration options are
%   cfg.eventMarkers = event aarkers extracted from the corresponding *.hdr file (see CARE_EXTRACTEVENTMARKERS)
%
% SEE also CARE_PREPROCESSING, CARE_EXTRACTEVENTMARKERS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

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
% -------------------------------------------------------------------------
colCollaboration  = (eventMarkers == 11);
colIndividual     = (eventMarkers == 12);
colRest           = (eventMarkers == 13);
colAll            = colCollaboration | colIndividual | colRest;

durCollaboration  = round(120 * data_preproc.sub1.fs - 1);                  % duration collaboration condition: 120 seconds      
durIndividual     = round(120 * data_preproc.sub1.fs - 1);                  % duration individual condition: 120 seconds 
durRest           = round(80 * data_preproc.sub1.fs - 1);                   % duration rest condition: 80 seconds 

% -------------------------------------------------------------------------
% Adapt the s matrix
% -------------------------------------------------------------------------
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);
evtIndividual     = find(sMatrix(:, colIndividual) > 0);
evtRest           = find(sMatrix(:, colRest) > 0);

for i = evtCollaboration
  sMatrix(i:i+durCollaboration, colCollaboration) = 1;
end

for i = evtIndividual
  sMatrix(i:i+durIndividual, colIndividual) = 1;
end

for i = evtRest
  sMatrix(i:i+durRest, colRest) = 1;
end

eventMarkers      = eventMarkers(colAll);
sMatrix           = sMatrix(:, colAll);

% -------------------------------------------------------------------------
% Adapt the s matrix
% -------------------------------------------------------------------------
fprintf('Conduct generalized linear model regression for all channels of subject 1...\n');
data_glm.sub1 = execGLM(eventMarkers, sMatrix, data_preproc.sub1);
fprintf('Conduct generalized linear model regression for all channels of subject 2...\n');
data_glm.sub2 = execGLM(eventMarkers, sMatrix, data_preproc.sub2);

end

function data_out = execGLM(evtMark, s, data_in)
    % build output matrix
    beta = zeros(size(data_in.hbo, 2), 4);                                 
  
  for channel = 1:1:size(data_in.hbo, 2)
    % conduct generalized linear model regression
    % beta estimates for a generalized linear regression of the responses 
    % in data_in.hbo(:, channel) on the predictors in the sMatrix
    beta(channel,:) = glmfit(s, data_in.hbo(:, channel));
  end
  
  % put results into a structure
  data_out.eventMarker = evtMark;
  data_out.s           = s;
  data_out.hbo         = data_in.hbo;
  data_out.time        = (1:1:size(data_in.hbo, 1)) / data_in.fs;
  data_out.fsample     = data_in.fs;
  data_out.channel     = 1:1:size(data_in.hbo, 2);
  data_out.beta        = beta(:, 2:end);                                    % for the existing conditions only the columns 2:end are relevant  
end

