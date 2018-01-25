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
% Extract hbo data, the time vector and event markers from data object
% -------------------------------------------------------------------------
hbo1 = data.hboSub1;                                                        % extract hbo data of first subject
hbo2 = data.hboSub2;                                                        % extract hbo data of second subject
t = data.t;                                                                 % extract time vector               

eventC = t(data.cfg.evtCollaboration);                                      % extract event markers of collaboration condition
eventI = t(data.cfg.evtIndividual);                                         % extract event markers of individual condition
eventR = t(data.cfg.evtRest);                                               % extract event markers of resting condition
eventT = t(data.cfg.evtTalk);                                               % extract event markers of conversation condition    

durC = t(data.cfg.durCollaboration + 1);                                    % extract duration of collaboration condition
durI = t(data.cfg.durIndividual + 1);                                       % extract duration of individual condition
durR = t(data.cfg.durRest + 1);                                             % extract duration of resting condition
durT = t(data.cfg.durTalk + 1);                                             % extract duration of conversation condition

% -------------------------------------------------------------------------
% Create coherence plot
% -------------------------------------------------------------------------
sigPart1 = [t, hbo1(:,channel)];
sigPart2 = [t, hbo2(:,channel)];
wtc(sigPart1, sigPart2, 'mcc', 0, 'as', 0, 'ahs', 0);

colormap jet;

getAxis   = gca;
y         = getAxis.YLim;
recty0    = 0.068 * (y(2) - y(1)) + y(1);
txOffset  = 50 * (t(2) - t(1));
ty0       = 0.086 * (y(2) - y(1)) + y(1);

for i=1:1:length(eventC)
  x = [eventC(i) eventC(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th collaboration condition
  line(x+durC, y, 'Color', 'white');                                        % end of i-th collaboration condition
  rectangle('Position', [eventC(i) recty0 durC 0.42], ....                  % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventC(i) + txOffset, ty0, sprintf('Collab %d', i));                 % create condition label
end

for i=1:1:length(eventI)
  x = [eventI(i) eventI(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th individual condition
  line(x+durI, y, 'Color', 'white');                                        % end of i-th individual condition
  rectangle('Position', [eventI(i) recty0 durI 0.42], ...                   % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventI(i) + txOffset, ty0, sprintf('Indiv %d', i));                  % create condition label
end

for i=1:1:length(eventR)
  x = [eventR(i) eventR(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th resting condition
  line(x+durR, y, 'Color', 'white');                                        % end of i-th resting condition
  rectangle('Position', [eventR(i) recty0 durR 0.42], ....                  % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventR(i) + txOffset, ty0, sprintf('Rest %d', i));                   % create condition label
end

for i=1:1:length(eventT)
  x = [eventT(i) eventT(i)];
  line(x, y, 'Color', 'white');                                             % start of i-th resting condition
  line(x+durT, y, 'Color', 'white');                                        % end of i-th resting condition
  rectangle('Position', [eventT(i) recty0 durT 0.42], ....                  % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventT(i) + txOffset, ty0, sprintf('Conver %d', i));                 % create condition label
end

end
