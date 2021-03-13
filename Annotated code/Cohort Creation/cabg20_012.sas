/************************************************************
FILENAME: cabg20_012.sas
AUTHOR: skaufman
DATE: 4/28/2017
ID: 54
SUMMARY: CREATE XWALK, FIX UP HCFASPEC.
************************************************************/


proc summary data=cabg20.nch07_14_coh_v2;
   class prf_upin_org prfnpi;
   output out=out1;                
run;

data out2(drop=_type_ rename=(_freq_=num_of_npis_for_prf_upin));
   set out1;
   if _type_ eq 3;
run;

proc sort data=out2 out=out3;
   by prf_upin_org descending num_of_npis_for_prf_upin;
run;

data cabg20.carrier_based_upin_npi_xwalk(keep=prf_upin_org prfnpi);
   set out3;
   by prf_upin_org;
   if first.prf_upin_org;
run;


/** PERFORMING NPI **/

%sortdata2(cabg20.carrier_based_upin_npi_xwalk,prf_upin_org);

data y2007a y2007b y2008_12;
   set cabg20.nch07_14_coh_v2;
   if sfromdt_yyyy in(2006 2007) and prf_upin_org ne ' ' and prfnpi eq ' ' then output y2007a;
   else if sfromdt_yyyy in(2006 2007) then output y2007b;
   else output y2008_12;
run;

%sortdata2(y2007a,prf_upin_org);

data y2007a;
   merge
      y2007a(in=a)
      cabg20.carrier_based_upin_npi_xwalk(rename=(prfnpi=prfnpi_xw))
      ;
   by prf_upin_org;
   if a;
   prfnpi=prfnpi_xw;
run;

data cabg20.nch07_14_coh_v3;
   set y2007a y2007b y2008_12;
run;


/** REFERRING NPI **/

/* Note: technically, I should use a different xwalk--one based on referring upin.
   however, the only time we'll care about this is if the referring=performing.  So,
   we can use the performing upin-npi xwalk. */

%sortdata2(cabg20.carrier_based_upin_npi_xwalk,prf_upin_org);

data y2007a y2007b y2008_12;
   set cabg20.nch07_14_coh_v3;
   if sfromdt_yyyy in(2006 2007) and rfr_upin ne ' ' and rfr_npi eq ' ' then output y2007a;
   else if sfromdt_yyyy in(2006 2007) then output y2007b;
   else output y2008_12;
run;

%sortdata2(y2007a,rfr_upin);

data y2007a;
   merge
      y2007a(in=a)
      cabg20.carrier_based_upin_npi_xwalk(rename=(prf_upin_org=rfr_upin prfnpi=rfr_npi_xw))
      ;
   by rfr_upin;
   if a;
   rfr_npi=rfr_npi_xw;
run;

data cabg20.nch07_14_coh_v4;
   set y2007a y2007b y2008_12;
run;


/* BEST HCFASPEC */

proc hpsummary data=cabg20.nch07_14_coh_v4;
   class prfnpi hcfaspcl;
   output out=out1;
run;
data out1(drop=_type_ rename=(_freq_=num_of_recs_per_doc));
   set out1;
   if _type_ eq 3;
run;
proc sort data=out1 out=out2;
   by prfnpi descending num_of_recs_per_doc;
run;
data cabg20.best_hcfaspec_for_prfnpi(keep=hcfaspcl prfnpi rename=(hcfaspcl=best_hcfaspcl));
   set out2;
   by prfnpi;
   if first.prfnpi;
run;

%sortdata2(cabg20.nch07_14_coh_v4,prfnpi);
%sortdata2(cabg20.best_hcfaspec_for_prfnpi,prfnpi);

data cabg20.nch07_14_coh_v5;
   merge
      cabg20.nch07_14_coh_v4(in=a)
      cabg20.best_hcfaspec_for_prfnpi(in=b)
      ;
   by prfnpi;
   if a;
   in_best_hcfaspec=b;
run;


data cabg20.nch07_14_coh_v6(drop=num_of_type1_recodes num_of_type2_recodes 
       num_of_type3_recodes random_variate);
   length hcfaspcl_final $ 2;
   length type_recode 3;
   set cabg20.nch07_14_coh_v5 end=last;
   random_variate=ranuni(5);
   if not in_best_hcfaspec then do;
      hcfaspcl_final=hcfaspcl;
      type_recode=1;
      num_of_type1_recodes+1;
   end;
   else if in_best_hcfaspec then do;
      if best_hcfaspcl ne hcfaspcl then do;
         hcfaspcl_final=best_hcfaspcl;
         type_recode=2;
         num_of_type2_recodes+1;
      end;
      else do;
         hcfaspcl_final=best_hcfaspcl;
         type_recode=3;
         num_of_type3_recodes+1;
      end;
   end;
   if last then do;
      put num_of_type1_recodes= num_of_type2_recodes= num_of_type3_recodes=;
   end;
run;
