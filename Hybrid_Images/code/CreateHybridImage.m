%% Developed By Naman Goyal (2015csb1021@iitrpr.ac.in)
% It takes to images and overlapping bounding boxes with low pass and high
% pass filters
function result = CreateHybridImage(img1, area1, img2, area2,low_pass_filter, high_pass_filter)
    
    s1 = size(img1);
    s2 = size(img2);
    h1 = s1(1);
    h2 = s2(1);
    w1 = s1(2);
    w2 = s2(2);
    
    low_pass = imfilter(img1,low_pass_filter,'same');
    high_pass = imfilter(img2, high_pass_filter,'same');
    
    % COpy the non-overlapping portion in img1
    result(:,1:area1(1),:)= img1(:,1:area1(1),:);
    
    % Generate weighted mask to get hybird images with no filters in area
    % common two images before the overlapping box
    mask1 = ones(area1(2),1)*linspace(1,0,area1(3));
    mask1 = cat(3,mask1,mask1,mask1);
    mask2 = 1 - mask1;
    result(1:area1(2),area1(1)+1:area1(1)+area1(3),:) = floor(mask1.*double(img1(1:area1(2),area1(1)+1:area1(1)+area1(3),:)) + mask2.*double(img2(1:area1(2),1:area1(3),:)));
    
    % Generate weighted mask to get hybird images with low and high filters in area
    % common two images inside the overlapping box
    clear mask1;
    clear mask2;
    mask1 = ones(area1(4),1)*linspace(1,0,area1(3));
    mask1 = cat(3,mask1,mask1,mask1);
    mask2 = 1 - mask1;
    result(area1(2)+1:area1(2)+area1(4),area1(1)+1:area1(1)+area1(3),:) = floor(mask1.*(mask1.*double(low_pass(area1(2)+1:area1(2)+area1(4),area1(1)+1:area1(1)+area1(3),:))+mask2.*double(img1(area1(2)+1:area1(2)+area1(4),area1(1)+1:area1(1)+area1(3),:))) + mask2.*(mask1.*double(high_pass(area1(2)+1:area1(2)+area1(4),1:area1(3),:))+ mask2.*double(img2(area1(2)+1:area1(2)+area1(4),1:area1(3),:))));
    
    % Generate weighted mask to get hybird images with no filters in area
    % common two images after the overlapping box
    clear mask1;
    clear mask2;
    mask1 = ones(h1 - (area1(2)+area1(4)),1)*linspace(1,0,area1(3));
    mask1 = cat(3,mask1,mask1,mask1);
    mask2 = 1 - mask1;
    result(area1(2)+area1(4)+1:h1,area1(1)+1:area1(1)+area1(3),:) = floor(mask1.*double(img1(area1(2)+area1(4)+1:h1,area1(1)+1:area1(1)+area1(3),:)) + mask2.*double(img2(area1(2)+area1(4)+1:h1,1:area1(3),:)));
    
    result(:,area1(1)+area1(3)+1:area1(1)+w2,:) = img2(:,area1(3)+1:w2,:);
end