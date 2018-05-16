function badChannels = CARE_pulseQualityCheck( data, SD, t )
% CARE_PULSEQUALTITYCHECK is a function for a visual data quality check. It
% will display the time frequency response of all nirs channels. Using this
% figure the user can  assess, whether the plots show pulse activity or not 
% and exclude certain channels from further analyses.
%
% Use as
%   badChannel = CARE_pulseQualityCheck( data, SD )
%
% where data has to be motion corrected optical density data, SD the
% source/detector definition and t the corresponding time vector
%
% SEE also HMROD2CONC

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Convert changes in OD to changes in concentrations (HbO, HbR, and HbT)
% -------------------------------------------------------------------------
ppf   = [6 6];                                                              % partial pathlength factors for each wavelength.
data  = hmrOD2Conc(data, SD, ppf);

% -------------------------------------------------------------------------
% Extract hbo
% -------------------------------------------------------------------------
hbo = squeeze(data(:,1,:));

% -------------------------------------------------------------------------
% Estimate and show time-frequency responses of all channels
% -------------------------------------------------------------------------
for i = 1:1:size(hbo, 2)
  subplot(4,4,i);
  sig = [t, hbo(:,i)];
  sigma2=var(sig(:,2));                                                     % estimate signal variance
  
  [wave,period,~,coi,~] = wt(sig);                                          % compute wavelet power spectrum
  power = (abs(wave)).^2 ;
  
  for j=1:1:length(coi)
    wave(period >= coi(j), j) = NaN;                                        % set values below cone of interest to NAN
  end

  h = imagesc(t, log2(period), log2(abs(power/sigma2)));
  colorbar;
  Yticks = 2.^(fix(log2(min(period))):fix(log2(max(period))));
  set(gca,'YLim',log2([min(period),max(period)]), ...
          'YDir','reverse', 'layer','top', ...
          'YTick',log2(Yticks(:)), ...
          'YTickLabel',num2str(Yticks'), ...
          'layer','top')
  title(sprintf('Channel %d', i));
  ylabel('Period in seconds');
  xlabel('Time in seconds');
  set(h, 'AlphaData', ~isnan(wave));

  colormap jet;
end
set(gcf,'units','normalized','outerposition',[0 0 1 1])                     % maximize figure

badChannels = CARE_channelCheckbox();
close(gcf); 

end
