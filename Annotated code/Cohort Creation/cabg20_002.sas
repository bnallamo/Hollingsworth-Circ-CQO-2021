/************************************************************
FILENAME: cabg20_002.sas
AUTHOR: skaufman
DATE: 3/31/2017
ID: 54 CABG20PCT
SUMMARY: USE DENOMINATOR DATA TO IDENTIFY THOSE WHO HAVE
ELIGIBILITY TO BE IN COHORT.
************************************************************/

options mprint mlogic symbolgen;

%let k=
   BENE_ID SEX /*AGE*/ SDOB SDOD RACE ZIPCODE COUNTY STATE
   ENTITL1 ENTITL2 ENTITL3 ENTITL4 ENTITL5
   ENTITL6 ENTITL7 ENTITL8 ENTITL9 ENTITL10 ENTITL11 ENTITL12 HMO1 HMO2
   HMO3 HMO4 HMO5 HMO6 HMO7 HMO8 HMO9 HMO10 HMO11 HMO12
   ;


%macro den(file);
proc sort data=med.&file out=&file nodupkey;
   by bene_id;
run;
%mend den;

%den(den07p20);
%den(den08p20);
%den(den09p20);
%den(den10p20);
%den(den11p20);
%den(den12p20);
%den(den13p20);
%den(den14p20);


/* To correct for blasted name changes in 2011. */

data den11p20;
   set den11p20(rename=(
      BUYIN01-BUYIN12=entitl1-entitl12
      HMOIND01-HMOIND12=hmo1-hmo12
      BENE_DOB=sdob
      DEATH_DT=sdod
      STATE_CD=STATE
      CNTY_CD=COUNTY
      ));
run;


/** And more stupid name changes in 2012. Yeah! **/

data den12p20;
   length zipcode $ 5;
   set den12p20(rename=(
      BUYIN_IND_01-BUYIN_IND_12=entitl1-entitl12
      HMO_IND_01-HMO_IND_12=hmo1-hmo12
      BIRTH_DT=sdob
      DEATH_DT=sdod
      STATE_CODE=STATE
      COUNTY_CD=COUNTY
      SEX_IDENT_CD=sex
      RACE_CD=race
      ));
   zipcode=substr(strip(ZIP_CD),1,5);
run;


/** And still more in 2013. Yeah! **/

data den13p20;
   length zipcode $ 5;
   set den13p20(rename=(
      BENE_MDCR_ENTLMT_BUYIN_IND_01-BENE_MDCR_ENTLMT_BUYIN_IND_12=entitl1-entitl12
      BENE_HMO_IND_01-BENE_HMO_IND_12=hmo1-hmo12
      BENE_BIRTH_DT=sdob
      BENE_DEATH_DT=sdod
      STATE_CODE=STATE
      BENE_COUNTY_CD=COUNTY
      BENE_SEX_IDENT_CD=sex
      BENE_RACE_CD=race
      ));
   zipcode=substr(strip(BENE_ZIP_CD),1,5);
run;


/** At least 2013 = 2014. **/

data den14p20;
   length zipcode $ 5;
   set den14p20(rename=(
      BENE_MDCR_ENTLMT_BUYIN_IND_01-BENE_MDCR_ENTLMT_BUYIN_IND_12=entitl1-entitl12
      BENE_HMO_IND_01-BENE_HMO_IND_12=hmo1-hmo12
      BENE_BIRTH_DT=sdob
      BENE_DEATH_DT=sdod
      STATE_CODE=STATE
      BENE_COUNTY_CD=COUNTY
      BENE_SEX_IDENT_CD=sex
      BENE_RACE_CD=race
      ));
   zipcode=substr(strip(BENE_ZIP_CD),1,5);
run;


data den07_14;
   set
      den07p20(in=a keep=&k)
      den08p20(in=b keep=&k)
      den09p20(in=c keep=&k)
      den10p20(in=d keep=&k)
      den11p20(in=e keep=&k)
      den12p20(in=f keep=&k)
      den13p20(in=g keep=&k)
      den14p20(in=h keep=&k)
      ;

   if a then denom_year=2007;
   else if b then denom_year=2008;
   else if c then denom_year=2009;
   else if d then denom_year=2010;
   else if e then denom_year=2011;
   else if f then denom_year=2012;
   else if g then denom_year=2013;
   else if h then denom_year=2014;
run;

proc sort data=den07_14 nodupkey;
   by bene_id denom_year;
run;

proc sort data=cabg20.cabg08_14_v2 out=cabg08_14_v2 nodupkey;
   by bene_id;
run;

data cabg20.protocohort1;
   retain denom_year;
   merge
      den07_14(in=a)
      cabg08_14_v2(in=b keep=bene_id)
      ;
   by bene_id;
   if not a then do;
      put "** NO DENOM RECORD " bene_id=;
      delete;
   end;
   if b;
   format sdob mmddyy10.;
run;
