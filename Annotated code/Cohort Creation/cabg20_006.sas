/************************************************************
FILENAME: cabg20_006.sas (from tdiff_008.sas)
AUTHOR: skaufman
DATE: 4/18/2017
ID: 54 CABG20PCT
SUMMARY: FINISH FILTERING FOR COHORT.
************************************************************/

proc sort data=cabg20.entitlehmo07_14_v3 out=entitlehmo07_14_v3 nodupkey;
   by bene_id sadmsndt;
run;

proc sort data=entitlehmo07_14_v3 nodupkey;
   by bene_id;
run;

proc sort data=cabg20.cabg08_14_v2 nodupkey;
   by bene_id sadmsndt;
run;

proc sort data=cabg20.cabg08_14_v2 nodupkey;
   by bene_id;
run;

data cabg20.cabg08_14_v3;
   merge
      entitlehmo07_14_v3(in=a)
      cabg20.cabg08_14_v2(in=b drop=sslssnf)
      ;
   by bene_id sadmsndt;
   if a and b;
run;

data cabg20.cabg08_14_v4;
   length time_under_obs 5;
   set cabg20.cabg08_14_v3;
   time_under_obs=earliest_end_date-sadmsndt+1;
   days_of_post=earliest_end_date-sdschrgdt;
   if cabg_dt le sdod le sdschrgdt+90 then patient_died_90d=1;
   else patient_died_90d=0;
   if days_of_post lt 90 and patient_died_90d eq 0 then delete;
run;

proc freq data=cabg20.cabg08_14_v4;
   tables race sex patient_died_90d / missprint;
   title1 "FROM CABG20_006.SAS";
run;

proc means data=cabg20.cabg08_14_v4 ndec=2 min median max;
   var time_under_obs days_of_post age_at_sadmsndt;
run;

