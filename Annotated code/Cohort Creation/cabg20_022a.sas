/************************************************************
FILENAME: cabg20_022a.sas (from cabgf2_025a.sas (was 0_preCONTROL_PSI.sas))
AUTHOR: skaufman
DATE: 5/9/2017
ID: 54

SUMMARY: *Run before control_psi.sas.*  CREATES PSI VARIABLES FOR
COMPLICATIONS. NOTE THAT I AM RELYING ON THE HCUP WEB SITE FOR
DEFINITIONS OF THE HCUP VARS, THEN I'LL USUALLY BE ABLE TO CONTRUCT
APPROPRIATE VARS WITH MEDPAR DATA.

NOTE THAT 2011 WAS USED AS A MIDPOINT YEAR (HENCE, E.G., "SID11").
************************************************************/

libname zip2fips "F:\Documents\SKAUFMAN\SAS Zipcode to County";
libname psisas "F:\Documents\SKAUFMAN\54 JH CABG20PCT\CABG\PSI SAS";
libname drg "F:\Documents\SKAUFMAN\54 JH CABG20PCT\CABG\PSI SAS\DRG-related";
libname aha "F:\Documents\SKAUFMAN\AHA Files";

options mprint nosymbolgen;

/** BELOW WE ADD APPROPRIATE ZIPCODES FOR MERGING WITH COHORT FILE, 
    IN ORDER TO GET THE FIPS PATIENT-STATE-COUNTY VARIABLE, REQUIRED FOR
    THE HCUP SAS PROGRAM **/

data saszip_2002_2_2014(drop=saszip_year);
   length zip5c $ 5;
   set zip2fips.saszip_2002_2_2014(keep=zip patient_state_county saszip_year where=(saszip_year eq 2011));
   zip5c=put(zip,z5.);
   rename patient_state_county=pstco;
   drop zip;
run;

%sortdata2(saszip_2002_2_2014,zip5c);

data medp08_14;
   set cabg20.medp08_14;
   if sadmsndt eq sadmsndt_coh and sdschrgdt eq sdschrgdt_coh;
   age=int(intck('month',dob,sadmsndt)/12);
   if month(dob) eq month(sadmsndt) and day(sadmsndt) lt day(dob) then age=age-1;
run;

proc means data=medp08_14 n nmiss min median max;
   var age;
run;

%sortdata2(medp08_14 nodupkey, bene_id)

data psisas.SID11(rename=(
      zipcode=zip5c
      bene_id=key
      drg_cd=drg
      loscnt=los
      DSTNTNCD=disp
      DGNS_CD1-DGNS_CD25=dx1-dx25
      PRCDR_CD1-PRCDR_CD25=pr1-pr25
      ));
   length pointoforiginub04 $ 1;
   set medp08_14;
   dqtr=qtr(sdschrgdt);
   year=year(sdschrgdt);
   ageday=.;  /** NOTE, THIS IS HCUP NIS DATA, AND IT'S FOR THOSE < 1 Y.O. **/
   /*  NO DGNS CODES DROPPED. NOTE THAT IF ONLY 20 VARS ACTUALLY USED, PROG WOULD ERR OUT. */
   atype=TYPE_ADM+0; /* I'VE VERIFIED THAT THE LEVELS ARE THE SAME */

   /* BASED ON http://www.hcup-us.ahrq.gov/db/vars/siddistnote.jsp?var=asource */
   /* IT SEEMS THAT ASOURCEUB92 HAS THE SAME CODING AS MEDPAR SRC_ADMS */
   if SRC_ADMS eq '7' then asource=1;
   else if SRC_ADMS in('4' 'A' 'D') then asource=2;
   else if SRC_ADMS in('5' '6' 'B' 'C') then asource=3;
   else if SRC_ADMS in('8') then asource=4;
   else if SRC_ADMS in('1' '2' '3') then asource=5;
   else asource=.;

   mort30=.; /* OPTIONAL */
   dnr=.; /* OPTIONAL */
   pay1=1;
   pay2=.; /* OPTIONAL */
   discwt=.; /* OPTIONAL */
   drgver=.; /* APPARENTLY, THIS WILL BE COMPUTED BY MACRO */
   pointoforiginub04=SRC_ADMS; /* BASED ON PAGE 86 OF DOCUMENTATION */

   array dxpoa[25] $;  /* I'M ASSUMING THAT FOR OUR DATA, THE DXS WERE NOT AT ADMISSION */
   do i=1 to 25;
      dxpoa[i]=' ';
   end;
run;
%sortdata2(psisas.SID11,zip5c);

data psisas.SID11;
   merge
      saszip_2002_2_2014
      psisas.SID11(in=a)
      ;
   by zip5c;
   if a;
run;

%sortdata2(psisas.SID11,prvnumgrp);

proc sort data=aha.aha2011_v2 out=aha2011 nodupkey;
   by hcfaid;
   where hcfaid ne ' ';
run;


/** BELOW I ADD AHAID BY MERGING WITH HCFAID<->PRVBNUMGRP **/
/** THIS IS IMPORTANT SO THAT I CAN MERGE IN NATIONAL INPATIENT
    SAMPLE (NIS) data. ALSO PROVIDES OFFICIAL HOSPID. **/


data psisas.SID11(rename=(/*hospidn=hospid*/ racen=race sexn=sex));
   merge
      psisas.SID11(in=a)
      aha2011(keep=id hcfaid rename=(id=hospid hcfaid=prvnumgrp))
      ;
   by prvnumgrp;
   if a;
   /*hospidn=hospid+0;
   drop hospid;*/

   /** RECODING RACE TO CONFORM TO HCUP **/
   if race eq '1' then racen=1;
   else if race eq '2' then racen=2;
   else if race in('0' '3') then racen=6;
   else if race eq '4' then racen=4;
   else if race eq '5' then racen=3;
   else if race eq '6' then racen=5;
   drop race;

   /** RECODING SEX **/
   sexn=sex+0;
   if sexn eq 0 then sexn=.;
   drop sex;
run;

%sortdata2(psisas.SID11,drg);
%sortdata2(drg.crosswalk_srk_v3,drg);

data psisas.sid11;
   merge
      drg.crosswalk_srk_v3(keep=drg mdc)
      psisas.sid11(in=a)
      ;
   by drg;
   if a;
run;
