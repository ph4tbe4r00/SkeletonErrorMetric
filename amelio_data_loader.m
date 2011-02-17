function out = amelio_data_loader(folder)

out = NaN(276, 195, 8);

for i = 1:8
    x = imread(sprintf('%sz=%.2d.png', folder, i));
    y = x(:,:,1) + 256*x(:,:,2) + 256^2*x(:,:,3);
    out(:,:,i) = y;
end