%% Developed By Naman Goyal (2015csb1021@iitrpr.ac.in)
% Generate a random full binary tree with 'n' internal nodes
function arr = rand_full_binary_tree(n)
    % Base case
    if n < 0
        arr = [];
    elseif n==0
        arr = [2];
    elseif n==1
        arr = [1 2 2];
    else
        
        % Generate  a truncated normal distribution mu = n/2, sigma = n/2,
        % to choose no of interal nodes in left and right child subtree
        distr = truncate(makedist('Normal','mu',n/2,'sigma',1),-1,n+1);
        x = floor(random(distr));
        if x<0
            x = 0;
        elseif x>n-1
            x = n-1;
        end
        
        lc = x;
        rc = n-1-lc;
        
        % Recursively build the left and right child subtree
        lt = rand_full_binary_tree(lc);
        rt = rand_full_binary_tree(rc);
        
        % Concatenate merged subtrees
        arr = [1];
        k=1;
        while isempty(lt)== false ||  isempty(rt) == false
            if isempty(lt) == true
                arr = [arr, zeros(1,k)];
            else
                arr = [arr, lt(1:k)]; lt(1:k) = [];
            end
            if isempty(rt) == true
                arr = [arr, zeros(1,k)];
            else
                arr = [arr, rt(1:k)]; rt(1:k) = [];
            end
            k=2*k;
        end
        
    end
end