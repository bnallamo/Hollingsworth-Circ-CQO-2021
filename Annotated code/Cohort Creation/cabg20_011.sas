/************************************************************
FILENAME: cabg20_011.sas (from first part of ddcap_002.sas)
AUTHOR: skaufman
DATE: 4/28/2017
ID: 25
SUMMARY: DO CLEANING OF IDS.
************************************************************/

data cabg20.nch07_14_coh_v2(drop=cnt_of:);
   set cabg20.nch07_14_coh end=last;


   /** CLEAN PRF_UPINS **/

   if prxmatch("/O/",prf_upin_org) then do;
      if cnt_of_oh_recodes_upin le 20 then do;
         put "** before " prf_upin_org=;
         prf_upin_org=translate(prf_upin_org,'0','O');
         put "** after " prf_upin_org=;
         put;
         cnt_of_oh_recodes_upin+1;
      end;
      else do;
         prf_upin_org=translate(prf_upin_org,'0','O');
         cnt_of_oh_recodes_upin+1;
      end;
   end;
   if last then put cnt_of_oh_recodes_upin=;

   if prf_upin_org ne ' ' then do;
      if not(prxmatch("/^[A-Z][0-9]{5}$/",prf_upin_org)) then do;
         if cnt_of_prf_upin_org_recodes le 20 then do;
            put "** before " prf_upin_org=;
            prf_upin_org=' ';
            put "** after " prf_upin_org=;
            put;
            cnt_of_prf_upin_org_recodes+1;
          end;
          else do;
             prf_upin_org=' ';
             cnt_of_prf_upin_org_recodes+1;
          end;
      end;
   end;
   if last then put cnt_of_prf_upin_org_recodes=;
 

   /** CLEAN RFR_UPINS **/

   if prxmatch("/O/",rfr_upin) then do;
      if cnt_of_oh_recodes_upin le 20 then do;
         put "** before " rfr_upin=;
         rfr_upin=translate(rfr_upin,'0','O');
         put "** after " rfr_upin=;
         put;
         cnt_of_oh_recodes_upin+1;
      end;
      else do;
         rfr_upin=translate(rfr_upin,'0','O');
         cnt_of_oh_recodes_upin+1;
      end;
   end;
   if last then put cnt_of_oh_recodes_upin=;

   if rfr_upin ne ' ' then do;
      if not(prxmatch("/^[A-Z][0-9]{5}$/",rfr_upin)) then do;
         if cnt_of_rfr_upin_recodes le 20 then do;
            put "** before " rfr_upin=;
            rfr_upin=' ';
            put "** after " rfr_upin=;
            put;
            cnt_of_rfr_upin_recodes+1;
          end;
          else do;
             rfr_upin=' ';
             cnt_of_rfr_upin_recodes+1;
          end;
      end;
   end;
   if last then put cnt_of_rfr_upin_recodes=;


   /** CLEAN PRFNPIS **/

  if prxmatch("/O/",prfnpi) then do;
      if cnt_of_oh_recodes_npi le 20 then do;
         put "** before " prfnpi=;
         prfnpi=translate(prfnpi,'0','O');
         put "** after " prfnpi=;
         put;
         cnt_of_oh_recodes_npi+1;
      end;
      else do;
         prfnpi=translate(prfnpi,'0','O');
         cnt_of_oh_recodes_npi+1;
      end;
   end;
   if last then put cnt_of_oh_recodes_npi=;

   if prxmatch("/L/",prfnpi) then do;
      if cnt_of_el_recodes_npi le 20 then do;
         put "** before " prfnpi=;
         prfnpi=translate(prfnpi,'1','L');
         put "** after " prfnpi=;
         put;
         cnt_of_el_recodes_npi+1;
      end;
      else do;
         prfnpi=translate(prfnpi,'1','L');
         cnt_of_el_recodes_npi+1;
      end;
   end;
   if last then put cnt_of_el_recodes_npi=;

   if prfnpi ne ' ' then do;
       if not(prxmatch('/^1[0-9]{9}$/',prfnpi)) then do;
          if cnt_of_npi_recodes le 20 then do;
             put "** before " prfnpi=;
             prfnpi=' ';
             put "** after " prfnpi=;
             put;
             cnt_of_npi_recodes+1;
           end;
           else do;
              prfnpi=' ';
              cnt_of_npi_recodes+1;
           end;
       end;
    end;
    if last then put cnt_of_npi_recodes=;


   /** CLEAN RFR_NPIS **/

  if prxmatch("/O/",rfr_npi) then do;
      if cnt_of_oh_recodes_rfr_npi le 20 then do;
         put "** before " rfr_npi=;
         rfr_npi=translate(rfr_npi,'0','O');
         put "** after " rfr_npi=;
         put;
         cnt_of_oh_recodes_rfr_npi+1;
      end;
      else do;
         rfr_npi=translate(rfr_npi,'0','O');
         cnt_of_oh_recodes_rfr_npi+1;
      end;
   end;
   if last then put cnt_of_oh_recodes_rfr_npi=;

   if prxmatch("/L/",rfr_npi) then do;
      if cnt_of_el_recodes_rfr_npi le 20 then do;
         put "** before " rfr_npi=;
         rfr_npi=translate(rfr_npi,'1','L');
         put "** after " rfr_npi=;
         put;
         cnt_of_el_recodes_rfr_npi+1;
      end;
      else do;
         rfr_npi=translate(rfr_npi,'1','L');
         cnt_of_el_recodes_rfr_npi+1;
      end;
   end;
   if last then put cnt_of_el_recodes_rfr_npi=;

   if rfr_npi ne ' ' then do;
       if not(prxmatch('/^1[0-9]{9}$/',rfr_npi)) then do;
          if cnt_of_rfr_npi_recodes le 20 then do;
             put "** before " rfr_npi=;
             rfr_npi=' ';
             put "** after " rfr_npi=;
             put;
             cnt_of_rfr_npi_recodes+1;
           end;
           else do;
              rfr_npi=' ';
              cnt_of_rfr_npi_recodes+1;
           end;
       end;
    end;
    if last then put cnt_of_rfr_npi_recodes=;

run;
