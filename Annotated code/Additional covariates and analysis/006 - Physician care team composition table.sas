libname network "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data";
libname provspec "G:\Hollingsworth\Data\Medicare\References";
libname ref "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\References";

/************************************************************
FILE: 006 - Physician care team composition table
AUTHOR: Phyllis
DATE: 04 August 2020
SUMMARY: GENERATING PHYSICIAN CARE TEAM COMPOSITION TABLES
************************************************************/


/**** Generating physician care team composition tables ****/

proc freq data = network.Relations_careteamTable order = freq;
	tables hcfaspcl / out = primary_specs noprint;
run;


proc freq data = network.Relations_careteamTable order = freq;
	where tokeep;
	tables hcfaspcl / out = primary_specs_sens noprint;
run;


data primary_specs (keep = hcfaspcl spec_rank);
	set primary_specs (where = (not missing(hcfaspcl)) obs = 10);
	spec_rank = _N_;
run;	


data primary_specs_sens (keep = hcfaspcl spec_rank_sens);
	set primary_specs_sens (where = (not missing(hcfaspcl)) obs = 10);
	spec_rank_sens = _N_;
run;


%sortdata2(network.Relations_careteamTable, hcfaspcl);
%sortdata2(primary_specs, hcfaspcl);
%sortdata2(primary_specs_sens, hcfaspcl);

	
data Relations_careteamTable_cats;
	merge network.Relations_careteamTable (in = a)
		  primary_specs (in = b)
		  primary_specs_sens (in = c);

	by hcfaspcl;

	if b then provspec_primary = provspec;
	else provspec_primary = "Other";

	if c then provspec_sens = provspec;
	else provspec_sens = "Other";

	if a;

	if missing(spec_rank) then spec_rank = 11;
	if missing(spec_rank_sens) then spec_rank_sens = 11;

run;

%sortdata2(Relations_careteamTable_cats, idPt);


%macro patlevel(suff, wherest);

data relations_careTeam_patlevel&suff (drop = i);
	set Relations_careteamTable_cats &wherest;

	by idPt;

	array overall[1:11] overall_1 - overall_11;
	array pre90[1:11] pre90_1 - pre90_11;
	array index[1:11] idx_1 - idx_11;
	array post90[1:11] post90_1 - post90_11;

	retain overall_1 - overall_11 pre90_1 - pre90_11 idx_1 - idx_11 post90_1 - post90_11;

	if first.idPt then do;
		overall_size = 0;
		pre90_size = 0;
		idx_size = 0;
		post90_size = 0;

		do i = 1 to 11;
			overall[i] = 0;
			pre90[i] = 0;
			index[i] = 0;
			post90[i] = 0;
		end;

	end;

	overall_size + 1;
	pre90_size + v90dpre;
	idx_size + idx;
	post90_size + v90dpst;

	overall[spec_rank&suff] = overall[spec_rank&suff] + 1;
	pre90[spec_rank&suff] = pre90[spec_rank&suff] + v90dpre;
	index[spec_rank&suff] = index[spec_rank&suff] + idx;
	post90[spec_rank&suff] = post90[spec_rank&suff] + v90dpst;

	if last.idPt then do;

		do i = 1 to 11;

			if overall_size eq 0 then overall[i] = .;
			else overall[i] = round(overall[i]*100/overall_size, 1);

			if pre90_size eq 0 then pre90[i] = .;
			else pre90[i] = round(pre90[i]*100/pre90_size, 1);

			if idx_size eq 0 then index[i] = .;
			else index[i] = round(index[i]*100/idx_size, 1);

			if post90_size eq 0 then post90[i] = .;
			else post90[i] = round(post90[i]*100/post90_size, 1);

		end;

		output;
	end;

run;

%mend patlevel;

%patlevel(,);
%patlevel(_sens, (where = (tokeep)));



proc freq data = network.Relations_careteamTable order = freq;
	tables provspec;
run;


proc means data = relations_careTeam_patlevel  p50 p25 p75 maxdec = 0;
	var overall_size pre90_size idx_size post90_size overall_1 - overall_11  pre90_1 - pre90_11  idx_1 - idx_11  post90_1 - post90_11;
run;



proc freq data = network.Relations_careteamTable order = freq;
	where tokeep;
	tables provspec;
run;


proc means data = relations_careTeam_patlevel_sens p50 p25 p75 maxdec = 0;
	var overall_size pre90_size idx_size post90_size overall_1 - overall_11  pre90_1 - pre90_11  idx_1 - idx_11  post90_1 - post90_11;
run;













