/************************************************************
FILENAME: cabg20_018.sas (from cabgf2_017)
AUTHOR: skaufman
DATE: 5/5/2017
ID: 54
SUMMARY: GET MED SCHOOL AFFILIATION FOR COHORTS AND NAMES OF HOSPS.
MAPP5 IS THE TRADITIONAL INDICATOR OF MED SCHOOL.
************************************************************/

libname aha 'F:\Documents\SKAUFMAN\AHA Files';

%let kp=mapp3 mapp5 mapp8 mapp12 mapp13 mname hcfaid mloczip;

data aha08_13;
   length mname $ 100 year 4;
   set
      aha.aha2008_v2(in=a keep=&kp)
      aha.aha2009_v2(in=b keep=&kp)
      aha.aha2010_v2(in=c keep=&kp)
      aha.aha2011_v2(in=d keep=&kp)
      aha.aha2012_v2(in=e keep=&kp)
      aha.aha2013_v2(in=f keep=&kp)
      ;
   if a then year=2008;
   else if b then year=2009;
   else if c then year=2010;
   else if d then year=2011;
   else if e then year=2012;
   else if f then year=2013;
run;


%let kp=mapp3 mapp5 mapp8 mapp12 mapp13 mname hcfaid mloczip;

data aha14(rename=(m3=mapp3 m5=mapp5 m8=mapp8 m12=mapp12 m13=mapp13));
   length mname $ 100 year 4 m3 m5 m8 m12 m13 $ 1;
   set aha.aha2014_v2(keep=&kp);
   year=2014;
   m3=put(mapp3,1.);
   m5=put(mapp5,1.);
   m8=put(mapp8,1.);
   m12=put(mapp12,1.);
   m13=put(mapp13,1.);
   drop mapp3 mapp5 mapp8 mapp12 mapp13;
run;

data aha.aha08_14;
   set aha08_13 aha14;
   if hcfaid eq '.' then do;
      hcfaid=' ';
   end;
run;

%pc(aha,aha08_14)

proc sort data=aha.aha08_14(keep=mname hcfaid year) out=aha1 nodupkey;
   where hcfaid ne ' ';
   by mname;
run;

%sortdata2(aha.aha08_14,mname year)

data aha.aha08_14_v2;
   merge
      aha.aha08_14(in=a)
      aha1(rename=(hcfaid=hcfaid_imp))
      ;
   by mname;
   if a;
   if hcfaid eq ' ' and hcfaid_imp ne ' ' then do;
      hcfaid=hcfaid_imp;
   end;
   mname=upcase(mname);
run;

proc sort data=aha.aha08_14_v2 nodupkey;
   by mname year hcfaid;
run;

data aha.aha08_14_v2(drop=hcfaid_imp);
   set aha.aha08_14_v2;
   if prxmatch("/VETERANS/",mname) and hcfaid eq ' ' then delete;
run;

data aha.aha08_14_v2(drop=i);
   set aha.aha08_14_v2;
   if hcfaid eq ' ' then delete;
   array m[5] mapp8 mapp3 mapp5 mapp12 mapp13;
   teaching_hosp=0;
   do i=1 to 5;
      if m[i] eq '1' then teaching_hosp=1;
   end;
   label teaching_hosp='teaching_hosp:mapp3,5,8,12, or 13';
run;

%sortdata2(cabg20.cabg08_14_v12,prvnumgrp admyear)
%sortdata2(aha.aha08_14_v2 nodupkey,hcfaid year)

data cabg20.cabg08_14_v13;
   merge
      cabg20.cabg08_14_v12(in=a)
      aha.aha08_14_v2(in=b rename=(hcfaid=prvnumgrp year=admyear))
      ;
   by prvnumgrp admyear;
   if a;
   in_aha=b;
run;


%pc(cabg20,cabg08_14_v13)

proc freq data=cabg20.cabg08_14_v13;
   tables in_aha mapp5 teaching_hosp;
   tables mapp5*teaching_hosp / norow nopercent;
   title1 "FROM CABG20_018.SAS";
run;
title1;
