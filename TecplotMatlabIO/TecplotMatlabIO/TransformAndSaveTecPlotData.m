function TransformAndSaveTecPlotData(image,rect,fileNameFullPath,varNameHeader)
%write transformed  2D image matrix, the first two dim are the coodinates,
% Usually `image` is a 2D matrix for the measurement scalar data: T, conc. 
% if there is more data, change the `image` to 3D array
% rect=[x_min, y_min, width, height] the physical region
% corresponding to  the image ROI, !!! 
% since  after imread() , image(0,0) is the left top corner
% make sure you have flipud(im) outside before this function!!!
% varNameHeader is an optional parameter, default for PLIF: 'VARIABLES="X/h" "Y/h" "Conc.(mg/L)"';
%
%------------------ data format of tecPlot---------
%TITLE="This is a title"
%VARIABLES="X" "Y" "concentration"
%zone i=5, j=4, DATAPACKING=POINT
% In order to show contour,  J must be bigger than 1,  i.e. 2D data format
%-------------------------------------------------

% fid = fopen(filename) open binary file on default.
% fid = fopen(filename, permission_tmode) on Windows systems,
% opens the file in text mode instead of binary mode (the default).
% On UNIX, text and binary mode are the same.

if nargin <4
    varNameHeader='VARIABLES="X/h" "Y/h" "Conc.(mg/L)"';
end

x_min=rect(1);
y_min=rect(2);
width=rect(3)-rect(1);
height=rect(4)-rect(2);

[in,jn]=size(image);

 pathDelimit = '\';
 cells = regexp(fileNameFullPath,pathDelimit,'split');
 title  =  char( cells(end) );
%title = fileName;

%
fid=fopen(fileNameFullPath,'wt');
if (fid<=0)
    error(strcat('can not open the file for write: ',fileName ));
end
%why I can not write a return/end of line to the file by \n
fprintf(fid,'TITLE="%s"',title); 
fprintf(fid,'\t');
fprintf(fid,varNameHeader);
fprintf(fid,'\t');
% as I save (x,y,conc) as one point, so the data is 1 dim in tecPlot
fprintf(fid,'zone i=%i,j=%i, DATAPACKING=POINT',in,jn);
fprintf(fid,'\n');

for j=1:jn
    for i=1:in      
       x = x_min+width * ((j-1)/(jn-1));
       y = y_min+height * ((i-1)/(in-1));
       fprintf(fid,'%f \t %f \t %f \n',x,y,image(i,j));   % can print vector
    end
end 

%     fprintf(fid,'\n');  % print TEXT field
fclose(fid);

end


