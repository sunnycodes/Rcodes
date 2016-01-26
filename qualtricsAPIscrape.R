#Qualtrics API to get results in JSON format. 

#getSurveys
data1 <-
  fromJSON(
    "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php
    ?Request=getSurveys
    &User=s.piya@gene2drug.com
    &Token=JhxaZWjl2v1pUWAuVpTbB4pUFa381EzMLBUybj0K
    &Format=JSON
    &Version=2.0"
  )


#getRecipient
data2 <-
  fromJSON(
    "https://survey.qualtrics.com/WRAPI/ControlPanel/api.php
    ?Request=getRecipient
    & User=s.piya@gene2drug.com
    & Token=JhxaZWjl2v1pUWAuVpTbB4pUFa381EzMLBUybj0K
    & Format=JSON
    & Version=2.0
    & LibraryID=
    & RecipientID="
  )

reza <- fromJSON(
  "https://co1.qualtrics.com/WRAPI/Contacts/api.php
  ?Request=getContactByInfoFields
  &User=bioinfo_api_user
  &Token=ZmeRs84kfKSaqVAhFfBFQBhubK5l5OWMKJncpBAB&Format=JSON
  &Version=2.0
  &History=1
  &Email=rizadpan%40tulane.edu"
)

reza<-fromJSON("https://co1.qualtrics.com/WRAPI/Contacts/api.php
               ?Request=getContactByInfoFields&User=bioinfo_api_user&Token=ZmeRs84kfKSaqVAhFfBFQBhubK5l5OWMKJncpBAB
               &Format=JSON&Version=2.0&History=1&Email=rizadpan%40tulane.edu")


sqldf('
select "Temp_project_flag9", count(*) from all_ta_jan group by 1
UNION ALL
select "temp_project_flag9.1", count(*) from all_ta_jan group by 1
')