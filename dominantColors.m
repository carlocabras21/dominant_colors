clear variables;
close all;

% todo: 
% - se colori sufficientemente "vicini", mediarli, togliendone uno
% - smanettare con i livelli di posterizzazione e testare livelli alti
%   con mediatura

% read and show the image
I = imread('peppers.png');
figure, imshow(I);

% gaussian filter for smoothing
I = imgaussfilt(I,2);
figure, imshow(I);

% first, posterize the image
nlevels = 10; % change this number if you want more detail
% *********
% from https://it.mathworks.com/help/images/ref/imquantize.html
% Generate thresholds for the ginven number of levels from the entire RGB image.
threshRGB = multithresh(I, nlevels); 

% Process the entire image with the set of threshold values computed from 
% entire image.
value = [0 threshRGB(2:end) 255]; 
J = imquantize(I, threshRGB, value);
% *********

figure, imshow(J);

% second, count the occurrences of each color
% *********
% from https://blogs.mathworks.com/steve/2008/01/31/counting-occurrences-of-image-colors/
rgb_columns = reshape(J, [], 3);
[unique_colors, m, n] = unique(rgb_columns, 'rows');
color_counts = accumarray(n, 1);

unique_colors_counts = [double(unique_colors) double(color_counts)];
% *********

% order the occurences and take the first 8 colors
ordered_ucc = sortrows(unique_colors_counts, 4, 'descend');

n_dominant_colors = 10;
dominant_colors = ordered_ucc(1:n_dominant_colors, 1:3);

[nrows, ncolumns, ~] = size(I);

dominant_colors_counts = ordered_ucc(1:n_dominant_colors, :);

proportional = false;

if proportional
    widths = dominant_colors_counts(:,4)./sum(dominant_colors_counts(:,4)).*ncolumns;
    x_positions = zeros(n_dominant_colors, 1);
    for i=2:n_dominant_colors
       x_positions(i) = sum(widths(1:i)); 
    end
else
    widths = ones(n_dominant_colors, 1)*ncolumns/n_dominant_colors;
    x_positions = 0 : ...
                  ncolumns/n_dominant_colors : ...
                  ncolumns-ncolumns/n_dominant_colors;
end

% print the dominant colors in bands
figure, axis off;
for i = 1:n_dominant_colors
   rectangle('Position',[x_positions(i), ...
                        0,  ...
                        widths(i), ...
                        80], ...
       'FaceColor', dominant_colors(i, :)/255);
end
