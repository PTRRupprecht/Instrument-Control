
mex binningMultipleChannelsUint16vs2.c


A = zeros(8192,512,'uint16');

for i = 1:2:400
    A(i,:) = 1;
end

for i = 1:size(A,1)
    for j = 1:size(A,2)
        A(i,j) = 200*sin((i+j)/100);
    end
end

A = bufferOut.Value;

lines = uint16(512);
pxls = uint16(512);
nb_ch = uint16(2);

lines = (512);
pxls = (512);
nb_ch = (2);

B = double(A);

mex binningMultipleChannelsUint16.c

[dad,daad] = binningMultipleChannelsUint16(A,pxls,lines,nb_ch);

figure(1); imagesc(dad);
figure(2); imagesc(daad)
figure(3); imagesc(A)