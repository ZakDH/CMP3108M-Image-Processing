% Task 5: Robust method --------------------------
for n=1:15 %loops through each of the images (15 in total)
    if n < 10 %file naming characteristics change from image 10 (0 is removed)
        IMG_{n}= imread(sprintf('IMG_0%s.png',num2str(n)));
    else
        IMG_{n}= imread(sprintf('IMG_%s.png',num2str(n)));
    end
    %transforming image for binarization
    I_gray = rgb2gray(IMG_{n});
    I_gray = imresize(I_gray,[512 NaN]);
    J_enhanced = imadjust(I_gray);
    level = graythresh(J_enhanced);
    BW = imbinarize(J_enhanced, level);
    %object recognition and image filling
    BW = bwareaopen(BW,300);
    
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
    
    BW = bw_a_filled | bw_b_filled | bw_c_filled | bw_d_filled;

    % detect blood cells in the images using erosion and dilation
    %erodes the image to remove the bacteria
    se = strel('disk',10);
    erodedBW = imerode(BW,se);
    
    %dilates the eroded image to restructure the blood cells before erosion
    se2 = strel('disk',10);
    blood_image = imdilate(erodedBW,se2);

    %bacteria image is the original image minus the recognised blood cells
    bacteria_image = BW - blood_image;

    %labels the blood cells with a red colour
    blood = label2rgb(blood_image, 'prism','k'); 

    %labels the bacteria with a blue colour
    bacteria = label2rgb(bacteria_image, 'jet','k');

    %combines the seperated blood cells and bacteria to one image
    combined_image = blood + bacteria;
    
    % if loop to name the files the same as the original files
    if n < 10 %file naming characteristics change from image 10 (0 is removed)
        baseFileName = sprintf('IMG_0%s.png',num2str(n));
    else
        baseFileName = sprintf('IMG_%s.png',num2str(n));
    end
    %checks to see if the output files exists
    if not(isfolder("output\"))
    mkdir("output\") %if not output file is made
    end
    fullFileName = fullfile('output',baseFileName);
    imwrite(combined_image,fullFileName,'png')%new images are written to the output folder
end
figure
imshowpair(BW, combined_image,'montage')
title('original labelled image compared to final image')

% Task 6: Performance evaluation -----------------
% Step 1: Load ground truth data
output_folder = ('output\');
output_list = dir(strcat(output_folder,'*.png')); %creates a string with the path and adds '*.png'
output_files = {output_list.name}; %takes the name column from the output_list array

for n = 1:15 %loops through the ground truth images and the comparison images
    if n < 10
        IMG_{n} = imread(fullfile(output_folder,output_files{n})); %reads through the output folder and reads in the corresponding image
        GT_{n} = imread(sprintf('IMG_0%s_GT.png',num2str(n)));%reads through the folder and reads in the corresponding image
    else
        IMG_{n} = imread(fullfile(output_folder,output_files{n})); 
        GT_{n} = imread(sprintf('IMG_%s_GT.png',num2str(n)));
    end
GT_{n} = rgb2gray(GT_{n});
GT_{n} = imresize(GT_{n},[512 NaN]);
GT_{n} = label2rgb(GT_{n}, 'prism','k','shuffle'); %used to visualise the ground truth images
L_GT = im2double(GT_{n}); %converts ground truth images to double for scoring

IMG_{n} = imresize(IMG_{n},[512 NaN]);
L_IMG = im2double(IMG_{n}); %converts comparison images to double for scoring

%performance evaluation
dice_score = 2*nnz(L_IMG&L_GT)/(nnz(L_IMG) + nnz(L_GT)); %computes the dice score between the two images
precision_score = sum(sum(L_GT&L_IMG))/sum(L_GT(:)); %computes the precision score between the two images
recall_score = sum(sum(L_GT&L_IMG))/sum(L_IMG(:)); %computes the recall score between the two images

figure % consists of 6 different subplots per image
subplot(2,3,1)
imshow(L_GT)
title(['Dice Score = ' num2str(dice_score)]) % converts the dice score to a string for titling
subplot(2,3,4)
imshow(L_IMG)
title(['Dice Score = ' num2str(dice_score)])

subplot(2,3,2)
imshow(L_GT)
title(['Precision Score = ' num2str(precision_score(:,:,1))]) %takes the array value wanted from the array
subplot(2,3,5)
imshow(L_IMG)
title(['Precision Score = ' num2str(precision_score(:,:,1))]) %takes the array value wanted from the array

subplot(2,3,3)
imshow(L_GT)
title(['Recall Score = ' num2str(recall_score(:,:,1))]) %takes the array value wanted from the array
subplot(2,3,6)
imshow(L_IMG)
title(['Recall Score = ' num2str(recall_score(:,:,1))]) %takes the array value wanted from the array
end