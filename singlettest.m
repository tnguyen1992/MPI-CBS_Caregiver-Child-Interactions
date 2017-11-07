function  singlettest(tId,old,ndyad)
%% 2-6: old=1
%% load CARE File
load(['Users/trinhnguyen/MATLAB/data/Processed/CARE_fNIRS_',tId,'.mat'])

%% Extract markes
load('/Users/trinhnguyen/MATLAB/Add-Ons/contrast.mat')
load('/Users/trinhnguyen/MATLAB/Add-Ons/fillsignal.mat')
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

%% adapt s variable 
% change of triggers
x=s(:,1:3);

%% Fill signal with duration of events
x(markers(1):markers(1)+eve,1)=1;
x(markers(2):markers(2)+eve,1)=1;

x(markers(3):markers(3)+eve,2)=1;
x(markers(4):markers(4)+eve,2)=1;

x(markers(5):markers(5)+basel,3)=1;
x(markers(6):markers(6)+basel,3)=1;
x(markers(7):markers(7)+basel,3)=1;

%x(markers(8):markers(8)+eve,4)=1;

%% Choose channel (1-16)
topo=zeros(1,4);


for ch=1:16
y=(hbo(:,ch));

%T value of a single subject
%define x
%x is a matrix, the columns are the conditions and rows are all measured
%time frames > x corresponds to s in the processed file
%y is the signal in a single channel

[a,b,c] = glmfit(x,y);

%beta value, the T value, and the p-value of each individual condition
beta = a(2:end);
T = c.t(2:end);
p = c.p(2:end);

%contrast between conditions
%covb = c.covb(2:end, 2:end);

%contrast is a matrix that contains all wanted contrasts between conditions
%V = contrast  * covb * contrast';

%T-value of the contrast
%T = (beta * contrast') / sqrt(V) * sqrt(length(x));

%% save variables
topo(ch,1)=ch;
topo(ch,2:4)=beta;

end

%% plot t values

%figure;bar([T,ch])

%% save data


save(['/Users/trinhnguyen/MATLAB/data/results/beta/tbCARE_',tId,'.mat'],'topo')
