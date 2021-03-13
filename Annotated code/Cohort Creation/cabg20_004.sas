/************************************************************
FILENAME: cabg20_004.sas (from tdiff_007.sas)
AUTHOR: skaufman
DATE: 4/14/2017
ID: 54 CABG20PCT
SUMMARY: DETERMINE ELIGIBILITY WITH QUASI-REGISTRY DATA.
************************************************************/

*Starting month/year: 1/1/2007;

%sortdata2(cabg20.entitlehmo07_14,bene_id)
%sortdata2(cabg20.cabg08_14_v2,bene_id)

data entitlehmo07_14;
   merge
      cabg20.cabg08_14_v2(keep=bene_id sadmsndt)
      cabg20.entitlehmo07_14
      ;
   by bene_id;
   format sadmsndt mmddyy10.;
run;

data cabg20.entitlehmo07_14_v2(drop=i j k);
   length flagset $ 3;
   set entitlehmo07_14(rename=(sdob=dob));

   array ent[96] $;
   array hmo[96] $;

   mon_at_sadmsndt=1+intck('month',mdy(1,1,2007),sadmsndt);

   age_at_sadmsndt=int(intck('month',dob,sadmsndt)/12);
   if month(dob) eq month(sadmsndt) and day(sadmsndt) lt day(dob) then age_at_sadmsndt=age_at_sadmsndt-1;

   if age_at_sadmsndt ge 66;


/* BEFORE */

   pre_elig_flag=1;
   pre_hmo_flag=0;

   if ent[mon_at_sadmsndt-12] eq ' ' then do; /* NOTE: I removed (mon_at_sadmsndt-12 eq 0) b/c this will never occur.*/
      pre_elig_flag=.N;
      pre_hmo_flag=.N;
   end;
   else do i=mon_at_sadmsndt-12 to mon_at_sadmsndt;  /** IS PATIENT ELIGIBLE 1 Y BACK? **/
      if ent[i] ne '3' and ent[i] ne ' ' then pre_elig_flag=0;
      if hmo[i] ne '0' and hmo[i] ne ' ' then pre_hmo_flag=1;
   end;
   if pre_elig_flag then do;
      eligstart=intnx('month',mdy(1,1,2007),mon_at_sadmsndt-13);
   end;


 /* AFTER */

   do j=mon_at_sadmsndt+1 to 96;
      if ent[j] ne '3' and pre_elig_flag then do;
         eligstop=intnx('month',mdy(1,1,2007),j-1); /** DATE THAT ELIG STOPS **/
         leave;
      end;
   end;

   if pre_elig_flag eq 1 and eligstop eq . then eligstop=mdy(12,31,2014);
   
   do k=mon_at_sadmsndt+1 to 96;
      if hmo[k] ne '0' and hmo[k] ne ' ' then do;
         hmostart=intnx('month',mdy(1,1,2007),k-1); /** DATE OF POST HMO APPEARANCE  **/
         leave;
      end;
      if hmo[k] eq ' ' then do;
         hmoblank=intnx('month',mdy(1,1,2007),k-1); /** DATE OF POST HMO BLANK  **/
         leave;
      end;
   end; 

   death_du_fo=0;
    if sadmsndt le sdod then do;
      death_date_du_fo=sdod;
      death_du_fo=1;
   end;
   
   if eligstop ne . then do;
      earliest_end_date=min(death_date_du_fo,hmostart,hmoblank,eligstop);
   end;
      
   flagset=cats(pre_elig_flag,pre_hmo_flag,death_du_fo);
   label flagset="pre_elig_flag,pre_hmo_flag,death_du_fo";

   will_keep=0;
   if (pre_hmo_flag eq 0 and pre_elig_flag eq 1) then will_keep=1;

   format earliest_end_date sdod death_date_du_fo eligstart eligstop 
      dob hmostart hmoblank mmddyy10.;

run;

data cabg20.entitlehmo07_14_v2;
   retain flagset bene_id will_keep dob sadmsndt sdod mon_at_sadmsndt
      age_at_sadmsndt pre_elig_flag pre_hmo_flag eligstart eligstop hmostart
      hmoblank death_du_fo death_date_du_fo earliest_end_date;
   set cabg20.entitlehmo07_14_v2;
run;


proc sort data=cabg20.entitlehmo07_14_v2 out=work.sorttemptablesorted;
   by flagset;
run;

proc surveyselect data=work.sorttemptablesorted out=cabg20.entitlehmo07_14_v2_rs
         method=srs n=5 seed=999 selectall;
   strata flagset;
run;
quit;


data cabg20.entitlehmo07_14_v3(drop=will_keep mon_at_sadmsndt
      pre_elig_flag pre_hmo_flag yr2007--hmo96);
   set cabg20.entitlehmo07_14_v2;
   if will_keep;
run;

%pc(cabg20,entitlehmo07_14_v3);
