Lab 1: Hybrid Images
====================

Introduction
------------
This project creates a collage using Hybrid images.

The code was tested on Matlab 2017a.

* Please refer to [Report.pdf](Report.pdf) for detailed analysis.
* Please refer to [lab.pdf](lab.pdf) for about the project.


Directory Structure
-------------------
---code

	|
	|---Collage_Wrapper.m
	|---Collage_Wrapper_AbsSize.m
	|---CreateHybridImage.m
	|---Merge_Image.m
	|---Collage_Wrapper.m
	|---rand_full_binary_tree.m


---[lab.pdf](lab.pdf)

---README.md

---[Report.pdf](Report.pdf)


To Run
------
The function prototype is
result = Collage_Wrapper(dir_path, low_pass_filter, high_pass_filter)

* result is the final collage output
* dir_path is directory of .jpg files which is optional and default the present working directory.
* low_pass_filter and high_pass_filter are optional and by default gaussian and unsharp respectively used ot create hybrid image from 2 images.

e.g. imshow(Collage_Wrapper('images'))
imshow(Collage_Wrapper_AbsSize('images'))

Developed By
============
Naman Goyal (2015CSB1021)
