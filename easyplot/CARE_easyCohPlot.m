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
%   cfg.channel     = number of channel (1 to 16) (default: 1)
%   cfg.considerCOI = true or false, if true the values below the cone of
%                     interest will be set to NaN
%
% See also CARE_WTC

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
channel     = CARE_getopt(cfg, 'channel', 1);
considerCOI = CARE_getopt(cfg, 'considerCOI', true);

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
eventS = t(data.cfg.evtStop);                                               % extract stop markers
eventP = t(data.cfg.evtPreschoolForm);                                      % extract event markers of preschool from condition

durC = t(data.cfg.durCollaboration + 1);                                    % extract duration of collaboration condition
durI = t(data.cfg.durIndividual + 1);                                       % extract duration of individual condition
durR = t(data.cfg.durRest + 1);                                             % extract duration of resting condition
if data.cfg.durTalk > 0
  durT = t(data.cfg.durTalk + 1);                                           % extract duration of conversation condition
else
  durT = [];
end
if data.cfg.durPreschoolForm > 0
  durP = t(data.cfg.durPreschoolForm + 1);                                  % extract duration of preschool form condition
else
  durP = [];
end
% -------------------------------------------------------------------------
% Create coherence plot
% -------------------------------------------------------------------------
sigPart1 = [t, hbo1(:,channel)];
sigPart2 = [t, hbo2(:,channel)];

if considerCOI
  [Rsq,period, ~, coi, ~] = wtc(sigPart1, sigPart2, 'mcc', 0, 'as', 0, ...
                                'ahs', 0);

  for i=1:1:length(coi)
    Rsq(period >= coi(i), i) = NaN;
  end

  h = imagesc(t, log2(period), Rsq);
  set(gca,'clim',[0 1]);
  colorbar;
  Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
  set(gca,'YLim',log2([min(period),max(period)]), ...
          'YDir','reverse', 'layer','top', ...
          'YTick',log2(Yticks(:)), ...
          'YTickLabel',num2str(Yticks'), ...
          'layer','top')
  ylabel('Period in seconds');
  xlabel('Time in seconds');
  set(h, 'AlphaData', ~isnan(Rsq));
else
  wtc(sigPart1, sigPart2, 'mcc', 0, 'as', 0, 'ahs', 0);
end

colormap jet;

getAxis   = gca;
y         = getAxis.YLim;
recty0    = 0.068 * (y(2) - y(1)) + y(1);
txOffset  = 50 * (t(2) - t(1));
ty0       = 0.086 * (y(2) - y(1)) + y(1);

for i=1:1:length(eventC)
  x = [eventC(i) eventC(i)];
  line(x, y, 'Color', 'black');                                             % start of i-th collaboration condition
  if isempty(eventS)
    timePeriod = durC;
  else
    timePeriod = eventS(find(eventS > eventC(i), 1)) - eventC(i);
  end
  line(x+timePeriod, y, 'Color', 'black');                                  % end of i-th collaboration condition
  rectangle('Position', [eventC(i) recty0 timePeriod 0.42], ....            % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventC(i) + txOffset, ty0, sprintf('Collab %d', i));                 % create condition label
end

for i=1:1:length(eventI)
  x = [eventI(i) eventI(i)];
  line(x, y, 'Color', 'black');                                             % start of i-th individual condition
  if isempty(eventS)
    timePeriod = durI;
  else
    timePeriod = eventS(find(eventS > eventI(i), 1)) - eventI(i);
  end
  line(x+timePeriod, y, 'Color', 'black');                                  % end of i-th individual condition
  rectangle('Position', [eventI(i) recty0 timePeriod 0.42], ...             % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventI(i) + txOffset, ty0, sprintf('Indiv %d', i));                  % create condition label
end

for i=1:1:length(eventR)
  x = [eventR(i) eventR(i)];
  line(x, y, 'Color', 'black');                                             % start of i-th resting condition
  if isempty(eventS)
    timePeriod = durR;
  else
    timePeriod = eventS(find(eventS > eventR(i), 1)) - eventR(i);
  end
  line(x+timePeriod, y, 'Color', 'black');                                  % end of i-th resting condition
  rectangle('Position', [eventR(i) recty0 timePeriod 0.42], ....            % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventR(i) + txOffset, ty0, sprintf('Rest %d', i));                   % create condition label
end

for i=1:1:length(eventT)
  x = [eventT(i) eventT(i)];
  line(x, y, 'Color', 'black');                                             % start of i-th resting condition
  if isempty(eventS)
    timePeriod = durT;
  else
    timePeriod = eventS(find(eventS > eventT(i), 1)) - eventT(i);
  end
  line(x+timePeriod, y, 'Color', 'black');                                  % end of i-th resting condition
  rectangle('Position', [eventT(i) recty0 timePeriod 0.42], ....            % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventT(i) + txOffset, ty0, sprintf('Conver %d', i));                 % create condition label
end

for i=1:1:length(eventP)
  x = [eventP(i) eventP(i)];
  line(x, y, 'Color', 'black');                                             % start of i-th resting condition
  if isempty(eventS)
    timePeriod = durP;
  else
    timePeriod = eventS(find(eventS > eventP(i), 1)) - eventP(i);
  end
  line(x+timePeriod, y, 'Color', 'black');                                  % end of i-th resting condition
  rectangle('Position', [eventP(i) recty0 timePeriod 0.42], ....            % create rectangle for condition label
            'FaceColor',[1 0.95 0.87], 'EdgeColor', [0.1 0.1 0.1]);
  text(eventP(i) + txOffset, ty0, sprintf('Preschool %d', i));              % create condition label
end

end
