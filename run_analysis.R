download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "dataset.zip")
unzip("dataset.zip")

setwd("UCI HAR Dataset")


subject_train <- read.table("train/subject_train.txt")
xtrain <- read.table("train/X_train.txt")
ytrain <- read.table("train/y_train.txt")


subject_test <- read.table("test/subject_test.txt")
xtest <- read.table("test/X_test.txt")
ytest <- read.table("test/y_test.txt")

x <- rbind(xtrain, xtest)
y <- rbind(ytrain, ytest)
names(y) <- "activityid"

subjects <- rbind(subject_train, subject_test)
names(subjects) <- "subject"

#
# Construct the headers for the data set
# 

# Read the features and convert to lower case.
# Reading the file you get the column index in the first
# column (V1) and the name of the feature in the second (V2)
#features <- tolower(read.table("features.txt")[,2])
features <- read.table("features.txt")[,2]

names(x) <- features

x <- x[,grep("mean\\(\\)|std\\(\\)", features)]  # Only keep the mean and standard deviation features
x <- cbind(subjects, x, y)          

activities <- read.table("activity_labels.txt")
names(activities) <- c("activityid", "activity")

# Merge and remove the activity id, since we have the activity text
thedata <- subset(merge(x,activities), select = -activityid)

#
# Calculate the mean value of each variable over activity and subject.
# This is done by melting the dataset and then apply the mean function
# using dcast
library(reshape2)
v <- names(thedata)
idlist <- c("activity", "subject")
valuelist <- v[2:(length(v)-1)]
mdata <- melt(thedata, id=idlist, measure.vars=valuelist)
df <- dcast(mdata, activity + subject ~ variable, mean)

varnames <- names(df)
varnames[3:68] <- paste(trimws(varnames[3:68]),"_avg", sep="")
names(df) <- varnames

# Save the tidy dataset.
# Explicitly setting field and decimal separator to handle
# different locales.
# Since the headers do not have the syntax for variables, they
# have to be read with check.names=FALSE, e.g.
#   read.csv("UCI HAR Dataset averages.txt", sep=";", dec=".", header=TRUE, check.names = FALSE)
setwd("..")
write.table(df, "UCI HAR Dataset averages.txt",  row.names = FALSE, sep=";", dec=".")

