libname netmod "G:\Hollingsworth\ACOs\Network Analysis\Xianshi and Hyesun Project\Model code and data";

/************************************************************
FILE: 005 - Final model with sandwich estimator and sensitivity analyses
AUTHOR: Phyllis
DATE: 30 June 2020
SUMMARY: RUNNING MAIN MODEL AND SENSITIVITY ANALYSES
************************************************************/


proc format;
   value sex
      1='x1 Male'
      2='2 Female'
      ;
    value age_index
	  low-65='18-65'
      66-69='66-69'
      70-74='70-74'
      75-79='75-79'
      80-84='80-84'
      85-high='85+'
      ;
   value ses_group
      0='x1 Low'
      1='2 Medium'
	  2='3 High'
      ;
	value pchrlson
    	0 = "x0"
		1 = "1"
		2-high = "2+"
		;
	value hospbd
		0-250 = "x1 Small"
		>251-500 = "2 Medium"
		>500 - high = "3 High"
		;
	 value TVWB
	 	0 - 0.8627806 = "x0 Low Segregation"
		>0.8627806 - 0.8990240 = "1 Medium Segregation"
		>0.8990240 - high = "2 High Segregation"
		;
	 value black_ind
	 	0 = "x0 White"
		1 = "1 Black"
		;

	 value DRG_cat
	 	1, 2 = "1 DRG"
	  ;
run;



data Regdata (rename = (JSW = hospid));
	set netmod.RegData;
	if black eq 2 or white eq 2;

	black_ind = black eq 2;

	if missing(ses_group) then ses_group = 0;
	if missing(teaching_hosp) then teaching_hosp = 1;

	tot_pop_hsa = tot_pop_hsa/1000;
	black_hsa = black_hsa/1000;
	hispanic_hsa = hispanic_hsa/1000;

run;

/*** Main Model - White as referent ***/
proc genmod data= RegData descend order = formatted plots = none;
  format black_ind black_ind. TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd. SEX sex.;
  
  class TVWB black_ind PCHRLSON proc_yr (ref = '2008') SEX ses_group elective_proc (ref = '0')  
		nonpro (ref = '0') region (ref = '0') hospbd_mean_hosp teaching_hosp (ref = '0') hospid / param = glm;

  model patient_died_90d = proc_yr black_ind age_at_sadmsndt SEX PCHRLSON ses_group elective_proc  

                  				 TVWB num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp nonpro hospbd_mean_hosp region teaching_hosp 

                  				 ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k 
								 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa rural_pct_hsa 
								   
								
								/*** Interaction terms ***/
								proc_yr*black_ind age_at_sadmsndt*black_ind SEX*black_ind PCHRLSON*black_ind ses_group*black_ind  elective_proc*black_ind      

								black_ind*TVWB num_benes_hosp*black_ind  num_benesB_hosp*black_ind  num_phys_hosp*black_ind  outCBSA_pct_hosp*black_ind
								nonpro*black_ind  hospbd_mean_hosp*black_ind  region*black_ind   teaching_hosp*black_ind


 							    ACHbeds_per_1000*black_ind  PCPs_per_100k*black_ind  MedSpec_per_100k*black_ind  Surg_per_100k*black_ind
								tot_pop_hsa*black_ind  black_hsa*black_ind  hispanic_hsa*black_ind  poverty_pct_hsa*black_ind  gradeduc_ge25_pct_hsa*black_ind  
								rural_pct_hsa*black_ind     

								 / link = logit dist = binomial type3;

   repeated subject = hospid / type = ind covb ;
   lsmeans black_ind*TVWB / om diff cl ilink;
   lsmestimate black_ind*TVWB 0 0 1 -1 0 0;
   lsmestimate black_ind*TVWB 0 0 0 0 -1 1;
   lsmestimate black_ind*TVWB 0 0 1 0 -1 0;
   lsmestimate black_ind*TVWB 0 0 0 1 0 -1;

   ods output GEEEmpPEst = lgparms;
   store out = black_model;
run;



/*** Output model coefficients ***/

data odds_ratios (keep = Parm Level1 Level2 OR CI);
	set lgparms;
	OR = strip(put(exp(Estimate),5.2));
	CI = strip('(' || strip(put(exp(LowerCL), 5.2))||' to '||strip(put(exp(UpperCL), 5.2)) || ')');

	if missing(Z) then do;
		OR = '';
		CI='';
	end;
run;


filename odsout 'G:\Hollingsworth\ACOs\Network Analysis\Xianshi and Hyesun Project\Model code and data';
ods listing close;
ods msoffice2k style=minimal path=odsout file='Odds Ratios.xls';

proc print data = odds_ratios noobs;
title 'Odds Ratios';
run;

ods msoffice2k close;
ods listing;
title;




/*** Main model - black as referent ***/
proc format;
	 value black_ind
	 	0 = "0 White"
		1 = "x1 Black"
		;
run;


proc genmod data= RegData descend order = formatted plots = none;
  format black_ind black_ind. TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd.;
  
  class TVWB black_ind PCHRLSON proc_yr SEX ses_group elective_proc nonpro region hospbd_mean_hosp teaching_hosp hospid / param = glm;

  model patient_died_90d = proc_yr black_ind age_at_sadmsndt SEX PCHRLSON ses_group elective_proc  

                  				 TVWB num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp nonpro hospbd_mean_hosp region teaching_hosp 

                  				 ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k 
								 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa rural_pct_hsa 
								   
								
								/*** Interaction terms ***/
								proc_yr*black_ind age_at_sadmsndt*black_ind SEX*black_ind PCHRLSON*black_ind ses_group*black_ind  elective_proc*black_ind      

								black_ind*TVWB num_benes_hosp*black_ind  num_benesB_hosp*black_ind  num_phys_hosp*black_ind  outCBSA_pct_hosp*black_ind
								nonpro*black_ind  hospbd_mean_hosp*black_ind  region*black_ind   teaching_hosp*black_ind


 							    ACHbeds_per_1000*black_ind  PCPs_per_100k*black_ind  MedSpec_per_100k*black_ind  Surg_per_100k*black_ind
								tot_pop_hsa*black_ind  black_hsa*black_ind  hispanic_hsa*black_ind  poverty_pct_hsa*black_ind  gradeduc_ge25_pct_hsa*black_ind  
								rural_pct_hsa*black_ind     

								 / link = logit dist = binomial type3;

   repeated subject = hospid / type = ind covb ;
   lsmeans black_ind*TVWB / om diff cl ilink;
   lsmestimate black_ind*TVWB 0 0 1 -1 0 0;
   lsmestimate black_ind*TVWB 0 0 0 0 -1 1;
   lsmestimate black_ind*TVWB 0 0 1 0 -1 0;
   lsmestimate black_ind*TVWB 0 0 0 1 0 -1;
   ods select nobs lsmeans lsmeandiffs;
run;





/*** Recycled Predictions ***/
data black_low;
	set RegData (rename = (black_ind = race_ind TVWB = seg_meas));
	black_ind = 1;
	TVWB = 0;
run;


data white_low;
	set RegData (rename = (black_ind = race_ind TVWB = seg_meas));
	black_ind = 0;
	TVWB = 0;
run;


data black_high;
	set RegData (rename = (black_ind = race_ind TVWB = seg_meas));
	black_ind = 1;
	TVWB = 1;
run;


data white_high;
	set RegData (rename = (black_ind = race_ind TVWB = seg_meas));
	black_ind = 0;
	TVWB = 1;
run;


proc plm source=black_model;
    score data=black_low out=black_low_pred pred=black_low_p lclm=black_low_lcl uclm=black_low_ucl / ilink;
run;

proc plm source=black_model;
    score data=white_low out=white_low_pred pred=white_low_p lclm=white_low_lcl uclm=white_low_ucl / ilink;
run;

proc plm source=black_model;
    score data=black_high out=black_high_pred pred=black_high_p lclm=black_high_lcl uclm=black_high_ucl / ilink;
run;

proc plm source=black_model;
    score data=white_high out=white_high_pred pred=white_high_p lclm=white_high_lcl uclm=white_high_ucl / ilink;
run;


%sortdata2(black_low_pred, rownames);
%sortdata2(white_low_pred, rownames);
%sortdata2(black_high_pred, rownames);
%sortdata2(white_high_pred, rownames);



data race_seg_preds;
	merge black_low_pred white_low_pred black_high_pred white_high_pred;
	by rownames;

	black_low_p = black_low_p*100;
	white_low_p = white_low_p*100;
	black_high_p = black_high_p*100;
	white_high_p = white_high_p*100;

run;


proc means data = race_seg_preds n mean std min max lclm uclm maxdec = 1;
	var black_low_p white_low_p black_high_p white_high_p;
run;

PROC TTEST data=race_seg_preds plots = none;
 paired black_low_p*white_low_p black_high_p*white_high_p black_high_p*black_low_p white_high_p*white_low_p;
RUN; 


/**** Sensitivity Analyses ****/

/*** Adjusting for DRG_Cat ****/
proc format;
	 value black_ind
	 	0 = "x0 White"
		1 = "1 Black"
		;
run;

proc genmod data= RegData descend order = formatted plots = none;
  format black_ind black_ind. TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd. DRG_cat DRG_cat.;
  
  class TVWB black_ind PCHRLSON proc_yr SEX ses_group elective_proc DRG_cat nonpro region hospbd_mean_hosp teaching_hosp hospid / param = glm;

  model patient_died_90d = TVWB black_ind PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc DRG_cat nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*black_ind  age_at_sadmsndt*black_ind  proc_yr*black_ind  SEX*black_ind
								num_benes_hosp*black_ind  num_benesB_hosp*black_ind  num_phys_hosp*black_ind  outCBSA_pct_hosp*black_ind
 							    tot_pop_hsa*black_ind  black_hsa*black_ind  hispanic_hsa*black_ind  poverty_pct_hsa*black_ind  gradeduc_ge25_pct_hsa*black_ind  
								rural_pct_hsa*black_ind  ACHbeds_per_1000*black_ind  PCPs_per_100k*black_ind  MedSpec_per_100k*black_ind  Surg_per_100k*black_ind
								ses_group*black_ind  elective_proc*black_ind  DRG_cat*black_ind  nonpro*black_ind  region*black_ind  hospbd_mean_hosp*black_ind  teaching_hosp*black_ind 


								black_ind*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans black_ind*TVWB / om cl ilink;
   ods select nobs lsmeans;
   title1 "Adjusting for DRG";
run;

proc format;
	 value black_ind
	 	0 = "0 White"
		1 = "x1 Black"
		;
run;

proc genmod data= RegData descend order = formatted plots = none;
  format black_ind black_ind. TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd. DRG_cat DRG_cat.;
  
  class TVWB black_ind PCHRLSON proc_yr SEX ses_group elective_proc DRG_cat nonpro region hospbd_mean_hosp teaching_hosp hospid / param = glm;

  model patient_died_90d = TVWB black_ind PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc DRG_cat nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*black_ind  age_at_sadmsndt*black_ind  proc_yr*black_ind  SEX*black_ind
								num_benes_hosp*black_ind  num_benesB_hosp*black_ind  num_phys_hosp*black_ind  outCBSA_pct_hosp*black_ind
 							    tot_pop_hsa*black_ind  black_hsa*black_ind  hispanic_hsa*black_ind  poverty_pct_hsa*black_ind  gradeduc_ge25_pct_hsa*black_ind  
								rural_pct_hsa*black_ind  ACHbeds_per_1000*black_ind  PCPs_per_100k*black_ind  MedSpec_per_100k*black_ind  Surg_per_100k*black_ind
								ses_group*black_ind  elective_proc*black_ind  DRG_cat*black_ind  nonpro*black_ind  region*black_ind  hospbd_mean_hosp*black_ind  teaching_hosp*black_ind 


								black_ind*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans black_ind*TVWB / om cl ilink;
   ods select nobs lsmeans;
   title1 "Adjusting for DRG";
run;




/*** removing patients with 3 day mortality ****/
proc format;
	 value $RACE
	 	1 = "x0 White"
		2 = "1 Black"
		;
run;

proc genmod data= netmod.death_3days descend /*order = formatted*/ plots = none;
  format RACE $RACE.; /*TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd.;*/
  
  class TVWB RACE PCHRLSON proc_yr SEX ses_group elective_proc nonpro region hospbd_mean_hosp teaching_hosp /*hospid*/ / param = glm;

  model patient_died_90d = TVWB RACE PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*RACE  age_at_sadmsndt*RACE  proc_yr*RACE  SEX*RACE
								num_benes_hosp*RACE  num_benesB_hosp*RACE  num_phys_hosp*RACE  outCBSA_pct_hosp*RACE
 							    tot_pop_hsa*RACE  black_hsa*RACE  hispanic_hsa*RACE  poverty_pct_hsa*RACE  gradeduc_ge25_pct_hsa*RACE  
								rural_pct_hsa*RACE  ACHbeds_per_1000*RACE  PCPs_per_100k*RACE  MedSpec_per_100k*RACE  Surg_per_100k*RACE
								ses_group*RACE  elective_proc*RACE  nonpro*RACE  region*RACE  hospbd_mean_hosp*RACE  teaching_hosp*RACE 


								RACE*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans RACE*TVWB / om cl ilink;
   ods select nobs lsmeans;
   title1 "No 3 day mortality";
run;

proc format;
	 value $RACE
	 	1 = "0 White"
		2 = "x1 Black"
		;
run;

proc genmod data= netmod.death_3days descend /*order = formatted*/ plots = none;
  format RACE $RACE.; /*TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd.;*/
  
  class TVWB RACE PCHRLSON proc_yr SEX ses_group elective_proc nonpro region hospbd_mean_hosp teaching_hosp /*hospid*/ / param = glm;

  model patient_died_90d = TVWB RACE PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*RACE  age_at_sadmsndt*RACE  proc_yr*RACE  SEX*RACE
								num_benes_hosp*RACE  num_benesB_hosp*RACE  num_phys_hosp*RACE  outCBSA_pct_hosp*RACE
 							    tot_pop_hsa*RACE  black_hsa*RACE  hispanic_hsa*RACE  poverty_pct_hsa*RACE  gradeduc_ge25_pct_hsa*RACE  
								rural_pct_hsa*RACE  ACHbeds_per_1000*RACE  PCPs_per_100k*RACE  MedSpec_per_100k*RACE  Surg_per_100k*RACE
								ses_group*RACE  elective_proc*RACE  nonpro*RACE  region*RACE  hospbd_mean_hosp*RACE  teaching_hosp*RACE 


								RACE*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans RACE*TVWB / om cl ilink;
   ods select nobs lsmeans;
   title1 "No 3 day mortality";
run;


/*** excluding physicians ****/
proc format;
	 value $RACE
	 	1 = "x0 White"
		2 = "1 Black"
		;
run;

proc genmod data= netmod.physicians_excluded descend /*order = formatted*/ plots = none;
  format RACE $RACE.; /*TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd.;*/
  
  class TVWB RACE PCHRLSON proc_yr SEX ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp /*hospid*/ / param = glm;

  model patient_died_90d = TVWB RACE PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*RACE  age_at_sadmsndt*RACE  proc_yr*RACE  SEX*RACE
								num_benes_hosp*RACE  num_benesB_hosp*RACE  num_phys_hosp*RACE  outCBSA_pct_hosp*RACE
 							    tot_pop_hsa*RACE  black_hsa*RACE  hispanic_hsa*RACE  poverty_pct_hsa*RACE  gradeduc_ge25_pct_hsa*RACE  
								rural_pct_hsa*RACE  ACHbeds_per_1000*RACE  PCPs_per_100k*RACE  MedSpec_per_100k*RACE  Surg_per_100k*RACE
								ses_group*RACE  elective_proc*RACE  nonpro*RACE  region*RACE  hospbd_mean_hosp*RACE  teaching_hosp*RACE 


								RACE*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans RACE*TVWB / om cl ilink;
   ods select nobs lsmeans;
   title1 "Excluding physicians";
run;

proc format;
	 value $RACE
	 	1 = "0 White"
		2 = "x1 Black"
		;
run;

proc genmod data= netmod.physicians_excluded descend /*order = formatted*/ plots = none;
  format RACE $RACE.; /*TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd.;*/
  
  class TVWB RACE PCHRLSON proc_yr SEX ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp /*hospid*/ / param = glm;

  model patient_died_90d = TVWB RACE PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*RACE  age_at_sadmsndt*RACE  proc_yr*RACE  SEX*RACE
								num_benes_hosp*RACE  num_benesB_hosp*RACE  num_phys_hosp*RACE  outCBSA_pct_hosp*RACE
 							    tot_pop_hsa*RACE  black_hsa*RACE  hispanic_hsa*RACE  poverty_pct_hsa*RACE  gradeduc_ge25_pct_hsa*RACE  
								rural_pct_hsa*RACE  ACHbeds_per_1000*RACE  PCPs_per_100k*RACE  MedSpec_per_100k*RACE  Surg_per_100k*RACE
								ses_group*RACE  elective_proc*RACE  nonpro*RACE  region*RACE  hospbd_mean_hosp*RACE  teaching_hosp*RACE 


								RACE*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans RACE*TVWB / om cl ilink;
   ods select nobs lsmeans;
   title1 "Excluding physicians";
run;

title;



/**** Sensitivity Analyses Differences ****/
/*** Adjusting for DRG_Cat ****/
proc format;
	 value $RACE
	 	1 = "x0 White"
		2 = "1 Black"
		;
run;

proc genmod data= RegData descend order = formatted plots = none;
  format black_ind black_ind. TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd. DRG_cat DRG_cat.;
  
  class TVWB black_ind PCHRLSON proc_yr SEX ses_group elective_proc DRG_cat nonpro region hospbd_mean_hosp teaching_hosp hospid / param = glm;

  model patient_died_90d = TVWB black_ind PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc DRG_cat nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*black_ind  age_at_sadmsndt*black_ind  proc_yr*black_ind  SEX*black_ind
								num_benes_hosp*black_ind  num_benesB_hosp*black_ind  num_phys_hosp*black_ind  outCBSA_pct_hosp*black_ind
 							    tot_pop_hsa*black_ind  black_hsa*black_ind  hispanic_hsa*black_ind  poverty_pct_hsa*black_ind  gradeduc_ge25_pct_hsa*black_ind  
								rural_pct_hsa*black_ind  ACHbeds_per_1000*black_ind  PCPs_per_100k*black_ind  MedSpec_per_100k*black_ind  Surg_per_100k*black_ind
								ses_group*black_ind  elective_proc*black_ind  DRG_cat*black_ind  nonpro*black_ind  region*black_ind  hospbd_mean_hosp*black_ind  teaching_hosp*black_ind 


								black_ind*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans black_ind*TVWB / om cl ilink diff;

   lsmestimate black_ind*TVWB  0 0 1 -1 0 0;
   lsmestimate black_ind*TVWB  0 0 0 0 1 -1;
   lsmestimate black_ind*TVWB  0 0 1 0 -1 0;
   lsmestimate black_ind*TVWB  0 0 0 1 0 -1;
   title1 "Adjusting for DRG";
run;




/*** removing patients with 3 day mortality ****/

proc genmod data= netmod.death_3days descend /*order = formatted*/ plots = none;
  format RACE $RACE.; /*TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd.;*/
  
  class TVWB RACE PCHRLSON proc_yr SEX ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp /*hospid*/ / param = glm;

  model patient_died_90d = TVWB RACE PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*RACE  age_at_sadmsndt*RACE  proc_yr*RACE  SEX*RACE
								num_benes_hosp*RACE  num_benesB_hosp*RACE  num_phys_hosp*RACE  outCBSA_pct_hosp*RACE
 							    tot_pop_hsa*RACE  black_hsa*RACE  hispanic_hsa*RACE  poverty_pct_hsa*RACE  gradeduc_ge25_pct_hsa*RACE  
								rural_pct_hsa*RACE  ACHbeds_per_1000*RACE  PCPs_per_100k*RACE  MedSpec_per_100k*RACE  Surg_per_100k*RACE
								ses_group*RACE  elective_proc*RACE  nonpro*RACE  region*RACE  hospbd_mean_hosp*RACE  teaching_hosp*RACE 


								RACE*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans RACE*TVWB / om cl ilink diff;

   lsmestimate RACE*TVWB 1 -1 0 0 0 0;
   lsmestimate RACE*TVWB 0 0 1 -1 0 0;
   lsmestimate RACE*TVWB 1 0 -1 0 0 0;
   lsmestimate RACE*TVWB 0 1 0 -1 0 0;
   title1 "No 3 day mortality";
run;




/*** excluding physicians ****/

proc genmod data= netmod.physicians_excluded descend /*order = formatted*/ plots = none;
  format RACE $RACE.; /*TVWB TVWB. PCHRLSON pchrlson. ses_group ses_group. hospbd_mean_hosp hospbd.;*/
  
  class TVWB RACE PCHRLSON proc_yr SEX ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp /*hospid*/ / param = glm;

  model patient_died_90d = TVWB RACE PCHRLSON age_at_sadmsndt proc_yr SEX
                  				 num_benes_hosp num_benesB_hosp num_phys_hosp outCBSA_pct_hosp
                  				 tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa 
								rural_pct_hsa ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k
								ses_group elective_proc  nonpro region hospbd_mean_hosp teaching_hosp 

								PCHRLSON*RACE  age_at_sadmsndt*RACE  proc_yr*RACE  SEX*RACE
								num_benes_hosp*RACE  num_benesB_hosp*RACE  num_phys_hosp*RACE  outCBSA_pct_hosp*RACE
 							    tot_pop_hsa*RACE  black_hsa*RACE  hispanic_hsa*RACE  poverty_pct_hsa*RACE  gradeduc_ge25_pct_hsa*RACE  
								rural_pct_hsa*RACE  ACHbeds_per_1000*RACE  PCPs_per_100k*RACE  MedSpec_per_100k*RACE  Surg_per_100k*RACE
								ses_group*RACE  elective_proc*RACE  nonpro*RACE  region*RACE  hospbd_mean_hosp*RACE  teaching_hosp*RACE 


								RACE*TVWB / link = logit dist = binomial type3;

   /*repeated subject = hospid / type = ind covb ;*/
   lsmeans RACE*TVWB / om cl ilink diff;

   lsmestimate RACE*TVWB 1 -1 0 0 0 0;
   lsmestimate RACE*TVWB 0 0 1 -1 0 0;
   lsmestimate RACE*TVWB 1 0 -1 0 0 0;
   lsmestimate RACE*TVWB 0 1 0 -1 0 0;
   title1 "Excluding physicians";
run;




