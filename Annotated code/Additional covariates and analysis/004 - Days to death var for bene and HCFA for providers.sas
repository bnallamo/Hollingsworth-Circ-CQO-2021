libname network "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\Data";
libname provspec "G:\Hollingsworth\Data\Medicare\References";
libname ref "G:\Hollingsworth\Network Analysis\Xianshi and Hyesun\References";

/************************************************************
FILE: 004 - Days to death var for bene and HCFA for providers
AUTHOR: Phyllis
DATE: 15 May 2020
SUMMARY: ADDING VARIABLES FOR SENSITIVITY ANALYSES
************************************************************/


/*** Obtaining distribution of physician specialties ***/


data phys_spec;
	set network.cabg08_14_v24 (keep = best_hcfaspcl_all prfnpi_all);
	numphys = countw(best_hcfaspcl_all);
	numphys_npi = countw(prfnpi_all);
	length npi $ 10 HCFASPCL $ 2 missing_HCFASPCL 3;

	do i = 1 to numphys_npi;
		if numphys ne numphys_npi then missing_HCFASPCL = 1;
		else missing_HCFASPCL = 0;
		HCFASPCL = scan(best_hcfaspcl_all, i, " ");
		npi = scan(prfnpi_all, i, " ");
		if missing_HCFASPCL then HCFASPCL = "";
		output;
	end;
	drop numphys numphys_npi i;
run;

proc sort data = phys_spec nodupkey;
	by npi descending HCFASPCL;
run;

proc sort data = phys_spec nodupkey;
	by npi;
run;

proc freq data = phys_spec;
	tables missing_HCFASPCL;
run;

%sortdata2(phys_spec, HCFASPCL);
%sortdata2(ref.phys_spec_todrop, HCFASPCL);

data network.physicians_specialty (drop = todrop best_hcfaspcl_all prfnpi_all);
	merge phys_spec (in = a) 
		  ref.phys_spec_todrop;
	length tokeep 3;

	by HCFASPCL;

	if missing(todrop) or ^todrop then tokeep = 1;
	else tokeep = 0;

run;

proc freq data = network.physicians_specialty;
	tables tokeep;
run;

proc freq data = network.physicians_specialty;
	where missing_HCFASPCL;
	tables tokeep;
run;

%sortdata2(network.physicians_specialty, NPI);


/**** Days until death var ***/
data network.days_pat_survived (keep = bene_id days_until_death_CABG);
	set network.cabg08_14_v24;
	days_until_death_CABG = sdod - cabg_dt;
run;

proc freq data = network.days_pat_survived;
	tables  days_until_death_CABG;
run;

	
/*** Reconcile with Xianshi's physician list ***/
%sortdata2(ref.npi_of_considered_hospitals, x);


proc sort data = ref.npi_of_considered_hospitals nodupkey;
	by x;
run;

proc contents data = ref.npi_of_considered_hospitals;
run;

proc contents data = network.physicians_specialty;
run;


data npi_of_considered_hospitals;
	set ref.npi_of_considered_hospitals;
	npi = put(x, z10.);
run;

proc sort data = npi_of_considered_hospitals nodupkey;
	by npi;
run;

data network.physicians_specialty_updated (drop = x);
	merge npi_of_considered_hospitals (in = a)
		  network.physicians_specialty (in = b);

	by npi;

	if a;

	if missing(HCFASPCL) then tokeep = 1;
run;

proc freq data = network.physicians_specialty_updated;
	tables tokeep;
run;

