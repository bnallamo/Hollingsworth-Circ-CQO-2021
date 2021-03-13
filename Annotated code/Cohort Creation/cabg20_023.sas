/************************************************************
FILENAME: cabg20_023.sas (from cabgf2_023.sas)
AUTHOR: skaufman
DATE: 5/9/2017
ID: 54
SUMMARY: ADD PSI VARIABLES TO COHORT DATA SET.
************************************************************/

libname psisas 'F:\Documents\SKAUFMAN\54 JH CABG20PCT\CABG\PSI SAS';

data psi1(rename=(key=bene_id));
   set psisas.psi1(keep=key tpps02--tpps19);
run;

%sortdata2(psi1,bene_id);
%sortdata2(cabg20.cabg08_14_v15,bene_id);

data cabg20.cabg08_14_v16;
   merge
      cabg20.cabg08_14_v15(in=a)
      psi1(in=b keep=bene_id tpps05 tpps06 tpps12 tpps15)
      ;
   by bene_id;
   in_cabg=a;
   in_psi1=b;
run;

proc freq data=cabg20.cabg08_14_v16;
   tables in_cabg * in_psi1;
   tables tpps05 tpps06 tpps12 tpps15 / missprint;
run;

data cabg20.cabg08_14_v16(drop=i);
   set cabg20.cabg08_14_v16(drop=in_cabg in_psi1);

   array tpps[4] tpps05 tpps06 tpps12 tpps15;
   array psi[4] psi05 psi06 psi12 psi15;

   do i=1 to 4;
      psi[i]=tpps[i];
     if tpps[i]=. then psi[i]=0;
   end;
run;

proc freq data=cabg20.cabg08_14_v16;
   tables psi05--psi15 / missprint;
run;
