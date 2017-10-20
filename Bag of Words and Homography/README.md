Lab 3: Bag of Words and Homography
==================================


Introduction
------------
This project consists of 2 parts.
Part 1 is to create a Bag of words based matching/categorization solution on the MNIST-fashion database.
Part 2 is to compute homography based on 4 corresponding points selected in 2 images warp which are then joined/stitched into a third image and based on the computed homography.


* Please refer to [Report.pdf](Report.pdf) for detailed analysis.
* Please refer to [lab.pdf](lab.pdf) for about the project.


Note
----
1. It was observed that best results/accuracy are obtained from PatchSURFBagOfWords for Part 1.
2. The closest word to the mean of the cluster is saved in 'clusters' folder.
3. The code was tested on Matlab 2017a.

Directory Structure
-------------------
<pre>
---bag of words
	|
	|---PatchSURFBagOfWords.m
	|---PatchIntensityBagOfWords.m
	|---InterestPointBagOfWords.m

---homogrpahy
	|
	|---ComputeHomography.m
</pre>


---[lab.pdf](lab.pdf)

---README.md

---[Report.pdf](Report.pdf)


Part 1
======

PatchSURFBagOfWords
-------------------
Create a Bag of words based matching/categorization solution on the MNIST-fashion database.
It uses SURF Descriptor patchwise.

PatchIntensityBagOfWords
------------------------
Create a Bag of words based matching/categorization solution on the MNIST-fashion database.
It uses intensity information (appended vector) patchwise.

InterestPointBagOfWords
-----------------------
Create a Bag of words based matching/categorization solution on the MNIST-fashion database.
It uses first detect Harris Interest Points and then use SURF Descriptor as a feature.



Part 2
======

ComputeHomography(im1, im2)
---------------------------
The program lets a user select four points each (in GUI) in the two images computes homography function and then uses it to join/stitch the two images (mosaic) into a another image. It computes homogrpahy both side that it warps im1 on im2 and vice versa, and displays both result and returns both computed homography.

Please select corresponding ppoints in same order in both the images. If you select wrong points please restart the program.

e.g. 
ComputeHomography(imread('data/synthetic1.jpg'),imread('data/synthetic2.jpg'));

If code takes long time to compute homography, please select a different set of non-colinear points.

References
----------
1. For parsing the MNIST Images and Labels from the input binary file code obtained from
http://ufldl.stanford.edu/wiki/index.php/Using_the_MNIST_Dataset which is available in open source license

2. For Displaying Confusion Matrix table with Row and Column Label, disptable obtained from
https://in.mathworks.com/matlabcentral/fileexchange/27384-disptable-display-matrix-with-column-or-row-labels
It is was that there was a non-black pixel corresponding every 28x28 array hence all patches for feature extracted are important. 


Dataset
-------

1. MNIST Fashion Dataset
Fashion-MNIST is a dataset of Zalando's article images—consisting of a training set of 60,000 examples and a test set of 10,000 examples. Each example is a 28x28 grayscale image, associated with a label from 10 classes.

https://github.com/zalandoresearch/fashion-mnist

2. Image Stitching
This file contains the dataset used in the SCIA2015 paper:
Giulia Meneghetti, Martin Danelljan, Michael Felsber and Klas Nordberg, Image alignment for panorama stitching in sparsely structured environments, SCIA 2015

The dataset can be found here:
http://www.cvl.isy.liu.se/research/datasets/passta/
Giulia Meneghetti giulia.meneghetti@liu.se


Developed By
------------
Naman Goyal (2015csb1021@iitrpr.ac.in)
