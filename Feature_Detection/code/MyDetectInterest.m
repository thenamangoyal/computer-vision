function MyDetectInterest(input_image,threshold)
    if nargin < 1
        input_image(:,:,1) = 0;
        input_image(:,:,2) = 0;
        input_image(:,:,3) = 0;
    end
    gx = [-1 0 1; -1 0 1; -1 0 1];
    gy = [-1 -1 -1; 0 0 0; 1 1 1];
    filt = fspecial('gaussian', [6 6], 1);
    
    % Convert to grayscale
    gray_image = double(rgb2gray(input_image));
    
    % Apply derivate in x direction
    Ix = imfilter(gray_image,gx,'conv', 'replicate');
    
    % Apply derivate in y direction
    Iy = imfilter(gray_image,gy,'conv', 'replicate');
    
    % Apply gaussian blur on square x direction
    Ix2 = imfilter(Ix.^2,filt,'conv', 'replicate');
    
    % Apply gaussian blur on square y direction
    Iy2 = imfilter(Iy.^2,filt,'conv', 'replicate');
    
    % Apply gaussian blur on xy direction - to make rotation independent
    IxIy = imfilter(Ix.^Iy,filt,'conv', 'replicate');
    
    % Define M = [Ix2 Ix.Iy; Iy.Ix Iy2]
    % Define R = det(M) - k*trace(M)^2
    
    % Calcuate the R
    R = (Ix2.*Iy2 - IxIy.^2) - 0.04*(Ix2 + Iy2).^2;
    s = size(R);
    if exist('threshold','var') ~= 0
        if size(threshold,2) >= 3
            R_thresh = max(max(R))*threshold(3);
        elseif size(threshold,2) == 2
            R_thresh = max(max(R))*threshold(2);
        else
            R_thresh = max(max(R))*0.01;
        end
    else
        R_thresh = max(max(R))*0.01;
    end
    rowset = [];
    colset = [];
    
    % Find colset and rowset
    for i=2:s(1)-1
        for j=2:s(2)-1
            if R(i,j) > R_thresh
                if (R(i,j) > R(i-1,j)) && (R(i,j) > R(i,j-1)) && (R(i,j) > R(i-1,j-1)) && (R(i,j) > R(i+1,j)) && (R(i,j) > R(i,j+1)) && (R(i,j) > R(i+1,j+1)) && (R(i,j) > R(i-1,j+1)) && (R(i,j) > R(i+1,j-1))
                    rowset = [rowset i];
                    colset = [colset j];
                end
            end
        end
    end
    % Plot
    subplot(1,2,1), imshow(input_image), hold on,
    plot(colset,rowset,'y+'), title('Corners in original image');
    
    %% canny Edge
    if exist('threshold','var') ~= 0
        can_res = double(MyCannyEdgeDetector(input_image, threshold));
    else
        can_res = double(MyCannyEdgeDetector(input_image));
    end
    % Apply derivate in x direction
    new_Ix = imfilter(can_res,gx,'conv', 'replicate');
    
    % Apply derivate in y direction
    new_Iy = imfilter(can_res,gy,'conv', 'replicate');
    
    % Apply gaussian blur on square x direction
    new_Ix2 = imfilter(new_Ix.^2,filt,'conv', 'replicate');
    
    % Apply gaussian blur on square y direction
    new_Iy2 = imfilter(new_Iy.^2,filt,'conv', 'replicate');
    
    % Apply gaussian blur on xy direction - to make rotation independent
    new_IxIy = imfilter(new_Ix.^new_Iy,filt,'conv', 'replicate');
    
    % Define M = [Ix2 Ix.Iy; Iy.Ix Iy2]
    % Define R = det(M) - k*trace(M)^2
    
    % Calcuate the R
    new_R = (new_Ix2.*new_Iy2 - new_IxIy.^2) - 0.04*(new_Ix2 + new_Iy2).^2;
    new_S = size(new_R);
    if exist('threshold','var') ~= 0
        if size(threshold,2) >= 3
            new_R_thresh = max(max(new_R))*threshold(3);
        elseif size(threshold,2) == 2
            new_R_thresh = max(max(new_R))*threshold(2);
        else
            new_R_thresh = max(max(new_R))*0.01;
        end
    else
        new_R_thresh = max(max(new_R))*0.01;
    end
    new_rowset = [];
    new_colset = [];
    
    % Find new_colset and new_rowset
    for i=2:new_S(1)-1
        for j=2:new_S(2)-1
            if new_R(i,j) > new_R_thresh
                if (new_R(i,j) > new_R(i-1,j)) && (new_R(i,j) > new_R(i,j-1)) && (new_R(i,j) > new_R(i-1,j-1)) && (new_R(i,j) > new_R(i+1,j)) && (new_R(i,j) > new_R(i,j+1)) && (new_R(i,j) > new_R(i+1,j+1)) && (new_R(i,j) > new_R(i-1,j+1)) && (new_R(i,j) > new_R(i+1,j-1))
                    new_rowset = [new_rowset i];
                    new_colset = [new_colset j];
                end
            end
        end
    end
    % Plot
    subplot(1,2,2), imshow(can_res), hold on,
    plot(new_colset,new_rowset,'y+'), title('Corners in canny Edge image');
    saveas(gcf, 'harris_detect.jpg');
end