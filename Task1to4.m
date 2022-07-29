clear; close all;

% Task 1: Pre-processing -----------------------
% Step-1: Load input image
I = imread('IMG_01.png');
% Step-2: Covert image to grayscale
I_gray = rgb2gray(I);

% Step-3: Rescale image
J = imresize(I_gray,[512 NaN]);
figure, imshow(J)
title("Resized image to 512 pixels")

% Step-4: Produce histogram before enhancing
figure, imhist(J, 64);

% Step-5: Enhance image before binarisation
J_enhanced = imadjust(J);

% Step-6: Histogram after enhancement
figure, imhist(J_enhanced,64);

%Step-7: Image Binarisation
BW = imbinarize(J_enhanced);
figure ,imshow(BW)
title('original binarisation')

% % Task 2: Edge detection ------------------------
BW1 = edge(J_enhanced,'prewitt');
figure ,imshow(BW1)
title('prewitt edge detection')

% % Task 3: Simple segmentation --------------------
level = graythresh(J_enhanced);
BW = imbinarize(J_enhanced, level);
figure
imshowpair(J_enhanced, BW, 'montage');
title('graythresh segmentation compared to original grayscale image')

%Fills any holes in the left top corner of the image
bw_b = padarray(padarray(BW,[1 0],1,'pre'),[0 1],1,'post');
bw_b_filled = imfill(bw_b,'holes');
bw_b_filled = bw_b_filled(2:end,1:end-1);

%Fills any holes in the right bottom corner of the image
bw_c = padarray(BW,[1 1],1,'post');
bw_c_filled = imfill(bw_c,'holes');
bw_c_filled = bw_c_filled(1:end-1,1:end-1);

%logical OR for all the images
bw_filled = bw_b_filled | bw_c_filled;
figure
imshowpair(BW, bw_filled, 'montage');
title('graythresh segmentation with filled holes')

% % Task 4: Object Recognition --------------------
I = imread('IMG_11.png');
I = imresize(I,[512 NaN]);
igray = rgb2gray(I);

J_enhanced = imadjust(igray);
level = graythresh(J_enhanced);
BW = imbinarize(J_enhanced, level);
BW = bwareaopen(BW,105);

%fills the unfilled blobs in each corner of the image
bw_a = padarray(BW,[1 1],1,'pre');
bw_a_filled = imfill(bw_a,'holes');
bw_a_filled = bw_a_filled(2:end,2:end);

bw_b = padarray(padarray(BW,[1 0],1,'pre'),[0 1],1,'post');
bw_b_filled = imfill(bw_b,'holes');
bw_b_filled = bw_b_filled(2:end,1:end-1);

bw_c = padarray(BW,[1 1],1,'post');
bw_c_filled = imfill(bw_c,'holes');
bw_c_filled = bw_c_filled(1:end-1,1:end-1);

bw_d = padarray(padarray(BW,[1 0],1,'post'),[0 1],1,'pre');
bw_d_filled = imfill(bw_d,'holes');
bw_d_filled = bw_d_filled(1:end-1,2:end);

%combines all the filled corners into 1 variable
BW = bw_a_filled | bw_b_filled | bw_c_filled | bw_d_filled;

%erodes the image to remove the bacteria
se = strel('disk',10);
erodedBW = imerode(BW,se);

%dilates the eroded image to restructure the blood cells before erosion
se2 = strel('disk',10);
blood_image = imdilate(erodedBW,se2);

%bacteria image is the original image minus the recognised blood cells
bacteria_image = BW - blood_image;
%removes some of the left over noise from the erosion technique
bacteria_image = bwareaopen(bacteria_image,105);
%labels the blood cells with a red colour
blood = label2rgb(blood_image, 'prism','k'); 
%labels the bacteria with a blue colour
bacteria = label2rgb(bacteria_image, 'jet','k');
%combines the seperated blood cells and bacteria to one image
new_image = blood + bacteria;
figure
imshow(new_image)
title('Bacteria and Blood cell object recognition image')