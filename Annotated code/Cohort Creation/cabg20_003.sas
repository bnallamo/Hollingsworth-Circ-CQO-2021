/************************************************************
FILENAME: cabg20_003.sas (from tdiff_006.sas)
AUTHOR: skaufman
DATE: 4/14/2017
ID: 54 CABG20PCT
SUMMARY: CREATE A QUASI-REGISTRY FILE IN THE SAME FORM AS
SEER TO BE ABLE TO USE SEER PROGRAM LOGIC.
************************************************************/

*Starting month/year: 1/1/2007;

%sortdata2(cabg20.protocohort1,bene_id)

data cabg20.entitlehmo07_14(keep=bene_id ent1-ent96 hmostatus1-hmostatus96
      yr2007-yr2014 sdob sdod state county sex race zipcode
      rename=(hmostatus1-hmostatus96=hmo1-hmo96));
   retain ent1-ent96 hmostatus1-hmostatus96 yr2007-yr2014;
   set cabg20.protocohort1(keep=bene_id sdob sdod state county sex race
      zipcode denom_year entitl1-entitl12 hmo1-hmo12);
   by bene_id;

   array entitl[12] $ entitl1-entitl12;
   array hmo[12] $ hmo1-hmo12;

   /********
   2007: ent1-ent12;
   2008: ent13-ent24;
   2009: ent25-ent36;
   2010: ent37-ent48;
   2011: ent49-ent60;
   2012: ent61-ent72;
   2013: ent73-ent84;
   2014: ent85-ent96;
   ********/

   array yr[*] $ 1 yr2007-yr2014;
   array ent[*] $ 1 ent1-ent96;
   array hmostatus[*] $ 1 hmostatus1-hmostatus96;

   if first.bene_id then do;
      do i=1 to hbound(ent);
         ent[i]=' ';
         hmostatus[i]= ' ';
      end;
      do i=1 to hbound(yr);
         yr[i]='0';
      end;
   end;

   if denom_year eq 2007 then do;
      do j=1 to 12;
         ent[j]=entitl[j];
         hmostatus[j]=hmo[j];
      end;
      yr2007='1';
   end;

   else if denom_year eq 2008 then do;
      do j=1 to 12;
         ent[j+12]=entitl[j];
         hmostatus[j+12]=hmo[j];
      end;
      yr2008='1';
   end;

   else if denom_year eq 2009 then do;
      do j=1 to 12;
         ent[j+24]=entitl[j];
         hmostatus[j+24]=hmo[j];
      end;
      yr2009='1';
   end;

   else if denom_year eq 2010 then do;
      do j=1 to 12;
         ent[j+36]=entitl[j];
         hmostatus[j+36]=hmo[j];
      end;
      yr2010='1';
   end;

   else if denom_year eq 2011 then do;
      do j=1 to 12;
         ent[j+48]=entitl[j];
         hmostatus[j+48]=hmo[j];
      end;
      yr2011='1';
   end;

   else if denom_year eq 2012 then do;
      do j=1 to 12;
         ent[j+60]=entitl[j];
         hmostatus[j+60]=hmo[j];
      end;
      yr2012='1';
   end;

   else if denom_year eq 2013 then do;
      do j=1 to 12;
         ent[j+72]=entitl[j];
         hmostatus[j+72]=hmo[j];
      end;
      yr2013='1';
   end;

   else if denom_year eq 2014 then do;
      do j=1 to 12;
         ent[j+84]=entitl[j];
         hmostatus[j+84]=hmo[j];
      end;
      yr2014='1';
   end;

   if last.bene_id;

run;


data cabg20.entitlehmo07_14;
   retain bene_id sdob yr2007-yr2014 ent1-ent96 hmo1-hmo96;
   set cabg20.entitlehmo07_14;
run;


/**** RANDOM SAMPLE FOR REVIEW ****/

proc surveyselect data=cabg20.entitlehmo07_14 out=cabg20.entitlehmo07_14_rs
         method=srs n=100 seed=240;
run;
quit;
