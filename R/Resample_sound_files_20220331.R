### Resample .wav files from 44.1 kHz to 4 kHz and save them in a different folder

# load libraries
library(tuneR)
library(seewave)

# resample files 

sites <- c('IPA4ST','IPS8ST','TBNI21ST','TBNI24ST','TBNI1ST','TBNI3ST','ROG6','ROG7')

repot.base <- '/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/CNN/Data/Eight_sites/'

test.files <- dir()

for(i in 1:length(sites)) {
    
setwd(paste('/Volumes/Gabon1/',sites[i],sep=''))

file <-  readWave(test.files[i],from=0,to=60,units='seconds')
file.filt<-bwfilter(file,n=4,to=4000,output='Wave')
file.resampled <- downsample(file.filt,8000)
file.resampled.round <- file.resampled
file.resampled.round@left <- round(file.resampled@left)

if (length(which(file.resampled.round@left>32767))>0) {
file.resampled.round@left[which(file.resampled.round@left>32767)] <- 32767}
if (length(which(file.resampled.round@left<(-32768)))>0) {
file.resampled.round@left[which(file.resampled.round@left<=(-32768))] <- -32768}

#file.normal <- normalize(file.resampled.round,unit=c('16'),rescale=FALSE)
writeWave(file.resampled.round, file = paste(repot,'/',test.files[i],sep=''))
print(i)
}
  
spectro(file,fastdisp = TRUE,flim=c(0,5))
spectro(file.filt,fastdisp = TRUE,flim=c(0,5))
spectro(file.resampled,fastdisp = TRUE,flim=c(0,3))
