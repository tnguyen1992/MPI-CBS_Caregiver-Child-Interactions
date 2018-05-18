function [ param ] = CARE_checkCondition( prefix, param )
% CARE_CHECKCONDITION - This functions checks the defined param,
% considering the study prefix
%
% If param is already numeric the function checks, if this number is 
% specified in the default values and returns this number in case of 
% confirmity. If param is a string, the function returns the associated 
% number, if the given string is valid. Otherwise the function throws an 
% error.

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf(['%s/../general/', prefix, '_generalDefinitions.mat'], ...
              filepath), 'generalDefinitions');

% -------------------------------------------------------------------------
% Default values
% -------------------------------------------------------------------------
defaultVals = [generalDefinitions.collabMarker, ...
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

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric( param )                                                       % if param is already numeric
  if isempty(find(defaultVals == param, 1))
    error('%d is not a valid param', param);
  end
else                                                                        % if param is specified as string
  switch param
    case 'Collaboration'
      param = defaultVals(1);                                               % collaboration condition
    case 'Individual'
      param = defaultVals(2);                                               % individual condition
    case 'Baseline'
      param = defaultVals(3);                                               % baseline condition
    case 'Collab-Base'
      param = defaultVals(4);                                               % collaboration minus baseline condition (meta condition)
    case 'Indiv-Base'
      param = defaultVals(5);                                               % individual minus baseline condition (meta condition)
    case 'Collab-Indiv'
      param = defaultVals(6);                                               % collaboration minus individual condition (meta condition)
    otherwise
      error('%d is not a valid param', param);
  end
end
