WD="C:/Users/xsyu/Desktop/organized code"
setwd(WD)
load("processed_data.RData")

###select black and white patients
RegData_BW=subset(RegData,BLACK=="2"|WHITE=="2",select=-c(BLACK,WHITE,etpall,etpW,JSW,TVW))
RegData_BW$RACE=factor(RegData_BW$RACE)

###transform variables into the form as in the table prepared by Phyllis
table(RegData_BW$PCHRLSON)
RegData_BW$PCHRLSON=factor(RegData_BW$PCHRLSON)
levels(RegData_BW$PCHRLSON)=c("0","1",rep("2+",14))
table(RegData_BW$ses_group)
RegData_BW$ses_group=factor(RegData_BW$ses_group)
table(RegData_BW$nonpro)
RegData_BW$nonpro=factor(RegData_BW$nonpro)
table(RegData_BW$DRG_cat)
RegData_BW$DRG_cat=factor(RegData_BW$DRG_cat)
table(RegData_BW$region)
RegData_BW$region=factor(RegData_BW$region)
range(RegData_BW$hospbd_mean_hosp)
RegData_BW$hospbd_mean_hosp=cut(RegData_BW$hospbd_mean_hosp,c(0,250,500,3000))
covariatesNames=c("PCHRLSON","age_at_sadmsndt","proc_yr","SEX"
                  ,"num_benes_hosp","num_benesB_hosp","num_phys_hosp","outCBSA_pct_hosp"
                  ,"tot_pop_hsa","black_hsa","hispanic_hsa","poverty_pct_hsa","gradeduc_ge25_pct_hsa","rural_pct_hsa","ACHbeds_per_1000","PCPs_per_100k","MedSpec_per_100k","Surg_per_100k")
#covariatesNames=c(covariatesNames,c("ses_group","elective_proc","DRG_cat","urban","nonpro","region","hospbd_mean_hosp","teaching_hosp"),"TVWB")
covariatesNames=c(covariatesNames,c("ses_group","elective_proc","urban","nonpro","region","hospbd_mean_hosp","teaching_hosp"),"TVWB")
#urban deleted because they all take same value
covariatesNames=covariatesNames[covariatesNames!="urban"] 

###impute by mode
table(RegData_BW$ses_group)
hist(RegData_BW$teaching_hosp)
RegData_BW$ses_group[is.na(RegData_BW$ses_group)]=0
RegData_BW$teaching_hosp[is.na(RegData_BW$teaching_hosp)]=1

###cut segregation measure by tertile
library(arules)
RegData_BW[,"TVWB"]=discretize(RegData_BW[,"TVWB"],method="fixed",breaks = c(0,0.8627806,0.8990240,1))
levels(RegData_BW[,"TVWB"])=c("low","moderate","high")
RegData_BW[,"TVWB"] <- relevel(RegData_BW[,"TVWB"], ref="low")

###Model fitting
datA=RegData_BW[,c("patient_died_90d","RACE",covariatesNames)]
datA$proc_yr=factor(datA$proc_yr)

temp=paste(covariatesNames,":RACE",sep="")
temp=paste(c(covariatesNames,"RACE",temp),collapse ="+")
fml=paste("patient_died_90d~",temp,sep="")
mdl=glm(as.formula(fml),data=datA,family=binomial(link = "logit"))
#summary(mdl)

temp=c("beta","Pr(>|Z|)","exp(beta)","CI1","CI2","sigma","Pr(>Chi)")
record=matrix(NA,nrow=length(names(mdl$coefficients))-1,ncol=length(temp))
record=data.frame(record)
colnames(record)=temp

row.names(record)=names(mdl$coefficients)[-1]
record$beta=coef(mdl)[-1]
record$`exp(beta)`=exp(record$beta)
record$`Pr(>|Z|)`=summary(mdl)$coefficients[-1,4]

record[,4:5]=confint(mdl)[-1,]
record$CI1exp=exp(record$CI1)
record$CI2exp=exp(record$CI2)
record$sigma=summary(mdl)$coefficients[-1,2]

temp=drop1(mdl,test="Chi")# deviance based test
library(stringr)

for(i in 2:dim(temp)[1]){
  tempname=row.names(temp)[i]
  tempword=word(tempname,1:2,sep=":")
  tempposition=str_detect(row.names(record),tempword[1])&str_detect(row.names(record),tempword[2])
  record$`Pr(>Chi)`[tempposition]=temp$`Pr(>Chi)`[i]
}

##organize the columns
record[,-c(2,3,7,8)]=signif(record[,-c(2,3,7,8)],3)
record[,c(2,3,7,8)]=round(record[,c(2,3,7,8)],3)
record_character=format(record, scientific = FALSE)
for(i in 1:dim(record)[2]){
  record_character[,i]=as.character(record[,i])
}
record_character$`Pr(>|Z|)`[record_character$`Pr(>|Z|)`=="0"]="<.001"
record_character$`Pr(>Chi)`[record_character$`Pr(>Chi)`=="0"]="<.001"
for(i in 1:dim(record_character)[1]){
  record_character[i,4]=paste(" (",record[i,4],",",record[i,5],")",sep="")
  record_character[i,8]=paste(" (",record[i,8],",",record[i,9],")",sep="")
}
record_character=record_character[,c(1,4,3,8,6,2,7)]
names(record_character)[2]="CI"
names(record_character)[4]="CI-exp"
record_ctgrcl=record_character   
record_ctgrcl$`Pr(>Chi)`[is.na(record_ctgrcl$`Pr(>Chi)`)]=" "
record_ctgrcl

write.csv(record_ctgrcl, file="Appendix Table 3. Full Multivariable Model Results from Primary Analysis.csv")

###Calculate E-value corresponding to the odds ratio of Black adults in high vs.low segregation hospital
library(EValue)
datA=RegData_BW[,c("patient_died_90d","RACE",covariatesNames)]
datA$RACE <- relevel(datA$RACE, ref = "2")
datA$proc_yr=factor(datA$proc_yr)

temp=paste(covariatesNames,":RACE",sep="")
temp=paste(c(covariatesNames,"RACE",temp),collapse ="+")
fml=paste("patient_died_90d~",temp,sep="")
mdl=glm(as.formula(fml),data=datA,family=binomial(link = "logit"))

est = summary(mdl)$coef["TVWBhigh", c(1, 2)]
RR = exp(est[1])
lowerRR = exp(est[1] - 1.96*est[2])
upperRR = exp(est[1] + 1.96*est[2])
E_value=evalues.RR(RR, lowerRR, upperRR)[2,1]
cat("The E-value corresponding to the odds ratio of Black adults in high vs.low segregation hospital is ",round(E_value,2),".",sep="")


