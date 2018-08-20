function [x, y, Vx, Vy,CHS] = TranslateTecPlotVectorDatToVelMat(case_file, rows, cols)
% deserialize my tecplot vec file into 2D matrix of  Vx, Xy, and row vector [x, y ]
%  Nx=cols=IMAX;

    if (nargin == 1)
         % ------------just extract the Nx Ny the dim of the 2D vel contour-------
        vecdata =importdata(case_file);
        if iscell(vecdata.textdata)
            filehead= vecdata.textdata{1};
        else
           filehead= vecdata.textdata; 
        end 
        [cols,rows] = ExtractTecPlotVecDim(filehead);
    elseif (nargin == 0)
        disp('please specify the input parameter, case_file, rows, cols');
    end 
    %------------------------- vec import ---------------
    % importdata() is embedded function of matlat, return a struct {data, textdata}
    %importdata looks at the file extension to determine which reader to use
    %------------ 

    % read the processed PIV file, 
    vecdata =importdata(case_file);
    data= vecdata.data;
    
    Nx=cols;
    Ny=rows;
    
    x = zeros(1,cols);
    y = zeros(1,rows);
    Vx = zeros(rows,cols);
    Vy = zeros(Ny,Nx);
    CHS = zeros(Ny,Nx);

    CHS_index = size(data, 2);
    CHSspecified = false;
    defaultCHS = 1;
    
    if CHS_index>4
        CHSspecified = true;
    end
    % the tecPiv need the y coord to be descending
    % should make X/col as outer loop, since matlab matrix is col major memory structure

    for r=rows:-1:1  % rows
       index = (r-1)*cols + 1;    % if Vx and Vy are 1D vector  
       y(r) = data(index,2);  
       Vx(r,:) = data(index:cols*r,3);
       Vy(r,:) = data(index:cols*r,4);
       if CHSspecified
            CHS(r,:) = data(index:cols*r,CHS_index);
       else
            CHS(r,:) = defaultCHS;
       end
        % the first Y coord is Y max, 
       % y_pos = y_end - height * ((i-1)/(row-1));  
    end
    for c=1:cols  % Ny
          
          x(c) = data(c,1);
          % x_pos = x0+width * ((j-1)/(col-1));  % it is for uniform
          % spacing
    end
end % function 