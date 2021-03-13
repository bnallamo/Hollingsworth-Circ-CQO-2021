/************************************************************
FILENAME: cabg20_027.sas (from cabgf2_034.sas)
AUTHOR: skaufman
DATE: 5/18/2017
ID: 54
SUMMARY: FAILURE TO RESCUE.

"Depending on your unit of analysis, the FTR rate is then the your
'failures' divided by patients with a majorcomp.  This is a bit
contentious with some in the surgical quality world because you do
not attribute deaths without a majorcomp to any category. That's why
it can be important to report the overall mortality rates as well."
Amir Ghaferi

************************************************************/

data cabg20.cabg08_14_v21;
   set cabg20.cabg08_14_v20;
   FTR=0;
   if patient_died_90d and severecomp then FTR=1;
   label FTR="FTR: PATIENT_DIED_90D & SEVERECOMP";
run;

proc freq data=cabg20.cabg08_14_v21;
   tables patient_died_90d * severecomp / missprint;
   tables ftr;
   title1 "FAILURE TO RESCUE";
   title2 "CABG20_027.SAS";
run;

proc freq data=cabg20.cabg08_14_v21;
   where 2008 le proc_yr le 2011;
   tables patient_died_90d * severecomp / missprint;
   tables ftr;
   title1 "FAILURE TO RESCUE";
   title2 "CABG20_027.SAS";
   title3 "where 2008 le proc_yr le 2011";
run;

title1; title2; title3;
