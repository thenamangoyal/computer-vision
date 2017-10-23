%% Developed By Naman Goyal (2015csb1021@iitrpr.ac.in)
% It takes to images at input with parameters whether to combine in height,
% alpha for bounding box computation and low pass and high pass filters and
% then computes and resizes images and bounding boxes and calls
% CreateHybridImage to merge the images
function result = Merge_Image(img1, img2, combine_height, alpha, low_pass_filter, high_pass_filter)
    s1 = (size(img1));
    h1 = s1(1);    
    w1 = s1(2);
    s2 = (size(img2));
    h2 = s2(1);
    w2 = s2(2);

    if (combine_height == true)
        % Compute Overlapping Bounding box
        area1 = [floor(w1*(1-alpha)) 0 w1-floor(w1*(1-alpha)) h1];
        area2 = [0 0 floor(alpha*w2) h2];
        
        % Resize images to match height
        new_h = floor((h1+h2)/2);
        img1 = imresize(img1, [new_h floor(w1*new_h/h1)]);            
        area1 = floor((new_h/h1)*area1);

        s1 = size(img1);
        h1 = s1(1);
        w1 = s1(2);
        img2 = imresize(img2,[new_h floor(w2*new_h/h2)]);
        area2 = floor((new_h/h2)*area2);
        s2 = size(img2);
        h2 = s2(1);
        w2 = s2(2);

    else
        % Compute Overlapping Bounding box
        area1 = [0 floor(h1*(1-alpha)) w1 h1-floor(h1*(1-alpha))];
        area2 = [0 0 w2 floor(alpha*h2)];
        
        % Resize images to match width
        new_w = floor((w1+w2)/2);
        img1 = imresize(img1, [floor(h1*new_w/w1) new_w]);
        area1 = floor((new_w/w1)*area1);
        s1 = size(img1);
        h1 = s1(1);
        w1 = s1(2);
        img2 = imresize(img2,[floor(h2*new_w/w2) new_w]);
        area2 = floor((new_w/w2)*area2);
        s2 = size(img2);
        h2 = s2(1);
        w2 = s2(2);            
    end


    % Make overlapping bounding box lie inside image and of same size and
    % relative location in both images
    if (area1(1) < 0)
        area1(1) = 0;
    end
    if (area1(1) > w1)
        area1(1) = w1;
    end

    if (area1(2) < 0)
        area1(2) = 0;
    end
    if (area1(2) > h1)
        area1(2) = h1;
    end

    if (area1(3)+area1(1)>w1)
        area1(3) = w1 - area1(1);
    end

    if (area1(4)+area1(2)>h1)
        area1(4) = h1 - area1(2);
    end
    
    if (area1(3)+area1(1)~= w1)
        area1(3) = w1-area1(1);
    end
    
    if (area2(1) < 0)
        area2(1) = 0;
    end
    if (area2(1) > w2)
        area2(1) = w2;
    end
    if (area2(2) < 0)
        area2(2) = 0;
    end
    if (area2(2) > h2)
        area2(2) = h2;
    end

    if (area2(3)+area2(1)>w2)
        area2(3) = w2 - area2(1);
    end
    if (area2(4)+area2(2)>h2)
        area2(4) = h2 - area2(2);
    end
    
    if (area2(1)~= 0)
        area2(3) = area2(3)+area2(1);
        area2(1)=0;
    end

    % Make overlapping boxes height same
    temp = min(area1(4),area2(4));
    if floor(temp/2 - area1(4)/2) > 0
        area1(2) = area1(2) + floor(temp/2 - area1(4)/2);
    end
    area1(4) = temp;
    if floor(temp/2 - area2(4)/2)>0
        area2(2) = area2(2) + floor(temp/2 - area2(4)/2);
    end
    area2(4) = temp;


    % Make overlapping boxes width same
    temp = min(area1(3),area2(3));
    if floor(temp/2 - area1(3)/2) > 0
        area1(1) = area1(1) + floor(temp/2 - area1(3)/2);
    end
    area1(3) = temp;
    if floor(temp/2 - area2(3)/2) > 0
        area2(1) = area2(1) + floor(temp/2 - area2(3)/2);
    end
    area2(3) = temp;


    if combine_height == false
        % If combine in width rotate the images and bounding box to do
        % height combine
        img1 = imrotate(img1, 90);
        img2 = imrotate(img2, 90);
        area1 = area1(:,[2 1 4 3]);
        area2 = area2(:,[2 1 4 3]);
    end

    % Create Hybrid Image
    result = CreateHybridImage(img1,area1,img2,area2, low_pass_filter, high_pass_filter);
    if (combine_height == false)
        % If combine in width rotate back the merge imaged in height
        result = imrotate(result, -90);
    end
end