#install important libraries
library(ggolot2)

#convert start and end date fields to Date datatype
dflisttrim_rbind$StartDate<-as.Date(dflisttrim_rbind$StartDate, format="%Y-%m-%d")
dflisttrim_rbind$EndDate<-as.Date(dflisttrim_rbind$EndDate, format="%Y-%m-%d")

#plot project specific charts
ggplot(perproject_analysis_percents, 
       aes(x=month,y=sab_complete_rate, group=1))+
  geom_line(colour="Red")+
  coord_cartesian(ylim=c(0,100))+
  theme_grey()+
  geom_point(color="Blue")+
  ggtitle("SAB Member Participation")+ylab("% of SAB Participation")+xlab("Month")

#plot all project charts  
ggplot(dflisttrim_rbind_complete, aes(x=EndDate, fill=SurveyCode)) +  
  geom_density(alpha=0.3) + 
  scale_x_date(labels = date_format("%m/%d"), breaks = date_breaks("days"), limits = as.Date(c('2016-05-18','2016-05-22'))) 
