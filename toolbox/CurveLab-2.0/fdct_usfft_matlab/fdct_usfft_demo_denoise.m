disp(' ');
disp('fdct_usfft_demo_denoise.m -- Image denoising via curvelet thresholding');
disp(' ');

disp(' ');
disp('Denoising is achieved by hard-thresholding of the curvelet coefficients.');
disp('We select the thresholding at 3*sigma_jl for all but the finest scale');
disp('where it is set at 4*sigma_jl; here sigma_jl is the noise level of a');
disp('coefficient at scale j and angle l (equal to the noise level times');
disp('the l2 norm of the corresponding curvelet). There are many ways to compute');
disp('the sigma_jl''s, e.g. by computing the norm of each individual curvelet,');
disp('and in this demo, we use Monte Carlo simulations.');
disp(' ');

% fdct_usfft_demo_denoise.m -- Image denoising via curvelet thresholding

% img = double(imread('Lena.jpg'));
img = double(imread('bacteria.BMP'));
img = img(1:128,1:128);
n = size(img,1);
sigma = 10;        
is_real = 1;

noisy_img = img + sigma*randn(n);

%wavelet denoising
[thr,sorh,keepapp] = ddencmp('den','wv',noisy_img);
wavelet_denoise = wdencmp('gbl',noisy_img,'db4',2,thr,sorh,keepapp);


disp('Compute all thresholds');
X = randn(n);
tic; C = fdct_usfft(X,is_real); toc; 

% Compute norm of curvelets (Monte Carlo) 
E = cell(size(C));
 for s=1:length(C)
   E{s} = cell(size(C{s}));
   for w=1:length(C{s})
     A = C{s}{w};
     E{s}{w} = median(abs(A(:) - median(A(:))))/.6745; % Estimate noise level with robust estimator
   end
 end

% Take curvelet transform
disp(' ');
disp('Take curvelet transform: fdct_usfft');
tic; C = fdct_usfft(noisy_img,is_real); toc;
Ct = C;

% Apply thresholding
for s = 2:length(C)
  thresh = 3*sigma + sigma*(s == length(C));
  for w = 1:length(C{s})
    Ct{s}{w} = C{s}{w}.* (abs(C{s}{w}) > thresh*E{s}{w});
  end
end

% Take inverse curvelet transform 
disp(' ');
disp('Take inverse transform of thresholded data: ifdct_usfft');

restored_img = ifdct_usfft(Ct,is_real);

figure; 
subplot(2,2,1); imagesc(img); colormap gray; axis('image');title('original image');
subplot(2,2,2); imagesc(noisy_img); colormap gray; axis('image');title('noise image');
subplot(2,2,3); imagesc(restored_img); colormap gray; axis('image');title('curvelet enhanced image');
subplot(2,2,4); imagesc(wavelet_denoise); colormap gray; axis('image');title('wavelet enhanced image');

% disp(' ');
% disp('This method is of course a little naive.');
% R=input('Do you want to see the outcome of a more sophisticated experiment? [Y/N] ','s');
% disp(' ');
% 
% if strcmp(R,'') + strcmp(R,'y') + strcmp(R,'Y'), 
%   combined = double(imread('LenaCombined.jpg'));
%   figure; imagesc(combined); colormap gray; axis('image');
%   
% disp('This image (courtesy of Jean-Luc Starck) is the result of a more sophisticated');
% disp('strategy which involves both curvelets and wavelets. For a reference, please see');
% disp('J.L. Starck, D.L. Donoho and E. Candes, Very High Quality Image Restoration,')
% disp('in SPIE conference on Signal and Image Processing: Wavelet Applications');
% disp('in Signal and Image Processing IX, A. Laine, M. A. Unser and A. Aldroubi Eds,'); 
% disp('Vol 4478, 2001.');
% disp(' ');
% disp('For other experiments, please check the "enhanced denoise demo" in the wrapping');
% disp('directory.');
% disp(' ')
% end
