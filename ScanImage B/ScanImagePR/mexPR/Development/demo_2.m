
mex M_PRFilterUint16_v2.c
mex M_PRFilterUint16_v3.c
mex M_PRFilterUint16_v4.c
mex M_PRFilterUint16_v5.c
mex M_PRFilterUint16_v6.c

A = zeros(8192,512,'uint16');


for i = 1:size(A,1)
    for j = 1:size(A,2)
        A(i,j) = 2^12*sin((i+j)/100);
    end
end



nb_lines = 512;
nb_pxls = 512;
nb_channels = 2;
binning = 8192/(nb_pxls*nb_channels);
time = zeros(32,1);
for i=1:32
    i
    tic
    for k = 1:1000
       y1 = M_PRFilterUint16_v6(A,nb_lines,nb_pxls,nb_channels,binning,i); % last parameter = nb of threads
    end
    time(i)=toc;    
end

time2 = zeros(32,1);
for i=1:32
    i
    tic
    for k = 1:1000
       y1 = M_PRFilterUint16_v5(A,nb_lines,nb_pxls,nb_channels,binning,i); % last parameter = nb of threads
    end
    time2(i)=toc;    
end

figure, imagesc(y1)

figure(1312);plot(time,'or'); hold on; plot(time2,'ok');
xlabel('Number of threads')
ylabel('Time (secs)')
