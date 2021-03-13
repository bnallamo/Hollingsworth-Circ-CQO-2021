/************************************************************
FILENAME: cabg20_016.sas (from cabgf2_010.sas)
AUTHOR: skaufman
DATE: 5/4/2017
ID: 54
SUMMARY: GET PCP. 
************************************************************/

proc sort data=cabg20.nch07_14_coh_v6;
   by bene_id claimindex;
run;

data cabg20.pcp;
   set cabg20.nch07_14_coh_v6;
   if prfnpi eq ' ' then delete;
run;

data cabg20.pcp;
   set cabg20.pcp;
   if best_hcfaspcl eq ' ' then delete;
run;

data cabg20.pcp;
   set cabg20.pcp;
   if provzip9 eq ' ' then delete;
run;

data cabg20.pcp;
   set cabg20.pcp;
   if best_hcfaspcl in('01' '08' '11' '38'); /* GENERAL PRACTICE, FAMILY P, INTERNAL MED, GERIATRICS */
run;

data cabg20.pcp;
   set cabg20.pcp;
   if sadmsndt-365 le sexpndt1 lt sadmsndt;
   drop sadmsndt sdschrgdt cabg_dt;
run;

%sortdata2(cabg20.pcp,bene_id sexpndt1);

/** DETERMINE THE PREDOMINANT PROVIDER IN RELATIVELY RARE
    CASES WHERE THERE IS MORE THAN ONE. **/    

proc summary data=cabg20.pcp;
   class bene_id prfnpi;
   output out=out1;                
run;
data out1(drop=_type_ rename=(_freq_=num_of_recs_per_doc));
   set out1;
   if _type_ eq 3;
run;
proc sort data=out1 out=out2;
   by bene_id descending num_of_recs_per_doc;
run;
proc sort data=out2 out=out3 nodupkey;
   by bene_id;
run;

proc sort data=cabg20.pcp;
   by bene_id;
run;

data cabg20.pcp_v2;
   merge
      cabg20.pcp
      out3(keep=bene_id prfnpi rename=(prfnpi=prfnpi_best))
      ;
   by bene_id;
   if prfnpi eq prfnpi_best;
run;

data cabg20.pcp_v2(rename=(prfnpi=pcp_npi
       prv_type=pcp_prv_type provzip9=pcp_provzip9
       best_hcfaspcl=pcp_best_hcfaspcl));
   set cabg20.pcp_v2(drop=prfnpi_best claimindex prvstate);
   by bene_id;
   if first.bene_id;
   drop sexpndt1 sexpndt2
      TYPSRVCB PLCSRVC HCPCS_CD MDFR_CD1 MDFR_CD2 BETOS LINEDGNS;
run;


/** THE POINT OF THE CODE BELOW IS TO SEE IF SOMEONE IS CALLED A PCP BUT
    IN FACT, SOMEWHERE, HAS ANOTHER CODING THAT WOULD PRECLUDE HIM FROM
    BEING CONSIDERED A PCP. SO, I JUST CREATE A BUNCH OF HCFASPEC GROUPS
    THAT EXCLUDE PCP, RESHAPE, AND DETERMINE IF THE CURRENT "PCP" HAS
    CODING FROM ANY OTHER GROUP. IF SO, HE IS DELETED.  **/

/** NOTE!  I AM NOT TESTING FOR THIS BECAUSE IT TURNED OUT JUST NOT TO HAPPEN
    LAST TIME, GIVEN THE APPROACH TAKEN HERE. **/ 


%sortdata2(cabg20.cabg08_14_v10,bene_id)

data cabg20.cabg08_14_v11;
   merge
      cabg20.cabg08_14_v10(in=a)
      cabg20.pcp_v2(in=b keep=bene_id pcp_:)
     ;
   by bene_id;
   if a;
   has_pcp_ind=b;
run;

proc freq data=cabg20.cabg08_14_v11;
   tables has_pcp_ind;
run;

