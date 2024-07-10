###calculate anomaly of CalCOFI ZooScan data
setwd('.../CalCOFI/Fish')
#fish<-read.csv('FishLarve.csv',header=TRUE) #datasheet generated from clean_FishLarvae.m 
fish<-read.csv('FishLarve1215.csv',header=TRUE) 

#remove non-data part(description)
sardine<-as.numeric(fish$sardine)
anchovy<-as.numeric(fish$anchovy)


# get the best lambda values
#install.packages("bestNormalize")
library(bestNormalize)
lambda<-yeojohnson(sardine)$lambda
sardis<-yeojohnson(sardine) #lambda:-2.6
ancdis<-yeojohnson(anchovy) #lambda:-0.42
sarp <- predict(sardis)
ancp<- predict(ancdis)
x2 <- predict(sardis, newdata = sarp, inverse = TRUE) # validation
x3<- predict(ancdis, newdata = ancp, inverse = TRUE) # validation
all.equal(x2, sardine) #double check if the reverse-transformed data is the same 
all.equal(x3, anchovy) # floating point precision


#insert yj_trans values
trans_fish<-cbind(fish,sarp,ancp)
colnames(trans_fish)<-c(colnames(fish),"yj_sardine","yj_anchovy")

#export table
setwd('.../CalCOFI/Fish')
write.csv(trans_fish,file=sprintf("YJ_FishLarve1215.csv"))

#proportion of zero values
length(which(sardine==0))  #10577
length(which(anchovy==0))  #7328
