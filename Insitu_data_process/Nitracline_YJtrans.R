### Power-transformation (Yeo-Johnson) for Natracline depth before anomalies calculation 
setwd('...')
nutrient<-read.csv('Final_raw_nitracline.csv',header=TRUE)   # output from Nitracline_beforeYJ.m 

#install.packages("bestNormalize")
library(bestNormalize)

#remove non-data part(description)
nitra<-as.numeric(nutrient$Nitracline)

# get the best lambda values
lambda<-yeojohnson(nitra)$lambda
nitradis<-yeojohnson(nitra)
nitrap <- predict(nitradis)
x2 <- predict(nitradis, newdata = nitrap, inverse = TRUE) # validation
all.equal(x2, nitra) #double check if the reverse-transformed data is the same 

#insert yj_trans values
trans_nitra<-cbind(nutrient,nitrap)
colnames(trans_nitra)<-c(colnames(nutrient),"yj_nitra")


#export table
setwd('...')
write.csv(trans_nitra,file=sprintf("YJ_Nitracline.csv"))

