# This will do a pilot monitoR test to find gunshots

# Load in relevant libraries

library(monitoR)
library(seewave)
library(tuneR)

################################ create templates ######################################################

# Read in gunshot template .wav files 
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/')
gs1 <- readWave('gs1.wav')

# Make correlation template with gunshot .wav files
 wct1 <- makeCorTemplate('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Gunshot_templates/gs1.wav',
                         t.lim= c(0.1,0.7), frq.lim = c(0,1.5),  wl = 512,name='gs1')

# Combine templates
ctemps <- combineCorTemplates(wct1)

################################ run on single file ####################################################

### run on single file 
# read in test data
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset/')
test.file <- '20210505T170000+0100_Long-term_Makokou.wav'

# perform spectral correlation and get detections
cscores <- corMatch('20210505T170000+0100_Long-term_Makokou.wav', 
                    ctemps,parallel = TRUE,show.prog = TRUE)
cdetects <- findPeaks(cscores)
#plot(cdetects,t.each=60*30)
getDetections(cdetects) 

################################# run on batch of data ###########################################

### run a batch process on the 100 test files

setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset/')
dir.survey <- '/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset/'
dir.survey.files <- dir('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset/')

# run batch correlation detector on 100 random files 
t1 <-Sys.time()
test.detects <- batchCorMatch(dir.template, dir.survey, ext.template = "wav", ext.survey = "wav",
                          ctemps, parallel = TRUE, show.prog = TRUE, cor.method = "pearson", warn = FALSE,
                          time.source = "fileinfo")
t2 <-Sys.time()

# clean detection dataframe and columsn for the minute and second of each detection
test.detects.clean <- test.detects[,-3]
test.detects.clean.thresh <- test.detects.clean[which(test.detects$score>0.4),]
test.detects.clean.thresh$minute <- ((test.detects.clean.thresh$time/60) - (abs(test.detects.clean.thresh$time/60) %% 1))
test.detects.clean.thresh$second <- (abs(as.numeric(test.detects.clean.thresh$time)/60) %% 1)*60

################################ copy detections to new folder ###################################

# copy all clips 

files.with.detections <- unique(test.detects.clean.thresh$id)

for (i in 1:length(files.with.detections)) {
  for (j in 1:length(files.with.detections[which(test.detects.clean.thresh == files.with.detections[i])])) {
    clip.to.write <- readWave(files.with.detections[i], 
                              from = test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],3]-2,
                              to = test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],3]+2, units = 'seconds')
    writeWave(clip.to.write, file=paste('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Detected_clips/', 
                                        substr(files.with.detections[i],1,nchar(files.with.detections[i])-4),'_',
                                        '_',as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],3],2)),'_', # time
                                        paste(as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],5],2)),'-', # time in min:sec
                                        as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],6],0)),sep=''), 
                                        '_',as.character(round(test.detects.clean.thresh[which(test.detects.clean.thresh == files.with.detections[i])[j],4],2)), # score
                                        '.wav',sep=''))
  }
}

