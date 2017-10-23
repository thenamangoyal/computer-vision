addpath('helper');
%% Load Train and Test Images
tload = tic;
images = loadMNISTImages('data/train-images-idx3-ubyte');
labels = loadMNISTLabels('data/train-labels-idx1-ubyte');
test_images = loadMNISTImages('data/t10k-images-idx3-ubyte');
test_labels = loadMNISTLabels('data/t10k-labels-idx1-ubyte');
n = size(images,2);
test_n = size(test_images,2);
width = ceil(sqrt(size(images,1)));
fprintf('Load dataset in %f sec\n',toc(tload));
%% Extract Train features
exttrain = tic;
patch_len = 7;
no_feature_per_image = width*width/(patch_len*patch_len);
no_patch_per_image = width/patch_len;
feature_Size = patch_len*patch_len;
no_feature = n*no_feature_per_image;
features = zeros(no_feature, feature_Size);
for i=1:n
    im = vec2mat(images(:,i),width)';
    for j=1:no_patch_per_image
        for k=1:no_patch_per_image
            temp = im(patch_len*(j-1)+1:patch_len*j,patch_len*(k-1)+1:patch_len*k);
            features(no_feature_per_image*(i-1)+no_patch_per_image*(j-1)+k,:) = temp(:)';
        end
    end
end
fprintf('Extract Train Features in %f sec\n',toc(exttrain));
%% Extract Test features
exttest = tic;
test_features = zeros(test_n*no_feature_per_image,feature_Size);
for i=1:test_n
    im = vec2mat(test_images(:,i),width)';
    for j=1:no_patch_per_image
        for k=1:no_patch_per_image
            temp = im(patch_len*(j-1)+1:patch_len*j,patch_len*(k-1)+1:patch_len*k);
            test_features(no_feature_per_image*(i-1)+no_patch_per_image*(j-1)+k,:) = temp(:)';
        end
    end
end
fprintf('Extract Test Features in %f sec\n',toc(exttest));
%% Create Dictionary by K-Means Clustering
tkmean = tic;
no_cluster = 32;
limit_no_of_iterations = 100;
time_limit = 500;
[cluster_center, feature_to_cluster]=CreateDictionary(features,no_cluster,limit_no_of_iterations,time_limit);
% save('dictionary.mat','cluster_center');
fprintf('K-Means Clustering complete with %d clusters in %f sec\n',no_cluster,toc(tkmean));
%% Find nearest neighbour
tnear = tic;
nearest_neighbour = zeros(no_cluster,1);

for i=1:no_cluster
  
    feature_in_this_cluster = find(feature_to_cluster == i);    
    D = features(feature_in_this_cluster,:) - repmat(cluster_center(i,:),size(feature_in_this_cluster,1),1);
    [~,nearest_feature] = min(sum(D.^2,2));
    nearest_neighbour(i,1) = feature_in_this_cluster(nearest_feature,1);
end

for i=1:no_cluster
    imwrite(vec2mat(cluster_center(i,:),patch_len)',strcat('clusters/mean',num2str(i),'.png'));
    image_index = ceil(nearest_neighbour(i,1)/no_feature_per_image);    
    patch_j_index = floor((nearest_neighbour(i,1)-(image_index-1)*no_feature_per_image-1)/no_patch_per_image)+1;
    patch_k_index = nearest_neighbour(i,1)-(image_index-1)*no_feature_per_image-(patch_j_index-1)*no_patch_per_image;
    im = vec2mat(images(:,image_index),width)';
    temp2 = im(patch_len*(patch_j_index-1)+1:patch_len*patch_j_index,patch_len*(patch_k_index-1)+1:patch_len*patch_k_index);
    imwrite(temp2,strcat('clusters/nearest_neighbour',num2str(i),'.png'));
    
end
fprintf('Found nearest neighbours in %f sec\n',toc(tnear));
%% Compute Histogram
thist = tic;
train_histogram = zeros(n,no_cluster);
for i=1:n
    train_histogram(i,:) = ComputeHistogram(features(no_feature_per_image*(i-1)+1:no_feature_per_image*(i),:),cluster_center);
end
fprintf('Computed Train Images Histogram in %f sec\n',toc(thist));
%% Compute histogram test images
ttesthist = tic;
test_histogram = zeros(test_n,no_cluster);
for i=1:test_n
   test_histogram(i,:) = ComputeHistogram(test_features(no_feature_per_image*(i-1)+1:no_feature_per_image*(i),:),cluster_center);
end
fprintf('Computed Test Images Histogram in %f sec\n',toc(ttesthist));
%% Compute Similarty Matrix based on Histogram Matching
tsim = tic;
sim_matrix = MatchHistogram(train_histogram,test_histogram);
fprintf('Computed Similarty Matrix based on Histogram Matching in %f sec\n',toc(tsim));
%% Predict based on k-Nearest Neighbours
tpredict = tic;
k_n = 3;
k_nearest_index = zeros(test_n,k_n);
ext_sim = sim_matrix;
for j=1:k_n
    [~, k_nearest_index(:,j)] = max(ext_sim,[],2);    
    ext_sim(test_n*(k_nearest_index(:,j)-1)+(1:test_n)') = -inf;    
end
% Break ties Nearest Neighbour
predict_labels_mat = labels(k_nearest_index);
[predict_labels,~,same_freq] = mode(predict_labels_mat,2);
count_same_freq = cellfun(@length,same_freq);
choose_first = (count_same_freq>1);
predict_labels(choose_first) = predict_labels_mat(choose_first,1);
fprintf('Predicted based on %d-Nearest Neighbours in %f sec\n',k_n, toc(tsim));
%% Accuracy
test_accuracy = sum(predict_labels == test_labels)/size(test_labels,1);

index_to_class = unique(labels); % Map Index -> Class
no_class = size(index_to_class,1);
class_to_index = containers.Map(index_to_class, 1:no_class); % Map Class -> Index

conf_matrix = zeros(no_class, no_class);
for i=1:test_n
    conf_matrix(class_to_index(test_labels(i,1)),class_to_index(predict_labels(i,1))) = conf_matrix(class_to_index(test_labels(i,1)),class_to_index(predict_labels(i,1))) +1;
end

classwise_precision = zeros(no_class,1);
classwise_recall = zeros(no_class,1);
    
for i=1:no_class
    classwise_precision(i,1) = conf_matrix(i,i)/sum(conf_matrix(:,i));
    classwise_recall(i,1) = conf_matrix(i,i)/sum(conf_matrix(i,:));
end    
fprintf('Confusion Matrix (Row: Actual,Col: Prediction)\n');
disptable(conf_matrix,cellstr(num2str(index_to_class)),cellstr(num2str(index_to_class)));
disp(table(index_to_class,classwise_precision,classwise_recall,'VariableNames',{'Class','Precision', 'Recall'}))
    
fprintf('Overall Accuracy %f\n', test_accuracy);