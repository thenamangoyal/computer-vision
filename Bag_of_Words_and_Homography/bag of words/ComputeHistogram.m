function [ hist ] = ComputeHistogram( features, cluster_center)
%ComputeHistogram generates the histogram using soft assignment for given
%feature vectors and the visual dictionary matrix
%   [ hist ] = ComputeHistogram( feature, cluster_center)
    if nargin <2
        error('Two input arguments required.');
    end
    f = size(features,1);
    k = size(cluster_center,1);
    if f==0
        hist = ones(1,k)/k;
    else
        hist = zeros(1,k);
        for i=1:f
            w = double(sum((cluster_center - repmat(features(i,:),k,1)).^2,2))';
            if any(w == 0)
                w = double(w==0);
            else
                w = 1./w;
            end
            w = w/sum(w);
            hist = hist +w;
        end
        hist = hist/sum(hist);
    end
end

