function value = CARE_getopt(structure, option, defaultVal)
% CARE_GETOPT gets the value of a specified option from a cfg structure.
%
% Use as
%   value = CARE_getopt(structure, option, defaultVal)

% where the input values are
%   structure  = configuration structure
%   option     = name of the option in apostrophes
%   defaultVal = any valid MATLAB data type (optional, default = [])
%
% If the key is present as field in the structure the corresponding value 
% will be returned. If the key is not present, the function will return the 
% default value or an empty array when no default was specified.

% Copyright (C) 2017, Daniel Matthes, MPI CBS

if nargin < 3
  defaultVal = [];
end

if isa(structure, 'struct')
  names = fieldnames(structure);                                            % get fieldnames from the structure
  if ~any(strcmp(option, names))
    value = defaultVal;
  else
    value = structure.(option);
  end
elseif isempty(structure)                                                   % no options are specified, return default
  value = defaultVal;
else                                    
  value = [];                                                               % return empty element, if variable structure has a false class
end
