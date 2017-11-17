function [ param ] = CARE_checkCondition( param )
% CARE_CHECKCONDITION - This functions checks the defined param. 
%
% If param is already numeric the function checks, if this number is 
% specified in the default values and returns this number in case of 
% confirmity. If param is a string, the function returns the associated 
% number, if the given string is valid. Otherwise the function throws an 
% error.

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Default values
% -------------------------------------------------------------------------
defaultVals = [11, 12, 13, 1113, 1213, 1112];

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric( param )                                                       % if param is already numeric
  if isempty(find(defaultVals == param, 1))
    error('%d is not a valid param', param);
  end
else                                                                        % if param is specified as paramber
  switch param
    case 'Collaboration'
      param = 11;                                                           % collaboration condition
    case 'Individual'
      param = 12;                                                           % individual condition
    case 'Baseline'
      param = 13;                                                           % baseline condition
    case 'Collab-Base'
      param = 1113;                                                         % collaboration minus baseline condition (meta condition)
    case 'Indiv-Base'
      param = 1213;                                                         % individual minus baseline condition (meta condition)
    case 'Collab-Indiv'
      param = 1112;                                                         % collaboration minus individual condition (meta condition)
    otherwise
      error('%d is not a valid param', param);
  end
end
