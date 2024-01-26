###calculate anomaly of CalCOFI ZooScan data
path_zoo<-('C:/Users/Tz-Chian Chen/OneDrive - Florida State University/CalCOFI/Zoo/ZooScan')
list=dir(path_zoo,".csv")
setwd('C:/Users/Tz-Chian Chen/OneDrive - Florida State University/CalCOFI/Zoo/ZooScan')
list[26]
zooall<-read.csv(list[26],header=FALSE)

gname<-"rhizaria"
#remove non-data part(description)
colnames(zooall)<-zooall[3,]
zooall<-zooall[-c(1:3),]
y<-as.numeric(zooall$`Abundance (No. per m2)`)

# get the best lambda values
#install.packages("bestNormalize")
library(bestNormalize)
lambda<-yeojohnson(y)$lambda
dis<-yeojohnson(y)
p <- predict(dis)
x2 <- predict(dis, newdata = p, inverse = TRUE) # validation

all.equal(x2, y) #double check if the reverse-transformed data is the same 

#insert yj_trans values
trans_zoo<-cbind(zooall,p)
colnames(trans_zoo)<-c(colnames(zooall),"yj_Abundance")

#export table
setwd('C:/Users/Tz-Chian Chen/OneDrive - Florida State University/CalCOFI/Zoo/yj_ZooScan')
write.csv(trans_zoo,file=sprintf("YJ_%s.csv",gname))






#read any Matlab output in R
install.packages("R.matlab")
library(R.matlab)
readMat()

#yeo-johnson transformation
#install.packages("VGAM")
#library(VGAM)
#psi <- matrix(0,length(y),1)
#for (ii in 1:lltry)
#  psi[ii,] <- yeo.johnson(y[ii], lambda)



# installing/loading the package:
if(!require(installr)) {
  install.packages("installr"); 
  require(installr)
} #load / install+load installr
# using the package:
updateR()