/************************************************************
FILENAME: cabg20_014.sas (from cabgf2_008.sas)
AUTHOR: skaufman
DATE: 5/2/2017
ID: 54
SUMMARY: GET HC PROFESSIONAL PANELS FOR THE THREE PHASES. ADDS
TAX_NUM.
************************************************************/

options varlenchk=nowarn;

data cabg20.hc_prof_panels;
   length best_hcfaspcl_grp $ 16 tax_num $ 9;
   set cabg20.nch07_14_coh_v6(in=a where=(prfnpi ne ' ' and best_hcfaspcl ne ' ' 
     and provzip9 ne ' ' and tax_num ne '000000000'));
   if best_hcfaspcl in('01' '08' '11') then best_hcfaspcl_grp="1_PCP";
   else if best_hcfaspcl in('02' '28' '91') then best_hcfaspcl_grp="2_GENSURG";
   else if best_hcfaspcl in('03' '06' '10' '29' '39' '44' '46' '82' '83' '90') then best_hcfaspcl_grp="3_MEDSPEC";
   else if best_hcfaspcl in('04' '14' '18' '24' '40' '85') then best_hcfaspcl_grp="4_OTRSURGSPEC";
   else if best_hcfaspcl in('76') then best_hcfaspcl_grp="5_PERIPHVASCDIS";
   else if best_hcfaspcl in('77') then best_hcfaspcl_grp="6_VASCSURG";
   else if best_hcfaspcl in('20') then best_hcfaspcl_grp="7_ORTHOPEDICSURG";
   else if best_hcfaspcl in('33' '78') then best_hcfaspcl_grp="8_CARDSURG";
   else if best_hcfaspcl in('34') then best_hcfaspcl_grp="9_UROLOGY";
   else if best_hcfaspcl in('38') then best_hcfaspcl_grp="10_GERIATRIC";
   else best_hcfaspcl_grp="0_OTHER";
run;

options varlenchk=warn;

proc freq data=cabg20.hc_prof_panels;
   tables best_hcfaspcl best_hcfaspcl_grp / missprint;
run;

%sortdata2(cabg20.hc_prof_panels,bene_id sexpndt1);

data cabg20.hc_prof_panels_v2;
   retain
      best_hcfaspcl_all_90dpre
      best_hcfaspcl_all_idx
      best_hcfaspcl_all_90dpst

      best_hcfaspcl_all_grp_90dpre
      best_hcfaspcl_all_grp_idx
      best_hcfaspcl_all_grp_90dpst

      prfnpi_all_90dpre
      prfnpi_all_idx
      prfnpi_all_90dpst

      tax_num_all_90dpre
      tax_num_all_idx
      tax_num_all_90dpst

      provzip9_all_90dpre
      provzip9_all_idx
      provzip9_all_90dpst

      len_best_hcfaspcl_all_90dpre
      len_best_hcfaspcl_all_90dpst
      len_best_hcfaspcl_all_idx
      len_prfnpi_all_90dpre
      len_prfnpi_all_90dpst
      len_prfnpi_all_idx
      len_tax_num_all_90dpre
      len_tax_num_all_idx
      len_tax_num_all_90dpst
      len_provzip9_all_90dpre
      len_provzip9_all_90dpst
      len_provzip9_all_idx
      len_best_hcfaspcl_all_grp_90dpre
      len_best_hcfaspcl_all_grp_90dpst
      len_best_hcfaspcl_all_grp_idx
      ;

   length best_hcfaspcl_all_90dpre $ 500;
   length best_hcfaspcl_all_90dpst $ 500;
   length best_hcfaspcl_all_idx $ 500;

   length prfnpi_all_90dpre $ 1500;
   length prfnpi_all_90dpst $ 1500;
   length prfnpi_all_idx $ 1500;

   length tax_num_all_90dpre $ 1500;
   length tax_num_all_idx $ 1500;
   length tax_num_all_90dpst $ 1500;

   length provzip9_all_90dpre $ 1500;
   length provzip9_all_90dpst $ 1500;
   length provzip9_all_idx $ 1500;

   length best_hcfaspcl_all_grp_90dpre $ 1500;
   length best_hcfaspcl_all_grp_90dpst $ 1500;
   length best_hcfaspcl_all_grp_idx $ 1500;

   set cabg20.hc_prof_panels end=last;
   by bene_id;

   if _n_ eq 1 then do;
      len_best_hcfaspcl_all_90dpre=0;
      len_best_hcfaspcl_all_90dpst=0;
      len_best_hcfaspcl_all_idx=0;
      len_prfnpi_all_90dpre=0;
      len_prfnpi_all_90dpst=0;
      len_prfnpi_all_idx=0;
      len_tax_num_all_90dpre=0;
      len_tax_num_all_idx=0;
      len_tax_num_all_90dpst=0;
      len_provzip9_all_90dpre=0;
      len_provzip9_all_90dpst=0;
      len_provzip9_all_idx=0;
      len_best_hcfaspcl_all_grp_90dpre=0;
      len_best_hcfaspcl_all_grp_90dpst=0;
      len_best_hcfaspcl_all_grp_idx=0;
   end;

   sep=' ';

   if first.bene_id then do;
      best_hcfaspcl_all_90dpre=' ';
      best_hcfaspcl_all_90dpst=' ';
      best_hcfaspcl_all_idx=' ';
      prfnpi_all_90dpre=' ';
      prfnpi_all_90dpst=' ';
      prfnpi_all_idx=' ';
      tax_num_all_90dpre=' ';
      tax_num_all_idx=' ';
      tax_num_all_90dpst=' ';
      provzip9_all_90dpre=' ';
      provzip9_all_90dpst=' ';
      provzip9_all_idx=' ';
      best_hcfaspcl_all_grp_90dpre=' ';
      best_hcfaspcl_all_grp_90dpst=' ';
      best_hcfaspcl_all_grp_idx=' ';
   end;

   if tax_num eq '000000000' then do;
      tax_num_rec+1;
      tax_num=' ';
   end;
   if last then put tax_num_rec=;

   /** DO BELOW TO MAKE SURE THAT CONCATENATED VALUES ALWAYS CORRESPOND
       TO THE RIGHT PERSON. NOTE THAT DON'T REALLY NEED FOR TYPE
       OF UPIN, AND BEST_HCFASPCL_GRP, AS THERE SHOULD BE NO BLANKS.  DOING SO
       THAT WE CAN USE THIS CODE EVEN IF THERE ARE, EVENTUALLY, BLANKS. **/

   if best_hcfaspcl  eq ' ' then best_hcfaspcl='Z9';
   if provzip9 eq ' ' then provzip9='Z99999999';
   if best_hcfaspcl_grp eq ' ' then best_hcfaspcl_grp='Z999999999999999';
   if prfnpi eq ' ' then prfnpi='Z999999999';
   if tax_num eq ' ' then tax_num='Z99999999';


   /** 90 DAYS PRIOR TO ADMISSION **/

   if sadmsndt-90 le sexpndt1 lt sadmsndt then do;
      if indexw(prfnpi_all_90dpre,prfnpi) eq 0 then do;
         prfnpi_all_90dpre=catx(sep,prfnpi_all_90dpre,prfnpi);
         if len_prfnpi_all_90dpre lt length(prfnpi_all_90dpre) then
                    len_prfnpi_all_90dpre=length(prfnpi_all_90dpre);
         tax_num_all_90dpre=catx(sep,tax_num_all_90dpre,tax_num);
         if len_tax_num_all_90dpre lt length(tax_num_all_90dpre) then
                     len_tax_num_all_90dpre=length(tax_num_all_90dpre);
         best_hcfaspcl_all_90dpre=catx(sep,best_hcfaspcl_all_90dpre,best_hcfaspcl);
         if len_best_hcfaspcl_all_90dpre lt length(best_hcfaspcl_all_90dpre) then
                    len_best_hcfaspcl_all_90dpre=length(best_hcfaspcl_all_90dpre);
         provzip9_all_90dpre=catx(sep,provzip9_all_90dpre,provzip9);
         if len_provzip9_all_90dpre lt length(provzip9_all_90dpre) then
                    len_provzip9_all_90dpre=length(provzip9_all_90dpre);
         best_hcfaspcl_all_grp_90dpre=catx(sep,best_hcfaspcl_all_grp_90dpre,best_hcfaspcl_grp);
         if len_best_hcfaspcl_all_grp_90dpre lt length(best_hcfaspcl_all_grp_90dpre) then
                    len_best_hcfaspcl_all_grp_90dpre=length(best_hcfaspcl_all_grp_90dpre);
      end;
   end;


   /** DURING HOSPITALIZATION **/

   else if sadmsndt le sexpndt1 le sdschrgdt then do;
      if indexw(prfnpi_all_idx,prfnpi) eq 0 then do;
         prfnpi_all_idx=catx(sep,prfnpi_all_idx,prfnpi);
         if len_prfnpi_all_idx lt length(prfnpi_all_idx) then
                    len_prfnpi_all_idx=length(prfnpi_all_idx);
         tax_num_all_idx=catx(sep,tax_num_all_idx,tax_num);
         if len_tax_num_all_idx lt length(tax_num_all_idx) then
                     len_tax_num_all_idx=length(tax_num_all_idx);
         best_hcfaspcl_all_idx=catx(sep,best_hcfaspcl_all_idx,best_hcfaspcl);
         if len_best_hcfaspcl_all_idx lt length(best_hcfaspcl_all_idx) then
                    len_best_hcfaspcl_all_idx=length(best_hcfaspcl_all_idx);
         provzip9_all_idx=catx(sep,provzip9_all_idx,provzip9);
         if len_provzip9_all_idx lt length(provzip9_all_idx) then
                    len_provzip9_all_idx=length(provzip9_all_idx);
         best_hcfaspcl_all_grp_idx=catx(sep,best_hcfaspcl_all_grp_idx,best_hcfaspcl_grp);
         if len_best_hcfaspcl_all_grp_idx lt length(best_hcfaspcl_all_grp_idx) then
                    len_best_hcfaspcl_all_grp_idx=length(best_hcfaspcl_all_grp_idx);
      end;
   end;


   /** 90 DAYS POST DISCHARGE **/

   else if sdschrgdt lt sexpndt1 le sdschrgdt+90 then do;
      if indexw(prfnpi_all_90dpst,prfnpi) eq 0 then do;
         prfnpi_all_90dpst=catx(sep,prfnpi_all_90dpst,prfnpi);
         if len_prfnpi_all_90dpst lt length(prfnpi_all_90dpst) then
                    len_prfnpi_all_90dpst=length(prfnpi_all_90dpst);
         tax_num_all_90dpst=catx(sep,tax_num_all_90dpst,tax_num);
         if len_tax_num_all_90dpst lt length(tax_num_all_90dpst) then
                     len_tax_num_all_90dpst=length(tax_num_all_90dpst);
         best_hcfaspcl_all_90dpst=catx(sep,best_hcfaspcl_all_90dpst,best_hcfaspcl);
         if len_best_hcfaspcl_all_90dpst lt length(best_hcfaspcl_all_90dpst) then
                    len_best_hcfaspcl_all_90dpst=length(best_hcfaspcl_all_90dpst);
         provzip9_all_90dpst=catx(sep,provzip9_all_90dpst,provzip9);
         if len_provzip9_all_90dpst lt length(provzip9_all_90dpst) then
                    len_provzip9_all_90dpst=length(provzip9_all_90dpst);
         best_hcfaspcl_all_grp_90dpst=catx(sep,best_hcfaspcl_all_grp_90dpst,best_hcfaspcl_grp);
         if len_best_hcfaspcl_all_grp_90dpst lt length(best_hcfaspcl_all_grp_90dpst) then
                    len_best_hcfaspcl_all_grp_90dpst=length(best_hcfaspcl_all_grp_90dpst);
      end;
   end;

   if last.bene_id;

run;

proc means data=cabg20.hc_prof_panels_v2 min max;
   var
      len_best_hcfaspcl_all_90dpre
      len_best_hcfaspcl_all_90dpst
      len_best_hcfaspcl_all_idx
      len_prfnpi_all_90dpre
      len_prfnpi_all_90dpst
      len_prfnpi_all_idx
      len_tax_num_all_90dpre
      len_tax_num_all_idx
      len_tax_num_all_90dpst
      len_provzip9_all_90dpre
      len_provzip9_all_90dpst
      len_provzip9_all_idx
      len_best_hcfaspcl_all_grp_90dpre
      len_best_hcfaspcl_all_grp_90dpst
      len_best_hcfaspcl_all_grp_idx
      ;
run;

proc sort data=cabg20.cabg08_14_v7;
   by bene_id;
run;

proc sort data=cabg20.hc_prof_panels_v2;
   by bene_id;
run;

data cabg20.cabg08_14_v8;
   merge
      cabg20.cabg08_14_v7(in=a)
      cabg20.hc_prof_panels_v2(in=b keep=best_hcfaspcl_all_90dpre--provzip9_all_90dpst
        BENE_ID)
      ;
   by bene_id;
   if a and b;
run;

%pc(cabg20,cabg08_14_v8)
