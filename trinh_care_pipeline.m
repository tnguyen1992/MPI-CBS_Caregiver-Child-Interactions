%% Trinh CARE Pipeline
%NIRx to NIRS (ab care_20 müsste es eine nirs Datei geben)
%NIRx_foldername='/Users/trinhnguyen/MATLAB/data/RAW/CARE_19/Subject1'
%SD_filename='/Users/trinhnguyen/MATLAB/data/NIRS/CARE.SD'
%outname='/Users/trinhnguyen/MATLAB/data/NIRS/care191.nirs'
%NIRx2nirs(NIRx_foldername, SD_filename,outname)

%% Stanford Pipeline Preprocessing
% Output processed files (filtered, corrected, hbo converted)
tId='0922'
nirsFile=['/Users/trinhnguyen/MATLAB/data/NIRS/care',tId,'.nirs']
cibsrEcho_hmrPipeline(nirsFile,tId)

%% Individual task-related activation
% output T values of contrasts and beta values
% dyads 2-6: old=1

singlettest(tId, old,ndyad)

%% WTC Analysis
% output coherence increase values and coherence values 
wtc_care(ndyad,old)
