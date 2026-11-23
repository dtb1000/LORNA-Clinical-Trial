/* Defining macro variables */
%let in=/home/u64484701/CT/Input;
%let file=adverse;									/* Change the file name as required */

/* Importing data from the CSV file */
proc import
	datafile="&in/&file..csv"
	dbms=csv
	out=raw.&file
	replace;
	guessingrows=max;
run;