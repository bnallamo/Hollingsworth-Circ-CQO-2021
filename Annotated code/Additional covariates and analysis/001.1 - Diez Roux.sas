libname network "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data";
libname ses "G:\Hollingsworth\SES";

/************************************************************
FILE: 001.1 - Diez Roux
AUTHOR: Maggie
DATE: 24 February 2020
SUMMARY: MERGE IN DIAZ-ROUX SES SCORE
************************************************************/

data diagnosis_cohort;
   length zip3 $ 3;
   set network.cabg08_14_v23 (keep=bene_id zipcode);
   zip3=strip(substr(zipcode,1,3));
   zip5=strip(substr(zipcode,1,5));
run;

data ses_zip5(drop=zipses);
   length zip5 $ 5;
   set ses.ses1(rename=(ses1=adr_ses_score));
   zip5=strip(put(strip(zipses),$5.));
   label adr_ses_score=;
run;

data ses_zip3(drop=zipses);
   length zip3 $ 3;
   set ses.ses2(rename=(ses1=adr_ses_score));
   if adr_ses_score ne 0;
   zip3=strip(put(strip(zipses),$3.));
   label adr_ses_score=;
run;

%sortdata(diagnosis_cohort,zip5);
%sortdata(ses_zip5,zip5);

data diagnosis_cohort_ses;
   merge
      diagnosis_cohort(in=a)
      ses_zip5(in=b)
      ;
   by zip5;
   if a;
run;

data missing (drop=adr_ses_score);
   set diagnosis_cohort_ses;
   if adr_ses_score eq .;
run;

%sortdata(missing,zip3);
%sortdata(ses_zip3,zip3);

data missing2(keep=bene_id adr_ses_score);
   merge
      missing(in=a)
      ses_zip3(in=b);
      ;
   by zip3;
   if a;
run;

%sortdata(diagnosis_cohort_ses,bene_id);
%sortdata(missing2,bene_id);

data diagnosis_cohort_ses(drop=zip3);
   merge
      diagnosis_cohort_ses
      missing2
      ;
   by bene_id;
run;

/*merge back in with dataset*/
proc sort data=network.cabg08_14_v23;
	by bene_id;
run;
proc sort data=diagnosis_cohort_ses;
	by bene_id;
run;
data network.cabg08_14_v23_ses;
	merge 
		network.cabg08_14_v23 (in=a)
		diagnosis_cohort_ses (in=b);
	by bene_id;
	if a;
run;


data hosps_seg (rename = (prvnumgrp_new = prvnumgrp));
	set network.hosps_seg_tertile;

	length prvnumgrp_new $6;


	prvnumgrp_new = put(prvnumgrp, z6.);

	drop prvnumgrp;
run;


%sortdata2(network.cabg08_14_v23_ses, prvnumgrp);
%sortdata2(hosps_seg, prvnumgrp);


data network.cabg08_14_v23_ses;
	merge network.cabg08_14_v23_ses (in = a)
		  hosps_seg (in = b);

	by prvnumgrp;

	if a and b;

run;

/* Create SES tertiles */

proc rank data=network.cabg08_14_v23_ses out=network.cabg08_14_v23_ses groups=3;
	var adr_ses_score;
	ranks ses_group;
run;
