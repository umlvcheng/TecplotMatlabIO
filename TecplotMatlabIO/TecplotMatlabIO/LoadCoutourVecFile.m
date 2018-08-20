function [Nx,Ny,x,y,contour_im] = LoadCoutourVecFile(case_file)
% Ny is y axis points, Nx is x axis point,  it is fixed in PLIF processing
% contour_im size is (I,J), so it display 

    Data = importdata(case_file);  
    %disp(case_file);
    
    % -----------extract the dimension --------------
    regexpEnable=1;
    if (regexpEnable == 1)
        
        
         fileHead = Data.textdata;
          if ( iscell(fileHead) )  % it mab be cell of string, there may be 3 lines in head,but only last line is need
              s=fileHead{end};
          else 
              s = fileHead;
          end
          %  i=20,j=114, DATAPACKING=POINT
          matchStr  = regexp(s, '[I|J]=\d+', 'match', 'ignorecase');
          %  [:digits:]  does not work in matlab!!!
          %posI = regexp(s, '[I|i]=','end')
          %Iindex = strfind(matchStr{1},',')
          Iinfo = matchStr{1};
          Iinfo=Iinfo(3:end);
          Jinfo = matchStr{2};
          %Jindex = strfind(matchStr{2},',')
          Jinfo=Jinfo(3:end);
%  
%         cells = regexp(zoneInfo,'=','split');
%         Iinfo = regexp( char( cells(2) ), ',','split') ;
%         Jinfo = regexp( char( cells(3) ), ',','split') ;    
         [I,statusI]= str2num(Iinfo);
         [J,statusJ]= str2num(Jinfo);
        % [x, status] = str2num('str') returns the status of the conversion in
        % logical status, where status equals logical 1 (true) if the conversion succeeds, and logical 0 (false) otherwise.
        if ( statusI == false ||  statusJ == false)
            disp('failure:  to extract I J dim for the vec file ');
        end
        Nx=J;
        Ny=I;
    else
        I=360;
        J=28;
    end
    % matrix(row, column), so Xcoord is column, column first save in momery
    contour_im = zeros(I,J);
    % matlab matrix , collum first? row first?
    % keep mind of the data save sequence
    
    x= zeros(1,J);    
    y= zeros(I,1);
    y=Data.data(1:I,2);
    
    for jj=1:J
        contour_im(:,jj) = Data.data(jj*I+1-I:jj*I,3);
        x(jj)=Data.data(jj*I+1-I,1);
    end
     
end