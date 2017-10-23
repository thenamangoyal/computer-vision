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
%% Genreate Patch Wise Points for Feature extraction
pinit = tic;
no_feature_per_image = 16;
no_feature_per_len = floor(sqrt(no_feature_per_image));
stepSize = floor(width/(no_feature_per_len+1));
offset = ceil((width - stepSize*(no_feature_per_len+1))/2);
rangeX = stepSize+offset:stepSize:stepSize*no_feature_per_len+offset;
rangeY = stepSize+offset:stepSize:stepSize*no_feature_per_len+offset;
[X, Y] = meshgrid(rangeX, rangeY);
             
scales = single(1.6);

% create SURFPoints object for the grid
locations = repmat([X(:) Y(:)], numel(scales),1);
scales    = repmat(scales, numel(X),1);            

points = SURFPoints(locations, 'Scale', scales(:));

fprintf('Generated Points for Feature Extraction in %f sec\n',toc(pinit));
%% Extract Train Features
exttrain = tic;
feature_Size = 64;
no_feature = n*no_feature_per_image;
features = zeros(no_feature, feature_Size);
for i=1:n
    % Get SURF Feature Descriptor
    [features(no_feature_per_image*(i-1)+1:no_feature_per_image*(i),:),~] = extractFeatures(vec2mat(images(:,i),width)',points,'Upright',true);
end
fprintf('Extract Train Features in %f sec\n',toc(exttrain));
%%  Extract Test features
exttest = tic;
test_features = zeros(test_n*no_feature_per_image,feature_Size);
for i=1:test_n
    [test_features(no_feature_per_image*(i-1)+1:no_feature_per_image*(i),:),~] = extractFeatures(vec2mat(test_images(:,i),width)',points,'Upright',true);
end
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
    image_index = ceil(nearest_neighbour(i,1)/no_feature_per_image);  
    point_index = nearest_neighbour(i,1) - (image_index-1)*no_feature_per_image;
    loc = points(point_index).Location;
    im = vec2mat(images(:,image_index),width)';
    bs = floor(10*points(point_index).Scale/1.6);
    imwrite(im(max(1,loc(2)-bs):min(loc(2)+bs,width),max(1,loc(1)-bs):min(loc(1)+bs,width)),strcat('clusters/nearest_neighbour',num2str(i),'.png'));
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