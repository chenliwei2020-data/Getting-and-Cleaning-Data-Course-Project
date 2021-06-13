##getting and cleaning data week 4 assignment

#download the data
if(!file.exists("./data")){dir.create("./data")} 
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileUrl,destfile="./data/dataset.zip") 

#unzip the dataset
unzip(zipfile="./data/dataset.zip", exdir = "./data")
 

library(dplyr)
## 1.	Merges the training and the test sets to create one data set.
## 1.1 read files

#### training data

x_train<-read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("./data/UCI HAR Dataset/train/Y_train.txt")
subject_train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt")


###  testing datasets
x_test<-read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("./data/UCI HAR Dataset/test/Y_test.txt")
subject_test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt")


### feature vector
features<-read.table("./data/UCI HAR Dataset/features.txt")


###1.2 merge the training and test sets to create one data set

##concatenate the data tables by rows
allx<-rbind(x_train,x_test)
ally<-rbind(y_train,y_test)
allsubject<-rbind(subject_train,subject_test)

str(allx)
str(ally)
str(allsubject)

##set names to viables

names(allsubject)<-c("subject")
names(ally)<-c("activity")
names(allx)<-features$V2

###1.3 merge column to get the data frame
datacombine<-cbind(allx,allsubject,ally)
str(datacombine)
names(datacombine)


###2. Extracts only the measurements on the mean and standard deviation for each measurement. 
##2.1 reading column names
colname<-names(datacombine)

##2.2subset the data frame datacombine by selected names of featuress
subdata<-grep("mean|std",colname)
subdatanames<-features$V2[subdata]
subdatanames<-c(subdatanames,"subject","activity")
subsetdata<-subset(datacombine,select=subdatanames)

str(subsetdata)


##3. Uses descriptive activity names to name the activities in the data set

### read activity labels

activitylabels<-read.table("./data/UCI HAR Dataset/activity_labels.txt")
colnames(activitylabels)<-c("activity","activitytype")

##merge datacombine and activitylabels
datacombine.withactivitynames<-merge(datacombine,activitylabels,by="activity")

## check data

str(datacombine.withactivitynames)
colnames(datacombine.withactivitynames)
head(datacombine.withactivitynames$activitytype,6)

##4.Appropriately labels the data set with descriptive variable names. 

### use gsub editing text variables 
names(datacombine.withactivitynames)<-gsub("^t", "time", names(datacombine.withactivitynames))
names(datacombine.withactivitynames)<-gsub("^f", "frequency", names(datacombine.withactivitynames))
names(datacombine.withactivitynames)<-gsub("Acc", "Accelerometer", names(datacombine.withactivitynames))
names(datacombine.withactivitynames)<-gsub("Gyro", "Gyroscope", names(datacombine.withactivitynames))
names(datacombine.withactivitynames)<-gsub("Mag", "Magnitude", names(datacombine.withactivitynames))
names(datacombine.withactivitynames)<-gsub("BodyBody", "Body", names(datacombine.withactivitynames))

## check

names(datacombine.withactivitynames)

install.packages("plyr")
library(plyr)

#### 5. From the data set in step 4, creates a second, independent tidy data set with the average 
### of each variable for each activity and each subject

#make a second tidy dataset
tidydata2<- aggregate(.~subject+activitytype,datacombine.withactivitynames,mean)

tidydata2<-tidydata2[order(tidydata2$subject,tidydata2$activitytype),]
str(tidydata2)

###write table

write.table(tidydata2, "./data//UCI HAR Dataset/tidydata2.txt", row.names=FALSE)



