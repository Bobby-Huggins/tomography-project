close all
clear all
clc

image = im2double(imread('20211129_bell_pepper_001.tif'));
figure
imshow(image, [])
binnedImage = binImage(image, 4);
figure
imshow(binnedImage, [])
binnedImage2 = im2double(imread('binned_4_20211129_bell_pepper_031.tif'));
figure
imshow(binnedImage2, [])