function [  ] = RunAll( outlier_rate, re_read )
if nargin <= 1
    outlier_rate = 3;
    
end
if nargin <=2
    re_read = false;
end
% clear all;
fileid = fopen(fullfile('.','bbs','bbs.json'));
readboxes = char(fread(fileid,inf)');
fclose(fileid);
box_const = jsondecode(readboxes);
maxlim = [1024 1024];
filedir = 'images';
totalN = 800;
patchsize = [64 64];
trainN = 6/8*totalN;

%%
re_read = false;
if re_read == true
    fprintf('Reading again may take 1-2 hours');
    gettrain = tic;
    negtrainset = [];
    postrainset = [];
    
    
    for i=1:trainN
        im = im2double(imread(fullfile(filedir,strcat(num2str(i-1),'.jpg'))));
        nonsize = ceil([size(im,1)/patchsize(1) size(im,2)/patchsize(2)]);
        nonauto = zeros(nonsize(1)*patchsize(1),nonsize(2)*patchsize(2),size(im,3));
        nonauto(1:size(im,1),1:size(im,2),:) = im;
        
        for b=1:size(box_const{i},1)
            y = (box_const{i}(b,:,2));
            x = (box_const{i}(b,:,1));
            ytop = round(min(y));
            ybottom = round(max(y));
            xtop = round(min(x));
            xbottom = round(max(x));
            if xtop < 1
                xtop = xtop +1;
            end
            if xbottom > size(im,2)
                xbottom = xbottom-1;
            end
            if ytop < 1
                ytop = ytop +1;
            end
            if ybottom > size(im,2)
                ybottom = ybottom-1;
            end
            if ytop>0 && ybottom <=size(im,1) && xtop >0 && xbottom <= size(im,2)
                
                auto_curr = im(ytop:ybottom,xtop:xbottom,:);
                
                w = size(auto_curr,1);
                h = size(auto_curr,2);
                if w >= h
                    old_auto = imresize(auto_curr, [ceil(patchsize(1)*(h/w)) patchsize(1)] );
                    auto_resized = zeros(patchsize(1),patchsize(2),size(im,3));
                    auto_resized(1:size(old_auto,1),1:size(old_auto,2),:) = old_auto;
                    [feature, ~] = extractHOGFeatures(auto_resized);
                    postrainset = [postrainset; feature];
                    %            imshow(newim);
                    %            hold on;
                    %            plot(o_p);
                    %            pause;
                    
                else % w < h
                    old_auto = imresize(im, [patchsize(2) ceil(patchsize(2)*(w/h))] );
                    
                    auto_resized = zeros(patchsize(1),patchsize(2),size(im,3));
                    auto_resized(1:size(old_auto,1),1:size(old_auto,2),:) = old_auto;
                    [feature, ~] = extractHOGFeatures(auto_resized);
                    postrainset = [postrainset; feature];
                    
                end
                nonauto(ytop:ybottom,xtop:xbottom,:) = 0;
            else
                fprintf('Skip box %d in image %d\n',b,i-1);
                %             subplot(121);
                %             imshow(nonauto);
                %             subplot(122);
                %             imshow(im);
                %             pause(2);
            end
        end
        h = size(nonauto,1);
        w = size(nonauto,2);
        if size(nonauto,2) > maxlim(2)
            nonauto = imresize(nonauto, [round(h*(maxlim(2)/w)) maxlim(2)]);
        end
        
        if size(nonauto,1) > maxlim(1)
            nonauto = imresize(nonauto, [maxlim(1) round(w/h*maxlim(1))]);
        end
        
        nonsize = ceil([size(nonauto,1)/patchsize(1) size(nonauto,2)/patchsize(2)]);
        newnonauto = zeros(nonsize(1)*patchsize(1),nonsize(2)*patchsize(2),size(nonauto,3));
        newnonauto(1:size(nonauto,1),1:size(nonauto,2),:) = nonauto;
        hogtime = tic;
        for a=1:size(newnonauto,1)/patchsize(1)
            for b=1:size(newnonauto,2)/patchsize(2)
                [feature, ~] = extractHOGFeatures(newnonauto((a-1)*patchsize(1)+1:a*patchsize(1),(b-1)*patchsize(2)+1:b*patchsize(2),:));
                negtrainset = [negtrainset; feature];
            end
        end
        fprintf('Got HOG features for %d image in %f s\n',i-1, toc(hogtime));
        %     imshow(newnonauto);
        
    end
    save('posfeat.mat','postrainset')
    save('negfeat.mat','negtrainset')
    fprintf('Got train features in %f s\n', toc(gettrain));
else
    
    
    fprintf('Loaded procesed dataset');
    load('posfeat.mat','postrainset')
    load('negfeat.mat','negtrainset')
end

%%
traintime = tic;
 len = min(round(outlier_rate*size(postrainset,1)),(size(negtrainset,1)));
negtrainsetuse = negtrainset(1:len,:);
Y = [ones(size(postrainset,1),1); zeros(size(negtrainsetuse,1),1)];
X = [postrainset; negtrainsetuse];
learnedmodel = fitcsvm(X,Y,'Standardize',true,'KernelFunction','RBF',...
    'KernelScale','auto');

fprintf('Trained on extracted features %f s\n', toc(traintime));
saveCompactModel(learnedmodel,'learntmodel');
%%
fileid = fopen(fullfile('.','bbs','bbs.json'));
readboxes = char(fread(fileid,inf)');
fclose(fileid);
box_const = jsondecode(readboxes);
maxlim = [1024 1024];
filedir = 'images';
totalN = 800;
patchsize = [64 64];
trainN = 6/8*totalN;
learnedmodel = loadCompactModel('learntmodel');
overall = size(zeros(200,1));
for i=trainN+1:totalN
    im = im2double(imread(fullfile(filedir,strcat(num2str(i-1),'.jpg'))));
    maxb = [1 1 0 0];
    for b=1:size(box_const{i},1)
        y = (box_const{i}(b,:,2));
        x = (box_const{i}(b,:,1));
        ytop = round(min(y));
        ybottom = round(max(y));
        xtop = round(min(x));
        xbottom = round(max(x));
        if ytop>0 && ybottom <=size(im,1) && xtop >0 && xbottom <= size(im,2)
            
            currb = [xtop ytop xbottom-xtop ybottom-ytop];
            if ((maxb(3)*maxb(4)) <= currb(3)*currb(4))
                maxb = currb;
            end
            im(ytop:ybottom,xtop:xbottom,2) = 1;
        end
    end
    
    
    %     h = size(im,1);
    %     w = size(im,2);
    %     if size(im,2) > maxlim(2)
    %         im = imresize(im, [round(h*(maxlim(2)/w)) maxlim(2)]);
    %     end
    %     if size(im,1) > maxlim(1)
    %         im = imresize(im, [maxlim(1) round(w/h*maxlim(1))]);
    %     end
    selected = []; % [scale y x]
    torun = true;
    maxscore = -inf;
    scales = [size(im,1) round(size(im,1)/2)];
    for sc=scales
        if torun == false
            break;
        end
        title([num2str(sc),' ', num2str(i-1)]);
        
        newim = im;
        %          newsize = ceil([size(im,1)/sc size(im,2)/sc]);
        %             newim = zeros(newsize(1)*sc,newsize(2)*sc,size(im,3));
        %             newim(1:size(im,1),1:size(im,2),:) = im;
        
        stride = max(4,round(sqrt(sc)));
        for a=1:stride:(size(newim,1)-sc+1)
            if torun == false
                break;
            end
            for b=1:stride:(size(newim,2)-sc+1)
                if torun == false
                    break;
                end
                plotim = newim;
                patch = newim(a:(a+sc-1),b:(b+sc-1),:);
                [testfeature, ~] = extractHOGFeatures(imresize(patch, patchsize)); hold on;
                
                [prediction, score] = predict(learnedmodel, testfeature);
                
                score =  score(2);
                if (prediction == 1) && (score > maxscore) && (score >=0)
                    
                    title(['Green: Actual Red: Predicted Score ',num2str(score)]);
                    maxscore = score;
                    selected = [b a sc sc];
                    
                    plotim(a:(a+sc-1),b:(b+sc-1),1) = 1;
                    
                    imshow(plotim);
                    pause(0.01);
                    if maxscore>0.011
                        torun = false;
                    end
                else
                    imshow(plotim); hold on
                    rectangle('Position',[b a sc sc]);
                    pause(0.000000001);
                end
            end
        end
        imshow(plotim);
        pause(0.01);
        close;
    end
    if torun == false
        if isequal(maxb,[1 1 0 0])
            accuracy = 1;
        else
            accuracy = bboxOverlapRatio(selected,maxb);
        end
   else
        if isequal(maxb,[1 1 0 0])
            accuracy = 1;
        else
            accuracy = 0;
        end
    end
    overall(i-trainN) = accuracy; 
    fprintf('Accuracy in %d is %f\n',i-trainN, accuracy);
    
end

total = sum(overall)/numel(overall);

