function [ cluster_center, feature_to_cluster] = CreateDictionary( features, no_cluster, limit_no_of_iterations, time_limit)
%CreateDictionary computes the visual dictionary through K-Means
%   Usage
%   [ cluster_center, feature_to_cluster] = CreateDictionary( features, no_cluster, limit_no_of_iterations, time_limit)
%   Optional: limit_no_of_iterations: 100 (default), time_limit: inf (default)
if nargin <2
    error('At least two input arguments required.');
end
if nargin < 3
    limit_no_of_iterations = inf;
end
if nargin < 4
    time_limit = inf;
end
kstart = tic;
seedinit = tic;
count = 1;
no_feature = size(features,1);
feature_Size = size(features,2);
cluster_center = zeros(no_cluster,feature_Size);
nottaken = true(no_feature,1);

[cluster_center(1,:),t] = datasample(features,1,'Replace',false);
nottaken(t) = false;
D = inf(no_feature,1);
for i=2:no_cluster
    D=min(D,sum((features - repmat(cluster_center(i-1,:),no_feature,1)).^2,2));
    norm_const = sum(D);
    if norm_const == 0 || norm_const == inf
        cluster_center(i:no_cluster,:) = datasample(features(nottaken,:),no_cluster-i+1,'Replace',false);
        break;
    end
    [cluster_center(i,:), t] = datasample(features,1,'Weights',D/norm_const);
    nottaken(t) = false;
end
fprintf('K-Means Seed Intialized in %f sec\n',toc(seedinit));

firstiter = tic;
Dist = zeros(no_feature, no_cluster);

clusters_moved = 1:no_cluster;
for i=1:no_cluster    
    Dist(:,i) = sum((features - repmat(cluster_center(i,:),no_feature,1)).^2,2);
end
[new_Dist,feature_to_cluster] = min(Dist,[],2);

criteria = sum(new_Dist);
for k=1:no_cluster
    features_in_this_cluster = (feature_to_cluster == k);
    if sum(features_in_this_cluster) > 0
        cluster_center(k,:) = mean(features(features_in_this_cluster,:));
    end
end
fprintf('K-Means %d Iteration in %f sec. Critera: %f, Features_moved: %d, Cluster_moved: %d\n',count,toc(firstiter),criteria,no_feature, size(clusters_moved,2));
    
while true
    if (count >= limit_no_of_iterations)
        % Iterartion Limit Exceeded
        fprintf('K-Means Iterartion limit of %d reached\n',limit_no_of_iterations);
        break;
    end
    if toc(kstart)>time_limit
        % Time Limit Exceeded
        fprintf('K-Means Time limit of %f seconds exceeded\n',time_limit);
        break;
    end
    
    iterstart = tic;
    count = count +1;
    old_feature_to_cluster = feature_to_cluster;
    
    for i=clusters_moved
        Dist(:,i) = sum((features - repmat(cluster_center(i,:),no_feature,1)).^2,2);
    end
    
    [new_Dist,new_feature_to_cluster] = min(Dist,[],2);
    old_criteria = criteria;
    criteria = sum(new_Dist);
    
    if criteria >= old_criteria
        % Minima Reached
        fprintf('K-Means Minima Reached\n');
        break;
    end
    features_moved = (new_feature_to_cluster ~= old_feature_to_cluster);  % features changing cluster  
    if any(features_moved)
        features_moved = features_moved(new_Dist(features_moved) < Dist(no_feature*(old_feature_to_cluster(features_moved)-1)+ find(features_moved)));
    end
    if ~any(features_moved)
        % Converged
        fprintf('K-Means Converged\n');
        break;
    end
    
    feature_to_cluster(features_moved) = new_feature_to_cluster(features_moved);
    clusters_moved = unique([feature_to_cluster(features_moved); old_feature_to_cluster(features_moved)])'; % clusters whose features change

    for k=1:no_cluster
        features_in_this_cluster = (feature_to_cluster == k);
        if sum(features_in_this_cluster) > 0
            cluster_center(k,:) = mean(features(features_in_this_cluster,:));
        end
    end    
    fprintf('K-Means %d Iteration in %f sec. Critera: %f, Features_moved: %d, Cluster_moved: %d\n',count,toc(iterstart),criteria,sum(features_moved), size(clusters_moved,2));

end
end

