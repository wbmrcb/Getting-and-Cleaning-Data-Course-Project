library(data.table)

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileDest <- paste("./data", tail(unlist(strsplit(x = fileURL, "/")), n = 1), sep = "/")

if(!file.exists(fileDest)){
  download.file(fileURL,
                destfile = fileDest,
                quiet = TRUE,
                mode = "wb")
  
  unzip(fileDest)
}

train <- fread("./UCI HAR Dataset/train/X_train.txt")
ltrain <- fread("./UCI HAR Dataset/train/y_train.txt")
test <- fread("./UCI HAR Dataset/test/X_test.txt")
ltest <- fread("./UCI HAR Dataset/test/y_test.txt")

# 1. Combined dataset
data <- rbind(train, test)

# 2. Mean and Standard Deviation colums
fnames <- fread("./UCI HAR Dataset/features.txt")
features <- fnames[V2 %like% "mean" | V2 %like% "std"]
meanNstd <- data[, features$V1, with = FALSE] # dataset with mean and standard deviation

# 3/4. Descriptive names and labled columns
lables <- rbind(ltrain, ltest)
activity_lables <- fread("./UCI HAR Dataset/activity_labels.txt")
colnames(meanNstd) <- features$V2
meanNstd <- cbind(meanNstd,
                  merge(lables, activity_lables,
                        by="V1", sort = FALSE)$V2)
names(meanNstd)[names(meanNstd) == "V2"] <- "activity"

# 5. Creating a tidy data set
tidySet <- meanNstd[, lapply(.SD, mean), by = "activity"]
write.table(tidySet, file = "tidySet.txt", row.name = FALSE)
