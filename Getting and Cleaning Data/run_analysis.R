# 1. Library calls for packages to be used in this analysis
library(data.table)
library(dplyr)
library(tidyr)
library(plyr)

# 2. Set working directory to pick up the data
setwd("C:/Users/ssais/Documents/11. Coursework/Data Science/3. Getting & Cleaning Data/data/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset/")

# 3. Reading the data sets from wd (features dealt with later)
xtrain <- read.table("./train/X_train.txt",header = FALSE)
ytrain <- read.table("./train/y_train.txt",header = FALSE)
subtrain <- read.table("./train/subject_train.txt",header = FALSE)

xtest <- read.table("./test/X_test.txt",header = FALSE)
ytest <- read.table("./test/y_test.txt",header = FALSE)
subtest <- read.table("./test/subject_test.txt",header = FALSE)

# 4. Merge Train & Test data sets for x,y,subject
mrgdatax <- rbind(xtrain,xtest)
mrgdatay <- rbind(ytrain,ytest)
mrgdatasub <- rbind(subtrain,subtest)

# 5. Merge Y (Activity) and Subject (Volunteer num 1-30) columns to X (features)
# Massaging feature names to add subject(leftmost) and Y(rightmost): in other 
# words [Subject][X-561 cols][Y] totaling 563 columns 

Mdata <- cbind(mrgdatasub, mrgdatax, mrgdatay)

# 6. Read feature table for making column names and add column names to merged data

features <- read.table("./features.txt",header = FALSE)
sub <- data.frame(V1= 0, V2= "Subject")
Y <- data.frame(V1=562, V2 = "Y")
features <- rbind(sub, features,Y)
feat <- transpose(features)
feat <- feat[2,]
names(Mdata) <- make.names(feat[1,])

# 7.  Extracting only mean and standard deviation for each measurement in Mdata 
# (merged data set). First, extracting relevant columns separately and putting
# it back together into Mdata

columnh <- names(Mdata)
Mdatastd <- Mdata[,which(grepl("*std()", columnh))]
Mdatamean <- Mdata[,which(grepl("*mean()", columnh) & !grepl("*meanFreq()",columnh))]

Mdata <- cbind(Subject = Mdata$Subject, Mdatamean, Mdatastd, Y = Mdata$Y)



# 8. Adding activity names in place of class labels for Y
activity <- read.table("./activity_labels.txt",header = FALSE)
names(activity) <- make.names(c("Y","Activity"))
Mdata <- join(Mdata, activity, by = "Y")
Mdata <- select(Mdata, -Y)

# 9. Removing extraneous data tables from workspace to contain only required messy dataset
# that needs to be tidied

rm("xtrain")
rm("xtest")
rm("subtrain")
rm("subtest")
rm("sub")
rm("Y")
rm("ytest")
rm("ytrain")
rm("mrgdatasub")
rm("mrgdatax")
rm("mrgdatay")
rm("feat")
rm("features")
rm("columnh")
rm("Mdatamean")
rm("Mdatastd")
rm("activity")

# 10. Renaming feature labels wrt naming conventions (all lower case, descriptive,
# not duplicated, no underscores,dots etc)
names(Mdata) <- tolower(names(Mdata))
names(Mdata) <- gsub(".","", names(Mdata),fixed = TRUE)
names(Mdata) <- gsub("tb","timeb", names(Mdata), fixed = TRUE)
names(Mdata) <- gsub("tg","timeg", names(Mdata),fixed = TRUE)
names(Mdata) <- gsub("fb","frequencyb", names(Mdata), fixed = TRUE)
names(Mdata) <- gsub("fg","frequencyg", names(Mdata),fixed = TRUE)
names(Mdata) <- gsub("acc","accelerometer", names(Mdata),fixed = TRUE)
names(Mdata) <- gsub("gyro","gyroscope", names(Mdata),fixed = TRUE)
names(Mdata) <- gsub("mag","magnitude", names(Mdata),fixed = TRUE)
names(Mdata) <- gsub("mean","average", names(Mdata),fixed = TRUE)
names(Mdata) <- gsub("std","standarddeviation", names(Mdata),fixed = TRUE)

# 11. Creating a second data set from Step 10 above to compute average of each
# activity and each subject. First, we check to ensure no missing data.

checkmissing <- colSums(is.na(Mdata))
if (sum(checkmissing)!=0) {print("Caution: Data has missing values - Clean data before analysing")}
print("Data has no missing values. Proceeding with analysis")

    
summarydata <- Mdata %>%
    group_by(activity,subject) %>%
summarize_all(mean)

#12 Writing new summarized data set back to the wd

write.table(summarydata, "./submission_data.txt", row.name = FALSE)

