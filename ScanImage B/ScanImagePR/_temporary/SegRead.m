function [W1, W2, N, Movie, FileName] = SegRead()
% read images and metadata
[FileName,PathName,FilterIndex] = uigetfile('*.tif'); file_name = strcat(PathName,FileName);
A = imfinfo(file_name);
W2 = A(1).Width; N = length([A.Width]);
W1 = A(1).Height; N = length([A.Width]);
Movie = zeros(W1,W2,N);
for i = 1:N; Movie(:,:,i) = double(imread(file_name,i)); end
end