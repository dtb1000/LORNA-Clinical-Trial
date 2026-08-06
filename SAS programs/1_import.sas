/* Defining macro variables */
%let in=/home/u64484701/CT/CSV;
%let file=ae;									/* Change the file name as required */

/* Importing data from the CSV file */
proc import
	datafile="&in/&file..csv"
	dbms=csv
	out=raw.&file
	replace;
	guessingrows=max;
run;