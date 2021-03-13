/************************************************************
FILENAME: cabg20_019.sas (from cabgf2_018.sas, cabgf2_019.sas)
AUTHOR: skaufman
DATE: 5/5/2017
ID: 54
SUMMARY: PRE-EXISTING CONDITIONS FOR "OUTCOME" ASSESSMENT.
************************************************************/

%sortdata2(cabg20.cabg08_14_v13, bene_id)
%sortdata2(cabg20.nch07_14_coh_v6, bene_id sexpndt1)

data
   ptb_90dprior
   ptb_idxhosp
   ptb_90dpost
   ;
   set cabg20.nch07_14_coh_v6;
   if sadmsndt-90 le sexpndt1 lt sadmsndt then output ptb_90dprior;
   else if sadmsndt le sexpndt1 le sdschrgdt then output ptb_idxhosp;
   else if sdschrgdt lt sexpndt1 le sdschrgdt+90 then output ptb_90dpost;
run;

data carrier90dprior(keep=bene_id pre_hcpcs_4_pr3995 pre_hcpcs_4_pr5498);
   retain pre_hcpcs_4_pr3995 pre_hcpcs_4_pr5498;
   set ptb_90dprior;
   by bene_id;
   if first.bene_id then do;
      pre_hcpcs_4_pr3995=0;
      pre_hcpcs_4_pr5498=0;
   end;
   if hcpcs_cd in('90935' '90936' '90937') then pre_hcpcs_4_pr3995=1;
   if hcpcs_cd in('90945' '90946' '90947') then pre_hcpcs_4_pr5498=1;
   if last.bene_id;
run;

proc freq data=carrier90dprior;
   tables pre_hcpcs_4_pr3995 pre_hcpcs_4_pr5498;
   title1 "90 DAYS PRIOR";
run;
title1;


data carrier90dpost(keep=bene_id post_hcpcs_4_pr3995 post_hcpcs_4_pr5498);
   retain post_hcpcs_4_pr3995 post_hcpcs_4_pr5498;
   set ptb_90dpost;
   by bene_id;
   if first.bene_id then do;
      post_hcpcs_4_pr3995=0;
      post_hcpcs_4_pr5498=0;
   end;
   if hcpcs_cd in('90935' '90936' '90937') then post_hcpcs_4_pr3995=1;
   if hcpcs_cd in('90945' '90946' '90947') then post_hcpcs_4_pr5498=1;
   if last.bene_id;
run;

proc freq data=carrier90dpost;
   tables post_hcpcs_4_pr3995 post_hcpcs_4_pr5498;
   title1 "90 DAYS POST";
run;
title1;

data cabg20.carrier_pre_post;
   merge
     carrier90dprior
     carrier90dpost
     ;
   by bene_id;
run; 


/*****************
   ptb_90dprior
   ptb_idxhosp
   ptb_90dpost
*****************/

data pre_icd9dx(keep=bene_id icd9dx_all_90dpre len_icd9dx_all_90dpre);
   retain
      icd9dx_all_90dpre
      len_icd9dx_all_90dpre
      ;
   length icd9dx_all_90dpre $ 800;
   set ptb_90dprior(keep=bene_id dgns_cd:);
   by bene_id;

   if _n_ eq 1 then do;
      len_icd9dx_all_90dpre=0;
   end;

   sep=' ';

   if first.bene_id then do;
      icd9dx_all_90dpre=' ';
   end;

   array icd9[*] dgns_cd:;
   do i=1 to dim(icd9);
      if indexw(icd9dx_all_90dpre,icd9[i]) eq 0 then do;
         icd9dx_all_90dpre=catx(sep,icd9dx_all_90dpre,icd9[i]);
         if len_icd9dx_all_90dpre lt length(icd9dx_all_90dpre)
            then len_icd9dx_all_90dpre=length(icd9dx_all_90dpre);
      end;
   end;

   if last.bene_id;
run;

proc means data=pre_icd9dx min max;
   var len_icd9dx_all_90dpre;
run;

data post_icd9dx(keep=bene_id icd9dx_all_90dpst len_icd9dx_all_90dpst);
   retain
      icd9dx_all_90dpst
      len_icd9dx_all_90dpst
      ;
   length icd9dx_all_90dpst $ 800;
   set ptb_90dpost(keep=bene_id dgns_cd:);
   by bene_id;

   if _n_ eq 1 then do;
      len_icd9dx_all_90dpst=0;
   end;

   sep=' ';

   if first.bene_id then do;
      icd9dx_all_90dpst=' ';
   end;

   array icd9[*] dgns_cd:;
   do i=1 to dim(icd9);
      if indexw(icd9dx_all_90dpst,icd9[i]) eq 0 then do;
         icd9dx_all_90dpst=catx(sep,icd9dx_all_90dpst,icd9[i]);
         if len_icd9dx_all_90dpst lt length(icd9dx_all_90dpst)
          then len_icd9dx_all_90dpst=length(icd9dx_all_90dpst);
      end;
   end;

   if last.bene_id;

run;

proc means data=post_icd9dx min max;
   var len_icd9dx_all_90dpst;
run;

data cabg20.pre_post_icd9dx;
   merge
     pre_icd9dx(in=a)
     post_icd9dx(in=b)
     ;
   by bene_id;
   in_pre=a;
   in_post=b;
run; 

proc freq data=cabg20.pre_post_icd9dx;
   tables in_pre * in_post;
run;

data cabg20.cabg08_14_v14;
   merge
      cabg20.cabg08_14_v13(in=a)
      cabg20.carrier_pre_post(in=b)
      cabg20.pre_post_icd9dx(in=c drop=in_pre in_post len_:)
      ;
   by bene_id;
   if a;
   in_carrier_pre_post=b;
   in_icd9=c;
run;

proc freq data=cabg20.cabg08_14_v14;
   tables in_carrier_pre_post in_icd9 / missprint;
   title1 "FROM CABG20_019.SAS";
run;

