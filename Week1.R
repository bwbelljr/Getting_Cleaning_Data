# Downloading Files
# Do this in R, so it can be included in Data Preparation Script

getwd() # current working directory

# setwd() sets the current directory to something of your choice

# Be Aware of Relative versus Absolute Paths
# In Windows, use backslashes instead of forward slashes

# Checking for and creating directories
# file.exists("directoryName") will check to see if the directory exists

file.exists("C:/MOOCs/Coursera/Getting_cleaning_Data/Week1") # returns TRUE

# dir.create("directoryName") will create a directory if it doesn't exist

dir.create("C:/MOOCs/Coursera/Getting_cleaning_Data/Week1/test_dir") # create test_dir

# Here is an example checking for a "data" directory and creating it if it doesn't exist
# if (!file.exists("data")){
#     dir.create("data")
# }
#

# Getting data from the internet - download.file()
# Downloads a file from the internet; helps with reproducibiity
# Important parameters are url (location on web), destfile (destination file), method
# Useful for csv, tab delimited, etc. Agnostic to file type

fileURL <- "http://data.baltimorecity.gov/api/views/k78j-azhn/rows.csv?accessType=DOWNLOAD"
download.file(fileURL, destfile="./towing.csv")
list.files("./")

# Note above, this is slightly different than code from slides
# My code above is inspired by: http://stackoverflow.com/questions/17300582/download-file-in-r-has-non-zero-exit-status
# I removed method="curl". In Windows, it by default works... On MAC, set to curl.
# Also, the original URL was https... But I changed it to http

# Take track of time - sometimes datasets change depending on the time...
dateDownloaded <- date()
dateDownloaded

# Reading Local Files (4:55)
# This is also covered in R Programming Course

# read.table() is main function for reading data into R
# Flexible and robust, but requires more parameters
# Don't use if working with big data
# Important parameters - file, header, sep, row.names, nrows
# Related: read.csv(), read.csv2()

fileUrl <- "http://data.baltimorecity.gov/api/views/dz54-2aru/rows.csv?accessType=DOWNLOAD"
download.file(fileUrl, destfile="./cameras.csv")
dateDownloaded <- date()

cameraData <- read.table("./cameras.csv")
head(cameraData)

cameraData <- read.table("./cameras.csv", sep=",", header=TRUE)
head(cameraData)

cameraData <- read.csv("./cameras.csv") # best if *.csv file
head(cameraData)

# Some more important parameters
# quote - tell R whether there are any quoted values
# na.strings - set characters that represents missing value
# nrows - how many rows to read of the file
# skip - number of lines to skip before starting to read

# Reading Excel Files
# Now, let's download the Excel version of this spreadsheet

fileUrl <- "http://data.baltimorecity.gov/api/views/dz54-2aru/rows.xlsx?accessType=DOWNLOAD"
download.file(fileUrl, destfile="./cameras.xlsx", mode='wb')
# Note: for xlsx package, must include mode='wb'
# Explanation is here: http://stackoverflow.com/questions/28325744/r-xlsx-package-error
dateDownloaded <- date()

install.packages("xlsx")
library("xlsx")
cameraData <- read.xlsx("./cameras.xlsx", sheetIndex=1, header=TRUE)
head(cameraData)

# Reading specific rows and columns
colIndex <- 2:3
rowIndex <- 1:4
cameraDataSubset <- read.xlsx("./cameras.xlsx", sheetIndex=1, colIndex=colIndex, rowIndex=rowIndex)
cameraDataSubset

# Reading XML
# XML - Extensible Markup Language
# XML is the bsis for most web scraping
# Components - Markup (labels that give the text structure) and Content (actual text)
# Tags correspond to general labels: start tags <section> and end tags </section>
# Empty tags <line-break />
# Elements are specific examples of tags: <Greeting> Hello, world </Greeting>
# Attributes are components of the label:
# <img src="jeff.jpg" alt="instructor"/>

# Read the (XML) file into R
install.packages("XML")
library("XML")

fileUrl <- "http://www.w3schools.com/xml/simple.xml"
doc <- xmlTreeParse(fileUrl, useInternal=TRUE) # Loads doc into R memory
rootNode <- xmlRoot(doc)
xmlName(rootNode) # rootNode - wrapper element for entire document
names(rootNode)

# Directly access parts of the XML document
rootNode[[1]] # returns first food element

rootNode[[1]][[1]]

xmlSApply(rootNode, xmlValue) # loops through rootNode and gets xmlValue

# XPath
# /node top level node of each element
# //node node at any level
# node[@attr-name] Node with an attribute name
# node[@attr-name='bob'] Node with attribute name attr-name='bob'

xpathSApply(rootNode, "//name", xmlValue) # returns all elements with "name" tag

xpathSApply(rootNode, "//price", xmlValue) #

# Extract Content by Attributes
fileUrl <- "http://espn.go.com/nfl/team/_/name/bal/baltimore-ravens"
doc <- htmlTreeParse(fileUrl, useInternal=TRUE)
scores <- xpathSApply(doc, "//li[@class='score']", xmlValue)
teams  <- xpathSApply(doc, "//li[@class='team-name']", xmlValue)
scores # returns nothing... I believe the XML tags have changed...
teams

# They provide XML tutorials from website...

# Reading JSON
# Javascript Object Notation - common data format for API's
# I think BASIS data is JSON.

# Reading JSON data jsonlite package
install.packages("jsonlite")
install.packages('curl')

library(jsonlite)
jsonData <- fromJSON("https://api.github.com/users/jtleek/repos")
names(jsonData)

names(jsonData$owner)

jsonData$owner$login

# Writing data frames to JSON
myjson <- toJSON(iris, pretty=TRUE)
cat(myjson)

# Convert back to JSON
iris2 <- fromJSON(myjson)
head(iris2)
# This might be the best way to work with BASIS JSON data...

# there are online tutorials for working with this...

# The data.table Package
# All functions that accept data.frame can work on data.table
# Written in C so it is much faster

# Create data tables just like data frames
library(data.table)
DF=data.frame(x=rnorm(9), y=rep(c("a","b","c"), each=3), z=rnorm(9))
head(DF, 3)

DT = data.table(x=rnorm(9), y=rep(c("a","b","c"), each=3), z=rnorm(9))
head(DT,3)

# See all the data tables in memory
tables()

# Subsetting Rows
DT[2,]
DT[DT$y=="a",]

DT[c(2,3)]

# Subsetting Columns - not the same as a data frame... - don't yet understand

# Calculating Values for Variables with Expressions
DT[, list(mean(x), sum(z))]

# Adding new columns
DT[, w:=z^2]
DT

DT2 <- DT
DT[, y:=2]
head(DT, n=3)
head(DT2, n=3)

# Need to explicitly make a copy of data table instead of just assigning it.

# Multiple Operations
DT[,m:= {tmp <- (x+z); log2(tmp+5)}]

# plyr like operations
DT[,a:=x>0]
DT
# plyr is extremely useful for my migraine dataset...

DT[,b:= mean(x+w), by=a]
DT

# Special Variables
# .N is an integer, length 1, containing the number of times a group appears
set.seed(123);
DT <- data.table(x=sample(letters[1:3], 1E5, TRUE))
DT[, .N, by=x]

# Keys
DT <- data.table(x=rep(c("a","b","c"), each=100), y=rnorm(300))
setkey(DT, x)
DT['a']

#Joins
DT1 <- data.table(x=c('a', 'a', 'b', 'dt1'), y=1:4)
DT2 <- data.table(x=c('a', 'b', 'dt2'), z=5:7)
setkey(DT1, x); setkey(DT2, x)
merge(DT1, DT2)

# data.table is a lot quicker in reading...

# Quiz 1

# Question 1

# Download the 2006 microdata survey about housing for the state of Idaho
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
download.file(fileURL, destfile="./ACS.csv")
list.files("./")

# Load data into Dataframe
acsData <- read.csv("ACS.csv")

# Look at names and data
names(acsData)

# How many properties are worth $1,000,000 or more?
# Which variable represents the property value?
# I think it is VAL
summary(acsData$VAL)
table(acsData$VAL)
# Since 1,000,000 or more properties are with code = 24, the answer is 53...

# Question 2
# Use the data you loaded from Question 1. Consider the variable FES in the code 
# book. Which of the "tidy data" principles does this variable violate? 

# Question 3
# Download the Excel spreadsheet on Natural Gas Aquisition Program here:
  
#  https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx"
download.file(fileUrl, destfile="./NGAP.xlsx", mode='wb')

# Read rows 18-23 and columns 7-15 into R and assign the result to a variable called
# dat

library(xlsx)
colIndex <- 7:15
rowIndex <- 18:23
dat <- read.xlsx("NGAP.xlsx", sheetIndex=1, header=TRUE, colIndex=colIndex, rowIndex=rowIndex)

# What is the value of:
sum(dat$Zip*dat$Ext,na.rm=T) 

# Question 4
# Read the XML data on Baltimore restaurants from here:
# https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml 

library("XML")

fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
doc <- xmlTreeParse(fileUrl, useInternal=TRUE) # Loads doc into R memory
rootNode <- xmlRoot(doc)
xmlName(rootNode) # rootNode - wrapper element for entire document
names(rootNode)

# How many restaurants have zipcode 21231? 
xmlSApply(rootNode, xmlValue)

xpathSApply(rootNode, "//zipcode", xmlValue) # returns all elements with "zipcode" tag
isZip <- xpathSApply(rootNode, "//zipcode", xmlValue) == 21231
table(isZip)
# Answer is 127

# Question 5
# The American Community Survey distributes downloadable data about United States 
# communities. Download the 2006 microdata survey about housing for the state of 
# Idaho using download.file() from here:
  
#  https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
download.file(fileURL, destfile="./ACS_housing.csv")
list.files("./")

# using the fread() command load the data into an R object
DT <- fread("ACS_housing.csv")

summary(DT)

# proc.time for calculating elapsed time for multiple statements

ptm <- proc.time()
rowMeans(DT)[DT$SEX==1]; rowMeans(DT)[DT$SEX==2]
proc.time() - ptm

ptm <- proc.time()
mean(DT[DT$SEX==1,]$pwgtp15); mean(DT[DT$SEX==2,]$pwgtp15)
proc.time() - ptm

# system.time is best for single statements
system.time(sapply(split(DT$pwgtp15,DT$SEX),mean))
system.time(DT[,mean(pwgtp15),by=SEX])
system.time(tapply(DT$pwgtp15,DT$SEX,mean))
system.time(mean(DT$pwgtp15,by=DT$SEX))

# My answer for Number 5 was wrong. Need to figure out what went wrong...



