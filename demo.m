%==========================================================================
% This is an implementation of the STGF algorithm for hyperspectral
% anomaly detection.
% Author: Weiying Xie, wyxie@xidian.edu.cn or zwpxwy@126.com 
%         Xidian University
%
% Please refer to the following paper if you use this code:
%
% @article{STGF, 
% author = {Weiying Xie and Tao Jiang and Yunsong Li and Xiuping Jia and Jie Lei},
% title = {Structure Tensor and Guided Filtering-Based Algorithm for Hyperspectral Anomaly Detection},
% jounal = {submitted to TGRS},
% year = {2018}
%}
% Version 1.0
% Copyright 2018, Xidian University
% When the paper is accepted, we will open the encryption code.

clear; 
clc;
close all; 
load abu-urban-5.mat

%% Band selection
tic
run Bandselection


%% image decomposition
Lambda = [22];
VectorAttributes(1) = 'a';    
Lambda = double(sort(nonzeros(Lambda))');
AP11 = attribute_profile(PC11_int16,'a', Lambda);
AP12 = attribute_profile(PC12_int16,'a', Lambda);
AP13 = attribute_profile(PC13_int16,'a', Lambda);

AP11 = double(AP11);AP12 = double(AP12);AP13 = double(AP13);

%% background removal
D(:,:,1) = AP11(:,:,2)-AP11(:,:,3);
D(:,:,2) = AP12(:,:,2)-AP12(:,:,3);
D(:,:,3) = AP13(:,:,2)-AP13(:,:,3);

%% adaptive weighting
rho = 0.5;
im1 = D(:,:,1);im2 = D(:,:,2);im3 = D(:,:,3);

EigInfo1 = stf(im1,rho); 
EigInfo2 = stf(im2,rho); 
EigInfo3 = stf(im3,rho); 

img=AdaptiveWeighting(EigInfo1.Trace,EigInfo2.Trace,EigInfo3.Trace,im1,im2,im3);

%% GF-based rectification
if length(size(img))>2  
    img=rgb2gray(img);  
end  
img = double(img) / 255;
I= img;
p = img;  
r = 1;   
eps = 0.5^2;   
O = guidedfilter(I, p, r, eps);  

toc

figure,imagesc(O),axis off,axis image,colormap gray
figure,imagesc(map),axis off,axis image,colormap gray