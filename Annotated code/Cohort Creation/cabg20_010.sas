/************************************************************
FILENAME: cabg20_010.sas
AUTHOR: skaufman
DATE: 4/27/2017
ID: 54
SUMMARY: SEND OUTPUT OF RULEOUT TO **RELEVANT** COMORBIDITY MACRO.
NOTHING IS EXCLUDED.
************************************************************/

%include 'F:\Documents\SKAUFMAN\Charlson - Klabunde\charlson.comorbidity.macro_srk.sas';

%comorb(cabg20.to_ruleout07_14_out,bene_id,indxpri,LOSCNT,LINEDGNS DGNS_CD1-DGNS_CD25,26,PRCDR_CD1-PRCDR_CD25,25,hcpcs_cd,filetype);

data comorb;
   set comorb(keep=pchrlson bene_id);
   if pchrlson ge 3 then klabmix=3;
   else klabmix=pchrlson;
   label klabmix='klabmix:pchrlson=0,1,2,3+';
   if pchrlson eq ' ' then do;
      pchrlson=0;
      klabmix=0;
   end;
run;

%sortdata(comorb,bene_id);

data cabg20.cabg08_14_v5;
   merge
      cabg20.cabg08_14_v4(in=a)
      comorb(in=b)
      ;
   by bene_id;
   if a;
   if pchrlson eq ' ' then do;
      pchrlson=0;
      klabmix=0;
   end;
   in_comorb=b;
run;
   

proc freq data=cabg20.cabg08_14_v5;
   tables in_comorb pchrlson klabmix / missprint;
   title1 "FROM CABG20_010.SAS";
run;
