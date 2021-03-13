/************************************************************
FILENAME: cabg20_009.sas
AUTHOR: skaufman
DATE: 4/27/2017
ID: 54
SUMMARY: TO RULEOUT
************************************************************/

options symbolgen mprint;

%include 'F:\Documents\SKAUFMAN\Charlson - Klabunde\remove.ruleout.dxcodes.macro.sas';

%sortdata2(cabg20.to_ruleout07_14,bene_id clmdte)

%ruleout(cabg20.to_ruleout07_14,bene_id,clmdte,idxdate-365,idxdate-1,LINEDGNS DGNS_CD1-DGNS_CD25,26,HCPCS_CD,filetype);
data cabg20.to_ruleout07_14_out;
   set clmrecs;
   indxpri="P";
run;
