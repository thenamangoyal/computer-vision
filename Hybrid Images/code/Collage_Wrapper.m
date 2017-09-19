%% Developed By Naman Goyal (2015csb1021@iitrpr.ac.in)
% It takes a path as input, reads all .jpg images in it and produces a
% collage using full binary tree method. You can optionally provide low_pass_filter, high_pass_filter used in creating hybrid image. 
function result = Collage_Wrapper(dir_path, low_pass_filter, high_pass_filter)
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
        % Read all images
        imgset(length(imgpath)) = struct(); 
        for i=1:length(imgpath)
            imgset(i).img = imread(strcat(dir_path,'\',imgpath(i).name));
            s = size(imgset(i).img);
            imgset(i).h = s(1);
            imgset(i).w = s(2);
            imgset(i).area = s(2)*s(1);

        end
        result = imgset(1).img;
        
        if length(imgset) > 1      
            % Sort images based on area
            
            ifields = fieldnames(imgset);
            icell = struct2cell(imgset);
            sz = size(icell);
            icell = reshape(icell, sz(1), []);
            icell = icell';


            acell = sortrows(icell, 4);
            acell = reshape(acell', sz);
            Asorted = cell2struct(acell, ifields, 1);
            
            % Generate  a random full binary tree
            rand_tree = rand_full_binary_tree(length(imgset)-1);            
            imgset = fliplr(Asorted);
            
            % Assign images in sorted order to the generated full binary tree
            img_assign = 1;
            collage(length(rand_tree)) = struct();
            for i=1:length(rand_tree)
                if rand_tree(i) == 0
                    % NULL Nodes
                    collage(i).node = false;
                    collage(i).ext_node = false;
                    collage(i).split = ' ';
                    collage(i).ratio = 0;
                    collage(i).img = 0;
                    
                elseif rand_tree(i) == 1
                    % Internal Nodes
                    collage(i).node = true;
                    collage(i).ext_node = false;
                    if rand(1) >=0.5
                        collage(i).split = 'V';
                    else
                        collage(i).split = 'H';
                    end
                    collage(i).ratio = 0;
                    collage(i).img = 0;
                else
                    % External Nodes
                    collage(i).node = true;
                    collage(i).ext_node = true;
                    collage(i).split = ' ';
                    stemp = size(imgset(img_assign).img);
                    collage(i).ratio = stemp(2)/stemp(1);
                    collage(i).img = imgset(img_assign).img;
                    img_assign =img_assign+1;
                end
                collage(i).split;
                
            end
            
           
            % Assign split information to internal nodes based on its children
            for i=length(collage):-1:1
                if collage(i).node == true && collage(i).ext_node == false
                    if collage(2*i).ext_node == true && collage(2*i+1).ext_node == true
                        i1 = collage(2*i).img;
                        i2 = collage(2*i+1).img;
                        s1 = size(i1);
                        s2 = size(i2);
                        if abs(s1(1) - s2(1)) <= abs(s1(2) -s2(2))
                            collage(i).split = 'V';
                        else
                            collage(i).split = 'H';
                        end
                    elseif collage(2*i).ext_node == true && collage(2*i+1).ext_node == false
                        if collage(2*i+1).split == 'H'
                            collage(i).split = 'V';
                        else
                            collage(i).split = 'H';
                        end
                    elseif collage(2*i).ext_node == false && collage(2*i+1).ext_node == true
                         if collage(2*i).split == 'H'
                            collage(i).split = 'V';
                        else
                            collage(i).split = 'H';
                         end
                    else
                        if collage(2*i).split == 'H' && collage(2*i+1).split == 'H'
                            collage(i).split = 'V';
                        elseif collage(2*i).split == 'V' && collage(2*i+1).split == 'V'
                            collage(i).split = 'H';
                        else
                            if rand(1) >=0.5
                                collage(i).split = 'V';
                            else
                                collage(i).split = 'H';
                            end
                        end
                    end
                end
            end
            
            % Call helper function to merge the images based on full binary tree
            result = merge_ans(1);
            
        end
    end
    
    % Recursive helper function to merge the images based on full binary tree
    function merge_img = merge_ans(node_index)
        if collage(node_index).ext_node == false
            M1 = merge_ans(2*node_index);
            M2 = merge_ans(2*node_index+1);
            if collage(node_index).split == 'V'
                collage(node_index).img = Merge_Image(M1, M2,true,alpha, low_pass_filter, high_pass_filter);
            else
                collage(node_index).img = Merge_Image(M1, M2,false,alpha, low_pass_filter, high_pass_filter);
            end
        end
        merge_img = collage(node_index).img;
    end
    

    
end
