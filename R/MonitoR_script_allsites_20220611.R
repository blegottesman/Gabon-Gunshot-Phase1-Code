# This will do a pilot monitoR test to find gunshots

# Load in relevant libraries

library(monitoR)
library(seewave)
library(tuneR)
library(dplyr)

################################ create templates ######################################################

# Read in gunshot template .wav files 
setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/Gunshot_templates/')

# Make correlation template with gunshot .wav files
wct1 <- makeCorTemplate('Temp1_Sure.0.S20210722T005941229+0100_E20210722T012940244+0100_+00.6856+013.2189__37.89_0-38_0.52_gun1.wav.TBNI21ST.01_01.LOG.wav',
                         t.lim= c(1,2.5), frq.lim = c(.1,1),  wl = 512,ovlp=0,name='gun1',score.cutoff=0.5)

wct2 <- makeCorTemplate('Temp2_Sure.0.S20210223T012948205+0100_E20210223T015946523+0100_+00.5025+012.7767__950.4_15-50_0.5_gun1.wav.IPA8ST.01_46.NP.wav',
                        t.lim= c(2.4,4.9), frq.lim = c(.12,1),  wl = 512,ovlp=0,name='gun2',score.cutoff=0.5)

wct3 <- makeCorTemplate('Temp3_Sure.0.20210810T213000+0100_Short-term_Makokou [-00.15920+012.22393]__736.9_12-17_0.57_gun4.wav.ROG6.21_42.FSC.wav',
                        t.lim= c(.5,2.5), frq.lim = c(.1,.9),  wl = 512,ovlp=0,name='gun3',score.cutoff=0.5)

wct4 <- makeCorTemplate('Temp4_Sure.0.S20210223T002948129+0100_E20210223T005946168+0100_+00.5025+012.7767__725.89_12-6_0.62_gun2.wav.IPA8ST.00_42.NP.wav',
                        t.lim= c(.6,3.8), frq.lim = c(.1,1),  wl = 512,ovlp=0,name='gun4',score.cutoff=0.5)

wct5 <- makeCorTemplate('Temp5_GOOD_Sure.0.20210807T223000+0100_Short-term_Makokou__1304.19_21-44_0.77_gun1.wav.ROG7.22_52.FSC.wav',
                        t.lim= c(.6,3.8), frq.lim = c(.1,1),  wl = 512,ovlp=0,name='gun5',score.cutoff=0.5)

wct6 <- makeCorTemplate('Temp6_Sure.0.20210807T223000+0100_Short-term_Makokou [-00.15920+012.22393]__1307.39_21-47_0.51_gun1.wav.ROG6.22_52.FSC.wav',
                        t.lim= c(.6,3.8), frq.lim = c(.1,1),  wl = 512,ovlp=0,name='gun6',score.cutoff=0.5)

wct7 <- makeCorTemplate('Temp7_GOOD_Sure.0.20210313T003000+0100_Short-term_Makokou__528.19_8-48_0.5_gun4.wav.TBNI1ST.00_39.LOG.wav',
                        t.lim= c(1,4.5), frq.lim = c(.1,1),  wl = 512,ovlp=0,name='gun7',score.cutoff=0.5)

wct8 <- makeCorTemplate('Temp8_Sure.0.20210311T200000+0100_Short-term_Makokou 1__1097.86_18-18_0.53_gun2.wav.TBNI3ST.20_18.LOG.wav',
                        t.lim= c(.6,3.8), frq.lim = c(.15,.8),  wl = 512,ovlp=0,name='gun8',score.cutoff=0.5)

wct9 <- makeCorTemplate('Temp9_GOOD_Sure.0.20210306T000000+0100_Short-term_Makokou 1__195.97_3-16_0.55_gun1.wav.TBNI3ST.00_03.LOG.wav',
                        t.lim= c(1,4.2), frq.lim = c(.1,.8),  wl = 512,ovlp=0,name='gun9',score.cutoff=0.5)

wct10 <- makeCorTemplate('Temp10_GOOD_Sure.0.20210222T233000+0100_Short-term_Makokou__25.6_0-26_0.73_gun1.wav.IPA4ST.23_30.NP.wav',
                        t.lim= c(1.7,4), frq.lim = c(.1,1),  wl = 512,ovlp=0,name='gun10',score.cutoff=0.5)

# Combine templates
#ctemps <- combineCorTemplates(wct1,wct2,wct3,wct4,wct5,wct6,wct7,wct8,wct9,wct10)

ctemps <- combineCorTemplates(wct1,wct2, wct5)

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

setwd('/Volumes/Gabon2/ROG_TBNI_Resampled/')
dir.survey <- '/Volumes/Gabon2/ROG_TBNI_Resampled/'
dir.survey.files <- dir('/Volumes/Gabon2/ROG_TBNI_Resampled/')

# run batch correlation detector on 100 random files 
t1 <-Sys.time()
test.detects <- batchCorMatch(dir.template, dir.survey, ext.template = "wav", ext.survey = "wav",
                          ctemps,  parallel = TRUE, show.prog = TRUE, cor.method = "pearson", warn = FALSE,
                          time.source = "fileinfo")
t2 <-Sys.time()

test.detects.ROG_TBNI <- test.detects

##################################################################################################

### run a batch process on the 1000 test files

# clean detection dataframe and columsn for the minute and second of each detection

load('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/MonitoR_Detection_CSVs_by_Site_Raw/test.detects.ROGTBNI.rdata')

test.detects <- test.detects.ROG_TBNI
test.detects.clean <- test.detects[,-3]
test.detects.clean.thresh2<- test.detects.clean
test.detects.clean.thresh2$minute <- ((test.detects.clean.thresh2$time/60) - (abs(test.detects.clean.thresh2$time/60) %% 1))
test.detects.clean.thresh2$second <- (abs(as.numeric(test.detects.clean.thresh2$time)/60) %% 1)*60

test.detects.clean.ROGTBNI <- test.detects.clean.thresh2
save(test.detects.clean.ROGTBNI, file = '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/MonitoR_Detection_CSVs_by_Site_Clean/test.detects.ROGTBNI.clean.rdata')

################################ remove detections that are not exactly 2 seconds and duplicates #

load('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/MonitoR_Detection_CSVs_by_Site_Clean/test.detects.CF.clean.rdata')

test.detects.dups <- test.detects.clean.ROGTBNI
test.detects.dups$time.round <- (round(test.detects.dups$time/4))*4
test.detects.dupremoved<- test.detects.dups
test.detects.dupremoved <- distinct(test.detects.dupremoved,time.round,id, .keep_all=TRUE)
  
################################ copy detections to new folder ###################################

# copy all clips 

# Set dataset to find clips in
files <- test.detects.dupremoved

# Set working directory 
setwd('/Volumes/Gabon2/ROG_TBNI_Resampled/')

# Set directory to copy clips to
directory.to.save <- '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/All_sites/Clips/'

# Get all unique filenames for the for loop
files.with.detections <- unique(files$id)

for (i in 1:length(files.with.detections)) {
  for (j in 1:length(files.with.detections[which(files == files.with.detections[i])])) {
    
    
    clip.to.write <- readWave(files.with.detections[i], 
                              from = files[which(files == files.with.detections[i])[j],3]-3,
                              to = files[which(files == files.with.detections[i])[j],3]+3, units = 'seconds')
    writeWave(clip.to.write, file=paste(directory.to.save, 
                                        substr(files.with.detections[i],1,nchar(files.with.detections[i])-4),'_',
                                        '_',as.character(round(files[which(files == files.with.detections[i])[j],3],2)),'_', # time
                                        paste(as.character(round(files[which(files == files.with.detections[i])[j],5],2)),'-', # time in min:sec
                                              as.character(round(files[which(files == files.with.detections[i])[j],6],0)),sep=''), 
                                        '_',as.character(round(files[which(files == files.with.detections[i])[j],4],2)), # score
                                        '_',as.character(files[which(files == files.with.detections[i])[j],2]), # template
                                        '.wav',sep=''))
  }
}



