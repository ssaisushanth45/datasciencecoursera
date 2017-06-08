# Topic: Getting and Cleaning Data - Coursera - Final Assignment Project Submission
Version.Revision: 1.0

Name: Sai S Sampathkumar
Address: xxxxxxx, xxxxxx
Email: xxx@xxxxxxxxx.xxx

## General Description:


The purpose of this project submission is to demonstrate the ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. In other words, it should have the following components:

- Each variable measured should in one column
- Each  different observation of that variable should be in a different row
- There should be one table for each "kind" of variable
- If there are multiple tables, they should include a column in the table that allows them to be joined or merged 

I have been tasked with creating a tidy data set based on the study outlined in:
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
using the Raw Data files in:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
Furthermore, my task is also to create one R script called run_analysis.R that does the following:

* Merges the training and the test sets to create one data set.
* Extracts only the measurements on the mean and standard deviation for each measurement.
* Uses descriptive activity names to name the activities in the data set
* Appropriately labels the data set with descriptive variable names.
* From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## Details of Steps Followed:

Based on the README.TXT, FEATURES.TXT, FEATURES_INFO.TXT of the researchers at Smartlabs, the following are salient highlights:
*	  Data is collected for 30 subjects broken into two groups - 21 subjects in Train (70% of data) and 9 subjects in Test data sets
*	  X data is of dimension 10299 observations X 561 feature combinations (combined for Train and Test sets) from accelerometer and gyroscope readings from the S2 phone
*	  Y variable (Response - Activity Label) and Subject (Volunteer No.) are each 10299 X 1 dimensional 
*	  6 activities are performed by the subjects (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
*	  10 time domain signals and 7 frequency domain signals data were collected

The following describes the thought process of the script:

* 1. Library calls for packages to be used in this analysis
* 2. Set working directory to pick up the data
* 3. Reading the data sets from wd (features dealt with later). 
* 4. Merge Train & Test data sets for x,y,subject	
* 5. Merge Y (Activity) and Subject (Volunteer num 1-30) columns to X (features).Massaging feature names to add subject(leftmost) and Y(rightmost): in other words [Subject][X-561 cols][Y] totaling 563 columns 
* 6. Read feature table for making column names and add column names to merged data
* 7. Extracting only mean and standard deviation for each measurement in Mdata(merged data set). First, extracting relevant columns separately and putting it back together into Mdata
* 8. Adding activity names in place of class labels for Y
* 9. Removing extraneous data tables from workspace; to contain only required messy dataset that needs to be tidied
* 10. Renaming feature labels wrt naming conventions (all lower case, descriptive, not duplicated, no underscores,dots etc)
* 11. Creating a second data set from Step 10 above to compute average of each activity and each subject. First, we check to ensure no missing data.
* 12. Writing new summarized dataset (submission_text) back to the working directory (which will be pushed to the Github repo)



## Files Included in this Submission:

* 'ReadMe.md'
* 'run_analysis.R' (providing the "Instructions List" as comments)
* 'CodeBook.md' (Refer aforementioned links for "Study Design")
* 'submission_data.txt' (cleaned up tidy data set) (taken out of here to be shared on the course website)

### Notes: 

- I am only creating a template at this time.

For more information about this submission/repo contact: xxx@xxxxxxxxx.xxx


### License:

Use of parts or in whole of this submission in publications must be acknowledged by referencing the following [1] 

[1] Sai S Sampathkumar's Coursera Project Submission: Getting & Cleaning Data

This submission repo is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their organization for its use or misuse. Any commercial use is prohibited.

Sai S Sampathkumar. June 2017.

