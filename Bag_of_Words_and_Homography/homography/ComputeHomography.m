function [ H_left,H_right ] = ComputeHomography( im1, im2 )
%ComputeHomography Creates homogrpahy from 2 images
% Return 2 homography based on 4 selected input points in both images.
% Example [ H_left,H_right,im3,im4 ] = ComputeHomography(im1, im2);
% where im1, im2 are 2 image objects and H_left,H_right are 2 computed homography

if nargin< 2
    error('Please specify 2 input image arguments.');
else
    n = 4;
    figure;
    subplot(1,2,1);
    imshow(im1);
    subplot(1,2,2);
    imshow(im2);
    subplot(1,2,1);
    title('Select Points here');
    x = zeros(n,1);
    y = zeros(n,1);
    for i=1:1:n
        hold on,
        [x(i),y(i)] = ginput(1);
        text(x(i),y(i),strcat('\leftarrow ',num2str(i)),'Color', 'b','FontSize',8);
        plot(x(i),y(i),'bo');
    end

    title('');

    subplot(1,2,2);

    title('Select Points here');
    x_new = zeros(i,1);
    y_new = zeros(i,1);
    for i=1:1:n
        hold on,
        [x_new(i),y_new(i)] = ginput(1);
        text(x_new(i),y_new(i),strcat('\leftarrow ',num2str(i)),'Color', 'b','FontSize',8);
        plot(x_new(i),y_new(i),'bo');
    end

    title('');
    close all;
    %% Compute Homography Left

    A = double(zeros(2*n,9));
    for i=1:1:4
        A(2*i-1,:) = [x(i) y(i) 1 0 0 0 -x_new(i)*x(i) -x_new(i)*y(i) -x_new(i)];
        A(2*i,:) = [0 0 0 x(i) y(i) 1 -y_new(i)*x(i) -y_new(i)*y(i) -y_new(i)];
    end

    % Using eigen value
    % [V,D] = eig(A'*A);
    % [~,col_min] = min((diag(D))); 
    % H = vec2mat(V(:,col_min), 3);

    % Using SVD
    [~,~,V] = svd(A);
    H_left = vec2mat(V(:,end), 3);
    fprintf('Left Homogrpahy i.e. Image 1 on Image 2:\n');
    disp(H_left);
       
    fprintf('Warping Image 1 on Image 2 based on computed left Homogrpahy\n');
    % Warp the Image to get reference
    tform = projective2d((H_left)');
    [~,ref1] = imwarp(im1,tform);

    % Calculate range of mosaic
    ref2 = imref2d([size(im2,1) size(im2,2)]);
    top_point_x = min(ref2.XWorldLimits(1),ref1.XWorldLimits(1));
    top_point_y = min(ref2.YWorldLimits(1),ref1.YWorldLimits(1));
    bottom_point_x = max(ref2.XWorldLimits(2),ref1.XWorldLimits(2));
    bottom_point_y = max(ref2.YWorldLimits(2),ref1.YWorldLimits(2));
    new_size = [round(bottom_point_y-top_point_y) round(bottom_point_x-top_point_x)];
    new_xworld_limits = [top_point_x bottom_point_x];
    new_yworld_limits = [top_point_y bottom_point_y];
    new_ref = imref2d(new_size,new_xworld_limits,new_yworld_limits);

    % Wrap and add both image
    im1trans =imwarp(im1,tform,'OutputView',new_ref);
    im2trans =imwarp(im2,projective2d(eye(3)),'OutputView',new_ref);
    im3 = max(im1trans,im2trans);
    figure;
    imshow(im3);
    title('Mosaic Image');
    %% Compute Homography Right

    A = double(zeros(2*n,9));
    for i=1:1:4
        A(2*i-1,:) = [x_new(i) y_new(i) 1 0 0 0 -x(i)*x_new(i) -x(i)*y_new(i) -x(i)];
        A(2*i,:) = [0 0 0 x_new(i) y_new(i) 1 -y(i)*x_new(i) -y(i)*y_new(i) -y(i)];
    end

    % Using eigen value
    % [V,D] = eig(A'*A);
    % [~,col_min] = min((diag(D))); 
    % H = vec2mat(V(:,col_min), 3);

    % Using SVD
    [~,~,V] = svd(A);
    V(:,end);
    H_right = vec2mat(V(:,end), 3);
    fprintf('Right Homogrpahy i.e. Image 2 on Image 1:\n');
    disp(H_right);
       
    fprintf('Warping Image 2 on Image 1 based on computed right Homogrpahy\n');
    % Warp the Image to get reference
    tform = projective2d((H_right)');
    [~,ref1] = imwarp(im2,tform);

    % Calculate range of mosaic
    ref2 = imref2d([size(im1,1) size(im1,2)]);
    top_point_x = min(ref2.XWorldLimits(1),ref1.XWorldLimits(1));
    top_point_y = min(ref2.YWorldLimits(1),ref1.YWorldLimits(1));
    bottom_point_x = max(ref2.XWorldLimits(2),ref1.XWorldLimits(2));
    bottom_point_y = max(ref2.YWorldLimits(2),ref1.YWorldLimits(2));
    new_size = [round(bottom_point_y-top_point_y) round(bottom_point_x-top_point_x)];
    new_xworld_limits = [top_point_x bottom_point_x];
    new_yworld_limits = [top_point_y bottom_point_y];
    new_ref = imref2d(new_size,new_xworld_limits,new_yworld_limits);

    % Wrap and add both image
    im1trans =imwarp(im2,tform,'OutputView',new_ref);
    im2trans =imwarp(im1,projective2d(eye(3)),'OutputView',new_ref);
    im4 = max(im1trans,im2trans);
    figure;
    imshow(im4);
    title('Mosaic Image 2');
end
