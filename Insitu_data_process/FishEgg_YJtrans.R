###calculate anomaly of CalCOFI ZooScan data
#import data(output from FishEgg_beforeYJ.m)
setwd('.../output')
fish<-read.csv('CleanIntegrated_FishEgg.csv',header=TRUE) 

#remove non-data part(description)
sardine<-as.numeric(fish$sardine)
anchovy<-as.numeric(fish$anchovy)

# get the best lambda values
#install.packages("bestNormalize")
library(bestNormalize)
lambda<-yeojohnson(sardine)$lambda
sardis<-yeojohnson(sardine)
ancdis<-yeojohnson(anchovy,lambda=lambda) 
# anchovy eggs have bad lambda value (-3.484 or-4.15, which should be 2~-2 for optimal range), so alternatively use lamda value of sardine eggs
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
setwd('.../output')
write.csv(trans_fish,file=sprintf("YJ_FishEgg.csv"))
