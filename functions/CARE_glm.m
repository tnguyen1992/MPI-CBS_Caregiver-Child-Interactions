function [ data_glm ] = CARE_glm( data_preproc )
% CARE_GLM conducts a generalized linear model regression on the induvidual 
% subjects of a specific dyad for every channel and returns a structure
% including the calculated coefficients
%
% Use as
%   [ data_glm ] = CARE_glm( data_preproc )
%
% where the input data has to be the result from CARE_PREPROCESSING
%
% SEE also CARE_PREPROCESSING

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
% Adapt the s matrix
% -------------------------------------------------------------------------
sMatrix = data_preproc.sub1.s;

evtCollaboration  = find(sMatrix(:, colCollaboration) > 0);
evtIndividual     = find(sMatrix(:, colIndividual) > 0);
evtBaseline       = find(sMatrix(:, colBaseline) > 0);

for i = evtCollaboration'
  sMatrix(i:i+durCollaboration, colCollaboration) = 1;
end

for i = evtIndividual'
  sMatrix(i:i+durIndividual, colIndividual) = 1;
end

for i = evtBaseline'
  sMatrix(i:i+durBaseline, colBaseline) = 1;
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

