#!/usr/bin/env Rscript

#--------------------------------------------------------------------------------------
# Note    : Import multple csv files containing survey data and extract/modify 
#           the demo data into a single mastert file (CSV)        
#--------------------------------------------------------------------------------------

#first argument is the location of the R script
#second argument is the location of the folder containing survey output files
args = commandArgs(trailingOnly = TRUE)
first_input<-args[1]

if (length(args)!=1) {
  stop(Sys.getenv("Please make sure to inclde 'Rscript <Path to the R script location> <Path to the directory location with survey files>!!!", call.=FALSE))
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
             dflisttrim[[j]] <- data.frame(dflistnew[[j]]$email
                                                   ,dflistnew[[j]]$RegR
                                                   ,dflistnew[[j]]$SegR
                                                   ,dflistnew[[j]]$WorkFocus
                                                   ,dflistnew[[j]]$EmpSector
                                                   ,dflistnew[[j]]$EmpSector_TEXT
                                                   ,dflistnew[[j]]$job
                                                   ,dflistnew[[j]]$job_TEXT
                                                   ,dflistnew[[j]]$cjob
                                                   ,dflistnew[[j]]$cjob_TEXT
                                                   ,dflistnew[[j]]$country
                                                   ,dflistnew[[j]]$Salutation
                                                   ,dflistnew[[j]]$Name_1_TEXT
                                                   ,dflistnew[[j]]$Name_2_TEXT
                                                   ,dflistnew[[j]]$degree_1
                                                   ,dflistnew[[j]]$degree_2
                                                   ,dflistnew[[j]]$degree_3
                                                   ,dflistnew[[j]]$NumBeds
                                                   ,dflistnew[[j]]$CompletionStatus
                                                   stringsAsFactors = FALSE)
    }

#bind all rows for trimmed dataframes to create a single dataframe
dflisttrim_rbind<-do.call("rbind", dflisttrim)
         
#Replace column names of the dataframe with new column names based on the Target Audience requirements
colnames(dflisttrim_rbind) <- c("Email"
                          ,"Continent"
                          ,"Segment"
                          ,"Research/Work Focus"
                          ,"Employment Sector"
                          ,"Employment Sector - Other"
                          ,"Job Position"
                          ,"Job Position - Other"
                          ,"Clinical Job Position"
                          ,"Clinical Job Position - Other"
                          ,"Country"
                          ,"Salutation"
                          ,"FirstName"
                          ,"LastName"
                          ,"Degree_1"
                          ,"Degree_2"
                          ,"Degree_3"
                          ,"Number of Beds"
                          ,"CompletionStatus")

#Modify colums as desired for the final output data frame
#only select records where the CompletionStatus = 'Complete'
dffinal<-sqldf('select
                "Email"
               ,"Continent"
               ,"Segment"
               ,"Research/Work Focus"
               ,"Employment Sector"
               ,"Employment Sector - Other"
               ,"Job Position"
               ,"Job Position - Other"
               ,"Clinical Job Position"
               ,"Clinical Job Position - Other"
               ,"Country"
               ,"Salutation"
               ,"FirstName"
               ,"LastName"
               ,"Degree_1"||"/"||"Degree_2"||"/"||"Degree_3" as Degree
               ,"Number of Beds"
          from dflisttrim_rbind
          where CompletionStatus="Complete" ')

#output dataframe to a csv file
write.csv(dffinal, file = "<outpuf file location>", row.names=FALSE)


