/************************************************************
FILENAME: cabg20_007.sas (from ddcap_001.sas)
AUTHOR: skaufman
DATE: 5/3/2017
ID: 54
SUMMARY: CREATES "NCH" FOR MEDICARE FOR OUR COHORT.
************************************************************/

data cohort;
   set cabg20.cabg08_14_v4(keep=bene_id sadmsndt age_at_sadmsndt sdschrgdt cabg_dt);
run;

%sortdata2(cohort,bene_id)

%macro combo(year);
data ptb&year._clms;
   set med.ptb&year.clms(keep=bene_id rfr_npi RFR_UPIN claimindex sfromdt sthrudt
       dgns_cd: /*new->*/ PMT_AMT
       );
   format sfromdt sthrudt mmddyy10.;
run;
%sortdata2(ptb&year._clms,bene_id);
data ptb&year._clms;
   merge
      cohort(in=a)
      ptb&year._clms(in=b)
      ;
   by bene_id;
   if a and b;
run;
data ptb&year._lnits;
   length linedgns $ 5;
   set med.ptb&year.lnits
   %if &year eq 07 %then %do;
           (keep=bene_id claimindex TAX_NUM hcpcs_cd linedgns sexpndt1 sexpndt2 provzip9
           HCFASPCL
           prf_upin_org PRFNPI PRGRPNPI PRV_TYPE PRVSTATE TYPSRVCB
           PLCSRVC MDFR_CD1 MDFR_CD2 BETOS /*provzip*/ LINEPMT stdprice
           );
   %end;
   %else %if &year eq 09 %then %do;
           (keep=bene_id claimindex TAX_NUM hcpcs_cd linedgns sexpndt1 sexpndt2 provzip9
           HCFASPCL
           prf_upin_org PRFNPI PRGRPNPI PRV_TYPE PRVSTATE TYPSRVCB
           PLCSRVC MDFR_CD1 MDFR_CD2 BETOS /*provzip*/ LINEPMT stdprice
           );
   %end;
   format sexpndt1 sexpndt2 mmddyy10.;
run;
proc sort data=ptb&year._clms nodupkey;
   by bene_id claimindex;
run;
%sortdata2(ptb&year._lnits,bene_id claimindex);
data cabg20.ptb&year._all(drop=i);
   merge
      ptb&year._clms(in=a)
      ptb&year._lnits
      ;
   by bene_id claimindex;
   if a;
   array str[*] _character_;
   do i=1 to dim(str);
      str[i]=strip(str[i]);
   end;
run;
%mend combo;

%combo(07);

data cabg20.ptb07_all(rename=(cindex=claimindex));
   length cindex $ 15;
   set cabg20.ptb07_all;
   cindex=put(claimindex,8.);
   drop claimindex;
run;

data ptb08_clms;
   length dgns_cd: $ 7;  
   set med.ptb08clms(keep=bene_id rfr_npi claimindex sfromdt sthrudt
       dgns_cd: pmt_amt);
   format sfromdt sthrudt mmddyy10.;
run;

%sortdata2(ptb08_clms,bene_id)

data ptb08_clms;
   merge
      cohort(in=a)
      ptb08_clms(in=b)
      ;
   by bene_id;
   if a and b;
run;

proc sort data=ptb08_clms nodupkey;
   by bene_id claimindex;
run;

data ptb08_lnits;
   length linedgns $ 7;
   set med.ptb08lnits(keep=bene_id claimindex TAX_NUM hcpcs_cd linedgns 
           sexpndt1 sexpndt2 provzip9 HCFASPCL
           prf_upin_org PRFNPI PRGRPNPI PRV_TYPE PRVSTATE TYPSRVCB
           PLCSRVC MDFR_CD1 MDFR_CD2 BETOS /*provzip*/ LINEPMT stdprice
           );
   format sexpndt1 sexpndt2 mmddyy10.;
run;

%sortdata2(ptb08_lnits,bene_id claimindex);

data cabg20.ptb08_all(drop=i);
   merge
      ptb08_clms(in=a)
      ptb08_lnits
      ;
   by bene_id claimindex;
   if a;
   array str[*] _character_;
   do i=1 to dim(str);
      str[i]=strip(str[i]);
   end;
run;

%combo(09);

data ptb10_clms;
   set med.ptb10clms(keep=bene_id clm_id rfr_npi sfromdt sthrudt
       dgns_cd: pmt_amt rename=(clm_id=claimindex)
       );
   format sfromdt sthrudt mmddyy10.;
run;

%sortdata2(ptb10_clms, bene_id)

data ptb10_clms;
   merge
      cohort(in=a)
      ptb10_clms(in=b)
     ;
   by bene_id;
   if a and b;
run;

proc sort data=ptb10_clms nodupkey;
   by bene_id claimindex;
run;

data ptb10_lnits;
   length linedgns $ 7 PRVSTATE $ 2;
   set med.ptb10lnits(keep=bene_id clm_id TAX_NUM hcpcs_cd linedgns sexpndt1 sexpndt2 provzip9
           PRFNPI HCFASPCL
           PRF_UPIN PRGRPNPI PRV_TYPE /*PRVSTATE*/ TYPSRVCB
           PLCSRVC MDFR_CD1 MDFR_CD2 BETOS /*provzip*/ LINEPMT stdprice
        rename=(clm_id=claimindex PRF_UPIN=prf_upin_org)
        );
   PRVSTATE="  "; /* FOR CONSISTENCY*/
   format sexpndt1 mmddyy10.;
run;

%sortdata2(ptb10_lnits,bene_id claimindex);

data cabg20.ptb10_all(drop=i);
   merge
      ptb10_clms(in=a)
      ptb10_lnits
      ;
   by bene_id claimindex;
   if a;
   array str[*] _character_;
   do i=1 to dim(str);
      str[i]=strip(str[i]);
   end;
run;

data ptb11_clms;
   set med.ptb11clms(keep=bene_id clm_id rfr_npi FROM_DT
         THRU_DT ICD_DGNS_CD1-ICD_DGNS_CD12 pmt_amt
       rename=(clm_id=claimindex FROM_DT=sfromdt THRU_DT=sthrudt
        ICD_DGNS_CD1-ICD_DGNS_CD12=dgns_cd1-dgns_cd12
       ));
   format sfromdt sthrudt mmddyy10.;
run;

%sortdata2(ptb11_clms, bene_id)

data ptb11_clms;
   merge
      ptb11_clms(in=a)
      cohort(in=b)
      ;
   by bene_id;
   if a and b;
run;

proc sort data=ptb11_clms nodupkey;
   by bene_id claimindex;
run;

data ptb11_lnits;
   length linedgns $ 7;
   set med.ptb11lnits(keep=
         BENE_ID CLM_ID TAX_NUM HCPCS_CD LINE_ICD_DGNS_CD EXPNSDT1 EXPNSDT2
         PRF_UPIN PRF_NPI provzip9 HCFASPCL PRGRPNPI PRV_TYPE
         PRVSTATE TYPSRVCB PLCSRVC MDFR_CD1 MDFR_CD2 BETOS
         /*provzip*/ LINEPMT stdprice
        rename=(CLM_ID=claimindex LINE_ICD_DGNS_CD=linedgns EXPNSDT1=sexpndt1
              EXPNSDT2=sexpndt2
              PRF_UPIN=prf_upin_org PRF_NPI=PRFNPI)
           );
   format sexpndt1 mmddyy10.;
run;

%sortdata2(ptb11_lnits,bene_id claimindex);

data cabg20.ptb11_all(drop=i);
   merge
      ptb11_clms(in=a)
      ptb11_lnits
      ;
   by bene_id claimindex;
   if a;
   array str[*] _character_;
   do i=1 to dim(str);
      str[i]=strip(str[i]);
   end;
run;

options varlenchk=nowarn;

data cabg20.ptb11_all;
  length prf_upin_org $ 6 PRFNPI $ 10 HCFASPCL $ 2 MDFR_CD1 MDFR_CD2 $ 2
      rfr_npi $ 10 pmt_amt 6 linepmt 6;
  set cabg20.ptb11_all;
run;

options varlenchk=warn;

%sortdata2(med.ptb12clms, bene_id)

data ptb12_clms(keep=bene_id claimindex rfr_npi sfromdt sthrudt sadmsndt
       age_at_sadmsndt sdschrgdt cabg_dt 
       dgns_cd: pmt_amt);
   merge
      med.ptb12clms(in=a rename=(
         ICD_DGNS_CD1-ICD_DGNS_CD12=dgns_cd1-dgns_cd12
         CLM_FROM_DT=sfromdt CLM_THRU_DT=sthrudt
         RFR_PHYSN_NPI=rfr_npi CLM_PMT_AMT=pmt_amt
         CLM_ID=claimindex))
      cohort(in=b)
      ;
   by bene_id;
   if a and b;
   format sfromdt sthrudt mmddyy10.;
run;

proc sort data=ptb12_clms nodupkey;
   by bene_id claimindex;
run;

data ptb12_lnits;
   length linedgns $ 7;
   set med.ptb12lnits(keep=
         BENE_ID CLM_ID TAX_NUM HCPCS_CD LINE_ICD_DGNS_CD LINE_1ST_EXPNS_DT
         LINE_LAST_EXPNS_DT PRF_PHYSN_NPI PRVDR_ZIP PRVDR_SPCLTY
         ORG_NPI_NUM CARR_LINE_PRVDR_TYPE_CD PRVDR_STATE_CD
         LINE_CMS_TYPE_SRVC_CD LINE_PLACE_OF_SRVC_CD
         HCPCS_1ST_MDFR_CD HCPCS_2ND_MDFR_CD BETOS_CD
         LINE_NCH_PMT_AMT stdprice
       rename=(
         clm_id=claimindex LINE_ICD_DGNS_CD=linedgns
         LINE_1ST_EXPNS_DT=sexpndt1 LINE_LAST_EXPNS_DT=sexpndt2
         PRF_PHYSN_NPI=prfnpi PRVDR_ZIP=provzip9
         PRVDR_SPCLTY=HCFASPCL ORG_NPI_NUM=PRGRPNPI
         CARR_LINE_PRVDR_TYPE_CD=PRV_TYPE PRVDR_STATE_CD=PRVSTATE
         LINE_CMS_TYPE_SRVC_CD=TYPSRVCB LINE_PLACE_OF_SRVC_CD=PLCSRVC
         HCPCS_1ST_MDFR_CD=MDFR_CD1 HCPCS_2ND_MDFR_CD=MDFR_CD2
         BETOS_CD=BETOS LINE_NCH_PMT_AMT=LINEPMT
         ));
   format sexpndt1 sexpndt2 mmddyy10.;
run;

%sortdata2(ptb12_lnits,bene_id claimindex);

data cabg20.ptb12_all(drop=i);
   merge
      ptb12_clms(in=a)
      ptb12_lnits
      ;
   by bene_id claimindex;
   if a;
   array str[*] _character_;
   do i=1 to dim(str);
      str[i]=strip(str[i]);
   end;
run;

options varlenchk=nowarn;

data cabg20.ptb12_all;
  length PRFNPI $ 10 HCFASPCL $ 2 MDFR_CD1 MDFR_CD2 $ 2
     rfr_npi $ 10 pmt_amt 6 linepmt 6;
  set cabg20.ptb12_all;
run;

%sortdata2(med.ptb13clms, bene_id)

data ptb13_clms(keep=bene_id clm_id rfr_npi sfromdt sthrudt
       dgns_cd: pmt_amt sadmsndt sdschrgdt
       age_at_sadmsndt cabg_dt rename=(clm_id=claimindex)
       );
   merge
      med.ptb13clms(in=a rename=(
         ICD_DGNS_CD1-ICD_DGNS_CD12=dgns_cd1-dgns_cd12
         CLM_FROM_DT=sfromdt
         CLM_THRU_DT=sthrudt
         RFR_PHYSN_NPI=rfr_npi
         CLM_PMT_AMT=pmt_amt))
      cohort(in=b)
      ;
   by bene_id;
   if a and b;
   format sfromdt sthrudt mmddyy10.;
run;

proc sort data=ptb13_clms nodupkey;
   by bene_id claimindex;
run;

data ptb13_lnits;
   length linedgns $ 7;
   set med.ptb13lnits(keep=
         BENE_ID CLM_ID TAX_NUM HCPCS_CD LINE_ICD_DGNS_CD LINE_1ST_EXPNS_DT
         LINE_LAST_EXPNS_DT PRF_PHYSN_NPI PRVDR_ZIP PRVDR_SPCLTY
         ORG_NPI_NUM CARR_LINE_PRVDR_TYPE_CD PRVDR_STATE_CD
         LINE_CMS_TYPE_SRVC_CD LINE_PLACE_OF_SRVC_CD
         HCPCS_1ST_MDFR_CD HCPCS_2ND_MDFR_CD BETOS_CD
         LINE_NCH_PMT_AMT stdprice
       rename=(
         clm_id=claimindex LINE_ICD_DGNS_CD=linedgns
         LINE_1ST_EXPNS_DT=sexpndt1 LINE_LAST_EXPNS_DT=sexpndt2
         PRF_PHYSN_NPI=prfnpi PRVDR_ZIP=provzip9
         PRVDR_SPCLTY=HCFASPCL ORG_NPI_NUM=PRGRPNPI
         CARR_LINE_PRVDR_TYPE_CD=PRV_TYPE PRVDR_STATE_CD=PRVSTATE
         LINE_CMS_TYPE_SRVC_CD=TYPSRVCB LINE_PLACE_OF_SRVC_CD=PLCSRVC
         HCPCS_1ST_MDFR_CD=MDFR_CD1 HCPCS_2ND_MDFR_CD=MDFR_CD2
         BETOS_CD=BETOS LINE_NCH_PMT_AMT=LINEPMT
         ));
   format sexpndt1 sexpndt2 mmddyy10.;
run;
%sortdata2(ptb13_lnits,bene_id claimindex);

data cabg20.ptb13_all(drop=i);
   merge
      ptb13_clms(in=a)
      ptb13_lnits
      ;
   by bene_id claimindex;
   if a;
   array str[*] _character_;
   do i=1 to dim(str);
      str[i]=strip(str[i]);
   end;
run;

options varlenchk=nowarn;

data cabg20.ptb13_all;
  length PRFNPI $ 10 HCFASPCL $ 2 MDFR_CD1 MDFR_CD2 $ 2
     rfr_npi $ 10 pmt_amt 6 linepmt 6;
  set cabg20.ptb13_all;
run;

options varlenchk=warn;

%sortdata2(med.ptb14clms, bene_id)

data ptb14_clms(keep=bene_id clm_id rfr_npi sfromdt sthrudt
       dgns_cd: pmt_amt sadmsndt sdschrgdt
       age_at_sadmsndt cabg_dt rename=(clm_id=claimindex));
   merge
      med.ptb14clms(in=a rename=(
         ICD_DGNS_CD1-ICD_DGNS_CD12=dgns_cd1-dgns_cd12
         CLM_FROM_DT=sfromdt
         CLM_THRU_DT=sthrudt
         RFR_PHYSN_NPI=rfr_npi
         CLM_PMT_AMT=pmt_amt))
      cohort(in=b)
      ;
   by bene_id;
   if a and b;
   format sfromdt sthrudt mmddyy10.;
run;

proc sort data=ptb14_clms nodupkey;
   by bene_id claimindex;
run;

data ptb14_lnits;
   length linedgns $ 7;
   set med.ptb14lnits(keep=
         BENE_ID CLM_ID TAX_NUM HCPCS_CD LINE_ICD_DGNS_CD LINE_1ST_EXPNS_DT
         LINE_LAST_EXPNS_DT PRF_PHYSN_NPI PRVDR_ZIP PRVDR_SPCLTY
         ORG_NPI_NUM CARR_LINE_PRVDR_TYPE_CD PRVDR_STATE_CD
         LINE_CMS_TYPE_SRVC_CD LINE_PLACE_OF_SRVC_CD
         HCPCS_1ST_MDFR_CD HCPCS_2ND_MDFR_CD BETOS_CD
         LINE_NCH_PMT_AMT stdprice
       rename=(
         clm_id=claimindex LINE_ICD_DGNS_CD=linedgns
         LINE_1ST_EXPNS_DT=sexpndt1 LINE_LAST_EXPNS_DT=sexpndt2
         PRF_PHYSN_NPI=prfnpi PRVDR_ZIP=provzip9
         PRVDR_SPCLTY=HCFASPCL ORG_NPI_NUM=PRGRPNPI
         CARR_LINE_PRVDR_TYPE_CD=PRV_TYPE PRVDR_STATE_CD=PRVSTATE
         LINE_CMS_TYPE_SRVC_CD=TYPSRVCB LINE_PLACE_OF_SRVC_CD=PLCSRVC
         HCPCS_1ST_MDFR_CD=MDFR_CD1 HCPCS_2ND_MDFR_CD=MDFR_CD2
         BETOS_CD=BETOS LINE_NCH_PMT_AMT=LINEPMT
         ));
   format sexpndt1 sexpndt2 mmddyy10.;
run;

%sortdata2(ptb14_lnits,bene_id claimindex);

data cabg20.ptb14_all(drop=i);
   merge
      ptb14_clms(in=a)
      ptb14_lnits
      ;
   by bene_id claimindex;
   if a;
   array str[*] _character_;
   do i=1 to dim(str);
      str[i]=strip(str[i]);
   end;
run;

options varlenchk=nowarn;

data cabg20.ptb14_all;
  length PRFNPI $ 10 HCFASPCL $ 2 MDFR_CD1 MDFR_CD2 $ 2
     rfr_npi $ 10 pmt_amt 6 linepmt 6;
  set cabg20.ptb14_all;
run;

options varlenchk=warn;


%macro nch(input_file,output_file);
   data &output_file(drop=i);
      set &input_file;
      provzip5=substr(provzip9,1,5);
      array diag[*] dgns_cd:;
      do i=1 to dim(diag);
         if length(diag[i]) gt 5 then do;
            put "diag code problem " "&input_file" bene_id= diag[i]= ;
            diag[i]=' ';
         end;
      end;
   run;
   proc sort data=&output_file;
      by bene_id sfromdt;
   run;
%mend nch;

%nch(cabg20.ptb07_all,ptb07_all);
%nch(cabg20.ptb08_all,ptb08_all);
%nch(cabg20.ptb09_all,ptb09_all);
%nch(cabg20.ptb10_all,ptb10_all);
%nch(cabg20.ptb11_all,ptb11_all);
%nch(cabg20.ptb12_all,ptb12_all);
%nch(cabg20.ptb13_all,ptb13_all);
%nch(cabg20.ptb14_all,ptb14_all);


options varlenchk=nowarn;

data cabg20.nch07_14_coh;
   length dgns_cd1-dgns_cd12 $ 5;
   set
      ptb07_all
      ptb08_all
      ptb09_all
      ptb10_all
      ptb11_all
      ptb12_all
      ptb13_all
      ptb14_all
      ;
   sfromdt_yyyy=year(sfromdt);
   format cabg_dt mmddyy10.;
run;

options varlenchk=warn;

proc means data=cabg20.nch07_14_coh n nmiss;
   var cabg_dt sdschrgdt;
run;

data cabg20.nch07_14_coh;
   retain bene_id
      sadmsndt sdschrgdt age_at_sadmsndt cabg_dt RFR_UPIN RFR_NPI sfromdt sthrudt
      sfromdt_yyyy sexpndt1 sexpndt2 prf_upin_org PRFNPI TAX_NUM PRGRPNPI PRV_TYPE
      PRVSTATE provzip9 HCFASPCL TYPSRVCB PLCSRVC linedgns dgns_cd1
      dgns_cd2 dgns_cd3 dgns_cd4 dgns_cd5 dgns_cd6 dgns_cd7 dgns_cd8
      dgns_cd9 dgns_cd10 dgns_cd11 dgns_cd12 claimindex HCPCS_CD MDFR_CD1
      MDFR_CD2 BETOS LINEPMT PMT_AMT stdprice provzip5
      ;
   set cabg20.nch07_14_coh;
   if sdschrgdt eq . then do;
      put sdschrgdt= bene_id=;
      sdschrgdt=cabg_dt;
   end;
run;
