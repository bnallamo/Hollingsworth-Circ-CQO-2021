/************************************************************
FILENAME: cabg20_017.sas (from cabgf2_015.sas)
AUTHOR: skaufman
DATE: 5/4/2017
ID: 54
SUMMARY: COMBINE THE THREE PHASES TO ANSWER THESE QUESTIONS, WHERE "SURGICAL
EPISODE" MEANS ALL PHASES COMBINED.

-percentage of patients who saw their personal physician within the surgical episode.
-average number of unique physicians a patient saw during the surgical episode.
-percentage of patients who saw a medical specialist within the surgical episode.
-percentage of patients who saw another surgical specialist within the surgical episode.
-percentage of patients who saw another PCP (not their personal physician) within the surgical episode.

************************************************************/


data cabg20.cabg08_14_v12;
   set cabg20.cabg08_14_v11;
   length saw_med_spec_pre_idx_pst saw_otr_surg_spec_pre_idx_pst saw_pcp_pre_idx_pst $ 3;


   /* SAW PERSONAL PHYSICIAN */

   if pcp_npi ne ' ' then do;
      if indexw(prfnpi_all_idx,pcp_npi) gt 0 then saw_pcp_in_idx=1;
      else saw_pcp_in_idx=0;
      if indexw(prfnpi_all_90dpre,pcp_npi) gt 0 then saw_pcp_in_90dpre=1;
      else saw_pcp_in_90dpre=0;
      if indexw(prfnpi_all_90dpst,pcp_npi) gt 0 then saw_pcp_in_90dpst=1;
      else saw_pcp_in_90dpst=0;
   end;
   saw_pcp_pre_idx_pst=cats(saw_pcp_in_90dpre,saw_pcp_in_idx,saw_pcp_in_90dpst); 
   

   /* UNIQUE MDS AND PRFNPIS IN IDX */

   num_unique_prfnpis_in_idx=countw(prfnpi_all_idx);


   /* SAW MEDICAL SPECIALIST */

   if indexw(best_hcfaspcl_all_grp_90dpre,"3_MEDSPEC") gt 0 then saw_med_spec_90dpre=1;
   else saw_med_spec_90dpre=0;
   if indexw(best_hcfaspcl_all_grp_idx,"3_MEDSPEC") gt 0 then saw_med_spec_idx=1;
   else saw_med_spec_idx=0;
   if indexw(best_hcfaspcl_all_grp_90dpst,"3_MEDSPEC") gt 0 then saw_med_spec_90dpst=1;
   else saw_med_spec_90dpst=0;
   saw_med_spec_pre_idx_pst=cats(saw_med_spec_90dpre,
           saw_med_spec_idx,saw_med_spec_90dpst);


   /* SAW OTHER SURGICAL SPECIALIST */

   if indexw(best_hcfaspcl_all_grp_90dpre,"4_OTRSURGSPEC") gt 0 then saw_otr_surg_spec_90dpre=1;
   else saw_otr_surg_spec_90dpre=0;
   if indexw(best_hcfaspcl_all_grp_idx,"4_OTRSURGSPEC") gt 0 then saw_otr_surg_spec_idx=1;
   else saw_otr_surg_spec_idx=0;
   if indexw(best_hcfaspcl_all_grp_90dpst,"4_OTRSURGSPEC") gt 0 then saw_otr_surg_spec_90dpst=1;
   else saw_otr_surg_spec_90dpst=0;
   saw_otr_surg_spec_pre_idx_pst=cats(saw_otr_surg_spec_90dpre,
          saw_otr_surg_spec_idx,saw_otr_surg_spec_90dpst);

run;

proc freq data=cabg20.cabg08_14_v12;
   tables saw_med_spec_pre_idx_pst--saw_otr_surg_spec_90dpst / missprint;
   title1 "FROM CABG20_017.SAS";
run;

%sortdata2(cabg20.hc_prof_panels,bene_id sexpndt1);


data hc_prof_panels(keep=
      bene_id best_hcfaspcl_all--provzip9_all
      maxlen_best_hcfaspcl_all--maxlen_best_hcfaspcl_all_grp);
   retain
      best_hcfaspcl_all
      best_hcfaspcl_all_grp
      prfnpi_all
      provzip9_all
      maxlen_best_hcfaspcl_all
      maxlen_prfnpi_all
      maxlen_provzip9_all
      maxlen_best_hcfaspcl_all_grp
      ;

   length best_hcfaspcl_all $ 600;
   length prfnpi_all $ 1800;
   length provzip9_all $ 1800;
   length best_hcfaspcl_all_grp $ 1500;

   set cabg20.hc_prof_panels; /** NOTE: NOT V2, WHICH IS RESHAPED **/
   by bene_id;

   if _n_ eq 1 then do;
      maxlen_best_hcfaspcl_all=0;
      maxlen_prfnpi_all=0;
      maxlen_provzip9_all=0;
      maxlen_best_hcfaspcl_all_grp=0;
   end;

   sep=' ';

   if first.bene_id then do;
      best_hcfaspcl_all=' ';
      prfnpi_all=' ';
      provzip9_all=' ';
      best_hcfaspcl_all_grp=' ';
   end;


   /** DO BELOW TO MAKE SURE THAT CONCATENATED VALUES ALWAYS CORRESPOND
       TO THE RIGHT PERSON. NOTE THAT DON'T REALLY NEED FOR PRFNPI,
       AND BEST_HCFASPCL_GRP, AS THERE SHOULD BE NO BLANKS.  DOING SO
       THAT WE CAN USE THIS CODE EVEN IF THERE ARE, EVENTUALLY, BLANKS. **/

   if best_hcfaspcl  eq ' ' then best_hcfaspcl='Z9';
   if prfnpi eq ' ' then prfnpi='Z99999';
   if provzip9 eq ' ' then provzip9='Z99999999';
   if best_hcfaspcl_grp eq ' ' then best_hcfaspcl_grp='Z999999999999999';

   if sadmsndt-90 le sexpndt1 le sdschrgdt+90 then do;
      if indexw(prfnpi_all,strip(prfnpi)) eq 0 then do;
         prfnpi_all=catx(sep,prfnpi_all,prfnpi);
         if maxlen_prfnpi_all lt length(prfnpi_all) then
                    maxlen_prfnpi_all=length(prfnpi_all);
         best_hcfaspcl_all=catx(sep,best_hcfaspcl_all,best_hcfaspcl);
         if maxlen_best_hcfaspcl_all lt length(best_hcfaspcl_all) then
                    maxlen_best_hcfaspcl_all=length(best_hcfaspcl_all);
         provzip9_all=catx(sep,provzip9_all,provzip9);
         if maxlen_provzip9_all lt length(provzip9_all) then
                    maxlen_provzip9_all=length(provzip9_all);
         best_hcfaspcl_all_grp=catx(sep,best_hcfaspcl_all_grp,best_hcfaspcl_grp);
         if maxlen_best_hcfaspcl_all_grp lt length(best_hcfaspcl_all_grp) then
                    maxlen_best_hcfaspcl_all_grp=length(best_hcfaspcl_all_grp);
      end;
   end;

   if last.bene_id;

run;


data cabg20.cabg08_14_v12;
   merge
      cabg20.cabg08_14_v12(in=a)
      hc_prof_panels
      ;
   by bene_id;
   if a;

   * -PERCENTAGE OF PATIENTS WHO SAW ANOTHER PCP (NOT THEIR PERSONAL PHYSICIAN) WITHIN THE SURGICAL EPISODE.;

   if pcp_npi ne ' ' then do;
      saw_outside_pcp=0;
      if indexw(prfnpi_all,pcp_npi) eq 0 then do;
         if indexw(best_hcfaspcl_all_grp,"1_PCP") then saw_outside_pcp=1;
      end;
   end;

run;


proc means data=cabg20.cabg08_14_v12 min max;
   var maxlen_best_hcfaspcl_all maxlen_prfnpi_all
       maxlen_provzip9_all maxlen_best_hcfaspcl_all_grp;
run;


data cabg20.cabg08_14_v12;
   set cabg20.cabg08_14_v12(drop=maxlen_best_hcfaspcl_all maxlen_prfnpi_all
       maxlen_provzip9_all maxlen_best_hcfaspcl_all_grp);
run;


proc freq data=cabg20.cabg08_14_v12;
   tables saw_outside_pcp / missprint;
run;
