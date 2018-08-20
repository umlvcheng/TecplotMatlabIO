function ProcessImagesInFolderByTecPlot(inputTemplateMacroFile, ROI)
% this function must be called after cd to the work folder contains iamges
% layout/macro tecplot file need to be updated in tec360 for each group of case
% you need to set the ROI, RIO_tecplot_export in this .m file
% ROI =[left, upper, width, height]
% and set physica_dim=[xmin, xmax,ymin,ymax] in macro file
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tec360 -b -p batch.mcr
% input and output file name is set in an automatic generated macro file
% see also ReviseTecPlotMacroFile.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin == 0  % set default var for parameters
    inputTemplateMacroFile = 'SetCoordAndAxisForImage.mcr';
    ROI = [398,22,332,590];
    % cropping ROI, unit pixel, if no ROI param, it will not crop image
end

%physica_dim=[xmin, xmax,ymin,ymax];
xmin = -2.5;
xmax =  2.5;
ymin = -4.5;
ymax = 4.5;
% physica_dim=[-2.5, 2.5,-5,5];  direct edit the macro file of tecplot
usingMatlab = 0;
RIO_tecplot_export=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% varargin - Variable length input argument list, cell array
% input file types:
fileFilter = '*.jpg';  % for image loader addon
fileFilter2 = '*.dat';
%
outputSuffix = '_processed';
outputFileType = '.jpg';

%layoutfile = '../layout.lay';
if exist('layout.lay','file') 
    layoutfile = 'layout.lay';
else
    layoutfile = ' '; % no layout is need for image loader addon
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tecplotBatchCMD = 'tecplot -b ';
tecplotBatchCMD = 'tec360 -b ';

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


for k=1:number_of_files
    datafileName = FileNames(k).name; 
    
    % rename the file, if there is % in the file name, % make trouble in  horzcat()
    if size(strfind(datafileName, '%'),2) ~= 0
    new_datafileName = strrep(datafileName, '%','percent');
    movefile(datafileName,new_datafileName);
    datafileName = new_datafileName;
    end
    
    inputImageFile=datafileName;
    szFileName=size(inputImageFile,2)-4;   % truncate .dat .bmp
    fStemName = inputImageFile(1:szFileName);
    outputFileName = strcat( fStemName , outputSuffix);
    outputFileName = strcat( outputFileName  , outputFileType );
    % strcat strip the blank, -> matrix concatenation (horzcat),
    % or enclose  the string in {} which will tell strcat to respect spaces.
   % 
   % file name may get blanks, so double quote sing may needed
   tmpImage='./tmp.bmp';
   CropAndSaveImage(inputImageFile,ROI,tmpImage);
   
   if usingMatlab
       SetPhysicalDimensionsToImage(tmpImage, xmin, xmax,ymin,ymax,'jpg');
   else % tecPlot     
       tmpMacroFile = './tmp.mcr';
       %call the set var for macro file
       ReviseTecPlotMacroFile(inputTemplateMacroFile, tmpImage,outputFileName,  tmpMacroFile);
       cmdline = horzcat( [tecplotBatchCMD , layoutfile,  tmpMacroFile] );
       dos(cmdline);
   end
   % remove/del tmpMacroFile
   CropAndSaveImage(outputFileName,RIO_tecplot_export,outputFileName);
   %%cmdline = horzcat( [tecplotBatchCMD ,' -p  ' , macrofile ,  '  ',
   %%layoutfile ,'  ','"',datafileName,'"', ' -y  ', '"',outputFileName,'"', '\n' ]);

end 

end

