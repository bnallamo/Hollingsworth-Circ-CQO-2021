libname network "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data";
libname med "G:\Hollingsworth\Data\Medicare";
libname aha "G:\Hollingsworth\Data\AHA"; 


/************************************************************
FILE: 002.2 - Adding and modifying hospital covariates
AUTHOR: Phyllis
DATE: 02 April 2020
SUMMARY: ADDING ADDITIONAL HOSPITAL VARIABLES FROM AHA AND AVERAGE HOSPITAL VOLUME
************************************************************/


/*** Adding race based hospital variables ***/
data network.cabg08_14_v24;
	set network.cabg08_14_v24 (drop = hispanic_pct_hosp black_pct_hosp black hispanic);

	length black hispanic 3;

	if strip(RACE) eq "2" then black = 1;
	else black = 0;

	if strip(RACE) eq "5" then hispanic = 1;
	else hispanic = 0;

run;


proc means data = network.cabg08_14_v24 mean noprint maxdec = 2;
	class prvnumgrp;
	var hispanic black;
	output out = hosp_chars mean(hispanic) = hispanic_pct_hosp
							mean(black) = black_pct_hosp;
run;


data hosp_chars (drop = _TYPE_ _FREQ_);
	set hosp_chars (where = (_TYPE_ eq 1));
run;


%sortdata2(network.cabg08_14_v24, prvnumgrp);
%sortdata2(hosp_chars, prvnumgrp);

data network.cabg08_14_v24;
	merge network.cabg08_14_v24 (in = a)
		  hosp_chars (in = b);

	by prvnumgrp;

	if a;

run;

/*** Adding hospital variables from AHA ***/
proc sort data = aha.allsurveys (keep = prvnumgrp year nonpro hospbd region urban where = (2008 <= year <= 2014)) nodupkey out = aha_info;
	by prvnumgrp year;
run;


data aha_info_cat;
	set aha_info (keep = prvnumgrp year nonpro region urban);

	by prvnumgrp year;

	if last.prvnumgrp;
run;

proc means data = aha_info mean noprint maxdec = 0;
	class prvnumgrp;
	var hospbd;
	output out = aha_info_num mean(hospbd) = hospbd_mean_hosp;
run;

data aha_info_num (drop = _TYPE_ _FREQ_);
	set aha_info_num;

	hospbd_mean_hosp = round(hospbd_mean_hosp);
run;

%sortdata2(aha_info_cat, prvnumgrp);
%sortdata2(aha_info_num, prvnumgrp);


data aha_info (drop = year);
	merge aha_info_cat (in = a)
		  aha_info_num (in = b);

	by prvnumgrp;

	if a and b;

run; 


/*** Obtaining average annual hospital volume ***/

%let cabg_icd9procs='3610' '3611' '3612' '3613' '3614' '3615' '3616'
          '3617' '3619' '3620';

options varlenchk=nowarn;

data cabg_volume (keep = prvnumgrp year);
   length sadmsndt 5;
   set
      med.med08p20std(keep=BENE_ID sadmsndt prvnumgrp DGNS_CD: PRCDR_CD: SSLSSNF sdschrgdt prcdr_dt:)
      med.med09p20std(keep=BENE_ID sadmsndt prvnumgrp DGNS_CD: PRCDR_CD: SSLSSNF sdschrgdt prcdr_dt:)
      med.med10p20std(keep=BENE_ID sadmsndt prvnumgrp DGNS_CD: PRCDR_CD: SSLSSNF sdschrgdt prcdr_dt:)
      med.med11p20std(keep=BENE_ID sadmsndt prvnumgrp DGNSCD1-DGNSCD25 PRCDRCD1-PRCDRCD25 SSLSSNF sdschrgdt
                 PRCDRDT1-PRCDRDT25
                rename=(DGNSCD1-DGNSCD25=DGNS_CD1-DGNS_cd25 PRCDRDT1-PRCDRDT25=prcdr_dt1-prcdr_dt25
            PRCDRCD1-PRCDRCD25=PRCDR_CD1-PRCDR_CD25))
      med.med12p20std(keep=BENE_ID sadmsndt prvnumgrp DGNS_CD1-DGNS_CD25 PRCDR_CD1-PRCDR_CD25 SS_LS_SNF_IND_CD
                PRCDR_DT1-PRCDR_DT25 sdschrgdt 
                rename=(SS_LS_SNF_IND_CD=SSLSSNF PRCDR_DT1-PRCDR_DT25=prcdr_dt1-prcdr_dt25))
      med.med13p20std(keep=BENE_ID sadmsndt prvnumgrp
                DGNS_1_CD--DGNS_25_CD
                SRGCL_PRCDR_1_CD--SRGCL_PRCDR_25_CD SS_LS_SNF_IND_CD sdschrgdt
                SRGCL_PRCDR_PRFRM_1_DT--SRGCL_PRCDR_PRFRM_25_DT
                rename=(
                  SS_LS_SNF_IND_CD=SSLSSNF
                  DGNS_1_CD=DGNS_CD1 DGNS_2_CD=DGNS_CD2 DGNS_3_CD=DGNS_CD3
                  DGNS_4_CD=DGNS_CD4 DGNS_5_CD=DGNS_CD5 DGNS_6_CD=DGNS_CD6
                  DGNS_7_CD=DGNS_CD7 DGNS_8_CD=DGNS_CD8 DGNS_9_CD=DGNS_CD9
                  DGNS_10_CD=DGNS_CD10 DGNS_11_CD=DGNS_CD11
                  DGNS_12_CD=DGNS_CD12 DGNS_13_CD=DGNS_CD13
                  DGNS_14_CD=DGNS_CD14 DGNS_15_CD=DGNS_CD15
                  DGNS_16_CD=DGNS_CD16 DGNS_17_CD=DGNS_CD17
                  DGNS_18_CD=DGNS_CD18 DGNS_19_CD=DGNS_CD19
                  DGNS_20_CD=DGNS_CD20 DGNS_21_CD=DGNS_CD21
                  DGNS_22_CD=DGNS_CD22 DGNS_23_CD=DGNS_CD23
                  DGNS_24_CD=DGNS_CD24 DGNS_25_CD=DGNS_CD25
                  SRGCL_PRCDR_1_CD=PRCDR_CD1 SRGCL_PRCDR_2_CD=PRCDR_CD2
                  SRGCL_PRCDR_3_CD=PRCDR_CD3 SRGCL_PRCDR_4_CD=PRCDR_CD4
                  SRGCL_PRCDR_5_CD=PRCDR_CD5 SRGCL_PRCDR_6_CD=PRCDR_CD6
                  SRGCL_PRCDR_7_CD=PRCDR_CD7 SRGCL_PRCDR_8_CD=PRCDR_CD8
                  SRGCL_PRCDR_9_CD=PRCDR_CD9 SRGCL_PRCDR_10_CD=PRCDR_CD10
                  SRGCL_PRCDR_11_CD=PRCDR_CD11 SRGCL_PRCDR_12_CD=PRCDR_CD12
                  SRGCL_PRCDR_13_CD=PRCDR_CD13 SRGCL_PRCDR_14_CD=PRCDR_CD14
                  SRGCL_PRCDR_15_CD=PRCDR_CD15 SRGCL_PRCDR_16_CD=PRCDR_CD16
                  SRGCL_PRCDR_17_CD=PRCDR_CD17 SRGCL_PRCDR_18_CD=PRCDR_CD18
                  SRGCL_PRCDR_19_CD=PRCDR_CD19 SRGCL_PRCDR_20_CD=PRCDR_CD20
                  SRGCL_PRCDR_21_CD=PRCDR_CD21 SRGCL_PRCDR_22_CD=PRCDR_CD22
                  SRGCL_PRCDR_23_CD=PRCDR_CD23 SRGCL_PRCDR_24_CD=PRCDR_CD24
                  SRGCL_PRCDR_25_CD=PRCDR_CD25
                  SRGCL_PRCDR_PRFRM_1_DT=prcdr_dt1 SRGCL_PRCDR_PRFRM_2_DT=prcdr_dt2
                  SRGCL_PRCDR_PRFRM_3_DT=prcdr_dt3 SRGCL_PRCDR_PRFRM_4_DT=prcdr_dt4
                  SRGCL_PRCDR_PRFRM_5_DT=prcdr_dt5 SRGCL_PRCDR_PRFRM_6_DT=prcdr_dt6
                  SRGCL_PRCDR_PRFRM_7_DT=prcdr_dt7 SRGCL_PRCDR_PRFRM_8_DT=prcdr_dt8
                  SRGCL_PRCDR_PRFRM_9_DT=prcdr_dt9 SRGCL_PRCDR_PRFRM_10_DT=prcdr_dt10
                  SRGCL_PRCDR_PRFRM_11_DT=prcdr_dt11 SRGCL_PRCDR_PRFRM_12_DT=prcdr_dt12
                  SRGCL_PRCDR_PRFRM_13_DT=prcdr_dt13 SRGCL_PRCDR_PRFRM_14_DT=prcdr_dt14
                  SRGCL_PRCDR_PRFRM_15_DT=prcdr_dt15 SRGCL_PRCDR_PRFRM_16_DT=prcdr_dt16
                  SRGCL_PRCDR_PRFRM_17_DT=prcdr_dt17 SRGCL_PRCDR_PRFRM_18_DT=prcdr_dt18
                  SRGCL_PRCDR_PRFRM_19_DT=prcdr_dt19 SRGCL_PRCDR_PRFRM_20_DT=prcdr_dt20
                  SRGCL_PRCDR_PRFRM_21_DT=prcdr_dt21 SRGCL_PRCDR_PRFRM_22_DT=prcdr_dt22
                  SRGCL_PRCDR_PRFRM_23_DT=prcdr_dt23 SRGCL_PRCDR_PRFRM_24_DT=prcdr_dt24
                  SRGCL_PRCDR_PRFRM_25_DT=prcdr_dt25
                  ))
      med.med14p20std(keep=BENE_ID sadmsndt prvnumgrp
                DGNS_1_CD--DGNS_25_CD
                SRGCL_PRCDR_1_CD--SRGCL_PRCDR_25_CD SS_LS_SNF_IND_CD sdschrgdt
                SRGCL_PRCDR_PRFRM_1_DT--SRGCL_PRCDR_PRFRM_25_DT
                rename=(
                  SS_LS_SNF_IND_CD=SSLSSNF
                  DGNS_1_CD=DGNS_CD1 DGNS_2_CD=DGNS_CD2 DGNS_3_CD=DGNS_CD3
                  DGNS_4_CD=DGNS_CD4 DGNS_5_CD=DGNS_CD5 DGNS_6_CD=DGNS_CD6
                  DGNS_7_CD=DGNS_CD7 DGNS_8_CD=DGNS_CD8 DGNS_9_CD=DGNS_CD9
                  DGNS_10_CD=DGNS_CD10 DGNS_11_CD=DGNS_CD11
                  DGNS_12_CD=DGNS_CD12 DGNS_13_CD=DGNS_CD13
                  DGNS_14_CD=DGNS_CD14 DGNS_15_CD=DGNS_CD15
                  DGNS_16_CD=DGNS_CD16 DGNS_17_CD=DGNS_CD17
                  DGNS_18_CD=DGNS_CD18 DGNS_19_CD=DGNS_CD19
                  DGNS_20_CD=DGNS_CD20 DGNS_21_CD=DGNS_CD21
                  DGNS_22_CD=DGNS_CD22 DGNS_23_CD=DGNS_CD23
                  DGNS_24_CD=DGNS_CD24 DGNS_25_CD=DGNS_CD25
                  SRGCL_PRCDR_1_CD=PRCDR_CD1 SRGCL_PRCDR_2_CD=PRCDR_CD2
                  SRGCL_PRCDR_3_CD=PRCDR_CD3 SRGCL_PRCDR_4_CD=PRCDR_CD4
                  SRGCL_PRCDR_5_CD=PRCDR_CD5 SRGCL_PRCDR_6_CD=PRCDR_CD6
                  SRGCL_PRCDR_7_CD=PRCDR_CD7 SRGCL_PRCDR_8_CD=PRCDR_CD8
                  SRGCL_PRCDR_9_CD=PRCDR_CD9 SRGCL_PRCDR_10_CD=PRCDR_CD10
                  SRGCL_PRCDR_11_CD=PRCDR_CD11 SRGCL_PRCDR_12_CD=PRCDR_CD12
                  SRGCL_PRCDR_13_CD=PRCDR_CD13 SRGCL_PRCDR_14_CD=PRCDR_CD14
                  SRGCL_PRCDR_15_CD=PRCDR_CD15 SRGCL_PRCDR_16_CD=PRCDR_CD16
                  SRGCL_PRCDR_17_CD=PRCDR_CD17 SRGCL_PRCDR_18_CD=PRCDR_CD18
                  SRGCL_PRCDR_19_CD=PRCDR_CD19 SRGCL_PRCDR_20_CD=PRCDR_CD20
                  SRGCL_PRCDR_21_CD=PRCDR_CD21 SRGCL_PRCDR_22_CD=PRCDR_CD22
                  SRGCL_PRCDR_23_CD=PRCDR_CD23 SRGCL_PRCDR_24_CD=PRCDR_CD24
                  SRGCL_PRCDR_25_CD=PRCDR_CD25
                  SRGCL_PRCDR_PRFRM_1_DT=prcdr_dt1 SRGCL_PRCDR_PRFRM_2_DT=prcdr_dt2
                  SRGCL_PRCDR_PRFRM_3_DT=prcdr_dt3 SRGCL_PRCDR_PRFRM_4_DT=prcdr_dt4
                  SRGCL_PRCDR_PRFRM_5_DT=prcdr_dt5 SRGCL_PRCDR_PRFRM_6_DT=prcdr_dt6
                  SRGCL_PRCDR_PRFRM_7_DT=prcdr_dt7 SRGCL_PRCDR_PRFRM_8_DT=prcdr_dt8
                  SRGCL_PRCDR_PRFRM_9_DT=prcdr_dt9 SRGCL_PRCDR_PRFRM_10_DT=prcdr_dt10
                  SRGCL_PRCDR_PRFRM_11_DT=prcdr_dt11 SRGCL_PRCDR_PRFRM_12_DT=prcdr_dt12
                  SRGCL_PRCDR_PRFRM_13_DT=prcdr_dt13 SRGCL_PRCDR_PRFRM_14_DT=prcdr_dt14
                  SRGCL_PRCDR_PRFRM_15_DT=prcdr_dt15 SRGCL_PRCDR_PRFRM_16_DT=prcdr_dt16
                  SRGCL_PRCDR_PRFRM_17_DT=prcdr_dt17 SRGCL_PRCDR_PRFRM_18_DT=prcdr_dt18
                  SRGCL_PRCDR_PRFRM_19_DT=prcdr_dt19 SRGCL_PRCDR_PRFRM_20_DT=prcdr_dt20
                  SRGCL_PRCDR_PRFRM_21_DT=prcdr_dt21 SRGCL_PRCDR_PRFRM_22_DT=prcdr_dt22
                  SRGCL_PRCDR_PRFRM_23_DT=prcdr_dt23 SRGCL_PRCDR_PRFRM_24_DT=prcdr_dt24
                  SRGCL_PRCDR_PRFRM_25_DT=prcdr_dt25
                  ))
                  ;

   array proc[25] prcdr_cd1-prcdr_cd25;
   array dates[25] prcdr_dt1-prcdr_dt25;
   do i=1 to dim(proc);
      if strip(proc[i]) in(&cabg_icd9procs) then do;
         cabged=1;
         cabg_dt=dates[i];
         leave;
      end;
   end;

   if cabged;
	
   year = year(sadmsndt);

   if 2008 <= year <= 2014;
run;


proc freq data = cabg_volume noprint;
	tables prvnumgrp*year / out = cabg_vol;
run;


data cabg_vol (keep = prvnumgrp COUNT rename = (COUNT = CABG_volume));
	set cabg_vol;
run;

proc means data = cabg_vol mean noprint maxdec = 0;
	class prvnumgrp;
	var CABG_volume;
	output out = cabg_vol_mean mean(CABG_volume) = CABG_volume_mean_hosp;
run;

data cabg_vol_mean (drop = _TYPE_ _FREQ_);
	set cabg_vol_mean;

	CABG_volume_mean_hosp = round(CABG_volume_mean_hosp);
run;

%sortdata2(cabg_vol_mean, prvnumgrp);

data network.cabg08_14_v24;
	merge network.cabg08_14_v24 (in = a)
		  aha_info
		  cabg_vol_mean;

	by prvnumgrp;

	if a;

run;

