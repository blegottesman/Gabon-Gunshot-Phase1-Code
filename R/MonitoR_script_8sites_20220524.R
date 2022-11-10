# This will do a pilot monitoR test to find gunshots

# Load in relevant libraries

library(monitoR)
library(seewave)
library(tuneR)
library(dplyr)

################################ create templates ######################################################

# Read in gunshot template .wav files 
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/')

# Make correlation template with gunshot .wav files
wct1 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Eight_Site_Templates/1.0.0.0.0.0.0.20210609T213000+0100_Long-term_Makokou__1016.82_16-57_0.68_gun1.wav',
                         t.lim= c(0,2.4), frq.lim = c(.1,1.5),  wl = 512,ovlp=0,name='gun1',score.cutoff=0.5)

wct2 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Eight_Site_Templates/1.0.0.0.0.0.0.20210616T013000+0100_Long-term_Makokou__1610.74_26-51_0.6_gun1.wav',
                        t.lim= c(.75,2), frq.lim = c(.075,.9),  wl = 512,ovlp=0,name='gun2',score.cutoff=0.5)

wct3 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Eight_Site_Templates/1.0.0.0.0.0.0.20210407T050000+0100_Long-term_Makokou__554.19_9-14_0.69_gun3.wav',
                        t.lim= c(.5,2.5), frq.lim = c(0,.8),  wl = 512,ovlp=0,name='gun3',score.cutoff=0.5)

wct4 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/Eight_Site_Templates/20210723T200000+0100_Short-term_Makokou.wav',
                        t.lim= c(1.75,3.5), frq.lim = c(0,.8),  wl = 512,ovlp=0,name='gun4',score.cutoff=0.5)

# Combine templates
ctemps <- combineCorTemplates(wct1,wct2,wct3,wct4)

################################ run on single file ####################################################

### run on single file 
# read in test data
#setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/CNN/Data/Eight_sites/')
#test.file <- '/Users/bengottesman/Documents/20210723T200000+0100_Short-term_Makokou.wav'

#t1 <-Sys.time()

# perform spectral correlation and get detections
#cscores <- corMatch('/Users/bengottesman/Documents/Gunshot_folder/S20210505T123011451+0100_E20210505T130004533+0100_+00.7694+013.1906.wav', 
#                    ctemps,parallel = TRUE)
#cdetects <- findPeaks(cscores)
#getDetections(cdetects) 

#t2 <-Sys.time()

#t2-t1
#plot(cdetects,t.each=60*28)

################################# run on batch of data ###########################################

### run a batch process on the 1000 test files

setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/CNN/Data/Eight_sites/')
dir.survey <- '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/CNN/Data/Eight_sites/'
dir.survey.files <- dir('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/CNN/Data/Eight_sites/')

# run batch correlation detector on 100 random files 
t1 <-Sys.time()
test.detects <- batchCorMatch(dir.template, dir.survey, ext.template = "w2av", ext.survey = "wav",
                          ctemps, parallel = TRUE, show.prog = TRUE, cor.method = "pearson", warn = FALSE,
                          time.source = "fileinfo")
t2 <-Sys.time()

# clean detection dataframe and columsn for the minute and second of each detection

save(test.detects, file = '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Eight_sites/eight_sites_raw_monitoR_results.rdata')

test.detects.clean <- test.detects[,-3]
test.detects.clean.thresh1 <- test.detects.clean[-which(test.detects.clean$score<0.7),]
#test.detects.clean.thresh1 <- test.detects.clean
#test.detects.clean.thresh2 <- test.detects.clean.thresh1[-which(test.detects.clean.thresh1$score<0.6 & test.detects.clean.thresh1$template=='gun2'),]
test.detects.clean.thresh2 <- test.detects.clean.thresh1
test.detects.clean.thresh2$minute <- ((test.detects.clean.thresh2$time/60) - (abs(test.detects.clean.thresh2$time/60) %% 1))
test.detects.clean.thresh2$second <- (abs(as.numeric(test.detects.clean.thresh2$time)/60) %% 1)*60

test.detects.clean <- test.detects.clean.thresh2
save(test.detects.clean, file = '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Eight_sites/eight_sites_clean_monitoR_results.rdata')

################################ remove detections that are not exactly 2 seconds and duplicates #

load('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Eight_sites/eight_sites_clean_monitoR_results.rdata')

test.detects.clean.crop <- test.detects.clean #[-which(test.detects.f1.clean$time > 1798 | test.detects.f1.clean$time < 2),]
test.detects.clean.crop$time.round <- round(test.detects.clean.crop$time)
test.detects.clean.crop.dupremoved <- distinct(test.detects.clean.crop,time.round,id, .keep_all=TRUE)

files <- test.detects.clean.crop.dupremoved
  
################################ copy detections to new folder ###################################

# copy all clips 

# Set dataset to find clips in
test.detects.clean.thresh <- files

# Set working directory 
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/CNN/Data/Eight_sites/')

# Set directory to copy clips to
directory.to.save <- '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Eight_sites/Eight_sites_detected_clips_above_pointseven/'

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



