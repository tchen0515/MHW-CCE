### Yeo-Johnson transformation for CalCOFI nitracline data calculating anomaly 
setwd('C:/Users/Tz-Chian Chen/OneDrive - Florida State University/CalCOFI/other')
nutrient<-read.csv('Final_nitracline.csv',header=TRUE)   #datasheet generated from nitracline.m 

#remove non-data part(description)
nitra<-as.numeric(nutrient$Nitracline)

# get the best lambda values
#install.packages("bestNormalize")
library(bestNormalize)
lambda<-yeojohnson(nitra)$lambda
nitradis<-yeojohnson(nitra)
nitrap <- predict(nitradis)
x2 <- predict(nitradis, newdata = nitrap, inverse = TRUE) # validation
all.equal(x2, nitra) #double check if the reverse-transformed data is the same 

#insert yj_trans values
trans_nitra<-cbind(nutrient,nitrap)
colnames(trans_nitra)<-c(colnames(nutrient),"yj_nitra")


#export table
setwd('C:/Users/Tz-Chian Chen/OneDrive - Florida State University/CalCOFI/other')
write.csv(trans_nitra,file=sprintf("YJ_Nitracline.csv"))

