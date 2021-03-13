/************************************************************
FILENAME: cabg20_024.sas (from cabgf2_028.sas)
AUTHOR: skaufman
DATE: 5/10/2017
ID: 54
SUMMARY: COMPLICATIONS CODING. NO LAPCOMP. DOES NOT DO COMPLICATIONS
THAT ARE BUILD FROM OTHERS.  THESE ARE BUILT WHEN PRE INFO CAN BE
TAKEN INTO ACCOUNT TO CORRECT INDEX COMPLICATIONS.
************************************************************/

data cabg20.cabg08_14_v17 (drop=i);
   set cabg20.cabg08_14_v16(rename=(psi05=fbcomp 
         psi06=ptxcomp psi12=vtecomp psi15=puncturecomp));

   array char[*] _character_;
   do i=1 to dim(char);
      char[i]=strip(char[i]);
   end;

   array diag[*] DGNS_CD1-DGNS_CD25;
   array surg[*] PRCDR_CD1-PRCDR_CD25;



/** FOREIGN BODY **/

   label fbcomp='psi 5: FOREIGN BODY';



/** IATROGENIC PTX **/

   label ptxcomp='psi 6: IATROGENIC PTX';



/** VTE **/

   label vtecomp='psi 12: DVT/PE';



/** ACCIDENTAL PUNCTURE OR LACERATION **/

   label puncturecomp='psi 15: ACCIDENTAL PUNCTURE OR LACERATION';



/** OTHER INFECTION **/

   infectioncomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '99739' '99731' '683' '5909' '5903' '5902' '5679' '56782' '56781'
            '5671' '5670' '567' '5192' '486' '485' '481' '00845'
            ) or
            substr(diag[i],1,4) in(
            '5901' '5673' '5672' '5908'
            ) or 
            substr(diag[i],1,3) in(
            '513' '510' '507' '484' '483' '482' '320'
            ) then infectioncomp=1;
   end;
   label infectioncomp='infectioncomp: PNEUM,POST-OP,CDIFF,PYELO,PERIT,MISC (CSP)';



/** POSTOPERATIVE HEMORRHAGE **/

   bleedcomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '9981' '99811' '99812' '2851'
            ) then bleedcomp=1;
   end;
   do i=1 to hbound(surg);
      if surg[i] in(
            '3998' '5412' '3941' '3949' '3443'
            ) then bleedcomp=1;
   end;
   label bleedcomp='bleedcomp: POSTOPERATIVE HEMORRHAGE';



/** POSTOPERATIVE HEMORRHAGE (recode) **/

   bleedcomp2=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '9981' '99811' '99812'
            ) then bleedcomp2=1;
   end;
   do i=1 to hbound(surg);
      if surg[i] in(
            '3998' '5412' '3941' '3949' '3443'
            ) then bleedcomp2=1;
   end;
   label bleedcomp2='bleedcomp2: POSTOPERATIVE HEMORRHAGE';



/** ACUTE RENAL FAILURE **/

   arfwodcomp=0;
   do i=1 to hbound(diag);
      if diag[i] in('9975'
            ) or
            substr(diag[i],1,3) in('584'
            ) then arfwodcomp=1;
   end;
   label arfwodcomp='arfwodcomp: ACUTE RENAL FAILURE';



/** ACUTE RENAL FAILURE REQUIRING DIALYSIS **/

   arfdcomp=0;
   do i=1 to hbound(diag);
      if diag[i] in('v560' 'v561'
            ) or
            substr(diag[i],1,3) in(
            '584' 'v451'
            ) then arfdcomp=1;
   end;
   do i=1 to hbound(surg);
      if surg[i] in(
            '3995'
            ) then arfdcomp=1;
   end;
   label arfdcomp='arfdcomp: ACUTE RENAL FAILURE REQUIRING DIALYSIS';



/** CHRONIC DIALYSIS **/

   esrdexclude=0;
   do i=1 to hbound(diag);
      if (substr(diag[i],1,3) eq '584') then d584=1;
   end;
   do i=1 to hbound(diag);
      if diag[i] in(
            'V451' 'V560' 'V561' 'V562' 'V563' 'V568' /*last two just added by ray*/
            ) then esrdexclude=1;
   end;
   do i=1 to hbound(surg);
      if surg[i] in(
            '3995' '5498'
            ) then esrdexclude=1;
   end;
   if d584 then esrdexclude=0;
   label esrdexclude='esrdexclude: CHRONIC DIALYSIS';
   drop d584;



/** ACUTE RENAL FAILURE EXCLUDING CHRONIC DIALYSIS **/

   if arfwodcomp eq 1 and esrdexclude eq 0 then arfcompNOcd=1;
   else if arfwodcomp eq 0 and esrdexclude eq 0 then arfcompNOcd=0;
   label arfcompNOcd='arfcompNOcd:ACUTE RENAL FAILURE EXCLUDING CHRONIC DIALYSIS';



/** CARDIAC COMPLICATIONS **/

   cardcomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '9971' '4275' '78551'
            ) or
            substr(diag[i],1,3) in(
            '410'
            ) then cardcomp=1;
   end;
   label cardcomp='cardcomp:CARDIAC COMPLICATIONS';



/** RESPIRATORY FAILURE **/

   pulmcomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '51881' '5184' '5185' '5187' '51884' '51882' '7991'
            ) or
            substr(diag[i],1,4) in(
            '9973' 
            ) then pulmcomp=1;
   end;
   label pulmcomp='pulmcomp:RESPIRATORY FAILURE';



/** GI COMPLICATIONS **/

   gicomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '53082' '5789' '9974'
            ) or
            substr(diag[i],1,4) in(
            '5310' '5311' '5312' '5314' '5316' '5320' '5321'
            '5322' '5324' '5326' '5330' '5331' '5332' '5334' '5336'
            '5340' '5341' '5342' '5344' '5346'
            ) or 
            substr(diag[i],1,3) in(
            '560'
            ) or
            substr(diag[i],1,3) eq '535' and substr(diag[i],5,1) eq '1' /* for 535.x1 */
            then gicomp=1;
   end;
   label gicomp='gicomp:GI COMPLICATIONS';



/** GU COMPLICATIONS **/

   gucomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470'
            'V446' 'V556' '591' '86814' '86804' '59382' '5991'
            '6190' '9986' '7888' '56789'
            ) or
            substr(diag[i],1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(diag[i],1,3) in(
            '866' '867'
            ) then gucomp=1;
   end;
   do i=1 to hbound(surg);
      if surg[i] in(
            '5502' '5503' '5512' '5521' '5522' '5529' '5592' '5593' '5594' '8773'
            '8774' '8875' '8845' '9761' '9762' '560' '5631' '5639' '598' '5674'
            '5675' '5679' '570' '5793' '5732' '5992' '5993' '3979' '3953'
            ) or 
            substr(diag[i],1,3) in(
            '558' '568' '566' '590' '592'
            ) then gucomp=1;
   end;
   label gucomp='gucomp:GU COMPLICATIONS';



/** GU COMPLICATIONS (RECODE) **/

   /* Ureteral injury, Renovascular, Obstruction, PNT, Fistula, Leak minus
   routine cysto */

   gucomp2=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470' 'V446' 'V556' '591'
            '86814' '86804' '59382' '5991' '6190' '9986' '7888' '56789'
            ) or
            substr(diag[i],1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(diag[i],1,3) in(
            '866' '867'
            ) then gucomp2=1;
   end;
   do i=1 to hbound(surg);
      if surg[i] in(
            '5502' '5503' '5512' '5521' '5522' '5529' '5592' '5593' '5594' '8773'
            '8774' '8875' '8845' '9761' '9762' '560' '5631' '5639' '598' '5992'
            '5993' '3979' '3953' '5674' '5675' '5679' '570' '5793'
            ) or 
            substr(diag[i],1,3) in(
            '568' '566' '590' '592' '558'
            ) then gucomp2=1;
   end;
   label gucomp2='gucomp2:GU COMPLICATIONS (RECODE, NO CYSTO)';



/** GU COMPLICATIONS (ANOTHER RECODE) **/

   /* Ureteral injury, Renovascular, Obstruction, PNT, Fistula, Leak minus
   routine cysto, RUS, and IVP */

   gucomp3=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '5933' '5934' '5935' '4421' '99772' '44581' '4470' 'V446' 'V556' '591'
            '86814' '86804' '59382' '5991' '6190' '9986' '7888' '56789'
            ) or
            substr(diag[i],1,4) in(
            '5938' '9024' '5996'
            ) or 
            substr(diag[i],1,3) in(
            '867' '866'
            ) then gucomp3=1;
   end;
   do i=1 to hbound(surg);
      if surg[i] in(
            '5502' '5503' '5512' '5521' '5522' '5529' '598' '5992' '5993' '3979'
            '3953' '5592' '5593' '5594' '8774' '8845' '9761' '9762' '560' '5631'
            '5639' '5674' '5675' '5679' '570' '5793'
            ) or 
            substr(diag[i],1,3) in(
            '558' '568' '590' '592' '566'
            ) then gucomp3=1;
   end;
   label gucomp3='gucomp3:GU COMPLICATIONS (RECODE, NO CYSTO, RUS, IVP)';



/** NEURO COMP/CEREBRAL INFARCTION **/

   neurocomp=0;
   do i=1 to hbound(diag);
      if substr(diag[i],1,4) in(
            '9970'
            ) or 
            substr(diag[i],1,3) in(
            '433' '434'
            ) then neurocomp=1;
   end;
   label neurocomp='neurocomp:CEREBRAL INFARCTION';



/** POSTOPERATIVE SEPSIS **/

   sepsiscomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '78552' '78550' '78559' '9980' '99591' '99592' '99662' '9993' '99931'
            '7907'
            ) or 
            substr(diag[i],1,3) in(
            '038'
            ) then sepsiscomp=1;
   end;
   label sepsiscomp='sepsiscomp:POSTOPERATIVE SEPSIS';



/** WOUND COMP **/

   woundcomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '9583' '99813' '99883'
            ) or
            substr(diag[i],1,4) in(
            '9983' '9985'
            ) then woundcomp=1;
   end;
   label woundcomp='woundcomp:WOUND COMP - SSI, Seroma, Dehiscence';



/** MISC COMP **/

   misccomp=0;
   do i=1 to hbound(diag);
      if diag[i] in(
            '9972' '9979' '99889' '9989' '9992' '9994' '9995' '9996' '9997' '9999'
            'E911' 'E912' '5187'
            ) or
            substr(diag[i],1,4) in(
            '9998' 'E876' 'E878' 'E879'
            ) then misccomp=1;
   end;
   label misccomp='misccomp:MISC COMP';


run;



proc freq data=cabg20.cabg08_14_v17;
   tables fbcomp ptxcomp vtecomp puncturecomp infectioncomp bleedcomp
      bleedcomp2 arfwodcomp arfdcomp Esrdexclude arfcompNOcd cardcomp
      pulmcomp gicomp gucomp gucomp2 gucomp3 neurocomp sepsiscomp woundcomp
      misccomp / missprint;
   title1 "ALL YEARS";
run;

proc freq data=cabg20.cabg08_14_v17;
   where 2008 le admyear le 2011;
   tables fbcomp ptxcomp vtecomp puncturecomp infectioncomp bleedcomp
      bleedcomp2 arfwodcomp arfdcomp Esrdexclude arfcompNOcd cardcomp
      pulmcomp gicomp gucomp gucomp2 gucomp3 neurocomp sepsiscomp woundcomp
      misccomp / missprint;
   title1 "WHERE 2008 LE ADMYEAR LE 2011";
run;

