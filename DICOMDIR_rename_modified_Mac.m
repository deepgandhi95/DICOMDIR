%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Authors: Deep B. Gandhi
%Last modified date: 9/25/2018
%Last modified by: Deep B. Gandhi
%Purpose: Parses the DICOMDIR file to obtain the directory record sequence
%and directory record type for each sequence, copies DICOM
%files based on the particular sequence type for each subject
%Inputs: DICOMDIR file
%Outputs: Folders containing DICOM files based on the direcory record type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

info = dicominfo('DICOMDIR');
%%
% Read the DirectoryRecordSequence structure until end,
% and read the all included DirectoryRecordType items sequentially
FN = fieldnames(info.DirectoryRecordSequence);
h = waitbar(0,'...');
for i = 1:length(FN);
    switch info.DirectoryRecordSequence.(FN{i}).DirectoryRecordType
        case 'PATIENT'
            cpdir = info.DirectoryRecordSequence.(FN{i}).PatientID;
            csdir = '';
            if ~isdir(cpdir)
                mkdir(cpdir)
            end
        case 'STUDY'
            cddir = info.DirectoryRecordSequence.(FN{i}).StudyDate;
            csdir = '';
            if ~isdir(fullfile(cpdir,cddir))
                mkdir(fullfile(cpdir,cddir))
            end
        case 'SERIES'
            SERIES = info.DirectoryRecordSequence.(FN{i});
            sn = num2str(SERIES.SeriesNumber);
            st = SERIES.SeriesDescription;
            suid = strsplit(SERIES.SeriesInstanceUID,'.');
            csdir = [sn '_' st '_' suid{10}];
            if ~isdir(fullfile(cpdir,cddir,csdir))
                mkdir(fullfile(cpdir,cddir,csdir))
            end
        case 'IMAGE'
            fname = info.DirectoryRecordSequence.(FN{i}).ReferencedFileID;
            if ~ispc
                fname = strrep(fname,'\','/');
            end
            switch length(sn)
                case '3 or 4-digit series'
                     if length(sn)==3
                     snf = ['0' sn];
                     elseif length(sn)==4
                     snf = sn;
                     else
                     continue
                     end 
                 case '6 or 7-digit series' 
                      if length(sn)==6
                      snf = ['0' sn];
                      elseif length(sn)==7
                      snf = sn;
                      else
                      continue
                      end
            end 
            in = info.DirectoryRecordSequence.(FN{i}).InstanceNumber;
            in = num2str(in,'%06.f');
            im = ['MR' sn in '.dcm'];
            [err,msg] = system(['cp ' fname ' "' fullfile(cpdir,cddir,csdir,im) '"']);
        case 'PRIVATE'
            fname = info.DirectoryRecordSequence.(FN{i}).ReferencedFileID;
            if ~ispc
                fname = strrep(fname,'\','/');
            end
            [~,im] = fileparts(fname);
            [err,msg] = system(['cp ' fname ' "' fullfile(cpdir,cddir,csdir,[im '.dcm']) '"']);
    end
    waitbar(i/length(FN),h,['Processing ' strrep(csdir,'_','\_') '...'])
end
close(h);