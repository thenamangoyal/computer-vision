Lab 4: Object Detection
=======================


Introduction
------------
Object detection (autorickshaw) in images. There are a total of 800 images using HOG+SVM

The code was tested on Matlab 2017a.

* Please refer to [Report.pdf](Report.pdf) for detailed analysis.
* Please refer to [lab.pdf](lab.pdf) for about the project.


Directory Structure
-------------------
---code

	|
	|---RunAll.m
	|---learntmodel.mat
	|---negfeat.mat
	|---posfeat.mat
	|---images (Download from https://goo.gl/q8j6JE)
	|---test (Download from https://goo.gl/q8j6JE)
	|---bbs

---[results](results)

---[lab.pdf](lab.pdf)

---README.md

---[Report.pdf](Report.pdf)




To Run
------

1. Download Dataset from https://goo.gl/q8j6JE

2. Unzip it directly inside code directory i.e. place the extracted 'images' and 'test' directly inside 'code'.

3. Basic Execution 

RunAll.m

i.e model runs on test data directly.

4. Advance Execution

RunAll( outlier_rate, re_read )

*Optional: outlier_rate, re_read 
*Change outlier_rate to 1 to 100 to see difference
*Re_read is NOT required it just re-reads whole dataset. By default false. May take 1-3 hour.

e.g. RunAll( 5 )
to see output with outliers reduced, where the model is saved and directly run on Test data.


Dataset
-------

This is a sample dataset for the Autorickshaw detection challenge. http://cvit.iiit.ac.in/autorickshaw_detection

Developed By
------------
Naman Goyal (2015csb1021@iitrpr.ac.in)
