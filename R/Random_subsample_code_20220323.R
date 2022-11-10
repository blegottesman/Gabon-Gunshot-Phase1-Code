# For this code, the goal is to create a random subsample of sites in order to inspect data for gunshots
# I could randomly go in to Gabon 1 and 2 and pick 100 files at random to look through... Would that do anything? 
# The other option is to run a detector on the subsample. 
# What is my primary goal in doing this? 

# load relevant packages

library(stringr)
library(tuneR)

setwd('/Volumes/Gabon/')

# randomly select 100 .wav files that are correct length (30 minutes) from full dataset
all.files <- list.files(recursive=TRUE) 
wav.files <- all.files[grep('.wav',all.files)]
wav.files.full <- wav.files[which(file.size(wav.files)>=154984448 & file.size(wav.files) <= 158711808)]
files.to.copy <- sample(wav.files.full,100,replace=FALSE)

# get .wav file names to add to the destination path
dest.name <- unlist(strsplit(files.to.copy,'/'))[grep('.wav',unlist(strsplit(files.to.copy,'/')))]

# copy files
file.copy(files.to.copy, paste('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset/',dest.name,sep=''))

#####################################################################################################################
# Modify code to only subsample files from sites with evidence of hunting / hunting with guns. List of folders made from the Phase 1 excel sheet site notes

sites.with.hunting <- c('IPA2LT', 'IPA7ST','IPA8ST','IPA13ST','IPA14ST',
                        'IPA20ST','TBNI2LT','TBNI3ST','TBNI5LT','TBNI8ST',
                        'TBNI17ST','TBNI22ST','TBNI23ST','TBNI24ST','TBNI25ST',
                        'CF2LT','CF3ST','CF4LT','CF6LT','CF8LT','ROG4')
                   
# Get all full .wav files from both directories     
setwd('/Volumes/Gabon1/')
all.files.gabon1 <- list.files(recursive=TRUE) 
wav.files.gabon1 <- all.files.gabon1[grep('.wav',all.files.gabon1)]
wav.files.full.gabon1 <- wav.files.gabon1[which(file.size(wav.files.gabon1)>=154984448 & file.size(wav.files.gabon1) <= 158711808)]

setwd('/Volumes/Gabon2/')
all.files.gabon2 <- list.files(recursive=TRUE) 
all.files.gabon2 <- list.files(recursive=TRUE) 
wav.files.gabon2 <- all.files.gabon2[grep('.wav',all.files.gabon2)]
wav.files.full.gabon2 <- wav.files.gabon2[which(file.size(wav.files.gabon2)>=154984448 & file.size(wav.files.gabon2) <= 158711808)]

# Combine gabon1 and gabon2
all.files.gabon <- c(wav.files.full.gabon1,wav.files.full.gabon2)

# Filter only sites with hunting / guns
files.with.hunting <- unique (grep(paste(sites.with.hunting,collapse="|"), 
                        all.files.gabon, value=TRUE))                        

# Copy files to local directory
files.to.copy <- sample(files.with.hunting,10,replace=FALSE)

# get .wav file names to add to the destination path
dest.name <- unlist(strsplit(files.to.copy,'/'))[grep('.wav',unlist(strsplit(files.to.copy,'/')))]

# copy files
setwd('/Volumes/Gabon1/')
file.copy(files.to.copy, paste('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset_1000/',dest.name,sep=''))
                        
# copy files
setwd('/Volumes/Gabon2/')
file.copy(files.to.copy, paste('/Users/bengottesman/Documents/Work/Gabon/Methods/Test_dataset_1000/',dest.name,sep=''))



                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        