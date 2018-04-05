function h=plotTraces(signal, channel, markers, traceColors, time)
% function plotTraces(signal, channel, markers, traceColors, time)
% signal: NxM matrix, where M is # of channels
% channel: the channels to be plot
% markers: Px1 vector or Px2 matrix of event onset (in unit
% scan). If Px2, then the 1st column is event type and it can be 1, 2, 3,
% etc
% traceColors: colors of each traces (optional), Nx3 array. If not
% specified, use default.
% time: the x-axis. if notn specified, use default 1:length(signal)
% 
% Xu Cui
% 2009/07/23

if(~exist('channel'))
    channel = 1:size(signal,2);
end
if(~exist('time'))
    time = 1:size(signal,1);
end

kk = 0;
for ch=channel
    kk = kk+1;
    %subplot(length(channel),1,kk);
    %plot(signal(:,ch) - kk*.2);
    %hold on;
    signal(:,ch) = signal(:,ch) + kk*1;
end

if(exist('traceColors'))
    for ii=1:length(channel)
        h=plot(time, signal(:,channel(ii)),'color',traceColors(ii,:));
        hold on;
    end
else
    plot(time,signal(:,channel))
end


if nargin < 3
    return;
end

m = markers;
hold on;
if(size(m,2)==1)
    for jj=1:length(m)
        line([m(jj) m(jj)],[0 kk+1],'color','m', 'LineStyle', ':');
    end
else
    colors = 'rbgm';
    colors = repmat(colors, 1, 100);
    for jj=1:size(m,1)
        line([m(jj,2) m(jj,2)],[0 kk+1],'color',colors(m(jj,1)), 'LineStyle', ':');
    end
end
