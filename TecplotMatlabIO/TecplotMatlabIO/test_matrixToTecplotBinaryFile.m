N=5;
[X,Y]=meshgrid(1:N,1:N);
D=X+Y;
D(:,:,2)=X-Y;
 %3Dim array
size(D)
output_file_name='test.plt';
title='';
varnames={'sum X+Y','substract'};
matrixToTecplotBinaryFile(X,Y,D,output_file_name,title,varnames);
system('tec360 test.plt');