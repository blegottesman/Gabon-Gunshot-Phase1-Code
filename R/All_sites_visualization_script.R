library(ggplot2) 
library(ggpubr)
library(tidyverse)
library(lubridate)
library(dplyr)
library(RColorBrewer)

# Read in datatable from Raven and crop to only look at gun detections with confidence scores >= 4

dfa <- read.csv('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/Dataframes/All_sites_selection_table_new.csv')
guns <- dfa[which(dfa$Gunshot.4and5confidence==1),]
guns.crop <- guns[,c(6,9,12,13,14,15)]
guns.crop$Gunshot <- 1
df <- guns.crop 

### Add additional variables including Site, Treatment Date, Day of the Week, Time of Gunshot, Hour, and when a gunshot occured in a file 

df$Site <- gsub('_','',substr(guns.crop$Begin.File,1,9))
df$Date <- as.Date(gsub('_','',substr(guns.crop$Begin.File,10,17)),'%Y%m%d')
df$Filetime <- substr(guns.crop$Begin.File,19,24)
df$Hour <- as.numeric(substr(df$Filetime,1,2))
df$FileTime <- strptime(gsub('-','',gsub('_','',substr(guns.crop$Begin.File,10,24))),'%Y%m%d%H%M%S')
df$SecondsIntoFile <- gsub('-','',gsub('_','',substr(df$Begin.File,26,32)))
df$TimeofGunshot <- df$FileTime + as.numeric(as.character(df$SecondsIntoFile))
df$Treatment <- ''
df$Weekday <- as.factor(weekdays(df$Date))
df$Weekday <- factor(df$Weekday,     # Reorder factor levels
                     c("Sunday", "Monday","Tuesday", "Wednesday","Thursday","Friday","Saturday"))

# fill in treatment (land use type)
df$Treatment[which(substr(df$Site,1,2) == 'IP')] <- "NP"
df$Treatment[which(substr(df$Site,1,2) == 'TB')] <- "LOG"
df$Treatment[which(substr(df$Site,1,2) == 'CF')] <- "CF"
df$Treatment[which(substr(df$Site,1,2) == 'RO')] <- "FSC"
df$Treatment[which(substr(df$Site,1,8) == 'TBNI21ST' |
                       substr(df$Site,1,8) == 'TBNI22ST' | 
                       substr(df$Site,1,8) == 'TBNI23ST' |
                       substr(df$Site,1,8) == 'TBNI24ST' |
                       substr(df$Site,1,8) == 'TBNI25ST')] <- "PP"

# Remove sites with less than 3 days of data

#df <- df %>% filter(!Site %in% c('TBNI5LT','TBNI11LT','TBNI13LT','TBNI8ST'))
df<-df[-which(df$Site=='TBNI8ST'),] # Remove because has less than three days of detecions

# Ensure that all duplicates were removed from this table

unique.filenames <- unique(substr(df$Begin.File,1,24))
df.dupremoved <- NULL
df.dup <- NULL

for(i in 1:length(unique(substr(df$Begin.File,1,24)))) {
file.match <- unique.filenames[i]
df.file <- df[which(substr(df$Begin.File,1,24) == unique.filenames[i]),]
df.file.time <- df.file[order(df.file$TimeofGunshot),]

if (dim(df.file.time[-which(abs(diff(as.numeric(df.file.time$SecondsIntoFile)))<2),])[1] == 0) # checks if there are no duplicates
  {df.dupremoved[[i]] <- df.file.time} else
  {df.dupremoved[[i]] <- df.file.time[-which(abs(diff(as.numeric(df.file.time$SecondsIntoFile)))<2),]}

if (dim(df.file.time[which(abs(diff(as.numeric(df.file.time$SecondsIntoFile)))<2),])[1] == 0) # checks if there are no duplicates
{df.dup <- df.dup} else
{df.dup[[i]] <- df.file.time[which(abs(diff(as.numeric(df.file.time$SecondsIntoFile)))<2),]}
}
 
# Collapse back into a dataframe

df <- bind_rows(df.dupremoved, .id = "column_label")
df.dups <- bind_rows(df.dup, .id = "column_label")

# Remove unwanted columns 

df <- df[,-c(1,4,7,10)]

# Sort dataframe 

df <- df[
  with(df, order(Site,FileTime)),
  ]

# Create Final List of Gunshot Table

write.csv(df,'/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/Dataframes/Final_Dataframes/df_gunshots_detected.csv')

######################################################################################################################################################
############################################################################ DF2 ##########################################################################
######################################################################################################################################################

# Summarize gunshot data for each site

# Site Treatment Gunshots per Day 

df2 <- df %>% 
  group_by(Site) %>% 
  summarise(sum(Gunshot))

df2 <- as.data.frame(df2)
colnames(df2) <- c('Site', 'Gunshots') 

# Add in number of files

num.of.files <- read.csv('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/Dataframes/Number_of_Files.csv')

df2.missing <- as.data.frame(cbind(setdiff(num.of.files$Site,df2$Site), Gunshots = 0))
colnames(df2.missing) <- c('Site', 'Gunshots') 

fulldf <- rbind(df2, df2.missing)
fulldf$Number_of_files <- 1

for(i in 1:dim(fulldf)[1]) {
  fulldf[i,3] <- num.of.files[which(num.of.files$Site == fulldf[i,1]),2]
}

# Add land use type
fulldf$Treatment <- ''
fulldf$Treatment[which(substr(fulldf$Site,1,2) == 'IP')] <- "NP"
fulldf$Treatment[which(substr(fulldf$Site,1,2) == 'TB')] <- "LOG"
fulldf$Treatment[which(substr(fulldf$Site,1,2) == 'CF')] <- "CF"
fulldf$Treatment[which(substr(fulldf$Site,1,2) == 'RO')] <- "FSC"
fulldf$Treatment[which(substr(fulldf$Site,1,8) == 'TBNI21ST' |
                     substr(fulldf$Site,1,8) == 'TBNI22ST' | 
                     substr(fulldf$Site,1,8) == 'TBNI23ST' |
                     substr(fulldf$Site,1,8) == 'TBNI24ST' |
                     substr(fulldf$Site,1,8) == 'TBNI25ST')] <- "PP"

fulldf$Gunshot_rate<- as.numeric(fulldf$Gunshots)/(fulldf$Number_of_files/48)

df2 <- fulldf

df2 <- df2[
  with(df2, order(Site)),
  ]

# Write file 

write.csv(df2,'/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/Dataframes/Final_Dataframes/df2_gunshots_detected_summarized.csv')

#################################################################################################################################################
################################################################ Plotting #######################################################################
#################################################################################################################################################

Hours <- c('0',"1",'2','3',"4","5",'6','7','8','9',"10","11","12","13","14","15","16","17","18","19","20", "21", "22","23")
df$Hour <- factor(df$Hour, c('0',"1",'2','3',"4","5",'6','7','8','9',"10","11","12","13","14","15","16","17","18","19","20", "21", "22","23"))

df$Treatment <- factor(df$Treatment,     # Reorder factor levels
                        c("LOG", "FSC","PP", "CF","NP"))
df2$Treatment <- factor(df2$Treatment,     # Reorder factor levels
                           c("LOG", "FSC","PP", "CF","NP"))


df$Site <- factor(df$Site,     # Reorder factor levels
                  c('TBNI1ST','TBNI2LT','TBNI3ST','TBNI4ST','TBNI6ST','TBNI7LT','TBNI9LT','TBNI10ST','TBNI12ST',
                     'TBNI14ST','TBNI15ST','TBNI16LT','TBNI17ST','TBNI18LT','TBNI19ST','TBNI20ST',
                     'ROG4','ROG5','ROG6','ROG7','ROG8','ROG9','ROG10','ROG11','ROG12','ROG13','ROG14','ROG15',
                     'TBNI21ST','TBNI22ST','TBNI23ST','TBNI24ST','TBNI25ST',
                     'CF1ST','CF2LT','CF3ST','CF4LT','CF5ST','CF6LT','CF7ST','CF8LT','CF9ST','CF10LT','CF11ST','CF12LT',
                     'IPA1ST','IPA2LT','IPA3ST','IPA4ST','IPA5LT','IPA6ST','IPA7ST',
                     'IPA8ST','IPA9LT','IPA10ST','IPA11ST','IPA13ST','IPA14ST','IPA15ST','IPA16ST','IPA17ST','IPA18ST','IPA19ST','IPA20ST'))

df2$Site<- factor(df2$Site,
                   c('TBNI1ST','TBNI2LT','TBNI3ST','TBNI4ST','TBNI6ST','TBNI7LT','TBNI9LT','TBNI10ST','TBNI12ST',
                     'TBNI14ST','TBNI15ST','TBNI16LT','TBNI17ST','TBNI18LT','TBNI19ST','TBNI20ST',
                     'ROG4','ROG5','ROG6','ROG7','ROG8','ROG9','ROG10','ROG11','ROG12','ROG13','ROG14','ROG15',
                     'TBNI21ST','TBNI22ST','TBNI23ST','TBNI24ST','TBNI25ST',
                     'CF1ST','CF2LT','CF3ST','CF4LT','CF5ST','CF6LT','CF7ST','CF8LT','CF9ST','CF10LT','CF11ST','CF12LT',
                     'IPA1ST','IPA2LT','IPA3ST','IPA4ST','IPA5LT','IPA6ST','IPA7ST',
                     'IPA8ST','IPA9LT','IPA10ST','IPA11ST','IPA13ST','IPA14ST','IPA15ST','IPA16ST','IPA17ST','IPA18ST','IPA19ST','IPA20ST'))

site.labels <- c('TBNI1ST','TBNI2LT','TBNI3ST','TBNI4ST','TBNI6ST','TBNI7LT','TBNI9LT','TBNI10ST','TBNI12ST',
                 'TBNI14ST','TBNI15ST','TBNI16LT','TBNI17ST','TBNI18LT','TBNI19ST','TBNI20ST',
                 'ROG4','ROG5','ROG6','ROG7','ROG8','ROG9','ROG10','ROG11','ROG12','ROG13','ROG14','ROG15',
                 'TBNI21ST','TBNI22ST','TBNI23ST','TBNI24ST','TBNI25ST',
                 'CF1ST','CF2LT','CF3ST','CF4LT','CF5ST','CF6LT','CF7ST','CF8LT','CF9ST','CF10LT','CF11ST','CF12LT',
                 'IPA1ST','IPA2LT','IPA3ST','IPA4ST','IPA5LT','IPA6ST','IPA7ST',
                 'IPA8ST','IPA9LT','IPA10ST','IPA11ST','IPA13ST','IPA14ST','IPA15ST','IPA16ST','IPA17ST','IPA18ST','IPA19ST','IPA20ST')

site.numbers <- parse_number(gsub("([0-9]+).*$", "\\1", site.labels))

# Barplot of gunshots vs. time of day 
tiff("/Users/bengottesman/Documents/Work/Gabon/Figures/All_Sites/Gunshots_TimeofDay.tiff", units="in", width=7.5, height=5, res=300)
ggbarplot(df, x = "Hour", y = "Gunshot", fill = 'Treatment', width = 0.5) + 
  xlab('Hour')+ ylab('Gunshots detected') + 
  labs(title = "Time of gunshots", x = "Hour", y = "Gunshots detected") +
  scale_x_discrete(labels= Hours,drop = F) + 
  scale_fill_manual(values = brewer.pal(5, name = 'Paired'), labels = c("Non-certified Logging","FSC-certified Logging", 'Proposed Protected Area','Community Forest','National Park'))+
  theme(legend.title= element_blank()) +theme(legend.text=element_text(size=8))
dev.off()

 # Barplot of sites vs gunshot rate

# Barplot of gunshot rate for each site 
tiff("/Users/bengottesman/Documents/Work/Gabon/Figures/All_Sites/Sites_vs_GunshotRate.tiff", units="in", width=9, height=5, res=300)
ggbarplot(df2, x = "Site", y = "Gunshot_rate", fill = 'Treatment', width = 0.5) + 
  xlab('Hour')+ ylab('Gunshots detected\n') + 
  labs(title = "Gunshots detected per site", x = "Site", y = "Gunshots detected") +
  theme(axis.text.x=element_text(color = "black", size=1, angle=30, vjust=.8, hjust=0.8)) +
  #  scale_fill_manual(values = c('#F8766D', "#7CAE00",'#00BFC4','#C77CFF'), labels = c("Non-certified Logging","FSC-certified Logging", 'Proposed Protected Area','National Park'))+
  scale_fill_manual(values = brewer.pal(5, name = 'Paired'), labels = c("Non-certified Logging","FSC-certified Logging", 'Proposed Protected Area','Community Forest','National Park'))+
  scale_x_discrete(drop = F) + 
  theme(text = element_text(size = 11)) + theme(axis.text.x = element_text(size =5))
dev.off()

# Barplot of total gunshots for each site 
tiff("/Users/bengottesman/Documents/Work/Gabon/Figures/All_Sites/Sites_vs_TotalGunshots.tiff", units="in", width=9, height=5, res=300)
ggbarplot(df, x = "Site", y = "Gunshot", fill = 'Treatment', width = 0.5) + 
  xlab('Hour')+ ylab('Gunshots detected\n') + 
  labs(title = "Gunshots detected per site", x = "Site", y = "Gunshots detected") +
  #theme(axis.text.x=element_text(color = "black", size=8, angle=30, vjust=.8, hjust=0.8)) + # We can either plot the full sitename or just sitenumber
  scale_fill_manual(values = brewer.pal(5, name = 'Paired'), labels = c("Non-certified Logging","FSC-certified Logging", 'Proposed Protected Area','Community Forest','National Park'))+
  scale_x_discrete(drop = F,labels=site.numbers) + 
  theme(text = element_text(size = 11)) + theme(axis.text.x = element_text(size = 5))
dev.off()

df2$Treatment <- factor(df2$Treatment,     # Reorder factor levels
                       c("LOG", "FSC","PP", "CF","NP"))

tiff("/Users/bengottesman/Documents/Work/Gabon/Figures/All_Sites/Treatments_vs_TotalGunshots.tiff", units="in", width=9, height=5, res=300)
  ggplot(df2, aes(x=Treatment, y=Gunshot_rate, fill=Treatment)) + 
  geom_boxplot() + xlab('\nLand use type')+ ylab('Gunshots per day\n') + theme(text = element_text(size = 12)) + 
  scale_fill_manual(values = brewer.pal(5, name = 'Paired'), labels = c("Non-certified Logging","FSC-certified Logging", 'Proposed Protected Area','Community Forest','National Park'))+
  ggtitle('Gunshots rates vs. land use type') +theme(legend.title= element_blank()) + scale_x_discrete(labels = function(x) 
    stringr::str_wrap(x, width = 15))
dev.off()




# Day of the week dataframe


df.daily <- df %>% filter(!Site %in% c('IPA2LT','IPA5LT','IPA9LT','TBNI2LT','TBNI7LT',
                    'TBNI9LT','TBNI16LT','TBNI18LT','CF2LT','CF4LT','CF6LT','CF8LT','CF10LT','CF12LT'))

df.daily$Weekday <- factor(df.daily$Weekday,     # Reorder factor levels
                           c("Sunday", "Monday","Tuesday", "Wednesday","Thursday",'Friday','Saturday'))

ggbarplot(df.daily, x = "Weekday", y = "Gunshot", fill = 'Treatment', width = 0.5) + 
  xlab('Weekday')+ ylab('Gunshots detected') + 
  labs(title = "Gunshots by day of week", x = "Day of week", y = "Gunshots detected") +
  scale_x_discrete(labels= Hours,drop = F) + 
  # scale_fill_manual(values = c("#F8766D", "#7CAE00",'#00BFC4','#C77CFF'), labels = c("Non-certified Logging","FSC-certified Logging", 'Proposed Protected Area','Community Forest','National Park'))+
  theme(legend.title= element_blank()) 



