# Rename sound files to include site name. This will make sure we don't have any doubles

setwd('/Volumes/Gabon1/')
base <- '/Volumes/Gabon1/'

# Remove all non-wav files 

#files.to.remove <- setdiff(list.files(recursive=TRUE),list.files(recursive=TRUE,pattern='.wav'))
#file.remove(files.to.remove)

# Go into site folders

site.folders <- list.files()
for (i in 33:length(site.folders)) {

 # Now filter out just folders containing days of recordings  
  
 site.name <-  site.folders[i]
 setwd(paste(base,'/',site.name,sep=''))
 day.site.folders <- dir()

for (j in 1:length(day.site.folders)) {
 setwd(paste(base,'/',site.name,sep=''))
 setwd(day.site.folders[j])
 day.site.files <- dir()
 file.rename(day.site.files, paste(site.name,'_',day.site.files,sep=''))
}
 }
