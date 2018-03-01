##Create directory if necessary
if(!file.exists("./data")){dir.create("./data")}

##Clean up the workspace
rm(list = ls())

##library useful packages
library(data.table) # package for data tables
library(dplyr) # enhanced data table processing features

##Set up download to a temp file, unzip required files
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp <- tempfile()
download.file(fileUrl,temp)

unzip(temp, list = TRUE)

YTest <- read.table(unzip(temp, "UCI HAR Dataset/test/y_test.txt"))
XTest <- read.table(unzip(temp, "UCI HAR Dataset/test/X_test.txt"))
SubjectTest <- read.table(unzip(temp, "UCI HAR Dataset/test/subject_test.txt"))
YTrain <- read.table(unzip(temp, "UCI HAR Dataset/train/y_train.txt"))
XTrain <- read.table(unzip(temp, "UCI HAR Dataset/train/X_train.txt"))
SubjectTrain <- read.table(unzip(temp, "UCI HAR Dataset/train/subject_train.txt"))
Features <- read.table(unzip(temp, "UCI HAR Dataset/features.txt"))
ActivityLabels <- read.table(unzip(temp,"UCI HAR Dataset/activity_labels.txt"))
unlink(temp) # very important to remove this

##Step 1: Merge training and test sets

data <- rbind(XTest, XTrain)
activity <- rbind(YTest, YTrain)
subject <- rbind(SubjectTest, SubjectTrain)

##Extract meand and standard deviation measurements
meanIndex <- grep("mean\\(\\)", Features$V2)
stdIndex <- grep("std\\(\\)", Features$V2)
data <- data[, c(meanIndex, stdIndex)]

## Step 3: Use descriptive activity names
activity$V1 <- factor(activity$V1, labels = ActivityLabels$V2)


### Step 4: Label column names
tidyData <- cbind(subject, activity, data)

meanLabel <- gsub("__", "", gsub('[^A-Za-z]', '_', Features$V2[meanIdx]))
stdLabel <- gsub("__", "", gsub('[^A-Za-z]', '_', Features$V2[stdIdx]))

names(tidyData) <- c("Subject", "Activity", as.character(meanLabel), as.character(stdLabel))

###Change measurement names to be intelligible
names(tidyData)<- gsub("Acc", "Accelerator", names(tidyData))
names(tidyData) <- gsub("Mag", "Magnitude", names(tidyData))
names(tidyData) <- gsub("Gyro", "Gyroscope", names(tidyData))
names(tidyData) <- gsub("^t", "time", names(tidyData))
names(tidyData) <- gsub("^f", "frequency", names(tidyData))


##Step 5: Create a second tidy data set
output <- group_by(tidyData, Subject, Activity) %>% summarize_all(funs(mean))
write.table(output, file="output.txt", row.names = FALSE)
