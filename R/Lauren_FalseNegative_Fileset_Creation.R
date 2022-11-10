library(ggplot2) 
library(ggpubr)
library(tidyverse)
library(lubridate)
library(dplyr)
library(RColorBrewer)

# Create subsample of files for Lauren

df<-read.csv('/Users/bengottesman/Documents/Work/Gabon/Figures/All_Sites_Figures_Code_Dataframe/Dataframes/df_gunshots_detected.csv')
df$shifted.times <- round_date(as.POSIXct(df$FileTime,tz='GMT'), '30 minutes')+hours(2)
df$shifted.hours <- hour(df$shifted.times)

setwd('/Volumes/Gabon2/Resampled_data/ROG_TBNI_Resampled/')
all.files <-list.files() 
all.files.time.shifted <- round_date(strptime(substr(all.files,10,24),'%Y%m%d_%H%M%S',tz='GMT'),'30 minutes')+hours(2)

# Filter only gunshots captured at night (between 22-2)
night.files <- df[which(df$shifted.hours<=4),]
night.files$Filename <- paste(substr(night.files$Begin.File,1,24),'.wav',sep='')



# Go into the full dataset and find files for the other portion of the nighttime

for(i in 1:length(nighthours)) {
  
  this.file <- night.hours[i,2]
  site.files <- all.files[which(substr(all.files,1,9)==substr(this.file,1,9))]
  site.files.time.shifted <- round_date(strptime(substr(site.files,10,24),'%Y%m%d_%H%M%S',tz='GMT'),'30 minutes')+hours(2)
  #site.files[which(as.Date(substr(site.files,10,17),format='%Y%m%d') == as.Date(night.hours$FileTime)[i])]
  site.files[which(as.Date(site.files.time.shifted) == as.Date(night.hours$FileTime)[i])]

  
  }
as.Date(night.hours$Date)+1



# Get all fullfiles of gunshot recordings

night.recordings <- unique(df$Begin.File) 

for(i in 1:length(night.recordings)) {
  
  this.file <- night.recordings[i]
  site.files <- all.files[which(substr(all.files,1,24)==substr(this.file,1,24))]
  file.copy(from = paste('/Volumes/Gabon2/Resampled_data/',site.files,sep=''), 
          to = paste('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/Gunshot_Review_Lauren/Dataset/Gunshot_All_Files/',
                     site.files,sep=''))
  print(i)
}

          

### COMPARE LAUREN AND RAVEN

lauren.gunshot <- read.csv('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/Gunshot_Review_Lauren/Raven_Workspace_for_Lauren_Review/Selection_Table/Lauren_Gunshot_Review_Nighttime_Files_With_Gunshots.Table.1.selections.csv')

lar <- lauren.gunshot[which(lauren.gunshot$Gunshot == 4 | lauren.gunshot$Gunshot == 5),]

lar.df <- as.data.frame(table(lar$Begin.File))

mon.df <- as.data.frame(table(night.files$Filename))


df.merge <-merge(mon.df,lar.df,by= 'Var1')
colnames(df.merge) <- c('Filename','monitoR','manual')

sum(df.merge$monitoR)
sum(df.merge$manual)

sum(df.merge$monitoR)/sum(df.merge$manual)
