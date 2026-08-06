/* Retrieving all mapped domains */
proc sql noprint;
	select memname
	into :datasets separated by ' '
	from dictionary.tables
	where libname='FINAL' and memtype='DATA'
	order by memname;
quit;

/* Using the %loc2xpt macro to export mapped domains as XPT files */
%macro export_all_xpt;
	%local i ds dsfile;

	%do i=1 %to %sysfunc(countw(&datasets));
		%let ds=%scan(&datasets, &i);
		%let dsfile=%sysfunc(lowcase(&ds));
		filename outfile "/home/u64484701/CT/XPT/&dsfile..xpt";
		%put NOTE: Exporting &ds...;
		%loc2xpt(libref=final, memlist=&ds, filespec=outfile, format=V9);
		filename outfile clear;
	%end;
%mend;

%export_all_xpt;