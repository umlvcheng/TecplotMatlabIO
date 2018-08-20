function PIVSaveAsTecPlotVecFile(saveFileName,X,Y,Vx,Vy,vecStatusFlag,varlistheader)
% Save 2D vector data[x y u v] to 1D tecplot text data, keeping the CHS(vecStatusFlag) flags 
% it is easy to calc vorticity wrong, since the X unit and vel unit may not not SI units
%using tecplot to calc them !
% x and y can be 1D array or 2D mat, x is column vector and y is row vector
% the vorticity calculation is not done, but easy to be calcuated in tecplot 
% also the coord unit is not sure in metre, so process only u and dimenless, 
% the index is very confusing, but user need not care this 



MagVorticityEnable=false; 
% it is easy to calc vorticity wrong, since the X unit and vel unit may not not SI units
%using tecplot to calc them !

vecStatusFlagSpecified = false; % defaul to 1, that each point is valid!
DefaultvecStatusFlag = 1.0;
InvalidVectorFlag=0;

InvalidVectorValue=nan;  % it is the conventional value for bad data point
% tecplot dis not support  nan or inf for no valid data point!!!

vel_mag_filter_enable = false;
vel_mag_threshold = 0.5;   % ??



if nargin <7
      varlistheader='VARIABLES="X/h" "Y/h" "U m/s" "V m/s"  "vecStatusFlag"';
end

if nargin >=6
vecStatusFlagSpecified = true;
CHS=vecStatusFlag;
end

if nargin <5
    error('please specify saveFileName and 2D matrices:  x,y,u,v ');
else
    % dim check, all same and count >1
end

% debug info 
disp('dim of Vel on X axis');  disp( size(Vx) );
disp('dim of X axis');  disp(size(X));
disp('dim of Y axis');  disp(size(Y));




if vecStatusFlagSpecified == false
    CHS=ones(size(Vx));  % 
    CHS(:,:)= DefaultvecStatusFlag; % mat assign to a scalar!
end

x_count=size(Vx,2); % column count, 
% when processing x(j,i), j must be process first for high effeciency
y_count=size(Vx,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%x and y can be 1D array or 2D mat, x is column array and y is row array
%matlab distinguish x and X, different varable name
if size(X,2) > 1 % it is 2D, but work just as column arry: [1 2 3] 
    x=X(1,:);
elseif size(X,1) > 1 && size(X,2) ==1
    x=X(:,1);  
end

% extract X and Y , 
if size(Y,2) > 1 && size(Y,1) > 1  % this is 2D 
    y=Y(:,1); 
elseif  size(Y,1) == 1  %   column arry: [1 2 3]
   y=Y(1,:);        
elseif size(Y,2) == 1      % row array [1;2;3]
    y=Y(:,1);  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=fopen(saveFileName,'wt');
if (fid<=0)
    error('can not open the file for write, return');
end

title = saveFileName;
%why I can not write a return/end of line to the file by \n
fprintf(fid,'TITLE="%s"',title); 
fprintf(fid,varlistheader);
% as I save (x,y,conc) as one point, so the data is 1 dim in tecPlot
fprintf(fid,'zone i=%i,j=%i, DATAPACKING=POINT',x_count,y_count);
fprintf(fid,'\n');

% ------save the data matrix, only five elements per line----
% vec file is row-first saving, and Y decrease from Ymax to Ymin
% also, a  grid of uniform space is presumpted, using 'x_pos = x0+width * ((j-1)/(col-1));'
% infact, it is not always true. 

% the tecPiv need the y coord to be descending

if MagVorticityEnable
%--------------build Vorticity-------------
% forward direvative , boundary treatment, 
vorticity = zeros(y_count, x_count);
for j=y_count:-1:2
    for i=2:x_count
       vorticity(j,i) =  - (   Vx(j,i) - Vx(j-1,i)  ) /  ( y(j) - y(j-1) )  ...
                         +    ( Vy(j,i) - Vy(j,i-1) ) / ( x(i)-x(i-1) );
       % my eq is diff from textbook(*-1.0, opposite sign), because I have flip the vector coord table
    end 
    vorticity(j,1) = vorticity(j,2);  % boundary treatment, 
end 
vorticity(1,:) = vorticity(2,:);   % boundary treatment, 

end

for i=1:x_count
    for j=y_count:-1:1
       % index = j*(Ny-1) + i;      % if Vx and Vy are 1D vector
       % x_pos = x0+width * ((j-1)/(col-1));  % it is for uniform spacing
       x_pos = x(i);
       % the first Y coord is Y max, 
       % y_pos = y_end - height * ((i-1)/(row-1));
       y_pos = y(j);
       vel_mag = (Vx(j,i)*Vx(j,i)+Vy(j,i)*Vy(j,i))^0.5;
       
       % spot blanking ;  need to comment out 
       if ( (x_pos>0.35 && -1.25<y_pos &&  y_pos<-0.95 && vel_mag>0.04) ...
             || (x_pos>0.40 && -1.25<y_pos &&  y_pos<-0.95 && vel_mag>0.02)  ...
             && vel_mag_filter_enable )
           CHS(j,i) = InvalidVectorFlag;
           Vx(j,i)=InvalidVectorValue;
           Vy(j,i)=InvalidVectorValue;
           vel_mag =InvalidVectorValue;
           vorticity(j,i) = InvalidVectorValue;           
       end
       if vel_mag > vel_mag_threshold && vel_mag_filter_enable
           CHS(j,i) = InvalidVectorFlag;
           Vx(j,i)=InvalidVectorValue;
           Vy(j,i)=InvalidVectorValue;
           vel_mag =InvalidVectorValue;
           vorticity(j,i) = InvalidVectorValue;
       end  
       if MagVorticityEnable
              fprintf(fid,'%f , %f , %f ,  %f ,%f \n',x_pos,y_pos,Vx(j,i),Vy(j,i), CHS(j,i), vel_mag,   vorticity(j,i) );  
       else      
              fprintf(fid,'%f , %f , %f ,  %f ,%f \n',x_pos,y_pos,Vx(j,i),Vy(j,i),CHS(j,i) );   
       end
    end
end 

fclose(fid);
% ------------------end of save vec ---------------------------------------
