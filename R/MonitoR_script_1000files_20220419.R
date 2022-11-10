# This will do a pilot monitoR test to find gunshots

# Load in relevant libraries

library(monitoR)
library(seewave)
library(tuneR)
library(dplyr)

################################ create templates ######################################################

# Read in gunshot template .wav files 
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/')
gs1 <- readWave('gs1.wav')

# Make correlation template with gunshot .wav files
wct1 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Cornell_Templates_8khz/gun10_mix1000_20161105_093314.wav',
                         t.lim= c(1.4,1.8), frq.lim = c(.1,1),  wl = 256,ovlp=75,name='gun1',score.cutoff=0.5)

wct2 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Cornell_Templates_8khz/gun4_tir500m_20180517_000000.wav',
                        t.lim= c(.8,1.1), frq.lim = c(.1,1),  wl = 256,ovlp=75,name='gun2',score.cutoff=0.5)

wct3 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Cornell_Templates_8khz/gun11_tir1100m_20180426_092825.wav',
                        t.lim= c(.3,.8), frq.lim = c(.1,.8),  wl = 256,ovlp=75,name='gun3',score.cutoff=0.5)

wct4 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Our_Data_Templates/8khz_20210309T020000+0100_Short-term_Makokou.wav',
                        t.lim= c(3.1,3.35), frq.lim = c(0,2),  wl = 256,ovlp=50,name='gun4',score.cutoff=0.4)

wct5 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Our_Data_Templates/8khz_S20210226T012948105+0100_E20210226T015944148+0100_+00.4842+012.7222.wav',
                        t.lim= c(.5,1.5), frq.lim = c(.1,1),  wl = 256,ovlp=50,name='gun5',score.cutoff=0.5)

wct6 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Our_Data_Templates/8khz_S20210301T140013296+0100_E20210301T142954226+0100_+00.4933+012.7250.wav',
                        t.lim= c(2.2,2.6), frq.lim = c(.1,1),  wl = 256,ovlp=50,name='gun6',score.cutoff=0.4)

# Combine templates
ctemps <- combineCorTemplates(wct1,wct2,wct3,wct4,wct5,wct6)

################################ run on single file ####################################################

### run on single file 
# read in test data
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset_1000_resampled/')
test.file <- 'S20210223T152955582+0100_E20210223T155950627+0100_+00.4842+012.7222.wav'

t1 <-Sys.time()

# perform spectral correlation and get detections
cscores <- corMatch('S20210223T152955582+0100_E20210223T155950627+0100_+00.4842+012.7222.wav', 
                    ctemps,parallel = TRUE)
cdetects <- findPeaks(cscores)
getDetections(cdetects) 

t2 <-Sys.time()

t2-t1
plot(cdetects,t.each=60*28)

################################# run on batch of data ###########################################

### run a batch process on the 1000 test files

setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset_1000_resampled/F4/')
dir.survey <- '/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset_1000_resampled/F4/'
dir.survey.files <- dir('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset_1000_resampled/F4/')

# run batch correlation detector on 100 random files 
t1 <-Sys.time()
test.detects <- batchCorMatch(dir.template, dir.survey, ext.template = "wav", ext.survey = "wav",
                          ctemps, parallel = TRUE, show.prog = TRUE, cor.method = "pearson", warn = FALSE,
                          time.source = "fileinfo")
t2 <-Sys.time()

test.detects.f4 <- test.detects 

# clean detection dataframe and columsn for the minute and second of each detection
test.detects <- test.detects.f4

test.detects.clean <- test.detects[,-3]
test.detects.clean.thresh1 <- test.detects.clean[-which(test.detects.clean$score<0.48 & test.detects.clean$template=='gun4'),]
#test.detects.clean.thresh1 <- test.detects.clean
#test.detects.clean.thresh2 <- test.detects.clean.thresh1[-which(test.detects.clean.thresh1$score<0.6 & test.detects.clean.thresh1$template=='gun2'),]
test.detects.clean.thresh2 <- test.detects.clean.thresh1
test.detects.clean.thresh2$minute <- ((test.detects.clean.thresh2$time/60) - (abs(test.detects.clean.thresh2$time/60) %% 1))
test.detects.clean.thresh2$second <- (abs(as.numeric(test.detects.clean.thresh2$time)/60) %% 1)*60

test.detects.f4.clean <- test.detects.clean.thresh2
save(test.detects.f1.clean, file = '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f1.clean.rdata')
save(test.detects.f2.clean, file = '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f2.clean.rdata')
save(test.detects.f3.clean, file = '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f3.clean.rdata')
save(test.detects.f4.clean, file = '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f4.clean.rdata')

################################ remove detections that are not exactly 2 seconds and duplicates #

load('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f1.clean.rdata')
load('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f2.clean.rdata')
load('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f3.clean.rdata')
load('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detection_Results_1000_Subsample/test.detects.f4.clean.rdata')

test.detects.f1.clean.crop <- test.detects.f1.clean #[-which(test.detects.f1.clean$time > 1798 | test.detects.f1.clean$time < 2),]
test.detects.f1.clean.crop$time.round <- round(test.detects.f1.clean.crop$time)
test.detects.f1.clean.crop.dupremoved <- distinct(test.detects.f1.clean.crop,time.round,id, .keep_all=TRUE)
#test.detects.f1.clean.crop.dupremoved7 <- test.detects.f1.clean.crop.dupremoved[which(test.detects.f1.clean.crop.dupremoved$score>0.65),]

test.detects.f2.clean.crop <- test.detects.f2.clean[-which(test.detects.f2.clean$time > 1798 | test.detects.f2.clean$time < 2),]
test.detects.f2.clean.crop$time.round <- round(test.detects.f2.clean.crop$time)
test.detects.f2.clean.crop.dupremoved <- distinct(test.detects.f2.clean.crop,time.round,id, .keep_all=TRUE)
#test.detects.f2.clean.crop.dupremoved7 <- test.detects.f2.clean.crop.dupremoved[which(test.detects.f2.clean.crop.dupremoved$score>0.65),]

test.detects.f3.clean.crop <- test.detects.f3.clean[-which(test.detects.f3.clean$time > 1798 | test.detects.f3.clean$time < 2),]
test.detects.f3.clean.crop$time.round <- round(test.detects.f3.clean.crop$time)
test.detects.f3.clean.crop.dupremoved <- distinct(test.detects.f3.clean.crop,time.round,id, .keep_all=TRUE)
#test.detects.f3.clean.crop.dupremoved7 <- test.detects.f3.clean.crop.dupremoved[which(test.detects.f3.clean.crop.dupremoved$score>0.65),]

test.detects.f4.clean.crop <- test.detects.f4.clean[-which(test.detects.f4.clean$time > 1798 | test.detects.f4.clean$time < 2),]
test.detects.f4.clean.crop$time.round <- round(test.detects.f4.clean.crop$time)
test.detects.f4.clean.crop.dupremoved <- distinct(test.detects.f4.clean.crop,time.round,id, .keep_all=TRUE)
#test.detects.f4.clean.crop.dupremoved7 <- test.detects.f4.clean.crop.dupremoved[which(test.detects.f4.clean.crop.dupremoved$score>0.65),]

files <- rbind(test.detects.f1.clean.crop.dupremoved,test.detects.f2.clean.crop.dupremoved,test.detects.f3.clean.crop.dupremoved,test.detects.f4.clean.crop.dupremoved)

################################ copy detections to new folder ###################################

# copy all clips 

# Set dataset to find clips in
test.detects.clean.thresh <- files

# Set working directory 
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset_1000_resampled/')

# Set directory to copy clips to
directory.to.save <- '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detected_clips_10secondlength/'

# Get all unique filenames for the for loop
files.with.detections <- unique(test.detects.clean.thresh$id)

for (i in 1:length(files.with.detections)) {
  for (j in 1:length(files.with.detections[which(test.detects.clean.thresh == files.with.detections[i])])) {
    
  
    clip.to.write <- readWave(files.with.detections[i], 
                              from = test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],3]-5,
                              to = test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],3]+5, units = 'seconds')
    writeWave(clip.to.write, file=paste(directory.to.save, 
                                        substr(files.with.detections[i],1,nchar(files.with.detections[i])-4),'_',
                                        '_',as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],3],2)),'_', # time
                                        paste(as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],5],2)),'-', # time in min:sec
                                        as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],6],0)),sep=''), 
                                        '_',as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],4],2)), # score
                                        '_',as.character(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],2]), # template
                                        '.wav',sep=''))
  }
}


