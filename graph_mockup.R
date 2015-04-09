# https://www.nexis.com/api/version1/sr?oc=00240&shr=t&crth=broad&nonLatin1Chars=true&hac=f&sr=%28%28ATL3%28%22Climate+change%22%29%29%29+and+DATE%28%3E%3D2014-03-28%29+and+not+PUBLICATION-TYPE%28Newswire+or+d%C3%A9p%C3%AAche+or+Presseagentur+or+Agencia+or+Agenzia+or+Persbureau%29&scl=t&hct=f&csi=138620%2C6742&secondRedirectIndicator=true#0||BOOLEAN|||search.common.threshold.broadrange|

library(XML)
library(plyr)
library(ggplot2)
library(reshape2)
library(scales)

DF = data.frame( outlet = character(), date = character())

for(i in 1:length(list.files("RAW/"))){
  file = list.files("RAW/")[i];
  print (file);
  
  tp <- htmlTreeParse(paste("RAW/",file,sep=""), useInternal=T)
  tpu <- unlist(xpathApply(tp, '//div', xmlValue))
  tpuNOs = gsub('\\n', ' ', tpu)                          # Replace all \n by spaces
  
  for(x in 1:length(tpuNOs)){
    if(regexpr("\\d+\\s\\w+\\s\\d+\\sDOCUMENTS", tpuNOs[x], perl=TRUE)[1] >= 0){
      outlet = tpuNOs[x+1];
      date = tpuNOs[x+2];
      title = tpuNOs[x+3];
    }
    else if(regexpr("LENGTH:\\s\\d+\\s\\w+", tpuNOs[x], perl=TRUE)[1] >= 0) {
      #text = ifelse(outlet=="The Analyst", tpuNOs[x+2], tpuNOs[x+1]);
      df = data.frame(outlet=outlet, date=date, title=title);
      DF = rbind.data.frame(DF, df)  
    }
  }
  
  print("....done.");
  
}
head(DF)


DF_work <- DF

## OUTLET
DF_work[unlist(lapply(DF_work$outlet, function(x){(regexpr(".*GUARDIAN.*", toupper(x), perl=TRUE)[1] >= 0)})),"PUBL"] <- "The Guardian"
DF_work[unlist(lapply(DF_work$outlet, function(x){(regexpr(".*NEW YORK.*", toupper(x), perl=TRUE)[1] >= 0)})),"PUBL"] <- "The New York Times"
DF_work$PUBL <- as.factor(DF_work$PUBL)

## DATE
DF_work$PUBDATE <- as.Date(DF_work[,"date"], format="%B %d, %Y")
DF_work$PUBWEEK <- format(DF_work$PUBDATE, format="%U")
DF_work$PUBYEAR <- format(DF_work$PUBDATE, format="%Y")
DF_work$MONDATE <- as.Date(paste("1",DF_work$PUBWEEK,DF_work$PUBYEAR,sep="."),format("%w.%W.%Y"))

## PLOT
BTNtheme <- theme_bw() + 
  theme(text=element_text(size=20), legend.position="top", 
        panel.border = element_blank(), legend.key = element_blank(),
        panel.grid.major = element_line(color="black")) 

col <- c("#5F9F9F","#ec7014")

ggplot(DF_work, aes(x=MONDATE, y=..count.., color=PUBL)) + 
  geom_point(stat="bin", size=4) + 
  scale_x_date(labels = date_format("%b"), breaks = date_breaks("months")) +
  geom_line(aes(x=MONDATE, y=..count..,group=PUBL, color=PUBL),stat="bin", position="identity", size=1.2) +
  scale_color_manual(values=col) +
  guides(colour = guide_legend(nrow = 1, byrow = T, title=NULL)) +
  ylab("") + xlab("") +
  BTNtheme



