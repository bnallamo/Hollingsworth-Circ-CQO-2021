/************************************************************
FILENAME: cabg20_021.sas (from cabgf2_020.sas)
AUTHOR: skaufman
DATE: 5/8/2017
ID: 54
SUMMARY: USE MEDPAR TO DETERMINE READMISSIONS, AS AN OUTCOME.

FROM RAY:
"DRG 462 is applicable to claims before 2008.  DRG 462 used to be the
DRG for rehabilitation - suggesting admission to acute inpatient
rehabilitation.  For claims after 2008, the new DRGs are 945 and 946,
so that should be amended."

************************************************************/

proc sort data=cabg20.medp08_14;
   by bene_id sadmsndt;
run;

data medp(drop=SSLSSNF);
   set cabg20.medp08_14(where=(SSLSSNF ne 'N'));
   if sdschrgdt_coh le sadmsndt le sdschrgdt_coh+90;
   format sadmsndt sdschrgdt mmddyy10.;
run;

data medp;
   set medp;
   if src_adms in('4' 'A' 'D') then delete; /* TRANSFER FROM ANOTHER ACUTE CARE 
       OR CRIT ACCESS FACILITY, OR WITHIN SAME FACILITY (D). */
run;

data cabg20.medp_readmissions;
   set medp;
   if drg_cd in(945 946) then delete; /* THESE ARE REHAB RECORDS, PER RAY */
   format sdschrgdt_coh sdschrgdt_coh cabg_dt mmddyy10.;
run;

ods select none;

proc hpsummary data=cabg20.medp_readmissions;
   class bene_id;
   output out=reads(drop=_type_ rename=(_freq_=num_of_readmissions_90d));
run;

ods select all;

data cabg20.cabg08_14_v15;
   merge
      cabg20.cabg08_14_v14
      reads(in=b)
      ;
   by bene_id;
   if not b then num_of_readmissions_90d=0;
run;

proc freq data=cabg20.cabg08_14_v15;
   tables num_of_readmissions_90d;
run;
