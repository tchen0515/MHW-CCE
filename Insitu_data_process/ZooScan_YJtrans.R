### Power-transformation (Yeo-Johnson) for ZooScan taxon -specific data
# This dataset does not have beforeYJ.m, this R code is the first part of process 
# raw data are available at https://oceaninformatics.ucsd.edu/zooscandb/
# when downloading the raw csv file, please make sure get all taxa (option: plot all taxa individually)

setwd('...')
zooall<-read.csv("PROPOOS_data_export_1721486427.762124.csv",header=FALSE) % https://oceaninformatics.ucsd.edu/zooscandb/

#download required packages
library(tidyverse)
library(bestNormalize)

#remove non-data part(description)
colnames(zooall)<-zooall[3,]  
zooall<-zooall[-c(1:3),]

#select the targeted taxa

zooall_2<-select(zooall,colnames(zooall[,1:7]),c("copepoda_calanoida Abundance (No. per m2)"
,"copepoda_eucalanids Abundance (No. per m2)"
,"copepoda_harpacticoida Abundance (No. per m2)"
,"copepoda_oithona_like Abundance (No. per m2)"
,"copepoda_poecilostomatoids Abundance (No. per m2)"
,"doliolids Abundance (No. per m2)"
,"euphausiids Abundance (No. per m2)"
,"nauplii Abundance (No. per m2)" 	
,"pyrosomes Abundance (No. per m2)"
,"salps Abundance (No. per m2)"))
# alter taxa column name into shorter form
colnames(zooall_2)<-c(colnames(zooall[,1:7]),"calanoida","eucalanids","harpacticoida"
,"oithona","poecilostomatoids","doliolids"
,"euphausiids","nauplii","pyrosomes","salps")

# calculate power-transformed abundance for each taxa
trans_zoo<-matrix(data=NA,nrow=nrow(zooall),ncol=10)
for (i in 8:17){
  y<-as.numeric(zooall_2[,i])
  # get the best lambda values
  lambda<-yeojohnson(y)$lambda
  dis<-yeojohnson(y)
  p <- predict(dis)
  x2 <- predict(dis, newdata = p, inverse = TRUE) # validation
  
  #all.equal(x2, y) #double check if the reverse-transformed data is the same 
  
  #insert yj_trans values
  trans_zoo[,i-7]<-p
}
# assort data table
colnames(trans_zoo)<-c(colnames(zooall_2[,8:17]))
yj_zoo<-cbind(zooall_2[,1:7],trans_zoo)


#export table
setwd('...')
write.csv(yj_zoo,file="YJ_ZooScanAll.csv")

