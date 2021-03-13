/************************************************************
FILENAME: cabg20_008.SAS (from tdiff_010.sas)
AUTHOR: skaufman
DATE: 4/27/2017
ID: 54
SUMMARY: DO CASEMIX ADJUSTMENT BASED ON KLABUNDE. CREATES TO_RULEOUT DATA
SET.  
************************************************************/

proc sort data=cabg20.cabg08_14_v4(keep=bene_id sadmsndt cabg_dt rename=(sadmsndt=idxdate))
     out=cohort nodupkey;
   by bene_id;
run;


options varlenchk=nowarn;

data medp07_14;  
  length sadmsndt 5 filetype $ 1;
   set
      med.med07p20(keep=BENE_ID sadmsndt DGNS_CD: PRCDR_CD: LOSCNT )
      med.med08p20(keep=BENE_ID sadmsndt DGNS_CD: PRCDR_CD: LOSCNT )
      med.med09p20(keep=BENE_ID sadmsndt DGNS_CD: PRCDR_CD: LOSCNT )
      med.med10p20(keep=BENE_ID sadmsndt DGNS_CD: PRCDR_CD: LOSCNT)
      med.med11p20(keep=BENE_ID sadmsndt DGNSCD1-DGNSCD25 PRCDRCD1-PRCDRCD25 LOSCNT
                rename=(DGNSCD1-DGNSCD25=DGNS_CD1-DGNS_cd25 
            PRCDRCD1-PRCDRCD25=PRCDR_CD1-PRCDR_CD25))
      med.med12p20( keep=BENE_ID sadmsndt DGNS_CD1-DGNS_CD25 PRCDR_CD1-PRCDR_CD25 LOS_DAY_CNT
                sdschrgdt rename=(LOS_DAY_CNT=LOSCNT))
      med.med13p20( keep=BENE_ID sadmsndt
           DGNS_1_CD--DGNS_25_CD
           SRGCL_PRCDR_1_CD--SRGCL_PRCDR_25_CD LOS_DAY_CNT
                rename=(
                  LOS_DAY_CNT=LOSCNT
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
                  ))
      med.med14p20( keep=BENE_ID sadmsndt
           DGNS_1_CD--DGNS_25_CD
           SRGCL_PRCDR_1_CD--SRGCL_PRCDR_25_CD LOS_DAY_CNT
                rename=(
                  LOS_DAY_CNT=LOSCNT
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
                  ))
                  ;
   filetype="M";
run;

options varlenchk=warn;

%sortdata2(medp07_14,bene_id);

data cabg20.medp07_14_klab;
   merge
      cohort(in=a)
      medp07_14(in=b)
      ;
   by bene_id;
   if a and b;
run;


/******* OUTPATIENT **********/

/* Now I'm going to create an outpatient data set that combines the two
   kinds of outpatient files to get something similar to SEER outpatient */
/* This is needlessly complex because the charming fellows at Dartmouth keep
   changing things like variable type, length, and name, almost at random it
   seems. */


%macro op(year);

%sortdata2(med.op&year.clms,bene_id);

data op&year.clms;
   length sfromdt 5 sthrudt 5;
   merge 
      med.op&year.clms(in=a
   %if &year eq 10 %then %do;
          rename=(clm_id=claimindex)
   %end;
   %if &year eq 11 %then %do;
          rename=(clm_id=claimindex ICD_DGNS_CD1-ICD_DGNS_CD25=dgns_cd1-dgns_cd25
                 FROM_DT=sfromdt THRU_DT=sthrudt)
   %end;
   %if &year eq 12 %then %do;
          rename=(clm_id=claimindex ICD_DGNS_CD1-ICD_DGNS_CD25=dgns_cd1-dgns_cd25
                 CLM_FROM_DT=sfromdt CLM_THRU_DT=sthrudt)
   %end;
   %if &year eq 13 %then %do;
          rename=(clm_id=claimindex ICD_DGNS_CD1-ICD_DGNS_CD25=dgns_cd1-dgns_cd25
                 CLM_FROM_DT=sfromdt CLM_THRU_DT=sthrudt)
   %end;
   %if &year eq 14 %then %do;
          rename=(clm_id=claimindex ICD_DGNS_CD1-ICD_DGNS_CD25=dgns_cd1-dgns_cd25
                 CLM_FROM_DT=sfromdt CLM_THRU_DT=sthrudt)
   %end;
        )
      cohort(in=b)
      ;
   by bene_id;
   if a and b;
   format sfromdt sthrudt mmddyy10.;
run;
proc sort data=op&year.clms;
   by bene_id claimindex;
run;

%sortdata2(med.op&year.revs,bene_id);

data op&year.revs;
   length srev_dt 5;
   merge
      med.op&year.revs(in=a 
   %if &year eq 10 %then %do;
         rename=(clm_id=claimindex)
   %end;
   %if &year eq 11 %then %do;
         rename=(clm_id=claimindex REV_DT=srev_dt)
         drop=THRU_DT
   %end;
   %if &year eq 12 %then %do;
         rename=(clm_id=claimindex REV_CNTR_DT=srev_dt)
         drop=CLM_THRU_DT
   %end;
   %if &year eq 13 %then %do;
         rename=(clm_id=claimindex REV_CNTR_DT=srev_dt)
         drop=CLM_THRU_DT
   %end;
   %if &year eq 14 %then %do;
         rename=(clm_id=claimindex REV_CNTR_DT=srev_dt)
         drop=CLM_THRU_DT
   %end;
         )
      cohort(in=b keep=bene_id)
      ;
   by bene_id;
   if a and b;
   format srev_dt mmddyy10.;
run;

proc sort data=op&year.revs;
   by bene_id claimindex;
run;

data outp&year._klab;
   merge
      op&year.clms(in=a)
      op&year.revs
      ;
   by bene_id claimindex;
   if a;
run;

%if &year eq 06 or &year eq 07 %then %do;
data outp&year._klab(rename=(x=claimindex));
   length x $ 15;
   set outp&year._klab;
   x=claimindex||"";
   drop claimindex;
run;
%end;

data outp&year._klab;
   set outp&year._klab;
   if sfromdt eq . then delete; /* NOTE: before I put in other restrictions
                                   to preclude missingness, but my review
                                   of the SEER outpatient indicated that
                                   only the from_date was always there. */
   filetype="O";
   array op[*] _character_;
   do i=1 to dim(op);
      op[i]=strip(op[i]);
   end;
run;

data outp&year._klab;
   length filetype $ 1;
   set outp&year._klab;
run;

%mend op;

%op(07);
%op(08);
%op(09);
%op(10);
%op(11);
%op(12);
%op(13);
%op(14);


data cabg20.outp07_14_klab(keep=filetype cabg_dt idxdate claimindex sfromdt sthrudt 
     BENE_ID dgns_cd1-dgns_cd25 srev_dt HCPCS_CD);
   length PDGNS_CD $ 10;
   set
      outp11_klab
      outp12_klab
      outp13_klab
      outp14_klab
      outp07_klab
      outp08_klab
      outp09_klab
      outp10_klab
      ;
run;



/******* CARRIER *********/

data cabg20.ptb07_14_klab;
   length filetype $ 1;
   set cabg20.nch07_14_coh(rename=(sadmsndt=idxdate));
   filetype="N";
run;

options VARLENCHK=nowarn;

/******* COMBINE ******/

data cabg20.to_ruleout07_14(drop=claimindex sfromdt sadmsndt srev_dt
      prfnpi provzip9 hcfaspcl sdschrgdt);
   length bene_id $ 15;
   retain filetype;
   length clmdte 5;
   set
      cabg20.ptb07_14_klab
      cabg20.outp07_14_klab
      cabg20.medp07_14_klab
      ;
   if filetype eq 'M' then do;
      clmdte=sadmsndt;
   end;
   else if filetype eq 'N' then do;
      clmdte=sfromdt;
   end;
   else if filetype eq 'O' then do;
      clmdte=sfromdt;                /* NOTE that I could have used the */
   end;                              /* srev_dt, but my review of the seer outp,
                                        which is the basis for the merged file,
                                        shows that there are plenty of repeated
                                        hcpcs with the same "from_date," which
                                        I think would not be true if the srev_dts
                                        were used. */
                                        
   format clmdte mmddyy10.;
run;

options VARLENCHK=warn;

proc sort data=cabg20.to_ruleout07_14;
   by bene_id clmdte;
run;

proc means data=cabg20.to_ruleout07_14 n nmiss;
   var idxdate;
run;
