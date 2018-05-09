clear variables;
close all;

% todo: 
% - se colori sufficientemente "vicini", mediarli, togliendone uno
% - smanettare con i livelli di posterizzazione e testare livelli alti
%   con mediatura

% read and show the image
I = imread('peppers.png');
figure, imshow(I), title('original');

% gaussian filter for smoothing
I = imgaussfilt(I,2);
% figure, imshow(I);

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

% figure, imshow(J);

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

desc_ord_colors = ordered_ucc(:, 1:3);

% desc_ord_colorsnow we need to discard the similar colors according to the human
% perception of colors => we use the CIE 1976 L*a*b*
% desc_ord_colors_lab = rgb2lab(desc_ord_colors);

j = 1;
[n, ~] = size(desc_ord_colors);
avg_desc_ord_colors = ones(n, 3);
appo = desc_ord_colors(1, :);
for i=2:n
   color2 = desc_ord_colors(i, :);
  
   distance = sqrt( 2*(color2(1) - appo(1))^2 + ...
                    4*(color2(2) - appo(2))^2 + ...
                    3*(color2(3) - appo(3))^2);
   if distance <= 75
       % take the average of these two
       appo = ...
            [ (color2(1) + appo(1))/2 ...
              (color2(2) + appo(2))/2 ...
              (color2(3) + appo(3))/2 ];
   else
       avg_desc_ord_colors(j, :) = appo;
       appo = desc_ord_colors(i, :);
       j = j+1;
   end
   
end

% colors = lab2rgb(avg_desc_ord_colors_lab);
colors = avg_desc_ord_colors;
% colors = colors + 0.00001; % some colors are <0, so I add this little factor
n_dominant_colors = 8;
dominant_colors = colors(1:n_dominant_colors, :);

[nrows, ncolumns, ~] = size(I);

dominant_colors_counts = ordered_ucc(1:n_dominant_colors, :);

widths = ones(n_dominant_colors, 1)*ncolumns/n_dominant_colors;
x_positions = 0 : ...
              ncolumns/n_dominant_colors : ...
              ncolumns-ncolumns/n_dominant_colors;

% print the dominant colors in bands
figure, axis off, title('palette of dominant colors');
for i = 1:n_dominant_colors
   rectangle('Position',[x_positions(i), ...
                        0,  ...
                        widths(i), ...
                        80], ...
       'FaceColor', dominant_colors(i, :)/255);
end
