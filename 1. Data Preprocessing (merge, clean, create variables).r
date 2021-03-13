WD="C:/Users/xsyu/Desktop/organized code"
setwd(WD)

###################################################
# process/creat hospital and HSA level covariates #
###################################################
Patient0814 <- read.csv("data/cabg08_14_v23.csv", stringsAsFactors=FALSE)
Hospital0814 <- read.csv("data/cabg08_14_hosp_level.csv", stringsAsFactors=FALSE)
temp <- read.csv("data/useful variables.csv", stringsAsFactors=FALSE)
Variable_HSA=temp$Variable.Name[1:23]
Variable_Hospital=temp$Variable.Name[24:34]

###select the variables used in the 2016 paper about outcome
Variable_HSA=Variable_HSA[c(c(1,11,10,18,15,19),c(20,21,22,23))]
Variable_Hospital=Variable_Hospital[c(1,2,5,6)]

###find the variables not in the hospital level data
Variable_HSA_missing=Variable_HSA[!Variable_HSA%in%names(Hospital0814)]
Variable_Hospital_missing=Variable_Hospital[!Variable_Hospital%in%names(Hospital0814)]
Variable_HSA_missing
Variable_Hospital_missing
c(Variable_HSA_missing,Variable_Hospital_missing)%in%names(Patient0814)

###found HSA level variables are missing, find them from the patient level data
hsa0814 <- read.csv("data/hsa_socio_vars.csv", stringsAsFactors=FALSE)
temp_commom_variable=Variable_HSA[Variable_HSA%in%names(hsa0814)]
hsa0814=cbind(hsa0814,matrix(NA,nrow=dim(hsa0814)[1],ncol=length(Variable_HSA_missing)))
names(hsa0814)[(dim(hsa0814)[2]+1-length(Variable_HSA_missing)):dim(hsa0814)[2]]=Variable_HSA_missing
Hospital0814=cbind(Hospital0814,matrix(NA,nrow=dim(Hospital0814)[1],ncol=length(Variable_HSA_missing)))
names(Hospital0814)[(dim(Hospital0814)[2]+1-length(Variable_HSA_missing)):dim(Hospital0814)[2]]=Variable_HSA_missing

for(i in 1:dim(hsa0814)[1]){
  temp=subset(Patient0814,hsanum==hsa0814$hsanum[i],select=Variable_HSA)
  temp=unique(temp)
  if(dim(temp)[1]==0){
    cat(i,", ",sep="")
    next
  }else if(dim(temp)[1]>1){
    cat(i," (discrepency), ",sep="")
    next
  }else if(sum(!temp[1,temp_commom_variable]==hsa0814[i,temp_commom_variable])>0){
    cat(i," (discrepency with hsa0814), ",sep="")
    next
  }
  hsa0814[i,Variable_HSA_missing]=temp[1,Variable_HSA_missing]
  temp=which(Hospital0814$hsanum==hsa0814$hsanum[i])
  Hospital0814[temp,Variable_HSA_missing]=hsa0814[i,Variable_HSA_missing]
}

rm(list=setdiff(ls(), c("hsa0814","Hospital0814")))
#save(hsa0814,file="data/hsa_completed.RData")
#save(Hospital0814,file="data/Hospital_completed.RData")

###################################################
#     process/creat patient level covariates      #
###################################################

###STEP1: Preprocessing
cabg_edges2mode <- read.csv("data/cabg_edges2mode.csv",header=F)
header <- read.csv("data/cabg_edges2mode_header.csv",header = F,colClasses = "character")
colnames(cabg_edges2mode)=header[1,]

cabg_igmxpanel_v2 <- read.csv("data/cabg_igmxpanel_v2.csv",header=F)
header <- read.csv("data/cabg_igmxpanel_v2_header.csv",header = F,colClasses = "character")
colnames(cabg_igmxpanel_v2)=header[1,]
cabg08_14_v22 <- read.csv("C:/Users/xsyu/Desktop/data/cabg08_14_v22.csv")
cabg_benekey <- read.csv("C:/Users/xsyu/Desktop/data/cabg_benekey.csv")
rm(header)

rawRelations=cabg_edges2mode[!is.na(cabg_edges2mode$id),]
rawHospitalPanel=cabg_igmxpanel_v2[!is.na(cabg_igmxpanel_v2$prvnumgrp),]
rawPatient=cabg08_14_v22
rm(cabg_edges2mode,cabg_igmxpanel_v2,cabg08_14_v22)

cabg_benekey$bene_id=as.character(cabg_benekey$bene_id)
rawPatient$bene_id=as.character(rawPatient$bene_id)

sum(!rawRelations$id%in%cabg_benekey$id)
sum(!rawPatient$bene_id%in%cabg_benekey$bene_id)

temp=cabg_benekey$id[match(rawPatient$bene_id,cabg_benekey$bene_id)]
rawPatient=data.frame(id=temp,rawPatient)

levels(rawRelations$cabg_date)
rawRelations$cabg_date=as.Date(rawRelations$cabg_date, "%m/%d/%Y")

rm(temp)
#setwd("C:/Users/xsyu/Desktop/data")
#save.image(file='rawdata0614.RData')

###STEP2: index data 

Patient=subset(rawPatient,!is.na(id))
Patient=Patient[order(Patient$id),]
sum(!(1:82033)%in%rawPatient$id)

Patient=subset(Patient,id%in%rawRelations$id)
sum(!(1:82033)%in%Patient$id)
sum(!Patient$id%in%(1:82033))

sum(!(1:82033)%in%rawRelations$id)
sum(!rawRelations$id%in%(1:82033))

rm(cabg_benekey)

#Index npi
temp=unique(rawRelations$npi)
temp=temp[order(temp)]
DicNpi=data.frame(id=1:length(temp),npi=temp)

temp=match(rawRelations$npi,DicNpi$npi)
Relations=cbind(idPt=rawRelations$id,idNpi=temp,rawRelations[,-1])

#Index prvnumgrp
temp=unique((rawRelations$prvnumgrp))
sum(!temp%in%rawHospitalPanel$prvnumgrp)
temp=temp[order(temp)]
DicPrvnumgrp=data.frame(id=1:length(temp),prvnumgrp=temp)

temp=match(Relations$prvnumgrp,DicPrvnumgrp$prvnumgrp)
Relations=cbind(Relations[,1:2],idPrvnumgrp=temp,Relations[,c(4:13,15:25,3,14)])

HospitalPanel=subset(rawHospitalPanel,prvnumgrp%in%Relations$prvnumgrp)
temp=match(HospitalPanel$prvnumgrp,DicPrvnumgrp$prvnumgrp)
HospitalPanel=data.frame(id=temp,HospitalPanel)

HospitalPanel=HospitalPanel[order(HospitalPanel$year),]
HospitalPanel=HospitalPanel[order(HospitalPanel$id),]

rm(list=setdiff(ls(), c("hsa0814","Hospital0814","DicNpi","DicPrvnumgrp","HospitalPanel","Patient","Relations")))

#renew race variable to RTI
data0814 <- read.csv("data/cabg08_14_v23.csv")
data0814$bene_id=as.character(data0814$bene_id)

temp=match(Patient$bene_id,data0814$bene_id)
sum(is.na(temp))

race_RTI=data0814$RTI_RACE[temp]
table(race_RTI)
table(Patient$RACE)
Patient$RACE_RTI=race_RTI
Patient=Patient[,c(1:12,280,13:279)]

Patient0814=data0814
rm(data0814,race_RTI,temp)

###################################################
#     measure provider care team segregation      #
###################################################

entropy<-function(x){
  #x is a vector of probability mass function
  
  if(abs(sum(x)-1)>1e-10|sum(x<0)>0){
    warning("Argument is not a PMF")
  }else{
    x=x[x>0]
    etp=-sum(x*log(x))
  }
  return(etp)
}

TVDistance<-function(P,Q){
  #P,Q are a vectors of probability mass function
  
  if(abs(sum(P)-1)>1e-10|sum(P<0)>0|abs(sum(Q)-1)>1e-10|sum(Q<0)>0){
    warning("Argument is not a PMF")
  }else{
    temp=sum(abs(P-Q))/2
    return(temp)
  }
}

KLDivergence<-function(P,Q){
  #P,Q are a vectors of probability mass function
  
  if(abs(sum(P)-1)>1e-10|sum(P<0)>0|abs(sum(Q)-1)>1e-10|sum(Q<0)>0){
    warning("Argument is not a PMF")
  }else{
    temp=data.frame(P,Q)
    temp=temp[temp$P>0,]
    if(sum(temp$Q==0)>0)warning("Q is 0 for some cases")
    KL=sum(temp$P*log2(temp$P/temp$Q))
  }
  return(KL)
}

JSDivergence<-function(P,Q){
  #P,Q are a vectors of probability mass function
  
  if(abs(sum(P)-1)>1e-10|sum(P<0)>0|abs(sum(Q)-1)>1e-10|sum(Q<0)>0){
    warning("Argument is not a PMF")
  }else{
    M=(P+Q)/2
    JS=(KLDivergence(P,M)+KLDivergence(Q,M))/2
  }
  return(JS)
}

noHspt=length(unique(Relations$idPrvnumgrp))

sum(!(1:noHspt)%in%Relations$idPrvnumgrp)
sum(!Relations$idPrvnumgrp%in%(1:noHspt))

tempRace=match(Relations$idPt,Patient$id)
tempRace=Patient$RACE[tempRace]
Relations=data.frame(Relations[,1:3],race=tempRace,Relations[,-c(1:3)])
table(tempRace)

HosStatistics=data.frame(id=1:noHspt,NoNpi=rep(NA,noHspt),NoPts=rep(NA,noHspt),NoWPts=rep(NA,noHspt),NoBPts=rep(NA,noHspt),NoRelations=rep(NA,noHspt),NoWRelations=rep(NA,noHspt),NoBRelations=rep(NA,noHspt)
                         ,etpall=rep(NA,noHspt),etpW=rep(NA,noHspt),etpB=rep(NA,noHspt),JSW=rep(NA,noHspt),JSB=rep(NA,noHspt),JSWB=rep(NA,noHspt),TVW=rep(NA,noHspt),TVB=rep(NA,noHspt),TVWB=rep(NA,noHspt))
for(i in 1:noHspt){
  tempRelations=subset(Relations,idPrvnumgrp==i)
  tempWhite=subset(tempRelations,race==1)
  tempBlack=subset(tempRelations,race==2)
  
  HosStatistics$NoPts[i]=length(unique(tempRelations$idPt))
  HosStatistics$NoWPts[i]=length(unique(tempWhite$idPt))
  HosStatistics$NoBPts[i]=length(unique(tempBlack$idPt))
  
  HosStatistics$NoRelations[i]=dim(tempRelations)[1]
  HosStatistics$NoWRelations[i]=dim(tempWhite)[1]
  HosStatistics$NoBRelations[i]=dim(tempBlack)[1]
  
  tempNpi=unique(tempRelations$idNpi)
  HosStatistics$NoNpi[i]=length(tempNpi)
  
  tempall=as.data.frame(table(tempRelations$idNpi))
  tempWhite=as.data.frame(table(tempWhite$idNpi))
  tempBlack=as.data.frame(table(tempBlack$idNpi))
  
  tempall=data.frame(tempNpi,Freq=tempall$Freq[match(tempNpi,tempall$Var1)])
  tempWhite=data.frame(tempNpi,Freq=tempall$Freq[match(tempNpi,tempWhite$Var1)])
  tempBlack=data.frame(tempNpi,Freq=tempall$Freq[match(tempNpi,tempBlack$Var1)])
  
  tempWhite$Freq[is.na(tempWhite$Freq)]=0
  tempBlack$Freq[is.na(tempBlack$Freq)]=0
  
  if(sum(tempall$Freq)>0)tempall$Freq=tempall$Freq/sum(tempall$Freq)
  if(sum(tempWhite$Freq)>0)tempWhite$Freq=tempWhite$Freq/sum(tempWhite$Freq)
  if(sum(tempBlack$Freq)>0)tempBlack$Freq=tempBlack$Freq/sum(tempBlack$Freq)
  
  if(HosStatistics$NoRelations[i]>0)HosStatistics$etpall[i]=entropy(tempall$Freq)
  if(HosStatistics$NoWRelations[i]>0)HosStatistics$etpW[i]=entropy(tempWhite$Freq)
  if(HosStatistics$NoBRelations[i]>0)HosStatistics$etpB[i]=entropy(tempBlack$Freq)
  
  if(HosStatistics$NoWRelations[i]>0){HosStatistics$JSW[i]=JSDivergence(tempWhite$Freq,tempall$Freq);HosStatistics$TVW[i]=TVDistance(tempWhite$Freq,tempall$Freq)}
  if(HosStatistics$NoBRelations[i]>0){HosStatistics$JSB[i]=JSDivergence(tempBlack$Freq,tempall$Freq);HosStatistics$TVB[i]=TVDistance(tempBlack$Freq,tempall$Freq)}
  
  if(min(HosStatistics$NoWRelations[i],HosStatistics$NoBRelations[i])>0){HosStatistics$JSWB[i]=JSDivergence(tempWhite$Freq,tempBlack$Freq);HosStatistics$TVWB[i]=TVDistance(tempWhite$Freq,tempBlack$Freq)}
}

rm(list=setdiff(ls(), c("hsa0814","Hospital0814","DicPrvnumgrp","HosStatistics","Patient0814")))

###################################################
# combine patient, hospital, HSA level variables, #  
# add more variables, process variables, select   #
# modeling cohort data                            #
###################################################

temp <- read.csv("data/useful variables.csv", stringsAsFactors=FALSE)
Variable_HSA=temp$Variable.Name[1:23]
Variable_Hospital=temp$Variable.Name[24:34]

###select the predictors used in the 2016 paper about outcome
Variable_HSA=Variable_HSA[c(c(1,11,10,18,15,19),c(20,21,22,23))]
Variable_Hospital=Variable_Hospital[c(1,2,5,6)]
variablesOTCM=c("patient_died_90d","ed_visit_90d","readmissions_90d")
variablesOTCM=c(paste("B",variablesOTCM,sep="_"),variablesOTCM)

###confirm that all predictors are in the hospital level data
Variable_HSA_missing=Variable_HSA[!Variable_HSA%in%names(Hospital0814)]
Variable_Hospital_missing=Variable_Hospital[!Variable_Hospital%in%names(Hospital0814)]
if(length(Variable_HSA_missing)+length(Variable_Hospital_missing)==0)cat("All predictors are available.\n")

###combine data
temp=match(DicPrvnumgrp$prvnumgrp,Hospital0814$prvnumgrp)
Hospital0814=data.frame(HOSid=DicPrvnumgrp$id,Hospital0814[temp,])
rm(temp,Variable_HSA_missing,Variable_Hospital_missing)

###select hospitals with at least 10 white patients and 10 Black patients
CutNoWPts=10
CutNoBPts=10
HosData=subset(HosStatistics,NoWPts>=CutNoWPts&NoBPts>=CutNoBPts)
names(HosData)

temp=match(HosData$id,Hospital0814$HOSid)
HosData=cbind(HosData[,-c(2:4,6:8)],Hospital0814[temp,c(Variable_Hospital,Variable_HSA)])
names(HosData)[2]="num_benesB_hosp"
HosData=HosData[,c(1,3:11,2,12:25)]

Patient0814$RACE=factor(Patient0814$RACE)
Patient0814$WHITE=factor((Patient0814$RACE=="1")+1)
Patient0814$BLACK=factor((Patient0814$RACE=="2")+1)
Patient0814$SEX=factor(Patient0814$SEX)
#Patient0814$patient_died_90d=factor(Patient0814$patient_died_90d)
#Patient0814$ed_visit_90d=factor(Patient0814$ed_visit_90d)
Patient0814$readmissions_90d=(Patient0814$num_of_readmissions_90d>0)+0
#Patient0814$readmissions_90d=factor(Patient0814$readmissions_90d)

Variable_Patient=c("prvnumgrp","PCHRLSON","proc_yr","age_at_sadmsndt","RACE","WHITE","BLACK","SEX","patient_died_90d","ed_visit_90d","readmissions_90d")
temp=Patient0814[,c("bene_id",Variable_Patient)]

temp1=match(temp$prvnumgrp,DicPrvnumgrp$prvnumgrp)
temp1=DicPrvnumgrp$id[temp1]
temp1=match(temp1,HosData$id)
HosData=HosData[temp1,-1]

RegData=cbind(bene_id=temp[,1],HosData[,1:9],temp[,3:7],HosData[,10:24],temp[,8:10])

names(RegData)

RegData=RegData[!is.na(temp1),]
RegData=RegData[,!names(RegData)=="PCHRLSON_hosp"]#delete hospital level PCHARLSON since it's already in patient level data


###add new variables updated on 2020/03/29
new_variable <- read.csv("data/cabg08_14_v24.csv", stringsAsFactors=FALSE)

temp=match(as.character(RegData$bene_id),new_variable$bene_id)
sum(is.na(temp))
RegData=cbind(RegData,new_variable[temp,c("ses_group","elective_proc","DRG_cat","urban","nonpro","region","hospbd_mean_hosp","teaching_hosp")])
RegData=RegData[,!names(RegData)%in%c("bene_id")]

rm(HosData,DicPrvnumgrp,Hospital0814,HosStatistics,Patient0814,temp,temp1,variablesOTCM,new_variable)

save(RegData,file="processed_data.RData")
