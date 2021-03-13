libname network "G:\Hollingsworth\Network Analysis\Data";
libname socio "G:\Hollingsworth\Network Analysis\Data\Sociocultural measures";
libname cap "G:\Hollingsworth\Network Analysis\Data\Healthcare capacity measures";
libname hosp "G:\Hollingsworth\Network Analysis\Data\Hospital measures";
libname origmed "G:\Hollingsworth\Data\Medicare";

/************************************************************
FILE: 002.1 - Adding Hospital and HSA covariates
AUTHOR: Phyllis
DATE: 26 March 2020
SUMMARY: MERGE IN HOSPITAL AND HSA COVARIATES
************************************************************/


/** Information on how zip codes compare to ZCTAs:
https://acsdatacommunity.prb.org/acs-data-products--resources/american-factfinder/f/3/t/427
https://acsdatacommunity.prb.org/acs-data-products--resources/american-factfinder/f/3/t/407
**/


/**** HSA level variables ****/
/*aggregate from ZCTA to HSA */
/* Merge on patient zip to HSA, then merge on sociocultural measures by HSA */
/* Population (log)
   Proportion of Hispanic residents
   Proportion of residents with graduate education
   Proportion of residents living beneath the federal poverty line
   Proportion of residents living in rural areas
   Proportions of residents aged 65 years and above*/

/*** Check zip code relationship to ZCTA ***/
proc freq data = network.zip_to_zcta_2018;
	tables zip_join_type;
	title1 "Check zip code relationship to ZCTA";
run;

proc freq data = network.zip_to_zcta_2018 noprint order = freq;
	tables zipcode / out = check_zip_dups;
run;

%sortdata2(network.zip_to_zcta_2018, zipcode);


/** Convert zipcode for zipcode to HSA file **/
data network.ZipHsaHrr14_v2;
	set network.ZipHsaHrr14;

	zipcode = put(zipcode14, z5.);
run;

%sortdata2(network.ZipHsaHrr14_v2, zipcode);

proc freq data = network.ZipHsaHrr14_v2 noprint order = freq;
	tables zipcode / out = check_zip_dups;
run;

/** Merge on ZCTAs and create HSA to ZCTA file **/

data network.ZCTAHsaHrr14;
	merge network.zip_to_zcta_2018 (in = a keep = zipcode ZCTA)
		  network.ZipHsaHrr14_v2 (in = b);

	by zipcode;

	zip_to_zcta = a;
	ziphsa = b;
run;


proc freq data = network.ZCTAHsaHrr14;
	tables zip_to_zcta*ziphsa;
	title1 "Check overlap between zip to ZCTA xwalk and zip to HSA xwalk";
run;

data network.ZCTAHsaHrr14;
	set network.ZCTAHsaHrr14 (where = (ziphsa));
	if missing(ZCTA) then ZCTA = zipcode;
run;


proc sort data = network.ZCTAHsaHrr14 nodupkey;
	by hsanum ZCTA;
run;

proc freq data = network.ZCTAHsaHrr14 noprint order = freq;
	tables ZCTA / out = check_zcta_dups;
run;

proc freq data = check_zcta_dups;
	tables count;
	title1 "Check how many ZCTAs are associated with multiple HSAs";
run;

/** Proportion of residents aged 65 years and above **/
data age_ge65 (rename = (ZCTA_new = ZCTA));
	set socio.ACS_14_5YR_age_ge65 (keep = zipcode HC01_EST_VC01 HC01_EST_VC31 rename = (HC01_EST_VC01 = tot_pop_est));

	ZCTA_new = put(zipcode, z5.);
	HC01_EST_VC31_new = HC01_EST_VC31;
	if findc(HC01_EST_VC31,'-+*NX()') > 0 then HC01_EST_VC31_new = "";
	age_ge65_pct = input(HC01_EST_VC31_new, 5.); 
	drop zipcode;
run;


proc freq data = age_ge65;
	where missing(HC01_EST_VC31_new);
	tables HC01_EST_VC31 tot_pop_est;
	title1 "Check the population estimates for ZCTAs that are missing percent age over 65";
run;

proc means data = age_ge65 n nmiss min p50 mean max maxdec = 2;
	var age_ge65_pct;
	title1 "Check the distribution of percent age over 65 for ZCTAs";
run;

data age_ge65 (keep = ZCTA tot_pop_est age_ge65_est);
	set age_ge65;
	age_ge65_est = round(tot_pop_est*age_ge65_pct/100, 1);
run;



/** Proportion of residents with graduate education **/
data gradeduc_ge25 (rename = (ZCTA_new = ZCTA));
	set socio.ACS_14_5YR_gradeduc (keep = zipcode HC01_EST_VC07 HC01_EST_VC14 rename = (HC01_EST_VC07 = tot_pop_est));

	ZCTA_new = put(zipcode, z5.);
	HC01_EST_VC14_new = HC01_EST_VC14;
	if findc(HC01_EST_VC14,'-+*NX()') > 0 then HC01_EST_VC14_new = "";
	gradeduc_ge25_pct = input(HC01_EST_VC14_new, 5.); 
	drop zipcode;
run;


proc freq data = gradeduc_ge25;
	where missing(HC01_EST_VC14_new);
	tables HC01_EST_VC14;
	title1 "Check population estimate for ZCTAs missing percent with graduate school education";
run;

proc means data = gradeduc_ge25 n nmiss min p50 mean max maxdec = 2;
	var gradeduc_ge25_pct;
	title1 "Check the distribution of percent with graduate school education for ZCTAs";
run;

data gradeduc_ge25 (keep = ZCTA tot_pop_est gradeduc_ge25_pct);
	set gradeduc_ge25;
run;




/** Proportion of hispanic or latino residents **/
data hispanic (rename = (ZCTA_new = ZCTA));
	set socio.ACS_14_5YR_hispanic (keep = zipcode HD01_VD01 HD01_VD03);

	ZCTA_new = put(zipcode, z5.);

	if HD01_VD01 > 0 then hispanic_pct = HD01_VD03*100/HD01_VD01;
	drop zipcode;

run;

proc means data = hispanic n nmiss min p50 mean max maxdec = 2;
	var hispanic_pct;
	title1 "Check the distribution of percent hispanic for ZCTAs";
run;

data hispanic (keep = ZCTA HD01_VD01 HD01_VD03 rename = (HD01_VD01 = tot_pop_est HD01_VD03 = hispanic_est));
	set hispanic;
run;





/** Proportion of black residents **/
data black (rename = (ZCTA_new = ZCTA));
	set socio.ACS_14_5YR_black (keep = zipcode HD01_VD01 HD01_VD03);

	ZCTA_new = put(zipcode, z5.);

	if HD01_VD01 > 0 then black_pct = HD01_VD03*100/HD01_VD01;
	drop zipcode;

run;

proc means data = black n nmiss min p50 mean max maxdec = 2;
	var black_pct;
	title1 "Check the distribution of percent black for ZCTAs";
run;

data black (keep = ZCTA HD01_VD01 HD01_VD03 rename = (HD01_VD01 = tot_pop_est HD01_VD03 = black_est));
	set black;
run;






/** Proportion of residents under poverty **/
data poverty (rename = (ZCTA_new = ZCTA));
	set socio.ACS_14_5YR_poverty (keep = zipcode HC01_EST_VC01 HC02_EST_VC01);

	ZCTA_new = put(zipcode, z5.);

	if HC01_EST_VC01 > 0 then poverty_pct = HC02_EST_VC01*100/HC01_EST_VC01;
	drop zipcode;

run;

proc means data = poverty n nmiss min p50 mean max maxdec = 2;
	var poverty_pct;
	title1 "Check the distribution of percent below poverty line for ZCTAs ";
run;

data poverty (keep = ZCTA HC01_EST_VC01 HC02_EST_VC01 rename = (HC01_EST_VC01 = tot_pop_est HC02_EST_VC01 = poverty_est));
	set poverty;
run;




/** Proportion of residents in urban area **/
data Rural (rename = (ZCTA_new = ZCTA));
	set socio.DEC_10_Rural (keep = zipcode D001 D005);

	ZCTA_new = put(zipcode, z5.);

	if D001 > 0 then Rural_pct = D005*100/D001;
	drop zipcode;

run;

proc means data = Rural n nmiss min p50 mean max maxdec = 2;
	var Rural_pct;
	title1 "Check the distribution of percent living in rural area for ZCTAs ";
run;

data Rural (keep = ZCTA D001 D005 rename = (D001 = tot_pop_est D005 = Rural_est));
	set Rural;
run;



/*** Merge datasets together and get HSA estimates ***/
%sortdata2(network.ZCTAHsaHrr14, ZCTA);
%sortdata2(age_ge65, ZCTA);
%sortdata2(gradeduc_ge25, ZCTA);
%sortdata2(hispanic, ZCTA);
%sortdata2(poverty, ZCTA);
%sortdata2(Rural, ZCTA);
%sortdata2(black, ZCTA);



data network.HSA_socio_vars (drop = gradeduc_ge25_pct);
	merge network.ZCTAHsaHrr14 (in = a keep = hsanum ZCTA)
		  age_ge65 (in = b rename = (tot_pop_est = age_tot_pop_est))
		  gradeduc_ge25 (in = c rename = (tot_pop_est = educ_ge25_tot_pop_est))
		  hispanic (in = d rename = (tot_pop_est = hispanic_tot_pop_est))
		  poverty (in = e rename = (tot_pop_est = poverty_tot_pop_est))
		  Rural (in = f rename = (tot_pop_est = rural_tot_pop_est))
		  black (in = g rename = (tot_pop_est = black_tot_pop_est));

	by ZCTA;

	if a;

	gradeduc_ge25_est = round(educ_ge25_tot_pop_est*gradeduc_ge25_pct/100, 1);
run;


proc means data = network.HSA_socio_vars n nmiss;
	var age_tot_pop_est educ_ge25_tot_pop_est hispanic_tot_pop_est black_tot_pop_est poverty_tot_pop_est rural_tot_pop_est;
	title1 "Check number of missing variables at ZCTA level after merging with HSA to ZCTA xwalk";
run;


%sortdata2(network.HSA_socio_vars, hsanum);



data network.HSA_socio_vars (keep = hsanum age_tot_pop_hsa educ_ge25_tot_pop_hsa hispanic_tot_pop_hsa black_tot_pop_hsa poverty_tot_pop_hsa rural_tot_pop_hsa
												age_ge65_hsa gradeduc_ge25_hsa hispanic_hsa black_hsa poverty_hsa rural_hsa
												age_ge65_pct_hsa gradeduc_ge25_pct_hsa hispanic_pct_hsa black_pct_hsa poverty_pct_hsa rural_pct_hsa);
	set network.HSA_socio_vars;

	by hsanum;

	array pop[6] age_tot_pop_est educ_ge25_tot_pop_est hispanic_tot_pop_est black_tot_pop_est poverty_tot_pop_est rural_tot_pop_est;  
	array hsapop[6] age_tot_pop_hsa educ_ge25_tot_pop_hsa hispanic_tot_pop_hsa black_tot_pop_hsa poverty_tot_pop_hsa rural_tot_pop_hsa;

	array est[6] age_ge65_est gradeduc_ge25_est hispanic_est black_est poverty_est rural_est;  
	array hsaest[6] age_ge65_hsa gradeduc_ge25_hsa hispanic_hsa black_hsa poverty_hsa rural_hsa;

	array hsapct[6] age_ge65_pct_hsa gradeduc_ge25_pct_hsa hispanic_pct_hsa black_pct_hsa poverty_pct_hsa rural_pct_hsa;

	retain pop hsapop est hsaest hsapct;
 
	if first.hsanum then do;
		do i = 1 to 6;
			hsapop[i]=.;
			hsaest[i]=.; 
			hsapct[i]=.; 
		end;
	end;

	do i= 1 to 6;

		if not missing(est[i]) and not missing(pop[i]) then do;
			hsapop[i]=sum(pop[i], hsapop[i]);
			hsaest[i]=sum(est[i], hsaest[i]); 
		end;

	end;	

	if last.hsanum then do;
		do i= 1 to 6;
			if hsapop[i] > 0 then hsapct[i] = hsaest[i]/hsapop[i];
		end;
		output;
	end;
run;


proc means data = network.HSA_socio_vars n nmiss min mean max maxdec = 2;
	var age_ge65_pct_hsa gradeduc_ge25_pct_hsa hispanic_pct_hsa black_pct_hsa poverty_pct_hsa rural_pct_hsa;
	title1 "Check the distribution of HSA vars for HSANUMs";
run;
	


%sortdata2(network.cabg08_14_v22, zipcode);
%sortdata2(network.ZipHsaHrr14_v2, zipcode);




data network.cabg08_14_v23;
	merge network.cabg08_14_v22 (in = a)
		  network.ZipHsaHrr14_v2 (in = b keep = zipcode hsanum);

	by zipcode;

	if a;
run;


%sortdata2(network.HSA_socio_vars, hsanum);
%sortdata2(network.cabg08_14_v23, hsanum);


data network.cabg08_14_v23;
	merge network.cabg08_14_v23 (in = a)
		  network.HSA_socio_vars (in = b);

	by hsanum;

	if a;

	tot_pop_hsa = age_tot_pop_hsa;
run;



proc means data = network.cabg08_14_v23 n nmiss min mean max maxdec = 2;
	var age_ge65_pct_hsa gradeduc_ge25_pct_hsa hispanic_pct_hsa black_pct_hsa poverty_pct_hsa rural_pct_hsa;
	title1 "Check the distribution of HSA vars for patients";
run;




/**** Health care capacity measures ****/
/* Merge on patient zip to HSA, then merge on capacity measures by HSA */
/* Acute care hospital beds per 1000 residents
   PCPs per 100,000 residents
   Medical specialists per 100,000 residents
   Surgeons per 100,000 residents*/

%sortdata2(cap.hosp_acute_hsa_2012, hsanum);
%sortdata2(cap.phys_cap_hsa_2011, hsanum);


data network.cabg08_14_v23;
	merge network.cabg08_14_v23 (in = a)
		  cap.hosp_acute_hsa_2012 (in = b rename = (ACHbeds_per1000 = ACHbeds_per_1000))
		  cap.phys_cap_hsa_2011 (in = c);

	by hsanum;

	if a;
run;


proc means data = network.cabg08_14_v23 n nmiss min mean max maxdec = 2;
	var ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k;
	title1 "Check the distribution of HSA vars for patients";
run;




/**** Adding RTI race variable for update proportion of Hispanic patients ****/
%sortdata2(origmed.den_0716, bene_id file_year);
%sortdata2(network.cabg08_14_v23, bene_id admyear);


data network.cabg08_14_v23;
	merge network.cabg08_14_v23 (in = a)
		  origmed.den_0716 (in = b keep = bene_id file_year RACE rename = (file_year = admyear RACE = RTI_RACE));

	by bene_id admyear;

	if a;

run; 

proc freq data = network.cabg08_14_v23;
	tables RACE*RTI_RACE / nopercent;
	title1 "Check overlap between race and RTI race variable";
run;


data black_white_pts;
	set network.cabg08_14_v23 (where = (race in ("1" "2")));
run;



/**** Hospital-level measures - AHA variables already added ****/
/* No. patients - collapse from analytic file
   No. physicians - collapse from analytic file
   Proportion of patients from outside CBSA - merge on CBSA based on zip for hospital and patients, then collapse
   Academic hospital - Already have from AHA
   Charlson score - collapse from analytic file
   Proportion of patients living below federal poverty line* - merge on by zip/ZCTA then collapse from analytic file
   Proportion of patients with graduate education* - merge on by zip/ZCTA then collapse from analytic file
   Proportion of patients living in a rural area* - merge on by zip/ZCTA then collapse from analytic file
   Proportion of Hispanic patients - collapse from analytic file
   Proportion of black patients - collapse from analytic file */


/** Get number of physicians per hospital across all years **/

/** all phys **/
data hosp_allphys (drop = i);
	set black_white_pts (keep = prvnumgrp prfnpi_all);
	num_npis = countw(prfnpi_all, ' ');
	do i = 1 to num_npis;
      prfnpi = scan(prfnpi_all, i, ' ');
      output;
   end;
run;


proc sort data = hosp_allphys (keep = prvnumgrp prfnpi) nodupkey;
	by prvnumgrp prfnpi;
run;

proc freq data = hosp_allphys noprint;
	tables prvnumgrp / out = hosp_numphys (keep = prvnumgrp count rename = (count = num_phys_hosp));
run;

proc means data = hosp_numphys mean maxdec = 0;
	var num_phys_hosp;
	title1 "Mean number of physicians in hospital at hospital level";
run;



/*** Merge on hospital and patient CBSA, proportion of patients living below federal poverty line, with graduate education, and living in a rural area ***/

%sortdata2(network.zip_cbsa_032014, zip descending tot_ratio);

data zip_to_cbsa;
	set network.zip_cbsa_032014;
	by zip;
	if first.zip then output;
run;

proc means data = zip_to_cbsa maxdec = 2 min mean max;
	var tot_ratio;
run;

proc freq data = zip_to_cbsa order = freq noprint;
	tables cbsa / out = num_zip_per_cbsa;
run;


/*** Fill in missing hospital zip variable - based off AHA's MLOCZIP ***/
%sortdata2(black_white_pts, prvnumgrp mloczip descending admyear);

data hosp_zip;
	set black_white_pts (keep = prvnumgrp mloczip where = (mloczip ne ""));
	by prvnumgrp;
	if first.prvnumgrp then output;
run;


data valid_hosp_zip miss_hosp_zip;
	set black_white_pts;
	if not missing(mloczip) then output valid_hosp_zip;
	else output miss_hosp_zip;
run;



%sortdata2(miss_hosp_zip, prvnumgrp);


data filled_hosp_zip;
	merge miss_hosp_zip (in = a drop = mloczip)
		  hosp_zip (in = b);

	by prvnumgrp;

	if a;

run;

data black_white_pts;
	set valid_hosp_zip filled_hosp_zip;
run;

/*** Merge on hospital cbsa variable by hospital zip ***/
%sortdata2(black_white_pts, mloczip);	
%sortdata2(zip_to_cbsa, zip);

data black_white_pts;
	merge black_white_pts (in = a)
		  zip_to_cbsa (in = b keep = zip cbsa rename = (zip = mloczip cbsa = hosp_cbsa));

	by mloczip;

	if a;

run;	


proc freq data = black_white_pts;
	format hosp_cbsa $misschar.;
	tables hosp_cbsa;
	title1 "Check how many hospitals have missing CBSAs";
run;


/*** Merge on patient cbsa and ZCTA by patient zip ***/
%sortdata2(black_white_pts, zipcode);
%sortdata2(network.zip_to_zcta_2018, zipcode);


data black_white_pts;
	merge black_white_pts (in = a)
		  network.zip_to_zcta_2018 (in = b keep = zipcode ZCTA)
		  zip_to_cbsa (in = c keep = zip cbsa rename = (zip = zipcode cbsa = pat_cbsa));

	by zipcode;

	if a;
run;

proc freq data = black_white_pts;
	format pat_cbsa ZCTA $misschar.;
	tables pat_cbsa ZCTA ;
	title1 "Check how many patients have missing CBSAs and ZCTAs";
run;



/*** Merge on characteristics using ZCTA ***/ 

%sortdata2(black_white_pts, ZCTA);
%sortdata2(gradeduc_ge25, ZCTA);
%sortdata2(poverty, ZCTA);
%sortdata2(Rural, ZCTA);


data black_white_pts (drop = poverty_tot_pop_est poverty_est rural_tot_pop_est rural_est gradeduc_ge25_pct tot_pop_est);
	merge black_white_pts (in = a)
		  gradeduc_ge25
		  poverty (rename = (tot_pop_est = poverty_tot_pop_est))
		  Rural (rename = (tot_pop_est = rural_tot_pop_est));

	by ZCTA;

	length out_hospCBSA black hispanic 3;

	if a;

	if poverty_tot_pop_est > 0 then poverty_pct_zcta = poverty_est/poverty_tot_pop_est;
	if rural_tot_pop_est > 0 then rural_pct_zcta = rural_est/rural_tot_pop_est;

	gradeduc_ge25_pct_zcta = gradeduc_ge25_pct/100;

	if missing(pat_cbsa) or missing(hosp_cbsa) or (pat_cbsa  eq "99999" and hosp_cbsa eq "99999") then out_hospCBSA = .;
	else if strip(pat_cbsa) eq strip(hosp_cbsa) then out_hospCBSA = 0;
	else out_hospCBSA = 1;

	if strip(RTI_RACE) eq "2" then black = 1;
	else black = 0;

	if strip(RTI_RACE) eq "5" then hispanic = 1;
	else hispanic = 0;
	
run;


proc means data = black_white_pts n nmiss min p10 p25 mean p75 p90 max maxdec = 2;
	var gradeduc_ge25_pct_zcta poverty_pct_zcta rural_pct_zcta out_hospCBSA;
	title1 "Check ZCTA based variables at patient level";
run;
		  

/*** Collapse Characteristics to hospital level ***/
proc means data = black_white_pts mean noprint maxdec = 2;
	class prvnumgrp;
	var out_hospCBSA PCHRLSON gradeduc_ge25_pct_zcta poverty_pct_zcta rural_pct_zcta hispanic black;
	output out = hosp_chars mean(out_hospCBSA) = outCBSA_pct_hosp mean(PCHRLSON) = PCHRLSON_hosp mean(gradeduc_ge25_pct_zcta) = gradeduc_ge25_pct_hosp 
							mean(poverty_pct_zcta) = poverty_pct_hosp mean(rural_pct_zcta) = rural_pct_hosp mean(hispanic) = hispanic_pct_hosp
							mean(black) = black_pct_hosp;
run;


data hosp_chars (drop = _TYPE_ rename = (_FREQ_ = num_benes_hosp));
	set hosp_chars (where = (_TYPE_ eq 1));
run;


proc means data = hosp_chars n nmiss min p25 mean p50 p75 max maxdec = 2;
	var outCBSA_pct_hosp PCHRLSON_hosp gradeduc_ge25_pct_hosp poverty_pct_hosp rural_pct_hosp hispanic_pct_hosp black_pct_hosp;
	title1 "Check hospital vars at hospital level";
run;

%sortdata2(black_white_pts, prvnumgrp);
%sortdata2(hosp_chars, prvnumgrp);

data black_white_pts;
	merge black_white_pts (in = a)
		  hosp_chars (in = b)
		  hosp_numphys (in = c);

	by prvnumgrp;

	if a;

run;


proc means data = black_white_pts n nmiss mean maxdec = 2;
	var outCBSA_pct_hosp PCHRLSON_hosp gradeduc_ge25_pct_hosp poverty_pct_hosp rural_pct_hosp hispanic_pct_hosp black_pct_hosp num_phys_hosp num_benes_hosp;
	title1 "Check hospital vars at patient level";
run;

title;

/*proc contents data = black_white_pts varnum;
run;*/


/*** Create bene to hsanum xwalk and hospital level file requested by Xianshi and Hyesun - 08/07/19 ***/

/*** bene xwalk ***/
data network.bene_hsanum_xwalk;
	set black_white_pts (keep = bene_id admyear hsanum);
run;



/*** hospital level file ***/
proc sort data = black_white_pts (keep = prvnumgrp mloczip outCBSA_pct_hosp PCHRLSON_hosp gradeduc_ge25_pct_hosp poverty_pct_hosp 
											   rural_pct_hosp hispanic_pct_hosp black_pct_hosp num_phys_hosp num_benes_hosp teaching_hosp where = (not missing(mloczip))) nodupkey out = hospital_level;
	by mloczip prvnumgrp;

run; 

%sortdata2(network.ZipHsaHrr14_v2, zipcode)



data network.cabg08_14_hosp_level;
	merge hospital_level (in = a)
		  network.ZipHsaHrr14_v2 (in = b keep = zipcode hsanum rename = (zipcode = mloczip));

	by mloczip;

	if a;
run;


%sortdata2(network.HSA_socio_vars, hsanum);
%sortdata2(network.cabg08_14_hosp_level, hsanum);


data network.cabg08_14_hosp_level;
	merge network.cabg08_14_hosp_level (in = a)
		  network.HSA_socio_vars (in = b);

	by hsanum;

	if a;

	tot_pop_hsa = age_tot_pop_hsa;
run;

proc freq data = network.cabg08_14_hosp_level;
	tables hsanum / missing;
run;

proc print data = network.cabg08_14_hosp_level;
	where hsanum eq .;
run;

proc freq data = network.cabg08_14_hosp_level order = freq noprint;
	tables prvnumgrp / out = hosp_mult_zipcodes;
run;

proc freq data = hosp_mult_zipcodes;
	tables count;
run;
