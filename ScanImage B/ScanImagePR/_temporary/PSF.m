[W1, W2, N, Movie, FileName] = SegRead();

Movie2 = Movie(:,:,1:2:end);

MM = zeros(30,1);

% figure, imagesc(Movie2(:,:,200))

x = 210; y = 255;
% x = 251; y = 231;

for k = 1:30
    MM(k) = mean(mean(mean(Movie2(x-5:x+5,y-5:y+5,(k-1)*15+1:k*15))));
end

size(MM)

figure, plot(0:0.5:14.5,-(MM-2^14))
    