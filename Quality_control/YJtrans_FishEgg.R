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
 


# plot histograms of two indexes
hist(log10(sardine), breaks=1000,xlab = "Log10 sardine egg",ylab = "frequency")
hist(log10(anchovy), breaks=1000,xlab = "Log10 anchovy egg",ylab = "frequency")
hist(ancp,breaks=1000) #distribution of YJ transfromed data
hist(sarp,breaks=1000)

#check the data distribution
library(nortest)
ad.test(transformed_anchovy)   # the Anderson-Darling test for normality
install.packages("fitdistrplus")
library(fitdistrplus)
fit <- fitdist(transformed_anchovy, "norm")  # Fit a normal distribution
summary(fit)


#proportion of zero values
length(which(sardine==0))  #9671
length(which(anchovy==0))  #11384

#reduce the zeros in anchovy
zeros<-anchovy[which(anchovy==0)]
anchovy2=anchovy[-zeros[1:10000]]
a<-anchovy[which(anchovy!=0)]




