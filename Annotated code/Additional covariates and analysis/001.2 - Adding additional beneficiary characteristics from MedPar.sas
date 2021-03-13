libname network "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data";
libname origmed "G:\Hollingsworth\Data\Medicare";

/************************************************************
FILE: 001.2 - Adding additional beneficiary characteristics from MedPar
AUTHOR: Phyllis
DATE: 25 February 2020
SUMMARY: MERGE IN SOURCE OF ADMISSIONS AND DRG VARIABLE
************************************************************/


data adms_drg;
	set origmed.medp_0716 (keep = bene_id sadmsndt sdschrgdt prvnumgrp type_adm drg_cd);
run; 

%sortdata2(adms_drg, bene_id sadmsndt sdschrgdt prvnumgrp);
%sortdata2(network.cabg08_14_v23_ses, bene_id sadmsndt sdschrgdt prvnumgrp);

data network.cabg08_14_v24;
	merge network.cabg08_14_v23_ses (in = a)
		  adms_drg (in = b);

	by bene_id sadmsndt sdschrgdt prvnumgrp;

	if a;
run;


%sortdata2(network.cabg08_14_v24, drg_cd);
%sortdata2(network.DRGdesc16_mod, drg_cd);

data network.cabg08_14_v24;
	merge network.cabg08_14_v24 (in = a)
		  network.DRGdesc16_mod (in = b keep = drg_cd drg_desc);

	by drg_cd;

	if a;
run; 



data network.cabg08_14_v24;
	set network.cabg08_14_v24;

	length elective_proc wPTCA_wMCC wPCTA_woMCC wcardcath_wMCC wcardcath_woMCC wocardcath_wMCC wocardcath_woMCC DRG_cat 3;

	if type_adm = '3' then elective_proc = 1;
	else if type_adm NE '3' then elective_proc = 0;

	wPTCA_wMCC = drg_cd eq 231;
	wPCTA_woMCC = drg_cd eq 232;
	wcardcath_wMCC = drg_cd eq 233;
	wcardcath_woMCC = drg_cd eq 234;
	wocardcath_wMCC  = drg_cd eq 235;
	wocardcath_woMCC = drg_cd eq 236;

	if drg_cd eq 231 then DRG_cat = 1;
	else if drg_cd eq 232 then DRG_cat = 2;
	else if drg_cd eq 233 then DRG_cat = 3;
	else if drg_cd eq 234 then DRG_cat = 4;
	else if drg_cd eq 235 then DRG_cat = 5;
	else if drg_cd eq 236 then DRG_cat = 6;	
	else DRG_cat = 7;

run;


proc freq data = network.cabg08_14_v24 order = freq;
	tables type_adm elective_proc drg_desc*(wPTCA_wMCC wPCTA_woMCC wcardcath_wMCC wcardcath_woMCC wocardcath_wMCC wocardcath_woMCC DRG_cat) / norow nocol nopercent;
run;


