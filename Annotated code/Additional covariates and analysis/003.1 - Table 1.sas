libname network "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data";
libname tables "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data\Tables";
libname origmed "G:\Hollingsworth\Data\Medicare";


/************************************************************
FILE: 003.1 - Table 1
AUTHOR: Phyllis
DATE: 26 April 2020
SUMMARY: GENERATING BENEFICIARY CHARACTERISTICS TABLE
************************************************************/


proc format;
   value $sex
      1='1 Male'
      2='2 Female'
      ;
   value $race
      0,3,4,6,5,1='1 White/Other/Unknown'
      2='2 Black'
      ;
   value ses_group
      0='1: Low'
      1='2: Medium'
	  2='3: High'
	  9='4: Missing'
      ;
	value elective_proc
	  0 = "0 Non elective"
	  1 = "1 Elective"
	;
	value DRG_cat
 	  1 = '1 Coronary bypass with PTCA with MCC'
	  2 = '2 Coronary bypass with PTCA without MCC'
	  3 = '3 Coronary bypass with cardiac catheterization with MCC'
	  4 = '4 Coronary bypass with cardiac catheterization without MCC'
	  5 = '5 Coronary bypass without cardiac catheterization with MCC' 
	  6 = '6 Coronary bypass without cardiac catheterization without MCC'
      7 = '7 Other'
     ;
	value klabmix
      0="0"
	  1="1"
	  2-high="2+"
	;
	 
	value dual_ind
		0 = "0 non-dual"
		1 = "1 dual"
	;
run; 


/*** Preparing data ***/
data black_white_pts;
	set network.cabg08_14_v24 (where = (race in ("1" "2")));
run;


proc freq data = black_white_pts;
	format sex $sex. race $race.  ses_group ses_group. elective_proc elective_proc. DRG_cat DRG_cat. klabmix klabmix.;
	tables segregation_level sex RACE ses_group elective_proc DRG_cat klabmix drg_cd;
run;

proc means data = black_white_pts  mean stddev maxdec = 1;
	var age_at_sadmsndt;
run;

data high_med_low;
	set black_white_pts;
	if segregation_level in ("low") then seg_level_num = 0;
	else if segregation_level in ("moderate") then seg_level_num = 1;
	else if segregation_level in ("high") then seg_level_num = 2;
	if missing(ses_group) then ses_group = 9;
run;



/*** Generating Summary Table ***/

%let groupvar=seg_level_num;
%let ds=high_med_low;
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



%freqs(sex, $sex.);
%freqs(race, $race.);
%freqs(ses_group, ses_group.);
%freqs(elective_proc, elective_proc.);
%freqs(DRG_cat, DRG_cat.);
%freqs(klabmix, klabmix.);
%freqs(dual_ind, dual_ind.);



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
ods msoffice2k style=minimal path=odsout file='Table1_withMediumSegregation.xls';
proc print data=tables.charvars noobs;
run;
ods msoffice2k close;
ods listing;
title;




%macro contvars(contvar);
proc means data = high_med_low mean stddev maxdec = 1;
	class seg_level_num;
	var &contvar;
run;

proc anova data=high_med_low;
	class seg_level_num;
	model &contvar = seg_level_num;
run;
quit;
%mend contvars;

%contvars(age_at_sadmsndt);









