function result = MyCannyEdgeDetector(input_image, threshold)
    if nargin < 1
        input_image(:,:,1) = 0;
        input_image(:,:,2) = 0;
        input_image(:,:,3) = 0;
    end
    input_image = rgb2gray(input_image);
    %Apply Gaussian Blur
    input_image = double(imfilter(input_image,fspecial('gaussian',[5 5], sqrt(2)), 'replicate','same'));
    %Get Gradient
    gx = [-1 0 1; -2 0 2; -1 0 1];
    gy = [-1 -2 -1; 0 0 0; 1 2 1];
    
    gradx = imfilter(input_image,gx, 'conv', 'replicate');
    grady = imfilter(input_image,gy, 'conv', 'replicate');
    
    grad = sqrt(gradx.^2 + grady.^2); 
    theta = atan2d(grady, gradx);
    
   %Based on nearest theta to 0, 45, 90, 135 generate edges - theta maybe negative
    s = size(theta);
    temp = zeros(s(1), s(2));
    for i=2:s(1)-1
        for j=2:s(2)-1
            if (theta(i,j)>=-22.5 && theta(i,j)<=22.5) || (theta(i,j)<-157.5 && theta(i,j)>=-180) || (theta(i,j)>=157.5 && theta(i,j)<=180)
                if (grad(i,j) > grad(i,j+1)) && (grad(i,j) > grad(i,j-1))
                    temp(i,j)= grad(i,j);
                else
                    temp(i,j)=0;
                end
            elseif (theta(i,j)>=22.5 && theta(i,j)<=67.5) || (theta(i,j)<-112.5 && theta(i,j)>=-157.5)
                if (grad(i,j) > grad(i+1,j+1)) && (grad(i,j) > grad(i-1,j-1))
                    temp(i,j)= grad(i,j);
                else
                    temp(i,j)=0;
                end
            elseif (theta(i,j)>=67.5 && theta(i,j)<=112.5) || (theta(i,j)<-67.5 && theta(i,j)>=-112.5)
                if (grad(i,j) >= grad(i+1,j)) && (grad(i,j) >= grad(i-1,j))
                    temp(i,j)= grad(i,j);
                else
                    temp(i,j)=0;
                end
            elseif (theta(i,j)>=112.5 && theta(i,j)<=157.5) || (theta(i,j)<-22.5 && theta(i,j)>=-67.5)
                if (grad(i,j) >= grad(i+1,j-1)) && (grad(i,j) >= grad(i-1,j+1))
                    temp(i,j)= grad(i,j);
                else
                    temp(i,j)=0;
                end
            end
        end
    end
    
    % Normalise the result
    grad = temp/max(temp(:));
    
    
    if (nargin < 2) || (size(threshold,2) == 0)
        threshold = [max(max(grad))*0.08 max(max(grad))*0.2];
    end
    if size(threshold,2) == 1
        threshold = [0.4*threshold(1) threshold(1)];
    end
    
    % Apply double threshold
    strongrow = [];
    strongcol = [];
    weak = zeros(s(1),s(2));
    result =  zeros(s(1),s(2));
    for i=2:s(1)-1
        for j=2:s(2)-1
            if grad(i,j) > threshold(2)
                strongrow = [strongrow i];
                strongcol = [strongcol j];
                result(i,j) = 1;
            elseif grad(i,j) > threshold(1)
                weak(i,j) = 1;
            end
        end
    end
    
    while (size(strongrow) > 0)
        toaddrow = [];
        toaddcol = [];
        for i=-1:1:1
            for j=-1:1:1
                if (strongrow(1) + i > 0) && (strongrow(1) + i <= s(1)) && (strongcol(1) + j > 0) && (strongcol(1) + j <= s(2))
                    if weak(strongrow(1) + i, strongcol(1) + j) == 1
                        result(strongrow(1) + i, strongcol(1) + j) = 255;
                        weak(strongrow(1) + i, strongcol(1) + j) = 0;
                        toaddrow = [toaddrow strongrow(1)+i];
                        toaddcol = [toaddcol strongcol(1)+j];
                    end
                end
            end
        end
        strongrow(1) = [];
        strongcol(1) = [];
        strongrow = [toaddrow strongrow];
        strongcol = [toaddcol strongcol];
    end


end
