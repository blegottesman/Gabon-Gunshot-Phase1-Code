library(stringr)

##### Remove .wav files less than 29 minutes #####

setwd('/Volumes/Gabon1/')

# randomly select 100 .wav files that are correct length (30 minutes) from full dataset
all.files <- list.files(recursive=TRUE) 
wav.files <- all.files[grep('.wav',all.files)]
wav.files.empty <- wav.files[which(file.size(wav.files)<=140000000)]
#unlink(wav.files.empty)


####### Remove any empty folders ######## 
####### Add dashes after shorter site names to make all filenames really start on 10th character
# 
# setwd('/Volumes/Gabon1/')
# base <- '/Volumes/Gabon1/'
# 
# site.folders <- list.files()
# #for (i in 33:length(site.folders)) {
#   
#   # Now filter out just folders containing days of recordings  
#   
#   site.name <-  site.folders[i]
#   setwd(paste(base,'/',site.name,sep=''))
#   day.site.folders <- dir()
#   
#   for (j in 1:length(day.site.folders)) {
#     setwd(paste(base,'/',site.name,sep=''))
#     setwd(day.site.folders[j])
#     day.site.files <- dir()
#     
#     if (length(day.site.files)!=0) {
# 
#     if (nchar(site.name)==4) {
#         file.rename(day.site.files, gsub('^(.{5})(.*)$', '\\1____\\2', day.site.files))}
#       
#     if (nchar(site.name)==5) {
#       file.rename(day.site.files, gsub('^(.{6})(.*)$', '\\1___\\2', day.site.files))}
#     
#     if (nchar(site.name)==6) {
#       file.rename(day.site.files, gsub('^(.{7})(.*)$', '\\1__\\2', day.site.files))} 
#     
#     if (nchar(site.name)==7) {
#       file.rename(day.site.files, gsub('^(.{8})(.*)$', '\\1_\\2', day.site.files))}
#     }}
# }
# 
# 
# ####### Now focus on renaming files to one standard convention 
# 
# setwd('/Volumes/Gabon2/')
# files <-list.files(full.names=FALSE, recursive=TRUE,include.dirs=FALSE)
# just.file.names <- unlist(lapply(strsplit(files,'/'),function(x) x[[3]]))
# just.file.paths <- paste(unlist(lapply(strsplit(files,'/'),function(x) x[[1]])),'/',
#                          unlist(lapply(strsplit(files,'/'),function(x) x[[2]])),'/',sep='')
# 
# file.lengths <- nchar(just.file.names)
# plot(file.lengths)
# 
# # Rename files starting with S0 
# 
# setwd('/Volumes/Gabon2/')
# files <-list.files(full.names=FALSE, recursive=TRUE,include.dirs=FALSE)
# just.file.names <- unlist(lapply(strsplit(files,'/'),function(x) x[[3]]))
# just.file.paths <- paste(unlist(lapply(strsplit(files,'/'),function(x) x[[1]])),'/',
#                          unlist(lapply(strsplit(files,'/'),function(x) x[[2]])),'/',sep='')
# 
# file.rename(paste(just.file.paths[which(substr(just.file.names,10,11)=='S0')],just.file.names[which(substr(just.file.names,10,11)=='S0')],sep=''),
#             paste(just.file.paths[which(substr(just.file.names,10,11)=='S0')],
#                   substr(just.file.names[which(substr(just.file.names,10,11)=='S0')],1,9),
#                   substr(just.file.names[which(substr(just.file.names,10,11)=='S0')],13,27),
#                   '.wav',sep=''))
#             
# # Rename files starting with S
# 
# 
# setwd('/Volumes/Gabon2/')
# files <-list.files(full.names=FALSE, recursive=TRUE,include.dirs=FALSE)
# just.file.names <- unlist(lapply(strsplit(files,'/'),function(x) x[[3]]))
# just.file.paths <- paste(unlist(lapply(strsplit(files,'/'),function(x) x[[1]])),'/',
#                          unlist(lapply(strsplit(files,'/'),function(x) x[[2]])),'/',sep='')
# 
# file.rename(paste(just.file.paths[which(substr(just.file.names,10,10)=='S')],just.file.names[which(substr(just.file.names,10,10)=='S')],sep=''),
#             paste(just.file.paths[which(substr(just.file.names,10,10)=='S')],
#                   substr(just.file.names[which(substr(just.file.names,10,10)=='S')],1,9),
#                   gsub('T','_',substr(just.file.names[which(substr(just.file.names,10,10)=='S')],11,25)),
#                   '.wav',sep=''))
# 
# # Rename files with Makokou
# 
# setwd('/Volumes/Gabon2/')
# files <-list.files(full.names=FALSE, recursive=TRUE,include.dirs=FALSE)
# just.file.names <- unlist(lapply(strsplit(files,'/'),function(x) x[[3]]))
# just.file.paths <- paste(unlist(lapply(strsplit(files,'/'),function(x) x[[1]])),'/',
#                          unlist(lapply(strsplit(files,'/'),function(x) x[[2]])),'/',sep='')
# 
# file.rename(paste(just.file.paths[grep('Makokou',just.file.names)],just.file.names[grep('Makokou',just.file.names)],sep=''),
#             paste(just.file.paths[grep('Makokou',just.file.names)],
#                   substr(just.file.names[grep('Makokou',just.file.names)],1,9),
#                   gsub('T','_',substr(just.file.names[grep('Makokou',just.file.names)],10,24)),
#                   '.wav',sep=''))
# 
# # Crop all files to correct length
# 
# setwd('/Volumes/Gabon1/')
# files <-list.files(full.names=FALSE, recursive=TRUE,include.dirs=FALSE)
# just.file.names <- unlist(lapply(strsplit(files,'/'),function(x) x[[3]]))
# just.file.paths <- paste(unlist(lapply(strsplit(files,'/'),function(x) x[[1]])),'/',
#                          unlist(lapply(strsplit(files,'/'),function(x) x[[2]])),'/',sep='')
# 
# file.rename(paste(just.file.paths,just.file.names,sep=''),
#             paste(just.file.paths,
#                   substr(just.file.names,1,24),
#                   '.wav',sep=''))
# 
# 
# write.csv(just.file.names,file='/Users/bengottesman/Documents/testy5.csv')

# ##################### MOVE EVERYTHING TO ONE FLATTENED FOLDER  ###########
# 
# # DO WHAT DANTE SHOWED ME
# 
 library(filesstrings)
# 
# setwd('/Volumes/Gabon1/Bens_Macbook/CF/')
# files <-list.files(recursive=TRUE)
# file.move(files, '/Volumes/Gabon1/Bens_Macbook/CF_Flat/')
# 
# setwd('/Volumes/Gabon1/Bens_Macbook/IPA_Part1/')
# files <-list.files(recursive=TRUE)
# file.move(files, '/Volumes/Gabon1/Bens_Macbook/IPA_Part1_Flat/')
# 
# setwd('/Volumes/Gabon1/Bens_Macbook/IPA_Part2/')
# files <-list.files(recursive=TRUE)
# file.move(files, '/Volumes/Gabon1/Bens_Macbook/IPA_Part2_Flat/')

setwd('/Volumes/Gabon1/Work_Macbook/ROG/')
files <-list.files(recursive=TRUE)
file.move(files, '/Volumes/Gabon1/Work_Macbook/ROG_Flat/')

setwd('/Volumes/Gabon1/Work_Macbook/TBNI_Part2/')
files <-list.files(recursive=TRUE)
file.move(files, '/Volumes/Gabon1/Work_Macbook/TBNI_Flat/')
