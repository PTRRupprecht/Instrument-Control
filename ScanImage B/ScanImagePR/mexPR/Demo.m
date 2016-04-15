mex PRmx_singleChannelBinning_uni_db.c

mex PRmx_multiChannelBinning_bidi_db.c
mex PRmx_delayedChannels_Binning_bidi_db.c

% create a dummy immage with 2 interleaved channels and every 2nd line flipped
A = randi(32000,8192,512,'uint16');
for i = 1:8192
    for k = 1:512
        A(i,k) = A(i,k) + 10000*sin((i+k)/100);
    end
end
A(200:550,:) = A(200:550,:)*0.7;
A(:,300:350) = A(:,300:350)*0.7;
for k = 1:512
    if mod(k,2) == 0
        A(:,k) = A(end:-1:1,k);
    end
end

% show image (this is a simulation of what comes out of the Alazar buffer:
% channels interleaved, every second line flipped, 4096 px per line

mex PRmx_multiChannelBinning_bidi_db.c

% A is the raw image, which will be binned to 512x512x2 pixels (binning
% factor 8), using 4 parallelized cores
y3 = PRmx_multiChannelBinning_bidi_db(A,512,512,2,8,4);

mex PRmx_multiChannelBinning_uni_db.c
y3 = PRmx_multiChannelBinning_uni_db(A,512,512,2,8,4);
% The resulting image which can be further used for display or saving:
figure(141), imagesc(y3)

y3 = PRmx_delayedChannels_Binning_bidi_db(A,512,512,2,8,4,2);
% The resulting image which can be further used for display or saving:
figure(141), imagesc(y3)


mex PRmx_singleChannelBinning_uni_db.c

A = randi(32000,4096,512,'uint16');
for i = 1:4096
    for k = 1:512
        A(i,k) = A(i,k) + 10000*sin((i+k)/100);
    end
end
A(200:550,:) = A(200:550,:)*0.7;
A(:,300:350) = A(:,300:350)*0.7;
for k = 1:512
    if mod(k,2) == 0
        A(:,k) = A(end:-1:1,k);
    end
end
y3 = PRmx_singleChannelBinning_uni_db(A(:,:),512,256,1,16,4);
y3 = PRmx_singleChannelBinning_bidi_db(A(:,:),512,256,1,16,4);
% The resulting image which can be further used for display or saving:
figure(141), imagesc(y3)



% How long does it take in average to run the MEX file?
tic
for k = 1:1000
y3 = PRmx_multiChannelBinning_bidi_db(A,512,512,2,8,4); 
end
b = toc;
fprintf('Average time for one call of the MEX file is %f ms.\n',b);


% How long does it take in function of the number of cores that are used?
time = zeros(20,1);
for i=1:20 % number of cores
    tic
    for k = 1:100
       y1 = PRmx_multiChannelBinning_bidi_db(A,512,512,2,8,i); % last parameter = nb of threads
    end
    time(i)=toc;    
end
figure(989), plot(time*10,'k.'); xlabel('number of parallelized cores'); ylabel('ms per MEX function call');


% How long does it take in function of the number of cores that are used?
time = zeros(20,1);
for i=1:20 % number of cores
    tic
    for k = 1:100
       y1 = PRmx_delayedChannels_Binning_bidi_db(A,512,512,2,8,i,2); % last parameter = nb of threads
    end
    time(i)=toc;    
end
figure(988), plot(time*10,'k.'); xlabel('number of parallelized cores'); ylabel('ms per MEX function call');
