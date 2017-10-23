function [ sim_matrix ] = MatchHistogram( train_histogram, test_histogram )
%MatchHistogram compares two histograms and returns the distance
%   [ sim_matrix ] = MatchHistogram( train_histogram, test_histogram  )
    dot_train = sqrt(sum(train_histogram.*train_histogram,2));
    dot_test = sqrt(sum(test_histogram.*test_histogram,2));
    m = size(test_histogram,1);
    n = size(train_histogram,1);
    k = size(test_histogram,2);
    sim_matrix = zeros(m,n);
    for i=1:m
        sim_matrix(i,:) = (sum((train_histogram).*(repmat(test_histogram(i,:),n,1)),2)./(dot_test(i)*dot_train))';
    end


end

