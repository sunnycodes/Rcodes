#!/usr/bin/env Rscript

#########################################################################################
#### Author: Sunny Piya                                                              ####
#### Purpose: Import multiple csv files containing survey (general recruitment data) ####
#### and extract the demo data into a single csv file for final upload to TA         ####
#########################################################################################

#take arguments from the command line.
#first argument is the location of the R script
#second argument is the location of the folder containing csv files (survey output)
args = commandArgs(trailingOnly = TRUE)
first_input<-args[1]

if (length(args)!=1) {
  stop(Sys.getenv("Please make sure to inclde 'Rscript <Path to the R script location> <Path to the directory location with survey files>", call.=FALSE))
} 

#load required packages if they are not installed on your machine
if (!require("sqldf")) {
  install.packages("sqldf", repos="http://cran.rstudio.com/") 
  library("sqldf")
}

#set working directory
setwd(first_input)
 
#function to remove the first row in each data frame within the master dataframe list
remove_row1 <- function(df){
  df[-1,]
}

#final all matching files with .csv extension in the working directory
file_list<-list.files(pattern="*.csv")

#import all survey .csv files from the directory into R, remove first row, and assign all dataframe to a list
dflistnew <- list()
for (i in 1:length(file_list)){
  dflistnew[[length(dflistnew)+1]] <- assign(file_list[i], remove_row1(read.csv(file_list[i])))
}

#select only useful fields from the raw .csv files 
dflisttrim <- list()
for (j in 1:length(dflistnew)){
             dflisttrim[[j]] <- data.frame(dflistnew[[j]]$email,
                                                   dflistnew[[j]]$RegR,#......
                                                  stringsAsFactors = FALSE)
    }

#bind all rows for trimmed dataframes to create a single dataframe
dflisttrim_rbind<-do.call("rbind", dflisttrim)
         
#Replace column names of the dataframe with new column names based on the Target Audience requirements
colnames(dflisttrim_rbind) <- c("Email", #.....
                          )

#Modify colums as desired for the final output data frame
#only select records where the CompletionStatus = 'Complete'
dffinal<-sqldf('select 
          
          from dflisttrim_rbind
          where CompletionStatus="Complete" ') #select the desired columns for the outfule file

#output dataframe to a csv file
write.csv(dffinal, file = "~/Desktop/final_output.csv", row.names=FALSE)


