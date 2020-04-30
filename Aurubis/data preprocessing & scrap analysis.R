rm(list = ls())
getwd()
setwd("/Users/apple/Desktop/BAprojects/data")
library(tidyverse)
library(ggplot2)
library(lubridate)
library(earth)
library(rpivotTable)
library(dummies)

#####import data#####
coilHsty = read_csv('coilHistory.csv')
oprDtl = read_csv('OperationsDetail.csv')

#####make a copy#####
coilHstyCopy = coilHsty
oprDtlCopy = oprDtl

#####delete useless columns#####
coilHsty[,82:124] = NULL
coilHsty[,c(2,8,11,13,14,18,19,20,23,24,25,26,27,28,29,30,31,36,43,44,48,56,61,68,73)] = NULL

oprDtl[,27:54] = NULL
oprDtl[,19:25] = NULL

#########################
#####caculate yield######
#########################

yield = coilHsty[,c('INVID#','INSGWT','INFGWT')]

for (i in 1:length(yield$`INVID#`)){
  if (yield$INSGWT[i] < yield$INFGWT[i] & yield$INSGWT!=0){
    yield$INSGWT[i] = yield$INFGWT[i]  ###replace starting weight with finishing weight when starting is less than finishing and finishing weight is not 0
  }
}

yield$INSSTA<-coilHsty$INSSTA

#####calculate yield for each coil#####
for (ID in unique(substr(yield$`INVID#`,1,6))){
  IDtmp = yield[substr(yield$`INVID#`,1,6) == ID,]
  yield$STGWT[substr(yield$`INVID#`,1,6) == ID] = IDtmp[1,2]
  birth<-sum(IDtmp$INSGWT[IDtmp$INSSTA=='BIRTH' & IDtmp$INFGWT==0])
  wt<-sum(IDtmp$INSGWT[nchar(IDtmp$`INVID#`)==max(nchar(IDtmp$`INVID#`)) & IDtmp$INFGWT==0 &IDtmp$INSGWT!=0])
  yield$FNGWT[substr(yield$`INVID#`,1,6) == ID] = birth+wt
}

yld<-yield
yld$STGWT<-as.numeric(yld$STGWT)
yld$yield<-yld$FNGWT/yld$STGWT

######aggregate yield by each coil######
aggyield<-as.data.frame(matrix(NA,19084,2))
aggyield$V1 <- unique(substr(yld$`INVID#`,1,6))
for (i in 1:length(aggyield$V1)){
  aggyield$V2[i]<-yld$yield[substr(yld$`INVID#`,1,6)==aggyield$V1[i]]
}

###########################
#####Variable Cleaning#####
###########################

#####elapsed time######
elap<-coilHstyCopy[,c(1,81)]
ch_elap<-as.data.frame(matrix(NA,19084,2))
ch_elap$V1<-unique(substr(elap$`INVID#`,1,6))
for (ID in unique(substr(elap$`INVID#`,1,6))){
    ch_elap$V2[substr(ch_elap$V1,1,6) == ID]<- sum(elap$INELAP[substr(elap$`INVID#`,1,6) == ID])
  }
colnames(ch_elap)<-c('INVID#','INELAP')

#######number of steps######

step<-coilHstyCopy[,1]
ch_step<-as.data.frame(matrix(NA,19084,2))
ch_step$V1<-unique(substr(step$`INVID#`,1,6))
for (ID in unique(substr(step$`INVID#`,1,6))){
  ch_step$V2[substr(ch_step$V1,1,6) == ID]<- length(step$`INVID#`[substr(step$`INVID#`,1,6) == ID])
}
colnames(ch_step)<-c('INVID#','steps')

#######start weight########

stgwt<-coilHstyCopy[,c(1,47)]
ch_stgwt<-as.data.frame(matrix(NA,19084,2))
ch_stgwt$V1<-unique(substr(stgwt$`INVID#`,1,6))
for (ID in unique(substr(stgwt$`INVID#`,1,6))){
  ch_stgwt$V2[substr(ch_stgwt$V1,1,6) == ID]<- stgwt[substr(stgwt$`INVID#`,1,6) == ID,][1,2]
}
colnames(ch_stgwt)<-c('INVID#','weight')

#######start width#########
stwid<-coilHstyCopy[,c(1,40)]
ch_stwid<-as.data.frame(matrix(NA,19084,2))
ch_stwid$V1<-unique(substr(stwid$`INVID#`,1,6))
for (ID in unique(substr(stwid$`INVID#`,1,6))){
  ch_stwid$V2[substr(ch_stwid$V1,1,6) == ID]<- stwid[substr(stwid$`INVID#`,1,6) == ID,][1,2]
}
colnames(ch_stwid)<-c('INVID#','width')

########start gauge#########
stgau<-coilHstyCopy[,c(1,41)]
ch_stgau<-as.data.frame(matrix(NA,19084,2))
ch_stgau$V1<-unique(substr(stgau$`INVID#`,1,6))
for (ID in unique(substr(stgau$`INVID#`,1,6))){
  ch_stgau$V2[substr(ch_stgau$V1,1,6) == ID]<- stgau[substr(stgau$`INVID#`,1,6) == ID,][1,2]
}
colnames(ch_stgau)<-c('INVID#','gauge')

########alloy###########

alloy<-coilHstyCopy[,c(1,15)]
ch_alloy<-as.data.frame(matrix(NA,19084,2))
ch_alloy$V1<-unique(substr(alloy$`INVID#`,1,6))
for (ID in unique(substr(alloy$`INVID#`,1,6))){
  ch_alloy$V2[substr(ch_alloy$V1,1,6) == ID]<- alloy[substr(alloy$`INVID#`,1,6) == ID,][1,2]
}
colnames(ch_alloy)<-c('INVID#','alloy')
save(ch_alloy,file="/Users/apple/Desktop/BA projects/data/ch_alloy.Rdata")

########start date(month)#######
date<-coilHstyCopy[,c(1,45)]
ch_date<-as.data.frame(matrix(NA,19084,2))
ch_date$V1<-unique(substr(date$`INVID#`,1,6))
for (ID in unique(substr(date$`INVID#`,1,6))){
  ch_date$V2[substr(ch_date$V1,1,6) == ID]<- month(ymd(date[substr(date$`INVID#`,1,6) == ID,][1,2]))
}
colnames(ch_date)<-c('INVID#','month')

#######machine number########
####insnxu####
mach<-coilHstyCopy[,c(1,35)]
length(unique(mach$INSNXU))

length(unique(tolower(mach$INSNXU))) #55
ch_mach<-as.data.frame(matrix(NA,19084,56))
ch_mach$V1<-unique(substr(mach$`INVID#`,1,6))
dum<-cbind(mach,dummy(tolower(mach$INSNXU),sep='_'))
colnames(ch_mach)[2:56]<-colnames(dum)[3:57]

for (i in (1:length(colnames(dum)[3:57]))){
  ch_mach[1+i]<-aggregate(dum[2+i], by=list(INVID=substr(dum$`INVID#`,1,6)), FUN=sum)[,2] ##frequency for each machine
}


####minor location######
minl<-coilHstyCopy[,c(1,17)]
length(unique(tolower(minl$INMINL))) #174
ch_minl<-as.data.frame(matrix(NA,19084,175))
ch_minl$V1<-unique(substr(minl$`INVID#`,1,6))
dum_minl<-cbind(minl,dummy(tolower(minl$INMINL),sep='_'))
colnames(ch_minl)[2:175]<-colnames(dum_minl)[3:176]

for (i in (1:length(colnames(dum_minl)[3:176]))){
  ch_minl[1+i]<-aggregate(dum_minl[2+i], by=list(INVID=substr(dum_minl$`INVID#`,1,6)), FUN=max)[,2] #whether this location appears for each coil
}

#####heat#####

heat<-coilHstyCopy[,c(1,9)]
ch_heat<-as.data.frame(matrix(NA,19084,2))
ch_heat$V1<-unique(substr(heat$`INVID#`,1,6))
for (ID in unique(substr(heat$`INVID#`,1,6))){
  ch_heat$V2[substr(ch_heat$V1,1,6) == ID]<- heat[substr(heat$`INVID#`,1,6) == ID,][1,2]
}
colnames(ch_heat)<-c('INVID#','heat')

#####density#####
den<-coilHstyCopy[,c(1,4)]
ch_den<-as.data.frame(matrix(NA,19084,2))
ch_den$V1<-unique(substr(den$`INVID#`,1,6))
for (ID in unique(substr(den$`INVID#`,1,6))){
  ch_den$V2[substr(ch_den$V1,1,6) == ID]<- den[substr(den$`INVID#`,1,6) == ID,][1,2]
}
colnames(ch_den)<-c('INVID#','density')


#####active code######
act<-coilHstyCopy[,c(1,37)]
length(unique(act$INSACT)) #4
ch_act<-as.data.frame(matrix(NA,19084,5))
ch_act$V1<-unique(substr(act$`INVID#`,1,6))
dum2<-cbind(act,dummy(act$INSACT,sep='_'))
colnames(ch_act)[2:5]<-colnames(dum2)[3:6]

for (i in (1:length(colnames(dum2)[3:6]))){
  ch_act[1+i]<-aggregate(dum2[2+i], by=list(INVID=substr(dum2$`INVID#`,1,6)), FUN=sum)[,2] #frequency of active code for each coil
}


#####finish gauge######
fgau<-coilHstyCopy[,c(1,66)]
ch_fgau<-as.data.frame(matrix(NA,19084,2))
ch_fgau$V1<-unique(substr(fgau$`INVID#`,1,6))
for (ID in unique(substr(fgau$`INVID#`,1,6))){
  ch_fgau$V2[substr(ch_fgau$V1,1,6) == ID]<- last(fgau[substr(fgau$`INVID#`,1,6) == ID,][,2])
}
colnames(ch_fgau)<-c('INVID#','finish_gauge')

#####status code#####
sta<-coilHstyCopy[,c(1,38)]
length(unique(sta$INSSTA)) #17
ch_sta<-as.data.frame(matrix(NA,19084,18))
ch_sta$V1<-unique(substr(sta$`INVID#`,1,6))
dum3<-cbind(sta,dummy(sta$INSSTA,sep='_'))
colnames(ch_sta)[2:18]<-colnames(dum3)[3:19]

for (i in (1:length(colnames(dum3)[3:19]))){
  ch_sta[1+i]<-aggregate(dum3[2+i], by=list(INVID=substr(dum3$`INVID#`,1,6)), FUN=sum)[,2] #frequency of status code for each coil
}
ch_sta$sta_NA<-NULL


#####number of orders for each coil######
ord<-coilHstyCopy[,c(1,32)]
length(unique(ord$INSENT)) #11386
ch_ord<-as.data.frame(matrix(NA,19084,2))
ch_ord$V1<-unique(substr(ord$`INVID#`,1,6))

for (i in 1:length(ch_ord$V1)){
  ch_ord$V2[i] = length(unique(ord$INSENT[substr(ord$`INVID#`,1,6) == ch_ord$V1[i]]))
}
colnames(ch_ord)<-c('INVID#','num_order')

#####scale#####
sca<-coilHstyCopy[,c(1,51)]
length(unique(sca$INSSCL)) #8
ch_sca<-as.data.frame(matrix(NA,19084,9))
ch_sca$V1<-unique(substr(sca$`INVID#`,1,6))
dum4<-cbind(sca,dummy(sca$INSSCL,sep='_'))
colnames(ch_sca)[2:9]<-colnames(dum4)[3:10]

for (i in (1:length(colnames(dum4)[3:10]))){
  ch_sca[1+i]<-aggregate(dum4[2+i], by=list(INVID=substr(dum4$`INVID#`,1,6)), FUN=sum)[,2] #frequency of scale for each coil
}
ch_sca$sca_NA<-NULL

######combine data together######

ch_m<-ch_elap
ch_m$steps<- ch_step$steps
ch_m$weight<-as.numeric(ch_stgwt$weight)
ch_m$width<-as.numeric(ch_stwid$width)
ch_m$gauge<-as.numeric(ch_stgau$gauge)
ch_m$alloy<-as.numeric(ch_alloy$alloy)
ch_m$month<-ch_date$month
ch_m$yield<-aggyield$V2

ch_m_all<-cbind(ch_m,ch_heat[2])
ch_m_all<-cbind(ch_m_all,ch_date[2])
ch_m_all<-cbind(ch_m_all,ch_den[2])
ch_m_all<-cbind(ch_m_all,ch_fgau[2])
ch_m_all<-cbind(ch_m_all,ch_act[2:5])
ch_m_all<-cbind(ch_m_all,ch_sta[2:17])
ch_m_all<-cbind(ch_m_all,ch_sca[2:8])
ch_m_all<-cbind(ch_m_all,ch_ord[2])
ch_m_all<-cbind(ch_m_all,ch_mach[2:57])
ch_m_all<-cbind(ch_m_all,ch_minl[2:175])

#delete useless rows
ch_m_all<-ch_m_all[ch_m_all$`INVID#`!='TIN',]
ch_m_all<-ch_m_all[ch_m_all$yield<=1,]
ch_m_all<-ch_m_all[is.na(ch_m_all$alloy)==FALSE,]

#delete useless columns & convert some columns as numeric
ch_m_all$minl_NA<-NULL
ch_m_all$minl_xx<-NULL
ch_m_all$mach_NA<-NULL
ch_m_all$`minl_??`<-NULL
ch_m_all$`minl_???`<-NULL
ch_m_all$mach_xxx<-NULL
ch_m_all$heat<-as.numeric(ch_m_all$heat)
ch_m_all$density<-as.numeric(ch_m_all$density)
ch_m_all$finish_gauge<-as.numeric(ch_m_all$finish_gauge)
ch_m_all$num_order<-as.numeric(ch_m_all$num_order)
ch_m_all<-ch_m_all[is.na(ch_m_all$heat)==FALSE,]

######save data#####
save(ch_m_all,file="/Users/apple/Desktop/BAprojects/data/ch_all.Rdata")
write.csv(ch_m_all,"ch_all.csv",row.names = FALSE)

########################
#####scrap analysis#####
########################

smdb_4 = read_csv('~/Documents/Aurubis/ch_all.csv')
scra <- smdb_4[,1:40] ## delete all the machine number variables
scra$lossrate <- 0
scra$whe_scrap <- 0 ## whe_scrap is whether the coil has scrap or not
for (i in 1:nrow(scra)){
  temp = yield[gsub("[A-Z]+","",yield$`INVID#`)==scra$`INVID#`[i],]
  temp = temp[temp$INSSTA=="SCRAP",]
  if (nrow(temp)==0){
    next
  }else{
    scra$lossrate[i] = sum(temp[,6]) ## loss rate is the sum of loss weight caused by scrap within one coil
    scra$whe_scrap[i] = 1
  }
}

scra$total_loss <- 1-scra$yield ## total loss is all the loss weight within one coil
names(scra)[41] = "scrap_loss"
scra$loss_rate <- scra$scrap_loss/scra$total_loss ## the proportion of loss weight of scrap in total loss weight

### correction for inf
scra$loss_rate[which(scra$loss_rate==Inf)] = NA
copyscra <- scra

### correction for total loss equals to 1
scra$loss_rate[which(scra$total_loss==1 & scra$loss_rate>1)] = 1

#### extract all the row containts scrap
mean_scra_loss <- mean(scra$loss_rate[which(scra$loss_rate>=0 & scra$loss_rate <=1)]) #0.01346135
mean(scra$loss_rate[which(scra$loss_rate>0 & scra$loss_rate <=1)])  #0.2011385
agg_scra <- scra[which(scra$loss_rate>0 & scra$loss_rate <=1),]

scrap_rate <- sum(scra$whe_scrap)/nrow(scra) ##6.88% of coil will have scraps

### descriptive analysis of scrap
agg_scra$alloy <- as.numeric(agg_scra$alloy)

for (i in 1:nrow(agg_scra)){
  agg_scra$alloy[i]=as.numeric(strsplit(as.character(agg_scra$alloy[i]),"")[[1]][1])
}
agg_scra$alloy = as.factor(agg_scra$alloy)
write.csv(agg_scra,file="~/Documents/Aurubis/agg_scra.csv",quote=F,row.names = F)

library(ggplot2)
ggplot(agg_scra[agg_scra$loss_rate <= 1,],aes(width,loss_rate)) + geom_point(aes(width,loss_rate),colour = 'blue',alpha = 0.3) +
  geom_smooth(method = "auto",colour = 'orange')
ggplot(agg_scra[agg_scra$loss_rate <= 1,],aes(alloy,loss_rate)) + geom_point(aes(alloy,loss_rate),colour = 'blue',alpha = 0.3) +
  geom_smooth(method = "auto",colour = 'orange')

### loss rate of different alloy
scra$alloy <- as.numeric(scra$alloy)

for (i in 1:nrow(scra)){
  scra$alloy[i]=as.numeric(strsplit(as.character(scra$alloy[i]),"")[[1]][1])
}
nrow(scra[scra$whe_scrap==1 & scra$alloy==1,])/nrow(scra[scra$alloy==1,])
nrow(scra[scra$whe_scrap==1 & scra$alloy==2,])/nrow(scra[scra$alloy==2,])
nrow(scra[scra$whe_scrap==1 & scra$alloy==4,])/nrow(scra[scra$alloy==4,])
nrow(scra[scra$whe_scrap==1 & scra$alloy==5,])/nrow(scra[scra$alloy==5,])
nrow(scra[scra$whe_scrap==1 & scra$alloy==6,])/nrow(scra[scra$alloy==6,])
nrow(scra[scra$whe_scrap==1 & scra$alloy==7,])/nrow(scra[scra$alloy==7,])

mean(smdb_4$yield)
mean(agg_scra$yield)




