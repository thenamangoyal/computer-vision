%% Developed By Naman Goyal (2015csb1021@iitrpr.ac.in)
% It takes a path as input, reads all .jpg images in it and produces a
% collage using closest matching pairs. You can optionally provide low_pass_filter, high_pass_filter used in creating hybrid image. 
function result = Collage_Wrapper_AbsSize(dir_path, low_pass_filter, high_pass_filter)
    if nargin == 0
        dir_path = pwd;
        low_pass_filter = fspecial('gaussian');
        high_pass_filter = fspecial('unsharp');
    elseif nargin == 1
        low_pass_filter = fspecial('gaussian');
        high_pass_filter = fspecial('unsharp');
    end
    alpha= 0.2;
    imgpath = dir(strcat(dir_path,'\*.jpg'));
    result = ones(1,1,3);
    result(:,:,3) = 0;

    if isempty(imgpath)==false
        % Read all images into a pool
        imgset(length(imgpath)) = struct(); 
        for i=1:length(imgpath)
            imgset(i).img = imread(strcat(dir_path,'\',imgpath(i).name));
            s = size(imgset(i).img);
            imgset(i).h = s(1);
            imgset(i).w = s(2);
            imgset(i).m = 0;

        end

        
        % Start meging using closest matching pairs
        hj = 0;
        wj = 0;
        count =0;
        while length(imgset) > 1
            clear result;
            count = count+1;
            
            % Get closest matching pair based on height
            h_pair1_index = 1;
            h_pair2_index = 2;
            h_pair_diff = abs(imgset(1).h - imgset(2).h);
            
            for i=2:length(imgset)
                for j=i+1:length(imgset)
                    if (abs(imgset(i).h - imgset(j).h) < h_pair_diff)
                        h_pair1_index = i;
                        h_pair2_index = j;
                        h_pair_diff = abs(imgset(i).h - imgset(j).h);
                    end
                end
            end
            
            % Get closest matching pair based on width
            w_pair1_index = 1;
            w_pair2_index = 2;
            w_pair_diff = abs(imgset(1).w - imgset(2).w);
            
            for i=2:length(imgset)
                for j=i+1:length(imgset)
                    if (abs(imgset(i).w - imgset(j).w) < w_pair_diff)
                        w_pair1_index = i;
                        w_pair2_index = j;
                        w_pair_diff = abs(imgset(i).w - imgset(j).w);
                    end
                end
            end
            
            % Compare the two closed matching pairs in width and height and
            % choose according to height and width combinations so far
            if (imgset(h_pair1_index).m + imgset(h_pair2_index).m < 3)&& ((wj>=2) ||  (h_pair_diff<= w_pair_diff && hj <2))
                % Combine in height
                img1 = imgset(h_pair1_index).img;
                img2 = imgset(h_pair2_index).img;
                new_m = imgset(h_pair1_index).m + imgset(h_pair2_index).m +1;
                imgset([h_pair1_index h_pair2_index]) = [];
                result = Merge_Image(img1, img2,true,alpha, low_pass_filter, high_pass_filter);
                hj = hj+ 1;
                wj = 0;
            else
                % Combine in width
                img1 = imgset(w_pair1_index).img; 
                img2 = imgset(w_pair2_index).img;
                new_m = imgset(w_pair1_index).m + imgset(w_pair2_index).m -1;
                imgset([w_pair1_index w_pair2_index]) = [];
                result = Merge_Image(img1, img2,false,alpha, low_pass_filter, high_pass_filter);
                wj = wj +1;
                hj = 0;
            end
            
            % Add combined image back to pool
            new_size = length(imgset)+1;
            imgset(new_size).img = result;
            s = size(result);
            imgset(new_size).h = s(1);
            imgset(new_size).w = s(2);
            imgset(new_size).m = new_m;
            
        end
        
%         % eturn only remaining image in the pool
        result = imgset(1).img;
    end
end