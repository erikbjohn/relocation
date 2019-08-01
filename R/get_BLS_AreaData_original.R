## script to scrape data from the following link format:
##  https://www.bls.gov/oes/special.requests/oesm03ma.zip
##  "oesm" + years + "ma.zip"
## for each (year):  download corresponding link
library(stringr)
library(readr)
library(purrr)
library(readxl) # read_excel()
library(dplyr)
library(data.table)
library(filesstrings) # file.move()
##_________________________________________________________________________

years <- 3:18
yrs_pad <- str_pad(years, 2, side=c("left"), pad = "0")
yrs_pad
  # yrs_Full <- paste0("20", yrs_pad)

link_by_year <- paste0("https://www.bls.gov/oes/special.requests/oesm", yrs_pad, "ma.zip")
##_________________________________________________________________________

setwd("/Users/Jethro/GitHub/relocation/BLS_area_data")
# getwd()

for (URL in link_by_year)  {
  download.file(url = URL, destfile = basename(URL))
  unzip(basename(URL))
}
##_________________________________________________________________________
# in 2014, BLS switched to xlsX files, and began saving them in folders within the zip files for each year posted online
# MOVE the xlsX files from the 2014-2018 subdirectories into your working directory:
XLSX_files <- list.files(pattern = "xlsx", full.names = FALSE, recursive = TRUE) # recursively accesses all 5 subdirectories
file.move(XLSX_files, "/Users/Jethro/GitHub/relocation/BLS_area_data")

# combine the two vectors for XLS and xlsX data file names into a single vector
XLSX_files <- list.files(pattern = "xlsx", full.names = FALSE, recursive = FALSE) # ignores the 8 redundant description files
XLS_files <- list.files(pattern = "xls$", recursive = TRUE)
#  print(XLSX_files)

files <- c(XLS_files, XLSX_files)
#  print(files)
ignore <- c("file_descriptions.xls", "field_descriptions.xls", "file_descriptions.xlsx", "field_descriptions.xlsx")
files <- files[!files %in% ignore]   # overwrites the list of all files to now exclude the four descriptions files
  print(files)

##_________________________________________________________________________
## NEXT STEP:  merge every table from all 16 years into one big data.table
##_________________________________________________________________________
# before using map() and rbindlist(), FIRST:
# WRITE A FUNCTION called "importByYear()" that:
  # takes the names from "files" vector as an input with "read_excel()"
  # uses "str_extract()" to get the year from each file name
  ### checks if all of the column names are the same
  # converts the tibbles into data.tables
##_________________________________________________________________________
  
extract_file_Years <-  str_extract(files, "20..")
extract_file_Years
## NOTE that 3 files {MSA_dl_1.xls, MSA_dl_2.xls, MSA_dl_3.xls} don't list the year
# 2009 was the only year missing from the entire printed list of MSA file names
# deleting them all and running just "unzip("oesm09ma.zip")" confirmed that these 3 are from 2009
## ALSO NOTE that the *2009 BOS and aMSA file names actually both include the year already*

file_Years_no_NA <- extract_file_Years
file_Years_no_NA[is.na(file_Years_no_NA)] <- 2009
# file_Years_no_NA
##_________________________________________________________________________

BLSdata <- map(files, read_excel)

names(BLSdata) <- file_Years_no_NA
# attributes(BLSdata)

##_________________________________________________________________________

Data_Merged <- rbindlist(BLSdata, fill = TRUE, idcol = "YEAR")   #"idcol" adds a column showing which list item each row came from

##_________________________________________________________________________
######_________________________________________________________________________
# BLSdata[1]    # displays tibble for the first file from BLSdata; print() is called implicitly, even for lists
#   BLSdata[[1]][["Year"]] <- 2008      # test: for each row in BLSdata[1], manually fills new column with the year