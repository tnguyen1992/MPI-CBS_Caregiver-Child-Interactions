function CARE_easyCohPlot(cfg, data)
% CARE_EASYCOHPLOT is a function, which makes it easier to create a
% coherence plot including event markers for the different conditions by 
% using the wtc function.
%
% Use as
%   CARE_easyCohPlot(cfg, data)
%
% where the input data has to be a result of CARE_WTC.
%
% The configuration options are 
%   cfg.channel = number of channel (1 to 16) (default: 1)
%
% See also CARE_WTC

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
channel   = CARE_getopt(cfg, 'channel', 1);

% -------------------------------------------------------------------------
% Extract hbo data and event markers from data object
% -------------------------------------------------------------------------
hbo1 = data.hboSub1;                                                        % extract hbo data of first subject
hbo2 = data.hboSub2;                                                        % extract hbo data of first subject

eventC = data.cfg.evtCollaboration;                                         % extract event markers of collaboration condition
eventI = data.cfg.evtIndividual;                                            % extract event markers of individual condition
eventR = data.cfg.evtRest;                                                  % extract event markers of resting condition
eventT = data.cfg.evtTalk;                                                  % extract event markers of conversation condition    

durC = data.cfg.durCollaboration;                                           % extract duration of collaboration condition
durI = data.cfg.durIndividual;                                              % extract duration of individual condition
durR = data.cfg.durRest;                                                    % extract duration of resting condition
durT = data.cfg.durTalk;                                                    % extract duration of conversation condition

% -------------------------------------------------------------------------
% Create coherence plot
% -------------------------------------------------------------------------
wtc(hbo1(:,channel), hbo2(:,channel), 'mcc', 0);
y = [0 13];

for i=1:1:length(eventC)
  x = [eventC(i) eventC(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th collaboration condition
  line(x+durC, y, 'Color', 'white');                                        % end of i-th collaboration condition
  rectangle('Position', [eventC(i) 1.8 durC 0.42], ....                     % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventC(i)+50, 2, sprintf('Collab %d', i));                           % create condition label
end

for i=1:1:length(eventI)
  x = [eventI(i) eventI(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th individual condition
  line(x+durI, y, 'Color', 'white');                                        % end of i-th individual condition
  rectangle('Position', [eventI(i) 1.8 durI 0.42], ...                      % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventI(i)+50, 2, sprintf('Indiv %d', i));                            % create condition label
end

for i=1:1:length(eventR)
  x = [eventR(i) eventR(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th resting condition
  line(x+durR, y, 'Color', 'white');                                        % end of i-th resting condition
  rectangle('Position', [eventR(i) 1.8 durR 0.42], ....                     % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventR(i)+50, 2, sprintf('Rest %d', i));                             % create condition label
end

for i=1:1:length(eventT)
  x = [eventT(i) eventT(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th resting condition
  line(x+durT, y, 'Color', 'white');                                        % end of i-th resting condition
  rectangle('Position', [eventT(i) 1.8 durT 0.42], ....                     % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventT(i)+50, 2, sprintf('Conver %d', i));                           % create condition label
end

end
