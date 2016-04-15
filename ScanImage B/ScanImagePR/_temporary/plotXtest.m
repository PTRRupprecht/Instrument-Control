mex plotX.c

figure(1); imagehandle = imagesc(rand(500));

A = rand(500); B = rand(500);

for i = 1:10
    tic
    set(imagehandle,'Cdata',A);
    toc
    tic
    plotX(B,imagehandle);
    toc
end