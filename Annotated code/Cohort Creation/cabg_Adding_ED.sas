libname srk "Z:\skaufman\for Hollingsworth\CABG20";
libname dennie "G:\Hollingsworth\ACOs\Dennie Physician Network\Data";
libname origmed "G:\Hollingsworth\ACOs\Data\Medicare";



data cabg08_14_finder;
	set srk.cabg08_14_v22 (keep = bene_id uniq_id sadmsndt sdschrgdt);
run;

%sortdata2(cabg08_14_finder, bene_id sadmsndt sdschrgdt);
%sortdata2(origmed.medp_0714, bene_id sadmsndt sdschrgdt);


data dennie.cabg08_14_admittype (drop = ER_AMT);
	merge cabg08_14_finder (in = a)
		  origmed.medp_0714 (in = b keep = bene_id sadmsndt sdschrgdt ER_AMT);
	by bene_id sadmsndt sdschrgdt;

	if a and b;

	length EDadmit 3;

	EDadmit = 0;

	if ER_AMT gt 0 then EDadmit = 1;
	format sdschrgdt mmddyy10.;
run;

proc freq data = dennie.cabg08_14_admittype;
	tables EDadmit;
run;

