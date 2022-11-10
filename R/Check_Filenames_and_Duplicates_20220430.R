# This script will give me the file name for each site

setwd('/Volumes/Gabon/Soundfiles_Precious_Drive1/')
dir.sites.1 <- dir()

site.file.names <- as.data.frame(matrix(nrow= 68,ncol=3))

for(i in 1:length(dir.sites.1)) {
  setwd('/Volumes/Gabon/Soundfiles_Precious_Drive1/')
  setwd(dir.sites.1[i])
  all.files <- list.files(recursive=TRUE) 
  wav.files <- all.files[grep('.wav',all.files)]
  wav.files.full <- wav.files[which(file.size(wav.files)>=154984448 & file.size(wav.files) <= 158711808)]
  nchar <- unlist(lapply(unlist(lapply(strsplit(wav.files.full,'/'),function(x) x[2])),nchar))
  if (length(unique(nchar))==1) {
    nchar.site <- unique(nchar)
  } else {nchar.site <- 'multiple.values'}
  random.file <- sample(wav.files.full,1)
  file.name <- strsplit(random.file,'/')[[1]][2]
  site.file.names[i,1] <- dir.sites.1[i]
  site.file.names[i,2] <- file.name
  site.file.names[i,3] <- nchar.site
}

# now do same thing for other part of harddrive

setwd('/Volumes/Gabon/Soundfiles_Precious_Drive2/')
dir.sites.2 <- dir()

for(i in 1:length(dir.sites.2)) {
  setwd('/Volumes/Gabon/Soundfiles_Precious_Drive2/')
  setwd(dir.sites.2[i])
  all.files <- list.files(recursive=TRUE) 
  wav.files <- all.files[grep('.wav',all.files)]
  wav.files.full <- wav.files[which(file.size(wav.files)>=154984448)] #& file.size(wav.files) <= 158711808)]
  nchar <- unlist(lapply(unlist(lapply(strsplit(wav.files.full,'/'),function(x) x[2])),nchar))
  if (length(unique(nchar))==1) {
    nchar.site <- unique(nchar)
  } else {nchar.site <- 'multiple.values'}
  random.file <- sample(wav.files.full,1)
  file.name <- strsplit(random.file,'/')[[1]][2]
  site.file.names[(i+54),1] <- dir.sites.1[i]
  site.file.names[(i+54),2] <- file.name
  site.file.names[(i+54),3] <- nchar.site
}

### Now find if there are any duplicate filenames in the dataset

library(stringr)
library(tuneR)

setwd('/Volumes/Gabon/')
all.files <- list.files(recursive=TRUE) 
wav.files <- all.files[grep('.wav',all.files)]

file.names <- lapply(wav.files, function(x) strsplit(x,'/')[[1]][4])

length(file.names)
length(unique(file.names))
