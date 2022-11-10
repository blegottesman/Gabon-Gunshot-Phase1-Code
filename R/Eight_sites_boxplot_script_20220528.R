library(ggplot2) 
library(ggpubr)
library(tidyverse)
theme_set(theme_bw(18))

setwd('/Users/bengottesman/Documents/Work/Gabon/Methods/Gunshot_methods/monitoR/Eight_sites')

df<- read.csv('Dataframe_Guns_eight_site_detection_table.csv')
df$Time_rounded <- as.numeric(as.character(df$Time_rounded))
#alltimes <- c('-4','-3','-2','-1','0','1','2','3','4')
Hours <- c('0',"1",'2','3',"4","5",'6','7','8','9',"10","11","12","13","14","15","16","17","18","19","20", "21", "22","23")
alltimes <- Hours
levels(df$Time_rounded) <- alltimes
df$Treatment <- factor(df$Treatment,     # Reorder factor levels
                        c("LOG", "FSC","PP", "NP"))
df$Site <- factor(df$Site,     # Reorder factor levels
                       c("TBNI3ST", "TBNI1ST", 'ROG6','ROG7',"TBNI21ST",'TBNI24ST','IPA4ST','IPA8ST'))


# Barplot of gunshot times
tiff("/Users/bengottesman/Documents/Work/Gabon/Figures/Zuzana_Presentation/Barplot_times.tiff", units="in", width=7, height=5, res=300)
ggbarplot(df, x = "Time_rounded", y = "Gunshot", fill = 'Treatment', width = 0.5) + 
  xlab('Hour')+ ylab('Gunshots detected') + scale_x_discrete(labels= Hours) + 
  labs(title = "Time of gunshots", x = "Hour", y = "Gunshots detected") +
  scale_fill_manual(values = c("#F8766D", "#7CAE00",'#00BFC4','#C77CFF'), labels = c("Non-certified logging","FSC-certified logging", 'Proposed Protected Area','National Park'))+
  scale_x_discrete(drop = F)+theme(legend.title= element_blank()) 
dev.off()

# Barplot of sites 
tiff("/Users/bengottesman/Documents/Work/Gabon/Figures/Zuzana_Presentation/Barplot_sites.tiff", units="in", width=7, height=5, res=300)
ggbarplot(df2, x = "Site", y = "Gunshots", fill = 'Treatment', width = 0.5) + 
  xlab('Hour')+ ylab('Gunshots detected\n') + 
  labs(title = "Gunshots detected per site", x = "Site", y = "Gunshots detected") +
  scale_fill_manual(values = c('#F8766D', "#7CAE00",'#00BFC4','#C77CFF'), labels = c("Non-certified logging","FSC-certified logging", 'Proposed Protected Area','National Park'))+
  scale_x_discrete(drop = F) +  scale_y_continuous(limits=c(0, 9),breaks=c(0,3,6,9)) +theme(legend.title= element_blank())+
  theme(text = element_text(size = 11)) + theme(axis.text.x = element_text(size = 8))
dev.off()


df2<- read.csv('Dataframe_Gunshot_2.csv')
df2$Treatment <- factor(df2$Treatment,     # Reorder factor levels
                         c('Non-certified logging', 'FSC-certified logging', 'Proposed Protected Area','National Park'))
df2$Site <- factor(df2$Site,     # Reorder factor levels
                  c("TBNI3ST", "TBNI1ST", 'ROG6','ROG7',"TBNI21ST",'TBNI24ST','IPA4ST','IPA8ST'))

tiff("/Users/bengottesman/Documents/Work/Gabon/Figures/Zuzana_Presentation/Boxplot.tiff", units="in", width=7, height=5, res=300)
p <- ggplot(df2, aes(x=Treatment, y=Gunshots_per_day, fill=Treatment)) + 
  geom_boxplot() + xlab('\nLand use type')+ ylab('Gunshots per day\n') + theme(text = element_text(size = 12)) + 
  ggtitle('Gunshots rates vs. land use type') +theme(legend.title= element_blank()) + scale_x_discrete(labels = function(x) 
    stringr::str_wrap(x, width = 15))
p
dev.off()


