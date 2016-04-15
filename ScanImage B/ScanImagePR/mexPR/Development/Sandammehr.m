% % 
% % 
% for i = 0:(32*32-1)
%     if mod(i,2*32) >= 32
%         temp = mod(i,32);
%         jj(i+1) = i + 32 - 2*temp  -1 ;
%     else
%         jj(i+1) = i;
%     end
% end
%     
% figure, plot(jj,'k.')
%     
%     
%     
%     
%       if ((ii % 2*nb_pxls) >= nb_pxls) {
%             temp = (ii % nb_pxls);
%             jj = ii + nb_pxls - 2*temp;
%             jj2 = ii2 + nb_pxls - 2*temp;
% //             jj = ii;
% //             jj2 = ii2;
%         }
%         else {
% 
% 


mex PRmx_multiChannelBinning_bidi.c

mex PRmx_singleChannelBinning_bidi_db.c


mex PRmx_multiChannelBinning_bidi_db.c

A = randi(38000,8192,512,'uint16');
for i = 1:8192
    for k = 1:512
        A(i,k) = A(i,k) + 1000*sin((i+k)/100);
    end
end

A(200:550,:) = A(200:550,:)*0.1;
A(:,300:350) = A(:,300:350)*0.1;


for k = 1:512
    if mod(k,2) == 0
        A(:,k) = A(end:-1:1,k);
    end
end

% A = ones(8192,512,'uint16');
figure, imagesc(A)

A = A + 32900;
mex PRmx_multiChannelBinning_bidi_db.c

mex PRmx_multiChannelBinning_db.c
mex PRmx_multiChannelBinning.c

y3 = PRmx_multiChannelBinning_db(A,512,512,2,8,2);

tic
for k = 1:1000
y3 = PRmx_multiChannelBinning_bidi_db(A,512,512,2,8,6); 
end
toc
B = A(1:end/2,:);
tic
for k = 1:1000
y3 = PRmx_singleChannelBinning_bidi_db(B,512,512,1,8,6,0); 
end
toc

mean(y3(:))

tic
for k = 1:1000
y3 = PRmx_singleChannelBinning_bidi_db(B,512,512,2,8,4); 
end
toc

  figure; imagesc(y3)
  
  max(y3(:))
  

time = zeros(32,1);
for i=1:12
    i
    tic
    for k = 1:100
       y1 = PRmx_multiChannelBinning_bidi_db(A,512,512,2,8,i); % last parameter = nb of threads
    end
    time(i)=toc;    
end

time2 = zeros(32,1);
for i=1:12
    i
    tic
    for k = 1:100
       y3 = PRmx_multiChannelBinning(A,512,512,2,8,i); % last parameter = nb of threads
    end
    time2(i)=toc;    
end

figure, plot(time,'k.'), hold on; plot(time2,'ro')

figure(31), imagesc(y1)
figure(41), imagesc(y3)



