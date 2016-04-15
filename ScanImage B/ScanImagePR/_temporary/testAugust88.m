

mex plotInC.c



figure(2); imagehandle = imagesc(rand(5));

A = rand(10000);

pv = libpointer('doublePtr',033);
pv2 = libpointer('doublePtr',A);
% set(imagehandle,'Cdata',A)

D = pv2.Value;

plotInC(A,imagehandle,pv2)



mex plotX.c
figure(2); imagehandle = imagesc(rand(5));
A = rand(5);
plotInC(A,imagehandle)