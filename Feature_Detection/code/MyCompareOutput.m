function [mse_mat, psnr_mat] = MyCompareOutput(input_image, threshold)
    if nargin < 1
        input_image(:,:,1) = 0;
        input_image(:,:,2) = 0;
        input_image(:,:,3) = 0;
    end

    if exist('threshold','var') ~= 0
        img1 = MyCannyEdgeDetector(input_image, threshold);
        img2 = edge(rgb2gray(input_image),'canny', threshold);
    else
        img1 = MyCannyEdgeDetector(input_image);
        img2 = edge(rgb2gray(input_image),'canny');
    end

    s = size(img1);
    m = (s(1) - mod(s(1), 3));
    n = (s(2) - mod(s(2),3));

     for i=1:((m/3)-1)
         for j=1:((n/3)-1)
             %MSE
             mse_mat(i,j) = sum(sum( (img1(3*i:3*(i+1),3*j:3*(j+1))-img2(3*i:3*(i+1),3*j:3*(j+1))).^2 ))/(3*3);
             %PSNR
             psnr_mat(i,j) = 10*log10(256*256/mse_mat(i,j));
         end
     end
     subplot(1,2,1);
     imshow(img1); 
     title('My Canny Edge Detector');

     subplot(1,2,2);
     imshow(img2);
     title('Matlab Canny Edge Detector');
     saveas(gcf, 'comp_output.jpg');
end