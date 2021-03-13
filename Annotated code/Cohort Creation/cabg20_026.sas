/************************************************************
FILENAME: cabg20_026.sas (from cabgf2_032.sas)
AUTHOR: skaufman
DATE: 5/17/2017
ID: 54
SUMMARY: USE OUTPATIENT REV CENTER, MEDPAR, and PARTB TO DETERMINE ED VISITS.
THIS IS BASED ON WORK BY KEITH KOCHER AND MAGGIE YIN OF CHOP.
************************************************************/


/*** COHORT ***/

data cohort(drop=sadmsndt sdschrgdt);
   set cabg20.medp08_14(keep=bene_id PRVNUMGRP DSTNTNCD sadmsndt sadmsndt_coh sdschrgdt
     cabg_dt sdschrgdt_coh);
   if sadmsndt eq sadmsndt_coh and sdschrgdt eq sdschrgdt_coh;
run;

proc sort data=cohort nodupkey;
   by bene_id;
run;


/*** OUTPATIENTS ***/

%let k=bene_id claimindex rev_cntr hcpcs_cd REV_CHRG srev_dt;


/******* OUTPATIENT **********/

options VARLENCHK=NOWARN;

data cabg20.op08_14revs;
   length srev_dt 5;
   set
      med.op08revs(keep=BENE_ID REV_CNTR HCPCS_CD REV_CHRG srev_dt)
      med.op09revs(keep=BENE_ID REV_CNTR HCPCS_CD REV_CHRG srev_dt)
      med.op10revs(keep=BENE_ID REV_CNTR HCPCS_CD REV_CHRG srev_dt)
      med.op11revs(keep=BENE_ID REV_CNTR HCPCS_CD REV_CHRG REV_DT
         rename=(REV_DT=srev_dt))
      med.op12revs(keep=BENE_ID REV_CNTR HCPCS_CD REV_CNTR_TOT_CHRG_AMT REV_CNTR_DT
         rename=(REV_CNTR_TOT_CHRG_AMT=REV_CHRG REV_CNTR_DT=srev_dt))
      med.op13revs(keep=BENE_ID REV_CNTR HCPCS_CD REV_CNTR_TOT_CHRG_AMT REV_CNTR_DT
         rename=(REV_CNTR_TOT_CHRG_AMT=REV_CHRG REV_CNTR_DT=srev_dt))
      med.op14revs(keep=BENE_ID REV_CNTR HCPCS_CD REV_CNTR_TOT_CHRG_AMT REV_CNTR_DT
         rename=(REV_CNTR_TOT_CHRG_AMT=REV_CHRG REV_CNTR_DT=srev_dt))
      ;
run;

options VARLENCHK=WARN;

proc sort data=cabg20.op08_14revs;
   by bene_id srev_dt;
run;

data cabg20.op08_14revs;
   merge
      cohort(in=a)
      cabg20.op08_14revs
      ;
   by bene_id;
   if a;
run;

data ed_from_op;
   set cabg20.op08_14revs;
   if sdschrgdt_coh le srev_dt le sdschrgdt_coh+90;
run;

data ed_from_op;
   set ed_from_op(where=(substr(rev_cntr,1,3) eq '045' or rev_cntr eq '0981'));
run;

data ed_from_op;
   set ed_from_op;
   by bene_id;
   if first.bene_id;
run;



/** INPATIENTS FROM MEDPAR **/

%let k=bene_id sadmsndt sadmsndt_coh sdschrgdt sdschrgdt_coh SRC_ADMS DSTNTNCD er_amt;

data medp08_14;
   set cabg20.medp08_14(keep=&k);
   if sdschrgdt_coh le sadmsndt le sdschrgdt_coh+90;
run;

proc sort data=medp08_14;
   by bene_id sadmsndt;
run;

data medp08_14;
   set medp08_14;
   if er_amt gt 0; /* er_amt from Maggie Yin */
run;

data ed_from_medp;
   set medp08_14;
   by bene_id;
   if first.bene_id;
run;



/**** PHYSICIAN BILLING (PART B) ****/

data ed_from_nch(rename=(sdschrgdt=sdschrgdt_coh));
   set cabg20.nch07_14_coh_v6(keep=bene_id hcpcs_cd sdschrgdt plcsrvc sexpndt1);
   if hcpcs_cd in ('99281' '99282' '99283' '99284' '99285') or plcsrvc eq '23';
run;

%sortdata2(ed_from_nch,bene_id);

data ed_from_nch;
   set ed_from_nch;
   if sdschrgdt_coh le sexpndt1 le sdschrgdt_coh+90;
run;

data ed_from_nch;
   set ed_from_nch;
   by bene_id;
   if first.bene_id;
run;


/*** COMBINE FILES ***/

data ed_final;
   length source $ 4;
   merge
      ed_from_op(in=a keep=bene_id)
      ed_from_medp(in=b keep=bene_id)
      ed_from_nch(in=c keep=bene_id)
      ;
   by bene_id;
   from_outp=a;
   from_medp=b;
   from_ptb=c;
   source=cats(from_outp,from_medp,from_ptb);
   label source="source: outp/medp/ptb";
run;


%sortdata2(ed_final nodupkey,bene_id);

data cabg20.cabg08_14_v20;
   merge
      cabg20.cabg08_14_v19(in=a)
      ed_final(in=b)
      ;
   by bene_id;
   if a;
   ed_visit_90d=b;
run;

proc freq data=cabg20.cabg08_14_v20;
   tables source ed_visit_90d / missprint;
run;

proc freq data=cabg20.cabg08_14_v20;
   where 2008 le proc_yr le 2011;
   tables source ed_visit_90d / missprint;
   title1 "where 2008 le proc_yr 2011";
run;

