###calculate anomaly of CalCOFI ZooScan data
setwd('C:/Users/Tz-Chian Chen/OneDrive - Florida State University/CalCOFI/Fish')
#fish<-read.csv('FishEgg_025grid.csv',header=TRUE) #datasheet generated from convertDaily_FishhEgg.m 
fish<-read.csv('integrated_FishEgg_025grid.csv',header=TRUE) 

#remove non-data part(description)
sardine<-as.numeric(fish$sardine)
anchovy<-as.numeric(fish$anchovy)


# get the best lambda values
#install.packages("bestNormalize")
library(bestNormalize)
lambda<-yeojohnson(sardine)$lambda
sardis<-yeojohnson(sardine)
ancdis<-yeojohnson(anchovy,lambda=lambda) # fishegg: still bad lambda value,-3.484 or-4.15 for0.25grid
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
setwd('C:/Users/Tz-Chian Chen/OneDrive - Florida State University/CalCOFI/Fish')
write.csv(trans_fish,file=sprintf("YJ_FishEgg_025grid_1215.csv"))

# Install and load the 'MASS' package
#detach("package:MASS",unload=TRUE)
#install.packages("MASS")
#library(MASS)

# manually transform YJ-anchovy
#ancp <- numeric(length(anchovy))
#for (i in 1:length(anchovy)) {
# if (anchovy[i] >= 0) {
#    ancp[i] <- ((anchovy[i] + 1)^lambda - 1) / lambda
#  } else {
#    ancp[i] <- -((-(anchovy[i] + 1)^lambda - 1) / lambda)
#  }
#}
 


#proportion of zero values
length(which(sardine==0))  #9671
length(which(anchovy==0))  #11384






