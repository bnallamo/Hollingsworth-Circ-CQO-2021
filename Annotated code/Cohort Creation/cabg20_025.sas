/************************************************************
FILENAME: cabg20_025.sas (from cabgf2_030.sas)
AUTHOR: skaufman
DATE: 5/10/2017
ID: 54
SUMMARY: PRE AND POST COMPLICATIONS.
************************************************************/


/** DO THE PRES **/

data cabg20.cabg08_14_v18(drop=word count);
   length word $ 5;
   set cabg20.cabg08_14_v17;


/** NOT IN PRE ... **/

   pre_fbcomp=.;
   pre_ptxcomp=.;
   pre_bleedcomp=.;
   pre_bleedcomp2=.;
   pre_vtecomp=.;
   pre_sepsiscomp=.;
   pre_woundcomp=.;
   pre_puncturecomp=.;
   pre_misccomp=.;
   pre_othercomp=.;
   pre_othercomp2=.;
   pre_severecomp4=.;
   pre_surgicalcomp=.;
   pre_surgicalcomp2=.;



/** OTHER INFECTION **/


   pre_infectioncomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
         '99739' '99731' '683' '5909' '5903' '5902' '5679' '56782' '56781'
         '5671' '5670' '567' '5192' '486' '485' '481' '00845'
         ) or
         substr(word,1,4) in(
         '5901' '5673' '5672' '5908'
         ) or 
         substr(word,1,3) in(
         '513' '510' '507' '484' '483' '482' '320'
         ) then pre_infectioncomp=1;
   end;
   label pre_infectioncomp='pre_infectioncomp: PNEUM,POST-OP,CDIFF,PYELO,PERIT,MISC (CSP)';



/** ACUTE RENAL FAILURE **/

   pre_arfwodcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in('9975'
            ) or
            substr(word,1,3) in('584'
            ) then pre_arfwodcomp=1;
   end;
   label pre_arfwodcomp='pre_arfwodcomp: ACUTE RENAL FAILURE';



/** ACUTE RENAL FAILURE REQUIRING DIALYSIS **/

   pre_arfdcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in('v560' 'v561'
            ) or
            substr(word,1,3) in(
            '584' 'v451'
            ) then pre_arfdcomp=1;
   end;
   if pre_hcpcs_4_pr3995 eq 1 then pre_arfdcomp=1;
   label pre_arfdcomp='pre_arfdcomp: ACUTE RENAL FAILURE REQUIRING DIALYSIS';



/** CHRONIC DIALYSIS **/

   pre_esrdexclude=0;

   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if (substr(word,1,3) eq '584') then d584=1;
   end;

   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
            'V451' 'V560' 'V561' 'V562' 'V563' 'V568'
            ) then pre_esrdexclude=1;
   end;

   if pre_hcpcs_4_pr3995 eq 1 or pre_hcpcs_4_pr5498 eq 1 then pre_arfdcomp=1;

   if d584 then pre_esrdexclude=0;

   label pre_esrdexclude='pre_esrdexclude: CHRONIC DIALYSIS';
   drop d584;



/** CARDIAC COMPLICATIONS **/


   pre_cardcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
            '9971' '4275' '78551'
            ) or
            substr(word,1,3) in(
            '410'
            ) then pre_cardcomp=1;
   end;
   label pre_cardcomp='pre_cardcomp:CARDIAC COMPLICATIONS';




/** RESPIRATORY FAILURE **/

   pre_pulmcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
            '51881' '5184' '5185' '5187' '51884' '51882' '7991'
            ) or
            substr(word,1,4) in(
            '9973' 
            ) then pre_pulmcomp=1;
   end;
   label pre_pulmcomp='pre_pulmcomp:RESPIRATORY FAILURE';




/** GI COMPLICATIONS **/

   pre_gicomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
            '53082' '5789' '9974'
            ) or
            substr(word,1,4) in(
            '5310' '5311' '5312' '5314' '5316' '5320' '5321'
            '5322' '5324' '5326' '5330' '5331' '5332' '5334' '5336'
            '5340' '5341' '5342' '5344' '5346'
            ) or 
            substr(word,1,3) in(
            '560'
            ) or
            substr(word,1,3) eq '535' and substr(word,5,1) eq '1' /* for 535.x1 */
            then pre_gicomp=1;
   end;
   label pre_gicomp='pre_gicomp:GI COMPLICATIONS';




/** GU COMPLICATIONS **/  /* Note using the procedure codes (or HCPCS representing
                             these codes), per JH, as did for index hospitalization. */

   pre_gucomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470'
            'V446' 'V556' '591' '86814' '86804' '59382' '5991'
            '6190' '9986' '7888' '56789'
            ) or
            substr(word,1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(word,1,3) in(
            '866' '867'
            ) then pre_gucomp=1;
   end;
   label pre_gucomp='pre_gucomp:GU COMPLICATIONS';




/** GU COMPLICATIONS (RECODE) **/

   /* Ureteral injury, Renovascular, Obstruction, PNT, Fistula, Leak minus
   routine cysto */

   pre_gucomp2=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470' 'V446' 'V556' '591'
            '86814' '86804' '59382' '5991' '6190' '9986' '7888' '56789'
            ) or
            substr(word,1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(word,1,3) in(
            '866' '867'
            ) then pre_gucomp2=1;
   end;
   label pre_gucomp2='pre_gucomp2:GU COMPLICATIONS (RECODE, NO CYSTO)';



/** GU COMPLICATIONS (ANOTHER RECODE) **/

   /* Ureteral injury, Renovascular, Obstruction, PNT, Fistula, Leak minus
   routine cysto, RUS, and IVP */

   pre_gucomp3=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if word in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470' 'V446' 'V556' '591'
            '86814' '86804' '59382' '5991' '6190' '9986' '7888' '56789'
            ) or
            substr(word,1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(word,1,3) in(
            '867' '866'
            ) then pre_gucomp3=1;
   end;
   label pre_gucomp3='pre_gucomp3:GU COMPLICATIONS (RECODE, NO CYSTO, RUS, IVP)';




/** NEURO COMP/CEREBRAL INFARCTION **/

   pre_neurocomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpre, count);
      if substr(word,1,4) in(
            '9970'
            ) or 
            substr(word,1,3) in(
            '433' '434'
            ) then pre_neurocomp=1;
   end;
   label pre_neurocomp='pre_neurocomp:CEREBRAL INFARCTION';



/** ACUTE RENAL FAILURE EXCLUDING CHRONIC DIALYSIS **/

   if pre_arfwodcomp eq 1 and pre_esrdexclude eq 0 then pre_arfcompNOcd=1;
   else if pre_arfwodcomp eq 0 and pre_esrdexclude eq 0 then pre_arfcompNOcd=0;
   label pre_arfcompNOcd='pre_arfcompNOcd:ACUTE RENAL FAILURE EXCLUDING CHRONIC DIALYSIS';



/** ANY COMP **/

   pre_anycomp=sum(of 
          pre_neurocomp pre_pulmcomp pre_cardcomp pre_gucomp3
          pre_gicomp pre_arfcompNOcd
          pre_infectioncomp) gt 0;
   label pre_anycomp='pre_anycomp: (incompl) ANY COMPLICATION INDICATORS';



/** ANY COMP 2 **/

   pre_anycomp2=sum(of 
         pre_neurocomp pre_pulmcomp pre_cardcomp pre_gicomp
         pre_infectioncomp) gt 0;
   label pre_anycomp2='pre_anycomp2:(incompl) ANYCOMP WITHOUT GUCOMP3 OR ARFWODCOMP';



/** MEDICAL COMP **/

   pre_medicalcomp=sum(pre_neurocomp, pre_pulmcomp, pre_cardcomp,
           pre_gicomp, pre_arfcompnocd, pre_infectioncomp) gt 0;
   label pre_medicalcomp='(incompl) pre_medicalcomp: MEDICAL COMPLICATIONS';



/** MEDICAL COMP 2 **/

   pre_medicalcomp2=sum(pre_pulmcomp, pre_cardcomp,
          pre_gicomp, pre_infectioncomp) gt 0;
   label pre_medicalcomp2='(incompl) pre_medicalcomp2: MEDICALCOMP W/O ARWODCOMP';




/** SEVERE COMP **/ 

   pre_severecomp=sum(pre_pulmcomp,
          pre_cardcomp, pre_gicomp, pre_arfcompnocd) gt 0;
   label pre_severecomp='(incompl) pre_severecomp';



/** SEVERE COMP W/ ARFD ONLY **/ 

   pre_severecomp2=sum(pre_pulmcomp,
          pre_cardcomp, pre_gicomp, pre_arfdcomp) gt 0;
   label pre_severecomp2='(incompl) pre_severecomp2: SEVERE COMP W/ ARFD ONLY';




/** SEVERE COMP W/O ARF **/ 

   pre_severecomp3=sum(pre_pulmcomp,
          pre_cardcomp, pre_gicomp) gt 0;
   label pre_severecomp3='(incompl) pre_severecomp3: SEVERE COMP W/ ARFD ONLY';



/** COMPLICATION COUNT **/

   pre_countcomp=sum(
       pre_neurocomp, pre_pulmcomp, pre_cardcomp, pre_gucomp3,
       pre_gicomp, pre_arfcompNOcd, pre_infectioncomp);
   label pre_countcomp='(incompl) pre_countcomp: NUMBER OF COMPLICATIONS';



/** COMPLICATION COUNT CATEGORIZED **/

   pre_countcomp2=pre_countcomp;
   if pre_countcomp2 gt 2 then pre_countcomp2=2;
   label pre_countcomp2='(incompl) pre_countcomp2: NUMBER OF COMPLICATIONS, TRICHOTOMOMIZED';

run;



/** NOW CORRECT THE INDEX COMPLICATIONS GIVEN THE PRE **/


data cabg20.cabg08_14_v18(drop=i countofrecodes);
   set cabg20.cabg08_14_v18 end=last;

   array pre[*]
      pre_infectioncomp pre_arfwodcomp pre_arfdcomp pre_esrdexclude
      pre_arfcompNOcd pre_cardcomp pre_pulmcomp pre_gicomp pre_gucomp
      pre_gucomp2 pre_gucomp3 pre_neurocomp
      ;
   array idx[*] 
      infectioncomp arfwodcomp arfdcomp esrdexclude arfcompNOcd cardcomp
      pulmcomp gicomp gucomp gucomp2 gucomp3 neurocomp
      ;

   do i=1 to dim(pre);
      if pre[i] eq 1 and idx[i] eq 1 then do;
         if countofrecodes lt 50 then do;
            put pre[i]= idx[i]=;
            idx[i]=0;
            countofrecodes+1;
         end;
         else do;
            idx[i]=0;
            countofrecodes+1;
         end;
      end;
   end;

   if last then put countofrecodes=;

run;



data cabg20.cabg08_14_v18;
   set cabg20.cabg08_14_v18;


/** AND BUILD COMBO VARIABLES THAT DEPEND ON CORRECT INDEX COMPLICATIONS **/


/** OTHERCOMP **/

   if fbcomp or ptxcomp or misccomp or neurocomp then othercomp=1;
   else othercomp=0;
   label othercomp='othercomp:FBCOMP OR PTXCOMP OR MISCCOMP OR NEUROCOMP';



/** OTHERCOMP2 **/

   if fbcomp or ptxcomp or misccomp then othercomp2=1;
   else othercomp2=0;
   label othercomp2='othercomp2:FBCOMP OR PTXCOMP OR MISCCOMP';



/** ANY COMP **/

   anycomp=sum(of misccomp puncturecomp woundcomp sepsiscomp vtecomp
          neurocomp pulmcomp cardcomp gucomp3 gicomp arfcompNOcd bleedcomp2
          infectioncomp ptxcomp fbcomp) gt 0;
   label anycomp='anycomp: ANY COMPLICATION INDICATORS';



/** ANY COMP 2 **/

   anycomp2=sum(of misccomp puncturecomp woundcomp sepsiscomp
         vtecomp neurocomp pulmcomp cardcomp gicomp bleedcomp2
         infectioncomp ptxcomp fbcomp) gt 0;
   label anycomp2='anycomp2: ANYCOMP WITHOUT GUCOMP3 OR ARFWODCOMP';



/** MEDICAL COMP **/

   medicalcomp=sum(sepsiscomp, vtecomp, neurocomp, pulmcomp, cardcomp,
           gicomp, arfcompnocd, infectioncomp) gt 0;
   label medicalcomp='medicalcomp: MEDICAL COMPLICATIONS';



/** MEDICAL COMP 2 **/

   medicalcomp2=sum(sepsiscomp, vtecomp, neurocomp, pulmcomp, cardcomp,
          gicomp, infectioncomp) gt 0;
   label medicalcomp2='medicalcomp2: MEDICALCOMP W/O ARWODCOMP';



/** SURGICAL COMP **/

   surgicalcomp=sum(misccomp, puncturecomp, woundcomp, gucomp3,
          bleedcomp2, ptxcomp, fbcomp) gt 0;
   label surgicalcomp='surgicalcomp';



/** SURGICAL COMP 2 **/

   surgicalcomp2=sum(misccomp, puncturecomp, woundcomp,
          bleedcomp2, ptxcomp, fbcomp) gt 0;
   label surgicalcomp2='surgicalcomp2:  w/o gucomp3';



/** SEVERE COMP **/ 

   severecomp=sum(puncturecomp, woundcomp, sepsiscomp, vtecomp, pulmcomp,
          cardcomp, gicomp, arfcompnocd, bleedcomp2) gt 0;
   label severecomp='severecomp';



/** SEVERE COMP W/ ARFD ONLY **/ 

   severecomp2=sum(puncturecomp, woundcomp, sepsiscomp, vtecomp, pulmcomp,
          cardcomp, gicomp, arfdcomp, bleedcomp2) gt 0;
   label severecomp2='severecomp2: SEVERE COMP W/ ARFD ONLY';



/** SEVERE COMP W/O ARF **/ 

   severecomp3=sum(puncturecomp, woundcomp, sepsiscomp, vtecomp,
          pulmcomp, cardcomp, gicomp, bleedcomp2) gt 0;
   label severecomp3='severecomp3: SEVERE COMP W/O ARF';



/** SEVERE COMP W/O ARF OR GI **/

   severecomp4=sum(puncturecomp, woundcomp, sepsiscomp, vtecomp,
          pulmcomp, cardcomp, bleedcomp2) gt 0;
   label severecomp4='severecomp4: SEVERE COMP W/O ARF OR GI';



/** COMPLICATION COUNT **/

   countcomp=sum(misccomp, puncturecomp, woundcomp,
       sepsiscomp, vtecomp, neurocomp, pulmcomp, cardcomp, gucomp3,
       gicomp, arfcompNOcd, bleedcomp2, infectioncomp, ptxcomp, fbcomp);
   label countcomp='countcomp: NUMBER OF COMPLICATIONS';



/** COMPLICATION COUNT CATEGORIZED **/

   countcomp2=sum(misccomp, puncturecomp, woundcomp,
       sepsiscomp, vtecomp, neurocomp, pulmcomp, cardcomp, gucomp3,
       gicomp, arfcompNOcd, bleedcomp2, infectioncomp, ptxcomp, fbcomp);
   if countcomp2 gt 2 then countcomp2=2;
   label countcomp2='countcomp2: NUMBER OF COMPLICATIONS, TRICHOTOMOMIZED';

run;



/** NOW BUILD THE POSTS **/


data cabg20.cabg08_14_v19(drop=word);
   length word $5;
   set cabg20.cabg08_14_v18;


/** NOT IN POST ... **/

   post_fbcomp=.;
   post_ptxcomp=.;
   post_bleedcomp=.;
   post_bleedcomp2=.;
   post_vtecomp=.;
   post_sepsiscomp=.;
   post_woundcomp=.;
   post_puncturecomp=.;
   post_misccomp=.;
   post_othercomp=.;
   post_othercomp2=.;
   post_severecomp4=.;
   post_surgicalcomp=.;
   post_surgicalcomp2=.;



/** OTHER INFECTION **/


   post_infectioncomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
         '99739' '99731' '683' '5909' '5903' '5902' '5679' '56782' '56781'
         '5671' '5670' '567' '5192' '486' '485' '481' '00845'
         ) or
         substr(word,1,4) in(
         '5901' '5673' '5672' '5908'
         ) or 
         substr(word,1,3) in(
         '513' '510' '507' '484' '483' '482' '320'
         ) then post_infectioncomp=1;
   end;
   label post_infectioncomp='post_infectioncomp: PNEUM,POST-OP,CDIFF,PYELO,PERIT,MISC (CSP)';



/** ACUTE RENAL FAILURE **/

   post_arfwodcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in('9975'
            ) or
            substr(word,1,3) in('584'
            ) then post_arfwodcomp=1;
   end;
   label post_arfwodcomp='post_arfwodcomp: ACUTE RENAL FAILURE';



/** ACUTE RENAL FAILURE REQUIRING DIALYSIS **/

   post_arfdcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in('v560' 'v561'
            ) or
            substr(word,1,3) in(
            '584' 'v451'
            ) then post_arfdcomp=1;
   end;
   if post_hcpcs_4_pr3995 eq 1 then post_arfdcomp=1;
   label post_arfdcomp='post_arfdcomp: ACUTE RENAL FAILURE REQUIRING DIALYSIS';



/** CHRONIC DIALYSIS **/

   post_esrdexclude=0;

   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if (substr(word,1,3) eq '584') then d584=1;
   end;

   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
            'V451' 'V560' 'V561' 'V562' 'V563' 'V568'
            ) then post_esrdexclude=1;
   end;

   if post_hcpcs_4_pr3995 eq 1 or post_hcpcs_4_pr5498 eq 1 then post_arfdcomp=1;

   if d584 then post_esrdexclude=0;

   label post_esrdexclude='post_esrdexclude: CHRONIC DIALYSIS';
   drop d584;



/** ACUTE RENAL FAILURE EXCLUDING CHRONIC DIALYSIS **/

   if post_arfwodcomp eq 1 and post_esrdexclude eq 0 then post_arfcompNOcd=1;
   else if post_arfwodcomp eq 0 and post_esrdexclude eq 0 then post_arfcompNOcd=0;
   label post_arfcompNOcd='post_arfcompNOcd:ACUTE RENAL FAILURE EXCLUDING CHRONIC DIALYSIS';



/** CARDIAC COMPLICATIONS **/


   post_cardcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
            '9971' '4275' '78551'
            ) or
            substr(word,1,3) in(
            '410'
            ) then post_cardcomp=1;
   end;
   label post_cardcomp='post_cardcomp:CARDIAC COMPLICATIONS';




/** RESPIRATORY FAILURE **/

   post_pulmcomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
            '51881' '5184' '5185' '5187' '51884' '51882' '7991'
            ) or
            substr(word,1,4) in(
            '9973' 
            ) then post_pulmcomp=1;
   end;
   label post_pulmcomp='post_pulmcomp:RESPIRATORY FAILURE';




/** GI COMPLICATIONS **/

   post_gicomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
            '53082' '5789' '9974'
            ) or
            substr(word,1,4) in(
            '5310' '5311' '5312' '5314' '5316' '5320' '5321'
            '5322' '5324' '5326' '5330' '5331' '5332' '5334' '5336'
            '5340' '5341' '5342' '5344' '5346'
            ) or 
            substr(word,1,3) in(
            '560'
            ) or
            substr(word,1,3) eq '535' and substr(word,5,1) eq '1' /* for 535.x1 */
            then post_gicomp=1;
   end;
   label post_gicomp='post_gicomp:GI COMPLICATIONS';




/** GU COMPLICATIONS **/  /* Note using the procedure codes (or HCPCS representing
                             these codes), per JH, as did for index hospitalization. */

   post_gucomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470'
            'V446' 'V556' '591' '86814' '86804' '59382' '5991'
            '6190' '9986' '7888' '56789'
            ) or
            substr(word,1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(word,1,3) in(
            '866' '867'
            ) then post_gucomp=1;
   end;
   label post_gucomp='post_gucomp:GU COMPLICATIONS';




/** GU COMPLICATIONS (RECODE) **/

   /* Ureteral injury, Renovascular, Obstruction, PNT, Fistula, Leak minus
   routine cysto */

   post_gucomp2=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470' 'V446' 'V556' '591'
            '86814' '86804' '59382' '5991' '6190' '9986' '7888' '56789'
            ) or
            substr(word,1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(word,1,3) in(
            '866' '867'
            ) then post_gucomp2=1;
   end;
   label post_gucomp2='post_gucomp2:GU COMPLICATIONS (RECODE, NO CYSTO)';



/** GU COMPLICATIONS (ANOTHER RECODE) **/

   /* Ureteral injury, Renovascular, Obstruction, PNT, Fistula, Leak minus
   routine cysto, RUS, and IVP */

   post_gucomp3=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if word in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470' 'V446' 'V556' '591'
            '86814' '86804' '59382' '5991' '6190' '9986' '7888' '56789'
            ) or
            substr(word,1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(word,1,3) in(
            '867' '866'
            ) then post_gucomp3=1;
   end;
   label post_gucomp3='post_gucomp3:GU COMPLICATIONS (RECODE, NO CYSTO, RUS, IVP)';




/** NEURO COMP/CEREBRAL INFARCTION **/

   post_neurocomp=0;
   count=0;
   do until(word=' ');
      count+1;
      word=scan(icd9dx_all_90dpst, count);
      if substr(word,1,4) in(
            '9970'
            ) or 
            substr(word,1,3) in(
            '433' '434'
            ) then post_neurocomp=1;
   end;
   label post_neurocomp='post_neurocomp:CEREBRAL INFARCTION';



/** ANY COMP **/

   post_anycomp=sum(of 
          post_neurocomp post_pulmcomp post_cardcomp post_gucomp3
          post_gicomp post_arfcompNOcd
          post_infectioncomp) gt 0;
   label post_anycomp='post_anycomp: (incompl) ANY COMPLICATION INDICATORS';



/** MEDICAL COMP **/

   post_medicalcomp=sum(post_neurocomp, post_pulmcomp, post_cardcomp,
           post_gicomp, post_arfcompnocd, post_infectioncomp) gt 0;
   label post_medicalcomp='(incompl) post_medicalcomp: MEDICAL COMPLICATIONS';



/** MEDICAL COMP 2 **/

   post_medicalcomp2=sum(post_pulmcomp, post_cardcomp,
          post_gicomp, post_infectioncomp) gt 0;
   label post_medicalcomp2='(incompl) post_medicalcomp2: MEDICALCOMP W/O ARWODCOMP';



/** ANY COMP 2 **/

   post_anycomp2=sum(of 
         post_neurocomp post_pulmcomp post_cardcomp post_gicomp
         post_infectioncomp) gt 0;
   label post_anycomp2='post_anycomp2:(incompl) ANYCOMP WITHOUT GUCOMP3 OR ARFWODCOMP';




/** SEVERE COMP **/ 

   post_severecomp=sum(post_pulmcomp,
          post_cardcomp, post_gicomp, post_arfcompnocd) gt 0;
   label post_severecomp='(incompl) post_severecomp';




/** SEVERE COMP W/ ARFD ONLY **/ 

   post_severecomp2=sum(post_pulmcomp,
          post_cardcomp, post_gicomp, post_arfdcomp) gt 0;
   label post_severecomp2='(incompl) post_severecomp2: SEVERE COMP W/ ARFD ONLY';



/** SEVERE COMP W/O ARF **/ 

   post_severecomp3=sum(post_pulmcomp,
          post_cardcomp, post_gicomp) gt 0;
   label post_severecomp3='(incompl) post_severecomp3: SEVERE COMP W/ ARFD ONLY';



/** COMPLICATION COUNT **/

   post_countcomp=sum(
       post_neurocomp, post_pulmcomp, post_cardcomp, post_gucomp3,
       post_gicomp, post_arfcompNOcd, post_infectioncomp);
   label post_countcomp='(incompl) post_countcomp: NUMBER OF COMPLICATIONS';



/** COMPLICATION COUNT CATEGORIZED **/

   post_countcomp2=post_countcomp;
   if post_countcomp2 gt 2 then post_countcomp2=2;
   label post_countcomp2='(incompl) post_countcomp2: NUMBER OF COMPLICATIONS, TRICHOTOMOMIZED';

run;



proc freq data=cabg20.cabg08_14_v19;
   tables
      pre_anycomp anycomp post_anycomp
      pre_anycomp2 anycomp2 post_anycomp2
      pre_arfcompNOcd arfcompNOcd post_arfcompNOcd
      pre_arfdcomp arfdcomp post_arfdcomp
      pre_arfwodcomp arfwodcomp post_arfwodcomp
      bleedcomp
      bleedcomp2
      pre_cardcomp cardcomp post_cardcomp
      pre_countcomp countcomp post_countcomp
      pre_countcomp2 countcomp2 post_countcomp2
      pre_esrdexclude esrdexclude post_esrdexclude
      fbcomp
      pre_gicomp gicomp post_gicomp
      pre_gucomp gucomp post_gucomp
      pre_gucomp2 gucomp2 post_gucomp2
      pre_gucomp3 gucomp3 post_gucomp3
      pre_infectioncomp infectioncomp post_infectioncomp
      pre_medicalcomp medicalcomp post_medicalcomp
      pre_medicalcomp2 medicalcomp2 post_medicalcomp2
      misccomp
      pre_neurocomp neurocomp post_neurocomp
      othercomp
      othercomp2
      ptxcomp
      pre_pulmcomp pulmcomp post_pulmcomp
      puncturecomp
      sepsiscomp
      severecomp
      pre_severecomp2 severecomp2 post_severecomp2
      pre_severecomp3 severecomp3 post_severecomp3
      severecomp4
      surgicalcomp
      surgicalcomp2
      vtecomp
      woundcomp
         /missprint
      ;
   title1 "ALL YEARS";
   title2 "FROM CABG20_025.SAS";
run;
title1;


proc freq data=cabg20.cabg08_14_v19;
   where 2008 le admyear le 2011;
   tables
      pre_anycomp anycomp post_anycomp
      pre_anycomp2 anycomp2 post_anycomp2
      pre_arfcompNOcd arfcompNOcd post_arfcompNOcd
      pre_arfdcomp arfdcomp post_arfdcomp
      pre_arfwodcomp arfwodcomp post_arfwodcomp
      bleedcomp
      bleedcomp2
      pre_cardcomp cardcomp post_cardcomp
      pre_countcomp countcomp post_countcomp
      pre_countcomp2 countcomp2 post_countcomp2
      pre_esrdexclude esrdexclude post_esrdexclude
      fbcomp
      pre_gicomp gicomp post_gicomp
      pre_gucomp gucomp post_gucomp
      pre_gucomp2 gucomp2 post_gucomp2
      pre_gucomp3 gucomp3 post_gucomp3
      pre_infectioncomp infectioncomp post_infectioncomp
      pre_medicalcomp medicalcomp post_medicalcomp
      pre_medicalcomp2 medicalcomp2 post_medicalcomp2
      misccomp
      pre_neurocomp neurocomp post_neurocomp
      othercomp
      othercomp2
      ptxcomp
      pre_pulmcomp pulmcomp post_pulmcomp
      puncturecomp
      sepsiscomp
      severecomp
      pre_severecomp2 severecomp2 post_severecomp2
      pre_severecomp3 severecomp3 post_severecomp3
      severecomp4
      surgicalcomp
      surgicalcomp2
      vtecomp
      woundcomp
         /missprint
      ;
   title1 "WHERE 2008 LE ADMYEAR LE 2011";
   title2 "FROM CABG20_025.SAS";
run;
title1;

