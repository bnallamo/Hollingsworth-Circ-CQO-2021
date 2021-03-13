/************************************************************
FILENAME: cabg20_015.sas (from cabgf2_009.sas)
AUTHOR: skaufman
DATE: 5/2/2017
ID: 54
SUMMARY: DETERMINES SURGEON.  USES 90D WINDOW.
************************************************************/

data cabg20.surgeon_coh;
   set cabg20.nch07_14_coh_v6;
   if hcpcs_cd in(
      '33510' '33511' '33512' '33513' '33514' '33515' '33516' '33517'
      '33518' '33519' '33520' '33521' '33522' '33523' '33524' '33525'
      '33526' '33527' '33528' '33529' '33530' '33533' '33534' '33535'
      '33536'
         );
   if sadmsndt-3 le sexpndt1 le sdschrgdt+90;
run;

proc freq data=cabg20.surgeon_coh;
   tables typsrvcb / missprint;
   title1 "FROM CABG20_015.SAS";
   title2 "BEFORE FILTERING";
run;

data cabg20.surgeon_coh;
   set cabg20.surgeon_coh;
   if typsrvcb in('2');
run;

proc freq data=cabg20.surgeon_coh;
   tables typsrvcb / missprint;
   title1 "FROM CABG20_015.SAS";
   title2 "AFTER FILTERING";
run;

proc freq data=cabg20.surgeon_coh;
   tables prv_type / missprint;
   title2 "BEFORE FILTERING";
run;

data cabg20.surgeon_coh(keep=sexpndt1 sexpndt2 bene_id claimindex 
     prfnpi--hcfaspcl best_hcfaspcl);
   set cabg20.surgeon_coh;
   if prv_type in('1' '7');  /** THE PURPOSE IS JUST TO LIMIT TO A PERSON,
                                  NOT INSTITUTIONS. **/
run;

proc freq data=cabg20.surgeon_coh;
   tables prv_type / missprint;
   title2 "AFTER FILTERING";
run;
title2;

proc sort data=cabg20.surgeon_coh nodupkey;
   by bene_id claimindex prfnpi;
run;

proc sort data=cabg20.surgeon_coh nodupkey;
   by bene_id claimindex;
run;



/** RETAIN ONLY PLAUSIBLE HCFASPCL CODES FOR CABG **/

data cabg20.surgeon_coh;
   set cabg20.surgeon_coh;
   if best_hcfaspcl in('02' '28' '33' '77' '78' '91');  /** PLAUSIBLE CODES PER JH/RB **/
run;


/** ULTIMATELY, THOUGH, IF CAN'T IDENTIFY SURGEON, CAN'T USE .... **/
/** ALSO, CREATE A RANKING FOR HCFASPECS TO USE IN DETERMINING WHO
    THE SURGEON WAS. **/

data cabg20.surgeon_coh;
   set cabg20.surgeon_coh;
   if prfnpi eq ' ' then delete;

   if best_hcfaspcl in('33' '78') then best_hcfaspcl_order=1; /*CARDSURG*/
   else if best_hcfaspcl in('02' '28' '91') then best_hcfaspcl_order=2; /*GENSURG*/
   else if best_hcfaspcl in('77') then best_hcfaspcl_order=3; /*VASCSURG*/
   else best_hcfaspcl_order=4; /*OTHER*/
run;

data cabg20.surgeon_coh;
   set cabg20.surgeon_coh;
   if best_hcfaspcl eq ' ' then delete;
run;

data cabg20.surgeon_coh;
   set cabg20.surgeon_coh;
   if provzip9 eq ' ' then delete;
run;


/** DETERMINE THE PREDOMINANT PROVIDER IN RELATIVELY RARE
    CASES WHERE THERE IS MORE THAN ONE.  NOTE THAT WHEN THERE
    IS MORE THAN ONE PROVIDER, IT'S MOSTLY THE SAME PROVIDER
    WITH DIFFERENT claimindexs.  SO, THERE'S NOT MUCH
    REASON TO FRET. NOTE THAT CERTAIN HCFASPECS ARE NOW
    GIVEN PRIORITY, AS PER "HCFASPCL_ORDER".**/
    

proc summary data=cabg20.surgeon_coh;
   class bene_id best_hcfaspcl_order prfnpi;
   output out=out1;                
run;
data out1(drop=_type_ rename=(_freq_=num_of_recs_per_doc));
   set out1;
   if _type_ eq 7;
run;
proc sort data=out1 out=out2;
   by bene_id best_hcfaspcl_order descending num_of_recs_per_doc;
run;
data out3;
   set out2;
   by bene_id;
   if first.bene_id;
run;

proc sort data=cabg20.surgeon_coh;
   by bene_id;
run;

data cabg20.surgeon_coh_v2;
   merge
      cabg20.surgeon_coh
      out3(keep=bene_id best_hcfaspcl_order prfnpi rename=(prfnpi=prfnpi_best))
      ;
   by bene_id;
   if prfnpi eq prfnpi_best;
run;

data cabg20.surgeon_coh_v2(rename=(prfnpi=surgeon_npi
       prv_type=surgeon_prv_type provzip9=surgeon_provzip9
       best_hcfaspcl=surgeon_best_hcfaspcl
       TAX_NUM=surgeon_tax_num));
   set cabg20.surgeon_coh_v2(drop=prfnpi_best claimindex prvstate);
   by bene_id;
   if first.bene_id;
run;


%sortdata2(cabg20.cabg08_14_v8,bene_id);

data cabg20.cabg08_14_v9(drop=sexpndt1
     sexpndt2);
   merge 
      cabg20.cabg08_14_v8(in=a)
      cabg20.surgeon_coh_v2(in=b drop=best_hcfaspcl_order hcfaspcl)
      ;
   by bene_id;
   if a;
   in_surgeon=b;
run;

proc freq data=cabg20.cabg08_14_v9;
   tables in_surgeon / missprint;
run;

data cabg20.cabg08_14_v10(drop=in_surgeon prgrpnpi in_prv);
   set cabg20.cabg08_14_v9;
   if in_surgeon;
run;

proc freq data=cabg20.cabg08_14_v10;
   tables surgeon_best_hcfaspcl / missprint;
run;

%pc(cabg20,cabg08_14_v10)
