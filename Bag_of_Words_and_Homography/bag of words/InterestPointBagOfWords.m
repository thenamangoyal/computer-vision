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
fprintf('Loaded dataset in %f sec\n',toc(tload));
%% Extract Features
exttrain = tic;
feature_Size = 64;
features = [];
no_feature_image = zeros(n+1,1);
points_location = [];

for i=1:n
    im = vec2mat(images(:,i),width)';
    points = detectHarrisFeatures(im,'MinQuality',0);
    [feature, valid_points] = extractFeatures(im,points,'Method','SURF','Upright',true);
    no_feature_image(i+1,1) = valid_points.Count;
    features = [features; feature];
    points_location = [points_location;[repmat(i,valid_points.Count,1) valid_points.Location]];
end
no_feature = sum(no_feature_image);
cum_no_feature_image = cumsum(no_feature_image);

fprintf('Extract Train Features in %f sec\n',toc(exttrain));
%%  Extract Test features
exttest = tic;
test_features = [];
test_points_location = [];
test_no_feature_image = zeros(test_n+1,1);
for i=1:test_n
    im = vec2mat(test_images(:,i),width)';
    points = detectHarrisFeatures(im,'MinQuality',0);
    [feature, valid_points] = extractFeatures(im,points,'Method','SURF','Upright',true);
    test_no_feature_image(i+1,1) = valid_points.Count;
    test_features = [test_features; feature];    
    test_points_location = [test_points_location;[repmat(i,valid_points.Count,1) valid_points.Location]];
end

test_no_feature = sum(test_no_feature_image);
cum_test_no_feature_image = cumsum(test_no_feature_image);
fprintf('Extract Test Features in %f sec\n',toc(exttest));
%% Create Dictionary by K-Means Clustering
tkmean = tic;
no_cluster = 50;
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
    image_index = points_location(nearest_neighbour(i,1),1);  
    loc = points_location(nearest_neighbour(i,1),2:3);
    im = vec2mat(images(:,image_index),width)';
    bs = 10;
    imwrite(im(max(1,round(loc(2)-bs)):min(round(loc(2)+bs),width),max(1,round(loc(1)-bs)):min(round(loc(1)+bs),width)),strcat('clusters/nearest_neighbour',num2str(i),'.png'));
end

fprintf('Found nearest neighbours in %f sec\n',toc(tnear));
%% Compute Histogram
thist = tic;
train_histogram = zeros(n,no_cluster);
for i=1:n
    train_histogram(i,:) = ComputeHistogram(features(cum_no_feature_image(i)+1:cum_no_feature_image(i+1),:),cluster_center);
end
fprintf('Computed Train Images Histogram in %f sec\n',toc(thist));
tic
%% Compute histogram test images
ttesthist = tic;
test_histogram = zeros(test_n,no_cluster);
for i=1:test_n
   test_histogram(i,:) = ComputeHistogram(test_features(cum_test_no_feature_image(i)+1:cum_test_no_feature_image(i+1),:),cluster_center);
end
fprintf('Computed Test Images Histogram in %f sec\n',toc(ttesthist));
%%% Compute Similarty Matrix based on Histogram Matching
tsim = tic;
sim_matrix = MatchHistogram(train_histogram,test_histogram);
fprintf('Computed Similarty Matrix based on Histogram Matching in %f sec\n',toc(tsim));
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