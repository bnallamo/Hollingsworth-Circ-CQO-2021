libname network "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data";
libname tables "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Revisions\Data\Tables\Hospital";


/************************************************************
FILE: 003.2 - Table 2
AUTHOR: Phyllis
DATE: 26 April 2020
SUMMARY: GENERATING HOSPITAL AND HSA CHARACTERSISTICS TABLE
************************************************************/

proc format;

	value hosp_bedsize
	  1 = "1 Small"
	  2  = "2 Medium"
	  3 = "3 Large"
	;
	value nonpro
	  0 = '0 For profit'
	  1 = '1 Not for profit'
	  2 = '2 Other'
	;
	value teach
	  0 = "1 Non teaching"
	  1 = "2 Teaching"
	;
	value urban
      0='1 Rural'
      1='2 Urban'
     ;
	value region
      0="3 South"
      1="1 Northeast"
      2="4 West"
      3="2 Midwest"
    ;
run; 


/*** Preparing data ***/
data black_white_pts;
	set network.cabg08_14_v24 (where = (race in ("1" "2")));
run;

%sortdata2(black_white_pts, prvnumgrp admyear);

data hosp_level;
	set black_white_pts;
	by prvnumgrp admyear;

	if 0 <= hospbd_mean_hosp <= 250 then hosp_bedsize = 1;
	else if 251 <= hospbd_mean_hosp <= 500 then hosp_bedsize = 2;
	else if 501 <= hospbd_mean_hosp then hosp_bedsize = 3;

	tot_pop_hsa = tot_pop_hsa/1000;
	black_hsa = black_hsa/1000;
	hispanic_hsa = hispanic_hsa/1000;

	if last.prvnumgrp then output;
run;


proc means data = black_white_pts mean noprint maxdec = 2;
	class prvnumgrp;
	var black;
	output out = hosp_chars sum(black) = num_black_benes_hosp;
run;


data hosp_chars (drop = _TYPE_ _FREQ_);
	set hosp_chars (where = (_TYPE_ eq 1));
run;

proc sort data = network.cabg08_14_hosp_loc_demo_info nodupkey out = hosp_chars_2;
	by prvnumgrp;
run;


data hosp_level;
	merge hosp_level (in = a)
	      hosp_chars (keep = prvnumgrp num_black_benes_hosp);
		  hosp_chars_2 (keep = prvnumgrp female_pct_hosp age_hosp);

	by prvnumgrp;

	if a;

run;	


proc freq data = hosp_level;
	format nonpro nonpro. hosp_bedsize hosp_bedsize. Region region. urban urban. teaching_hosp teach.;
	tables segregation_level nonpro hosp_bedsize Region urban teaching_hosp;
run;


proc means data =  hosp_level mean stddev maxdec = 1;
	var num_benes_hosp num_black_benes_hosp num_phys_hosp outCBSA_pct_hosp /*PCHRLSON_hosp age_hosp female_pct_hosp*/ CABG_volume_mean_hosp
		tot_pop_hsa black_hsa hispanic_hsa poverty_pct_hsa gradeduc_ge25_pct_hsa rural_pct_hsa
		ACHbeds_per_1000 PCPs_per_100k MedSpec_per_100k Surg_per_100k;
run;



data high_med_low_hosp_level;
	set hosp_level;
	if segregation_level in ("low") then seg_level_num = 0;
	else if segregation_level in ("moderate") then seg_level_num = 1;
	else if segregation_level in ("high") then seg_level_num = 2;
run;

/*** Generating Summary Table ***/

%let groupvar=seg_level_num;
%let ds=high_med_low_hosp_level;
%let levels=3;


%macro freqs(var, fmt);
ods output ChiSq=chisq_&var (keep=Prob Statistic);
proc freq data=&ds;
	tables &var*&groupvar / chisq norow nopercent OUTPCT sparse out=tables.freq_&var;
	format &var &fmt;
run;
data tables.freq_&var (drop=&var);
	length varname $30;
	set tables.freq_&var (keep=PCT_COL count &groupvar &var);
	varname="&var"||''||strip(put(&var,&fmt));
	if PCT_COL eq . then delete;
	format &var &fmt;
run;
data chisq_&var (drop=statistic);
	set chisq_&var;
	if statistic ne "Chi-Square" then delete;
	varname="&var";
run; 
proc sort data=tables.freq_&var;
	by varname;
run;
%mend freqs;

 
%freqs(nonpro, nonpro.);
%freqs(hosp_bedsize, hosp_bedsize.);
%freqs(Region, region.);
%freqs(urban, urban.);
%freqs(teaching_hosp, teach.);



data tables.charvars_pval;
	length varname $30;
	set chisq:;
run;

data tables.charvars_long;
	set tables.freq_:;
	by varname;
	retain varnum;
	if first.varname then do;
		varnum+1;
	end;
run; 

proc sort data=tables.charvars_long;
	by varnum;
run;

data tables.charvars_wide;
	length gp1-gp&levels $20;
	set tables.charvars_long;
	by varnum;
	keep varname gp1-gp&levels;
	retain gp1-gp&levels;
	array a (1:&levels) gp1-gp&levels;
	cnt=count;
	pct=strip(put(pct_col, 8.0));
	if first.varnum then do;
    	do i = 1 to &levels;
      		a( i ) = '';
    	end;
  	end;
	a(&groupvar+1)=strip(cnt)||''||"("||strip(pct)||")";
	if last.varnum;
run;
proc sort data=tables.charvars_wide;
	by varname;
run;
data tables.charvars;
	length varname $30;
	set tables.charvars_wide tables.charvars_pval;
run;
proc sort data=tables.charvars;
	by varname;
run;


filename odsout 'G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Revisions\Output';
ods listing close;
ods msoffice2k style=minimal path=odsout file='Table2_withMediumSegregation.xls';
proc print data=tables.charvars noobs;
run;
ods msoffice2k close;
ods listing;
title;




%macro contvars(contvar);
proc means data = high_med_low_hosp_level mean stddev maxdec = 1;
	class seg_level_num;
	var &contvar;
run;

proc anova data=high_med_low_hosp_level;
	class seg_level_num;
	model &contvar = seg_level_num;
run;
quit;
%mend contvars;



%contvars(num_benes_hosp); 
%contvars(num_black_benes_hosp); 
%contvars(num_phys_hosp); 
%contvars(outCBSA_pct_hosp); 
/*%contvars(PCHRLSON_hosp); 
%contvars(age_hosp); 
%contvars(female_pct_hosp);*/ 
%contvars(CABG_volume_mean_hosp);
%contvars(tot_pop_hsa); 
%contvars(black_hsa); 
%contvars(hispanic_hsa); 
%contvars(poverty_pct_hsa); 
%contvars(gradeduc_ge25_pct_hsa); 
%contvars(rural_pct_hsa);
%contvars(ACHbeds_per_1000); 
%contvars(PCPs_per_100k); 
%contvars(MedSpec_per_100k); 
%contvars(Surg_per_100k);


proc means data = high_med_low_hosp_level p50 maxdec = 2;
	class seg_level_num;
	var TVWB;
run;

proc means data = high_med_low_hosp_level p50 maxdec = 2;
	var TVWB;
run;












