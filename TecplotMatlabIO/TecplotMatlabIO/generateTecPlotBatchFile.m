function generateTecPlotBatchFile(macroFileName, fileTypeFilter)
% generate dos/bash file for batching processing  all files with 'fileTypeFilter' in current folder 
% macor file must be executable and  in the current folder containing data files
% layout file need to be updated in tec360 for each group of cases
% the layout file must have a name as: 'layout.lay'  in curernt folder or  '../layout.lay' in upper folder
% %%%%%%%%%%%%%%% tec360 cmd line%%%%%%%%%%%%%%%%%%%%
% tec360 -b -p batch.mcr -y psoutput.ps batch.lay mydatafile.
%  -y does not overwrite the export file name in macro file. 
%  -> delete/comment out the macro line  $!EXPORTSETUP EXPORTFNAME = ""
% if $! QUUIT is missing , tec360 can not quit automatically 
% %%%%%%%%%%%%%%%%%%% sample macro file%%%%%%%%%%%%%%
% #!MC 1200   
% # tecplot version number: 1200 -> only ver no>1200 can play it
% # Created by Tecplot 360 build 12.1.0.6712
% $!VarSet |MFBD| = 'D:\Program Files\Tecplot\Tec360 2009\bin'
% $!EXPORTSETUP EXPORTFORMAT = JPEG
% $!EXPORTSETUP IMAGEWIDTH = 706
% #$!EXPORTSETUP EXPORTFNAME = 'export.jpg'
% $!EXPORT 
%   EXPORTREGION = CURRENTFRAME
% $!RemoveVar |MFBD|
% $!QUIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tecplotBatchCMD = 'tecplot -b ';
tecplotBatchCMD = 'tec360 -b ';  %
outputFileType = '.jpg';

% some time the output file name can not been reached by '-y' option, =>
   needRenameByDOS = true;  % for PLIF contour data, need not rename process, output file has been specified
   defaultExportFname = 'export.*';
   
% identify OS   os=computer;
if ispc  % windows OS 
    renCMD = 'ren ';   % mv for linux
    newlinechar = '\n'; % '\r\n' for linux
    batchFileHeader='@echo off \n';
   batchFileSuffix= '.bat'
elseif isunix
     renCMD = 'mv ';   % mv for linux
     newlinechar = '\r\n'; % '\r\n' for linux and macOSX
     batchFileHeader= [ '#!/bin/sh', newlinechar];
     batchFileSuffix= '.sh';
else
     error('Failure to identify the OS, not windows, not Unix-like OS');
end

% batch file name
if nargin == 2
    fileFilter=fileTypeFilter;
    macrofile = macroFileName;
elseif   nargin == 1  
    fileFilter = '*.dat';
    macrofile = macroFileName;
else   
    fileFilter = '*.dat';
    macrofile = '../exportJPG.mcr';
end
   
[p,macroFileStem,suffix]=fileparts(macrofile);
batchFileName = strcat( macroFileStem,batchFileSuffix);

%layoutfile = '../layout.lay';
%layoutfile = 'tecplot625layout.lay';
if exist('layout.lay','file') 
    layoutfile = 'layout.lay';
elseif exist('../layout.lay','file') 
    layoutfile =  '../layout.lay';
else
    layoutfile = ' *.lay'; % using *.lay to match
end

% get the files list of date files
FileNames = dir(fileFilter);
if ( isempty(FileNames) == true )
    FileNames = dir(fileFilter2);
end
    
number_of_files = length(FileNames);
if( number_of_files == 0)
    disp('Warning!:  no data file found in this folder')
    return
end

fp = fopen(batchFileName,'wt');
fprintf(fp, batchFileHeader);
for k=1:number_of_files
    datafileName = FileNames(k).name; 
    
    % rename the file, if there is % in the file name, % make trouble in  horzcat()
    if size(strfind(datafileName, '%'),2) ~= 0
    new_datafileName = strrep(datafileName, '%','percent');
    movefile(datafileName,new_datafileName);
    datafileName = new_datafileName;
    end
    
    szFileName=size(datafileName,2)-4;   % truncate .dat -> ExtractFileNameStemAndSuffix
    fStemName = datafileName(1:szFileName);
    outputFileName = strcat( fStemName , '__',macroFileStem,outputFileType );
    % strcat strip the blank, -> matrix concatenation (horzcat),
    % or enclose  the string in {} which will tell strcat to respect spaces.
   % 
   % file name may get blanks, so double quote sing may needed
   if needRenameByDOS == true
   cmdline = horzcat( [tecplotBatchCMD ,' -p  ' , macrofile , '  ', layoutfile ,'  ','"',datafileName,'"', newlinechar ]);
   fprintf(fp, cmdline);
    renmeline = horzcat( [ renCMD,  ' ', defaultExportFname, ' "',outputFileName,'"', newlinechar ]);
   fprintf(fp, renmeline);
   else
          cmdline = horzcat( [tecplotBatchCMD ,' -p  ' , macrofile , ' -y  ', '"',outputFileName,'"', '  ', layoutfile ,'  ','"',datafileName,'"', newlinechar ]);
          fprintf(fp, cmdline);
   end
end 
fclose(fp);
%chmod +x 
end

