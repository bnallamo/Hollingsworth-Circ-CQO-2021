/************************************************************
FILENAME: cabg20_013.sas (from cabgf2_006.sas)
AUTHOR: skaufman
DATE: 5/1/2017
ID: 54
SUMMARY: MERGE IN FACILITY ZIPCODE AND STATE TO MEDPAR.
************************************************************/

options varlenchk=nowarn;

data prvnum;
   length sadmsndt 5 prvnumgrp $ 6;
   set
      med.med08p20(keep=BENE_ID sadmsndt ORGNPINUM PRVNUMGRP)
      med.med09p20(keep=BENE_ID sadmsndt ORGNPINUM PRVNUMGRP)
      med.med10p20(keep=BENE_ID sadmsndt ORGNPINUM PRVNUMGRP)
      med.med11p20(keep=BENE_ID sadmsndt ORGNPINM  prvnumgrp
           rename=(ORGNPINM=ORGNPINUM))
      med.med12p20(keep=BENE_ID sadmsndt ORG_NPI_NUM prvnumgrp
           rename=(ORG_NPI_NUM=ORGNPINUM))
      med.med13p20(keep=BENE_ID sadmsndt ORG_NPI_NUM prvnumgrp
           rename=(ORG_NPI_NUM=ORGNPINUM))
      med.med14p20(keep=BENE_ID sadmsndt ORG_NPI_NUM prvnumgrp
           rename=(ORG_NPI_NUM=ORGNPINUM))
      ;
run;

options varlenchk=warn;

%sortdata2(prvnum nodupkey,bene_id sadmsndt)
%sortdata2(cabg20.cabg08_14_v5,bene_id sadmsndt)

data cabg20.cabg08_14_v6(drop=flagset eligstart eligstop hmostart hmoblank death_du_fo
     in_comorb);
   merge
      cabg20.cabg08_14_v5(in=a)
      prvnum(in=b)
      ;
   by bene_id sadmsndt;
   if a;
   prvnum=b;
run;

proc freq data=cabg20.cabg08_14_v6;
   tables prvnum;
   title1 "FROM CABG20_013.SAS";
run;

data prv;
   length prvnumgrp $ 6 state_cd $ 2;
   set 
      med.pos08(in=a keep=prov1680 PROV2905 PROV3230 where=(prov1680 ne ' '))
      med.pos09(in=b keep=prov1680 PROV2905 PROV3230 where=(prov1680 ne ' '))
      med.pos10(in=c keep=prov1680 PROV2905 PROV3230 where=(prov1680 ne ' '))
      med.pos11(in=d keep=prvdr_num ZIP_CD STATE_CD
           rename=(prvdr_num=prov1680 zip_cd=prov2905 STATE_CD=PROV3230)
           where=(prov1680 ne ' '))
      med.pos12(in=e keep=prvdr_num zip_cd state_cd
           rename=(prvdr_num=prov1680 zip_cd=prov2905 STATE_CD=PROV3230)
           where=(prov1680 ne ' '))
      med.pos13(in=f keep=prvdr_num zip_cd state_cd
           rename=(prvdr_num=prov1680 zip_cd=prov2905 STATE_CD=PROV3230)
           where=(prov1680 ne ' '))
      med.pos14(in=g keep=prvdr_num zip_cd state_cd
           rename=(prvdr_num=prov1680 zip_cd=prov2905 STATE_CD=PROV3230)
           where=(prov1680 ne ' '))
      ;
   prvnumgrp=strip(prov1680);
   state_cd=strip(prov3230);
   if a then posyear=2008;
   else if b then posyear=2009;
   else if c then posyear=2010;
   else if d then posyear=2011;
   else if e then posyear=2012;
   else if f then posyear=2013;
   else if g then posyear=2014;
run;

proc freq data=prv;
   tables posyear / missprint;
run;

%sortdata2(prv,prvnumgrp posyear);

proc format;
   value $ zip
      " "="MISSING"
     other="VALID"
     ;
run;

data cabg08_14_v6;
   set cabg20.cabg08_14_v6;
   admyear=year(sadmsndt);
run;

proc sort data=cabg08_14_v6;
   by prvnumgrp admyear;
run;

data cabg20.cabg08_14_v7(drop=prvnum);
   merge
      cabg08_14_v6(in=a)
      prv(in=b keep=prvnumgrp state_cd PROV2905 posyear rename=(posyear=admyear))
      ;
   by prvnumgrp admyear;
   if a;
   rename PROV2905=facility_zip5;
   in_prv=b;
run;

proc freq data=cabg20.cabg08_14_v7;
   format facility_zip5 $zip.;
   tables in_prv facility_zip5 state_cd / missprint;
   title1 "FROM CABG20_013.SAS";
run;
title1;

proc print data=cabg20.cabg08_14_v7;
   where not in_prv;
   var prvnumgrp facility_zip5;
run;
