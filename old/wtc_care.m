function wtc_care(ndyad,old)
%% load subject file
%% Extract hbo time series from dc variable in subject file

load(['CARE_fNIRS_',ndyad,'1.mat'])
hbo1=squeeze(dc(:,1,:));

load(['CARE_fNIRS_',ndyad,'2.mat'])
hbo2=squeeze(dc(:,1,:));


load('fillsignal.mat')

if old==1
    load(['/Users/trinhnguyen/MATLAB/Add-Ons/care',ndyad,'markers.mat'])
    markers=caremarkers(1:7,:)
    hbo=squeeze(dc(:,1,:));
    
else
   
marker11=find(s(:,2)>0)
marker12=find(s(:,3)>0)
marker13=find(s(:,4)>0)
%marker14=find(s(:,5)>0)

markers=[marker11; marker12; marker13]
end
%% calculate wtc plot to see Frequency of interest
% loop doesn't work as error comes up
% mcc set to zero to make calculations faster
%%hold on
c1=markers(1);
c2=markers(2);
i1=markers(3);
i2=markers(4);
r1=markers(5);
r2=markers(6);
r3=markers(7);

%for ch=1:16
%wtc(hbo1(:,ch),hbo2(:,ch),'mcc',0);
%hold on
%line([c1 c1], [4 2048], 'Color','blue')
%line([c1+eve c1+eve], [4 2048], 'Color','blue')

%line([c2 c2], [4 2048], 'Color','blue')
%line([c2+eve c2+eve], [4 2048], 'Color','blue')

%line([i1 i1], [4 2048], 'Color','red')
%line([i1+eve i1+eve], [4 2048], 'Color','red')

%line([i2 i2], [4 2048], 'Color','red')
%line([i2+eve i2+eve], [4 2048], 'Color','red')

%line([r1 r1], [4 2048], 'Color','yellow')
%line([r2 r2], [4 2048], 'Color','yellow')
%line([r3 r3], [4 2048], 'Color','yellow')
%line([r1+basel r1+basel], [4 2048], 'Color','yellow')
%line([r2+basel r2+basel], [4 2048], 'Color','yellow')
%line([r3+basel r3+basel], [4 2048], 'Color','yellow')
%pause;

%end;



%% prepare matrix for CI 
cohin=zeros(1,6)

%%  find period of interest
[Rsq,period,scale,coi,sig95]=wtc(hbo1(:,16),hbo2(:,16),'mcc',0); 


period32 = find(period>32);
period32 = period32(1);
period128 = find(period>128);
period128 = period128(1);

period256 = find(period>256);
period256 = period256(1);
period1000 = find(period>1000);
period1000 = period1000(1);


%% loop to calculate CI for every channel in a dyad
for ch=1:16
[Rsq,period,scale,coi,sig95]=wtc(hbo1(:,ch),hbo2(:,ch),'mcc',0);



% calculate mean activation in frequency band of interest
% collaboration condition
b1 = mean(mean(Rsq(period256:period1024, c1:c1+eve)));
b2 = mean(mean(Rsq(period256:period1024, c2:c2+eve)));

b3 = mean(mean(Rsq(period32:period128, c1:c1+eve)));
b4 = mean(mean(Rsq(period32:period128, c2:c2+eve)));
% individual condition
bs1 = mean(mean(Rsq(period256:period1024, i1:i1+eve)));
bs2 = mean(mean(Rsq(period256:period1024, i2:i2+eve)));

bs3 = mean(mean(Rsq(period32:period128, i1:i1+eve)));
bs4 = mean(mean(Rsq(period32:period128, i2:i2+eve)));
% baseline
bi1 = mean(mean(Rsq(period256:period1024, r1:r1+basel)));
bi2 = mean(mean(Rsq(period256:period1024, r2:r2+basel)));
bi3 = mean(mean(Rsq(period256:period1024, r3:r3+basel)));
bi4 = mean(mean(Rsq(period32:period128, r1:r1+basel)));
bi5 = mean(mean(Rsq(period32:period128, r2:r2+basel)));
bi6 = mean(mean(Rsq(period32:period128, r3:r3+basel)));


% calculate coherence increase by substracting baseline from event
collab = (b1+b2)/2;
individual = (bs1+bs2)/2; 
baseline= (bi1+bi2+bi3)/3;
CI=collab-baseline;
CSI=individual-baseline;
CCI = collab - individual;

%collab_fr = (b3+b4)/2;
%individual_fr = (bs4+bs3)/2; 
%baseline_fr= (bi4+bi5+bi6)/3;
%CI_fr=collab_fr-baseline_fr;
%CSI_fr=individual_fr-baseline_fr;
%CCI_fr = collab_fr - individual_fr;
%save values in cohin variable
cohin(ch,1:6)=[collab, individual, baseline, CI,CSI, CCI]
end

% save cohin for dyad in file
save(['/Users/trinhnguyen/MATLAB/data/results/CI/cohincare',ndyad,'.mat'],'cohin')