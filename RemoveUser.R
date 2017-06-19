#!/usr/bin/env Rscript

#---------------------------------------------
# Download and Load required R libraries
#---------------------------------------------

if (!require("jsonlite")) {
  install.packages("jsonlite", repos="http://cran.rstudio.com/") 
  library("jsonlite")
}

if (!require("httr")) {
  install.packages("httr", repos="http://cran.rstudio.com/") 
  library("httr")
}

#---------------------------------------------
# Initialize counters and auth variables
#---------------------------------------------

User="username"
Token="token"
#i<-1; j<-1; k<-1; l<-1; m<-1; n<-1; a<-1; b<-1; c<-1

#------------------------------------------------------------------------------------
# Create a list of all blacklisted email domains
# This step will need to connect MySQL DB on cPanel to get
# the list present in social engine
#------------------------------------------------------------------------------------
#blacklist<-c(=>select black_list from engine4_advmemmanagement_blackwhitelists;)
black_list_raw<-read.csv(file='<input file location>', header=FALSE)
blacklist<-as.vector(black_list_raw[,"V1"])

#------------------------------------------------------------------------------------
# Create empty lists/df to hold blacklisted emails and CID
#------------------------------------------------------------------------------------
json_list <- list()
json_black_list_cid = c()
json_black_list_emails = c()

#------------------------------------------------------------------------------------
# create a dataframe to hold all CID/email pairs
#------------------------------------------------------------------------------------
json_df <-
  data.frame(
    "email_add" = character(),
    "cid" = character(),
    stringsAsFactors = FALSE
  )

#------------------------------------------------------------------------------------
# getDirectoryContacts API call until all accounts are downloaded
#------------------------------------------------------------------------------------
json_list[[i]] <- fromJSON(
  paste(
    "https://survey.qualtrics.com/WRAPI/Contacts/api.php",
    "?Request=getDirectoryContacts",
    "&User=",
    User,
    "&Token=",
    Token,
    "&Format=JSON&Version=2.0",
    "&Subscribers=subscribed",
    "&EmbeddedData=0",
    "&ModifiedOnOrAfter=",Sys.Date(),
    sep = ""
  )
)

#------------------------------------------------------------------------------------
# Check if there are more than 5000 accounts that
# were modified within the specified period
#------------------------------------------------------------------------------------
if(length(json_list[[i]]$Result) == 5000) {
  while (length(json_list[[i]]$Result) == 5000) {
    json_list[[i + 1]] <- fromJSON(
      paste(
        "https://survey.qualtrics.com/WRAPI/Contacts/api.php",
        "?Request=getDirectoryContacts",
        "&User=",
        User,
        "&Token=",
        Token,
        "&Format=JSON&Version=2.0",
        "&Subscribers=subscribed",
        "&EmbeddedData=0",
        "&ModifiedOnOrAfter=",Sys.Date(),
        "&StartContactID=",
        names(json_list[[i]]$Result[5000]),
        sep = ""
      )
    )
Sys.sleep(10)
i <- i + 1
  }
}

#------------------------------------------------------------------------------------
# Parse all elements of the json_list to find Emails 
# and CID and add to the master dataframe
#------------------------------------------------------------------------------------
for (a in 1:length(json_list)) {
  for (b in 1:length(json_list[[a]]$Result)) {
    json_df[c, "email_add"] <- json_list[[a]]$Result[[b]]$Email
    json_df[c, "cid"]       <- json_list[[a]]$Result[[b]]$ContactId
    c <- c + 1
    b <- b + 1
  }
  a <- a + 1
}

#------------------------------------------------------------------------------------
# Find if any of the new email domains are in the blacklist
#------------------------------------------------------------------------------------
for (k in 1:nrow(json_df)) {
  for (l in 1:length(blacklist)) {
    if (grepl(blacklist[l], json_df[k, "email_add"]) == TRUE) {
      json_black_list_cid[m] <- json_df[k, "cid"]
      json_black_list_emails[m] <- json_df[k, "email_add"]
      print(paste(json_black_list_emails[m], '--mactches pattern--', blacklist[l]))
      
      m <- m + 1
    }
    l < l + 1
  }
  k <- k + 1
}

#------------------------------------------------------------------------------------
# Store new blacklisted emails in a csv file
#------------------------------------------------------------------------------------
write.csv (json_black_list_emails, file=paste('<output file location>',Sys.Date(),'.csv'))

#------------------------------------------------------------------------------------
# updateContact API call to unsubscribe TA accounts that are in the blacklist
# Code is (0=subscribed, 1=unsubscribed)
#------------------------------------------------------------------------------------
for (n in 1:length(json_black_list_cid)) {
    POST(
      paste(
        "https://survey.qualtrics.com/WRAPI/Contacts/api.php"
        ,"?Request=updateContact"
        ,"&User=",User
        ,"&Token=",Token
        ,"&Format=JSON"
        ,"&Version=2.0"
        ,"&ContactID=",json_black_list_cid[n]
        ,"&Unsubscribed=1",
        sep = ""
      )
    )
   Sys.sleep(5)
   print(paste('Opting out: ',json_black_list_cid[n],'...',json_black_list_emails[n]))
  n <- n + 1
 }
