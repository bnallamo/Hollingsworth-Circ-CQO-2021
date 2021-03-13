libname network "G:\Hollingsworth\Network Analysis\Data";
libname socio "G:\Hollingsworth\Network Analysis\Data\Sociocultural measures";
libname cap "G:\Hollingsworth\Network Analysis\Data\Healthcare capacity measures";
libname hosp "G:\Hollingsworth\Network Analysis\Data\Hospital measures";
libname origmed "G:\Hollingsworth\Data\Medicare";
libname aha "G:\Hollingsworth\Data\AHA";


/************************************************************
FILE: 002.3 - Adding additional hospital covariates
AUTHOR: Phyllis
DATE: 10 April 2020
SUMMARY: ADDING CITY AND STATE HOSPITAL VARIABLES FROM AHA AND AVERAGE AGE AND PROPORTION OF FEMALES PER HOSPITAL
************************************************************/


/** zipcode = mloczip, originated from AHA file **/
data black_white_pts;
	set network.cabg08_14_v23 (where = (race in ("1" "2")));
run;


data hosp_chars;
	set black_white_pts;
	ssa_state_hosp = substr(prvnumgrp, 1, 2);
	length_mloczip = length(mloczip);
run;
	
proc freq data = hosp_chars;
	tables length_mloczip;
	tables ssa_state_hosp;
run;


proc sort data = hosp_chars (keep = prvnumgrp admyear mloczip where = (not missing(mloczip))) nodupkey out = hosp_zip;
	by prvnumgrp mloczip admyear;
run;

data hosp_zip;
	set hosp_zip;
	by prvnumgrp mloczip admyear;
	if last.mloczip then output;
run;

proc freq data = hosp_zip order = freq noprint;
	tables prvnumgrp / out = hosp_mult_zipcodes;
run;

proc freq data = hosp_mult_zipcodes;
	tables count;
run;






/** Merge on city and state information from AHA file **/
proc sort data = aha.allsurveys (keep = prvnumgrp mloczip mstate mloccity) nodupkey out = aha_info;
	by prvnumgrp mloczip;
run;

%sortdata2(hosp_zip, prvnumgrp mloczip);

data hosp_location;
	merge hosp_zip (in = a)
		  aha_info (in = b);

	by prvnumgrp mloczip;
	
	if a;
	inaha = b;

run;

proc freq data = hosp_location;
	tables inaha;
run;

proc print data = hosp_location;
	where ^inaha;
run;

data hosp_location (drop = inaha);
	set  hosp_location;
	if inaha;
run;


proc freq data = hosp_location;
	format mstate mloccity $misschar.;
	tables mstate mloccity;
run;



/** Add average age and proportion of females per hospital **/
data age_gender;
	set black_white_pts (keep = prvnumgrp age_at_sadmsndt SEX);
	female = SEX eq "2";
run;

proc freq data = age_gender;
	tables SEX*female;
run;

proc means data = age_gender mean noprint maxdec = 2;
	class prvnumgrp;
	var age_at_sadmsndt female;
	output out = hosp_age_gender mean(female) = female_pct_hosp mean(age_at_sadmsndt) =  age_hosp;
run;


data hosp_age_gender (drop = _TYPE_ rename = (_FREQ_ = num_benes_hosp));
	set hosp_age_gender (where = (_TYPE_ eq 1));
run;


proc means data = hosp_age_gender n nmiss min p25 mean p50 p75 max maxdec = 2;
	var age_hosp female_pct_hosp;
	title1 "Check hospital vars at hospital level";
run;

data network.cabg08_14_hosp_loc_demo_info (drop = admyear);
	merge hosp_location (in = a)
		  hosp_age_gender (in = b drop = num_benes_hosp);

	by prvnumgrp;

	if a and b;
run;










