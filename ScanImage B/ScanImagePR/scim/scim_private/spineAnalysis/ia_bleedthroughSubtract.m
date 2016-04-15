% ia_bleedthroughSubtract - Subtract a fraction of the signal on one channel from another channel
%
% SYNTAX
%  ia_bleedthroughSubtract(fraction, bleedthrough12, bleedthrough21)
%   bleedthrough12 - The fraction of bleedthrough from channel 1 into channel 2.
%   bleedthrough21 - The fraction of bleedthrough from channel 2 into channel 1.
%
% CREATED
%  Timothy O'Connor 12/22/09
%  Copyright UC Davis/Northwestern University/Howard Hughes Medical Institute 2009
function ia_bleedthroughSubtract(hObject, bleedthrough12, bleedthrough21)

im = stackBrowser('getUnfilteredImage', hObject);
imheader = getLocal(progmanager, hObject, 'currentHeader');

subtracted = im;
for i = 1 : size(im{1}, 3)
    subtracted{1}(:, :, i) = im{1}(:, :, i) - 0.01 * bleedthrough21 * im{2}(:, :, i);
end

for i = 1 : size(im{1}, 3)
    subtracted{2}(:, :, i) = im{2}(:, :, i) - 0.01 * bleedthrough12 * im{1}(:, :, i);
end

stackBrowser('processNewImage', hObject, subtracted, imheader);

return;