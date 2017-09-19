Lab 2: Feature Detection
========================

Introduction
------------
This project detects features in image i.e edges using Canny edge detection and interest points using Harris interest point detection.

The code was tested on Matlab 2017a.

* Please refer to [Report.pdf](Report.pdf) for detailed analysis.
* Please refer to [lab.pdf](lab.pdf) for about the project.


Directory Structure
-------------------
---code

	|
	|---MyCannyEdgeDetector.m
	|---MyCompareOutput.m
	|---MyDetectInterest.m
	|---lenna.png
	|---test.jpg


---[lab.pdf](lab.pdf)

---README.md

---[Report.pdf](Report.pdf)


MyCannyEdgeDetector(image, threshold)
-------------------------------------
It returns the output canny image

image is image matrix variable

threshold is 2x1 vector in format [low high]

e.g. 
imshow(MyCannyEdgeDetector(imread('lenna.png'),[0.0375 0.0938]));
imshow(MyCannyEdgeDetector(imread('test.jpg'),[0.03 0.2]));

MyCompareOutput(image, threshold)
-------------------------------------
It returns the MSE and PSNT matrix and saves the comparison figure as 'comp_output.jpg'

image is image matrix variable

threshold is 2x1 vector in format [low high]

e.g. 
MyCompareOutput(imread('lenna.png'),[0.0375 0.0938]);
MyCompareOutput(imread('test.jpg'),[0.03 0.2]);


MyDetectInterest(image, threshold)
----------------------------------
It saves the detected interest points figure as 'harris_detect.jpg'

image is image matrix variable

if threshold is 2x1 vector in format [low high] it is used a threshold for canny edge detector and high is used as threshold for Harris Detector

if threshold is 3x1 vector in format [low high harris_threshold] then [low high] is used a threshold for canny edge detector and harris_threshold is used as threshold for Harris Detector

e.g. 
MyDetectInterest(imread('test.jpg'),[0.03 0.2]);
MyDetectInterest(imread('test.jpg'),[0.03 0.2 0.01]);

Image Reference
---------------
www.cse.iitd.ernet.in/~pkalra/col783/canny.pdf

https://en.wikipedia.org/wiki/Lenna


Developed By
------------
Naman Goyal (2015csb1021@iitrpr.ac.in)
