function [X, Y, Vx, Vy, CHS]=loadTecPlotVecFile(case_file, option)
%  return  2D matrices:   X, Y  Vx, Xy, 
%  TranslateTecPlotVectorDatToVelMat() return: Row vector [x, y ] and 2D matrix of  Vx, Xy, 
%  options:    value for invalid vector cell ? 'zero' , 'inf' 'nan'
%  
% extract the I and J index, I is for X coord, it that a must in tecplot?
% ExtractTecPlotVecDim(filehead) is done inside 

InvalidVectorFlag=0;
InvalidVectorValue=0.0;
extendingXandYTo2DMatrix =false;
debug=false;

if nargin < 2
   option='zero'; % 'zero' , 'inf' 'nan'
end

[x_, y_, Vx, Vy, CHS] = TranslateTecPlotVectorDatToVelMat(case_file);
%deserialize my tecplot vec file into 2D matrix of  Vx, Xy, and row vector [x, y ]

% tecplot dis not support  nan or inf for no valid data point!!!
if ( strcmp(option ,'nan') )   % not sure strcmp return value, int or bool? YES, not like C
    % compares the strings S1 and S2 and returns logical 1  (true)
    % invalid vector is set as zero ! CHS=0; 
    InvalidVectorValue = nan;
elseif  ( strcmp(option ,'inf') ) 
    InvalidVectorValue = inf;
elseif   ( strcmp(option ,'zero') )
    InvalidVectorValue = 0.0;
end


for j=1:size(Vx,1)
     for i=1:size(Vx,2)
        if CHS(j,i)== InvalidVectorFlag
            Vx(j,i)=InvalidVectorValue;
            Vy(j,i)=InvalidVectorValue;
        end
     end
end 

if extendingXandYTo2DMatrix
    if size(x_,2) > 1 && size(x_,1) == 1
        X=zeros(size (Vx));  
        for ix=1:size(Vx, 1)
           X(ix, :) = x_;
        end 
        disp('X axis is extended to 2D matrix');
    end

    if size(y_,1) == 1 || size(y_,2) == 1    
        Y=zeros(size(Vx));
        for iy=1:size(Vx, 2)
            Y(:,iy) = y_;
        end
    end
else % X and Y is already 2D , or need NOT to extend
    X=x_;
    Y=y_;
end


% debug info 
if debug
  disp('dim of Vel on X axis');  disp( size(Vx) );
  disp('dim of X axis');  disp(size(X));
  disp('dim of Y axis');  disp(size(Y));
end

end

