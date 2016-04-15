%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Multithreading demo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear

mex M_BFilter.c

ima=imread('cameraman.tif');
ima=double(ima);

% add some noise 

level=15;
nima=ima + level*randn(size(ima));

% bilateral filter parameters

ratio=5;       % radius of the search area
sigmaS=5;      % regulates the importance of geometrical distance
sigmaI=level;  % regulates the importance of intensity distance 
               % (normally the best choice is the noise standard devaition)

%NC=feature('numCores');
NC=20;


for i=1:NC*2
    
tic
for k = 1:100
fima=M_BFilter(nima,ratio,sigmaS,sigmaI,i);
end
time(i)=toc;

end

clf
figure(1312);plot(time)
xlabel('Number of threads')
ylabel('Time (secs)')


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Multithreading demo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mex M_PRFilter.c

% image = rand(8192,512);

% A = zeros(8192,512,'uint16');
A = zeros(8192,512,'double');

for i = 1:2:400
    A(i,:) = 1;
end

for i = 1:size(A,1)
    for j = 1:size(A,2)
        A(i,j) = 200*sin((i+j)/100);
    end
end



nb_lines = 512;
nb_pxls = 512;
nb_channels = 2;
binning = 8192/(nb_pxls*nb_channels);




NC=8; % number of cores
for i=1:8
    i
    tic
    for k = 1:1000
        [y1,y2] = M_PRFilter(A,nb_lines,nb_pxls,nb_channels,binning,i); % last parameter = nb of threads
    end
    time(i)=toc;

end

figure(3); imagesc(y2)

figure(1312);plot(time)
xlabel('Number of threads')
ylabel('Time (secs)')


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Multithreading demo
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mex M_PRFilterUint16.c

mex M_PRFilterUint16_v2.c

% image = rand(8192,512);

A = zeros(8192,512,'uint16');
% A = zeros(8192,512,'double');

for i = 1:2:400
    A(i,:) = 1;
end

for i = 1:size(A,1)
    for j = 1:size(A,2)
        A(i,j) = 2^13*sin((i+j)/100);
    end
end



nb_lines = 512;
nb_pxls = 512;
nb_channels = 2;
binning = 8192/(nb_pxls*nb_channels);
time = zeros(32,1);
time2 = zeros(size(time));
NC=8; % number of cores
for i=1:32
    tic
    i
    for k = 1:1000
       y1 = M_PRFilterUint16_v2(A,nb_lines,nb_pxls,nb_channels,binning,i); % last parameter = nb of threads
%         [y1,y2] = binningMultipleChannelsUint16(A,nb_pxls,nb_lines,nb_channels);
    end
    time(i)=toc;    
end
for i = 1:12

    tic
    for k = 1:1000
       [y1,y2] = M_PRFilterUint16(A,nb_lines,nb_pxls,nb_channels,binning,i); % last parameter = nb of threads
%         [y1,y2] = binningMultipleChannelsUint16(A,nb_pxls,nb_lines,nb_channels);
    end
    time2(i)=toc;
end

figure(3); imagesc(y1)

figure(1312);plot(time,'or'); hold on; plot(time2,'ok')
xlabel('Number of threads')
ylabel('Time (secs)')
