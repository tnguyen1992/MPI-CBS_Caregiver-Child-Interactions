function [ param ] = CARE_checkCohParam( param )
% CARE_CHECKCONDITION - This functions checks the defined param. 
%
% If param is already a string the function checks, if this string is equal 
% to one of the specified default values and returns this string in case of 
% confirmity. If param is a number, the function returns the associated 
% string, if the given number is valid. Otherwise the function throws an 
% error.

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Default values
% -------------------------------------------------------------------------
defaultVals = {'Coll', 'Indi', 'Base', 'CBCI', 'IBCI', 'CICI'};

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if ~isnumeric( param )                                                    % if param is already a string
  if isempty(find(defaultVals == param, 1))
    error('%d is not a valid param', param);
  end
else                                                                        % if param is specified as paramber
  switch param
    case 1
      param = 'Coll';                                                       % coherence in collaboration condition
    case 2
      param = 'Indi';                                                       % coherence in individual condition
    case 3
      param = 'Base';                                                       % coherence in baseline (resting state) condition
    case 4
      param = 'CBCI';                                                       % coherence increase between collaboration and baseline condition
    case 5
      param = 'IBCI';                                                       % coherence increase between individual and baseline condition
    case 6
      param = 'CICI';                                                       % coherence increase between collaboration and individual condition
    otherwise
      error('%d is not a valid param', param);
  end
end
