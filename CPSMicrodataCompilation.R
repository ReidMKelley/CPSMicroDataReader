rm(list = ls())

cat("\014")
library("tictoc")
library("xlsx")
library("tidyverse")
setwd("C:/Users/Kelley_R/Desktop/CPSMicrodataReader")
source("CPSDataReaderFunctions.R")



# These four variables need to be filled in with appropriate values for the starting and ending months before running the script.
# The earliest available month is September 1995. The latest available month is currently August 2020. (As of September 14, 2020.)
StartMonth = 1
StartYear = 1999
EndMonth = 12
EndYear = 2000

# The archive location is a directory file that contains the previously downloaded copies of the Microdata. This needs to be filled in before running the script.
# These files are downloaded as zipped files from the Census website. Having a fixed archive allows for easy additions as months pass without requiring extra downloads.

ArchiveLocation = "C:/Users/Kelley_R/Desktop/CPS Microdata Storage/"

DataSourceFileStrings = read_tsv("DownloadedFilePaths.txt", col_names = c("FileString"))

# This section confirms that the Ending dates are valid given the starting dates. If it fails, an error is returned to show ther user that there is a problem.
# The first If statement ensures that the EndYear value is at least as large as the StartYear Value.
if (StartYear <= EndYear) {
  # If the EndYear value is at least as large as the StartYear, we then have to compare the EndMonth to the StartMonth. The only potential issue is 
  # EndYear are the same and the StartMonth is larger than the EndMonth. If true we have a problem,
  # and so this then stops the script flow and sends an error to the screen.
  if ((StartYear == EndYear)&&(StartMonth > EndMonth)) {
    stop("\n\nEndMonth value is less than StartMonth Value in first year. Correct before proceeding.\n\n")
  }
  # The other potential problem is if the EndYear value is less than the StartYear value. The else in the original If-else statement handles this case.
  # Similiar to the above it stops the script flow and sends an error to the screen.
} else {
  stop("\n\nEndYear value is less than StartYear value. Correct before proceeding.\n\n")
}

# These vairables set up the numbering system to easily order all the files from September 1995 onward. The number strings start with 001 for September 1995 and increase
# by 1 for each month. The IDMax gives the largest value for the selected set. Currently the largest possible IDMax value is 299; this will change as months pass.

# The points variables are for putting together the sequence of numbers. The initial point is set at September 1995. The StartPoint and EndPoint values are scaled off this.
InitialPoint = 12*1995 + 9
StartPoint = 12*StartYear + StartMonth - InitialPoint + 1
EndPoint = 12*EndYear + EndMonth - InitialPoint + 1
IDMax = max(100, EndPoint)
# This gives a vector of all the points selected. It allows for choosing a start point later than September 1995. 
# It is inserted into the various name part vectors to select only the ones that match the chosen start and end dates.
IDPoints = StartPoint:EndPoint

# IDNums is the vector of strings for each ID Number - it forces them all to be 3 digit strings in order to make sorting the actual files in Windows Explorer easier.
IDNums = c(str_c("00", 1:9), str_c("0", 10:99), as.character(100:IDMax))
IDNums = IDNums[IDPoints]

# These variables are used to set up the urls and file paths that contain the data files to download. 

# MonthsNum is used to help write up the month-year name combinations for finding the appropriate files. 
MonthsNum = c(9:12, rep(1:12, (EndYear - 1995)))
MonthsNum = MonthsNum[IDPoints]

MonthsName = str_to_lower(month.abb[MonthsNum])

# The Year variable is a vector that gives the corresponding year number for each month since 1995. 
# The if statement existis to ensure that the EndYear = 1995 case is properly handled, as the repeat function will duplicate the 1995s in the vector [1996, 1995].
if(EndYear>1995) {
  Years = c(rep(1995,4), sapply(1996:EndYear, function(x) rep(x, 12)))  
} else {
  Years = rep(1995,4)
}
Years = Years[IDPoints]

# FileDateName sets up the month-year name combinations for each file.
FileDateName = str_c(IDPoints, MonthsName, str_trunc(Years, width = 2, side = "left", ellipsis = ""))


FilesNeeded = DataSourceFileStrings$FileString[which(sapply(seq_along(DataSourceFileStrings$FileString), function(y) any(sapply(seq_along(FileDateName), function(x) str_detect(DataSourceFileStrings$FileString, FileDateName[x]))[y,])), TRUE)]


# 
# DataDictionaries = loadWorkbook("C:/Users/Kelley_R/Desktop/CPSMicrodataReader/DataDictionaryFilesFinalCopy.xlsx")
# X = getSheets(DataDictionaries)





# FileExtraction = sapply(1:Diff, function(x) sapply(1:12, function(y) FileUnziper(FileToUnzip = FileDestinationPath[y,x], ExtractedFileDest = "C:/Users/Kelley_R/Documents/CPSMicrodataStorage")))
# ExtractedFiles = sapply(1:Diff, function(x) str_c("C:/Users/Kelley_R/Documents/CPSMicrodataStorage/", IDVal[,x], FileDateName[,x], "pub.dat"))
# FileRenaming = sapply(1:Diff, function(x) file.rename(from = str_c("C:/Users/Kelley_R/Documents/CPSMicrodataStorage/", FileDateName[,x], "pub.dat"), to = ExtractedFiles[,x]))
# 
# DictionaryMonthConnection = tibble(OrderNumber = as.vector(IDVal), FileDateName = as.vector(FileDateName), FileDateNum = as.vector(FileDateNum), FileLocation = as.vector(ExtractedFiles))
# # DictionaryMonthConnection = tibble(OrderNumber = as.vector(IDVal), FileDateName = as.vector(FileDateName), FileDateNum = as.vector(FileDateNum), FileLocation = as.vector(ExtractedFiles), DataDictionary = as.vector(DictionaryDestPath))

# 
# 
# 
# 
# Test0 = CPSMicrodataReader(FileIn = "C:/Users/Kelley_R/Documents/CPSMicrodataStorage/sep95pub.cps", DataDictionaryIn = DataDictionary)
# 
# 
# 
# # FileInName = FileSourcePaths[1,1]
# # Test1 = CPSMicrodataReader(FileInName, DataDictionary)
# #
# # DataOut = list()
# # 
# # for (j in 1:12) {
# #   FileInVal = ExtractedFiles[j, 1]
# #   DataOut[[j]] = CPSMicrodataReader(FileIn = FileInVal, DataDictionaryIn = DataDictionary)# }
# # names(DataOut) = FileDateName
# 
# 
# ArchiveDirectoryName = str_replace(str_replace(str_trunc(as.character(Sys.time()), width = 16, side = "right", ellipsis = ""), pattern = " ", replacement = "_"), pattern = ":", replacement = "")
# ArchiveExtractedDirectory = str_c("C:/Users/Kelley_R/Documents/CPSMicrodataStorage/Archive/", ArchiveDirectoryName)
# D0 = dir.create(path = ArchiveExtractedDirectory)
# ArchiveZipDirectory = str_c("Z:/Reid/CPSMicrodataReading/MicrodataStorage/Archive/", ArchiveDirectoryName)
# D1 = dir.create(path = ArchiveZipDirectory)
# D01 = sapply(1:Diff, function(x) sapply(1:12, function(y) FileMover(FileToMove =  ExtractedFiles[y, x], DestinationOfFile = ArchiveExtractedDirectory)))
# D11 = sapply(1:Diff, function(x) sapply(1:12, function(y) FileMover(FileToMove =  FileDestinationPath[y, x], DestinationOfFile = ArchiveZipDirectory)))
# D12 = sapply(seq_along(DictionaryUniquePath), function(x) FileMover(FileToMove =  DictionaryUniquePath[x], DestinationOfFile = ArchiveZipDirectory))
# 

cat("\014")
toc()

# .rs.restartR()