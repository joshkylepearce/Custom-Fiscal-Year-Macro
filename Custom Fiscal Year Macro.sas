/************************************************************************************
***** Program: 	Custom Fiscal Year Macro	*****
***** Author:	joshkylepearce       		*****
************************************************************************************/

/************************************************************************************
Custom Fiscal Year Macro

Purpose:
Define the start & end of the fiscal year based on user-inputted parameters.
Fiscal year varies in jurisdictions across the world. 
This macro enables users to enter input parameters to match their jurisdiction.

For an overview of worldwide fiscal years, refer to the following URL:
https://www.britannica.com/money/fiscal-year

Input Parameters:
1.	fiscal_year	- fiscal year of interest.
2.	start_day	- Day of the month at the beginning of the fiscal year.
3.	start_month	- Month at the beginning of the fiscal year.
4.	end_day		- Day of the month at the end of the fiscal year.
5.	end_month	- Month at the end of the fiscal year.

Output Parameters:
1. 	start_date	- Start date of the fiscal year in date9. format.
2.	end_date	- End date of the fiscal year in date9. format.

Macro Usage:
1. 	Run the custom_ficsal_year macro code.
2. 	Call the custom_ficsal_year macro and enter the input parameters.
	e.g. for U.S. in fiscal year 2024:
	%custom_ficsal_year(
	fiscal_year	= 2024,
	start_day	= 1,
	start_month	= 10,
	end_day		= 30,
	end_month	= 9
	);
3.	Calling the macro creates two macro variables: start_date & end_date.
	These macros can be used as filters for querying within the fiscal year.

Notes:
-	Ensure that all input parameters are entered in numeric values (e.g. June=6).
-	Input parameters can be entered with/without quotations. 
	This is handled within the macro so that both options are applicable.
************************************************************************************/

%macro custom_fiscal_year(fiscal_year,start_day,start_month,end_day,end_month);

/*macro variables available during the execution of entire SAS session*/
%global start_date end_date;

/*
Input parameters are only compatible with macro if not in quotes.
Account for single & double quotations.
*/
/*Remove double quotes*/
%let fiscal_year = %sysfunc(compress(&fiscal_year., '"'));
%let start_day = %sysfunc(compress(&start_day., '"'));
%let start_month = %sysfunc(compress(&start_month., '"'));
%let end_day = %sysfunc(compress(&end_day., '"'));
%let end_month = %sysfunc(compress(&end_month., '"'));
/*Remove single quotes*/
%let fiscal_year = %sysfunc(compress(&fiscal_year., "'"));
%let start_day = %sysfunc(compress(&start_day., "'"));
%let start_month = %sysfunc(compress(&start_month., "'"));
%let end_day = %sysfunc(compress(&end_day., "'"));
%let end_month = %sysfunc(compress(&end_month., "'"));

/*Define current & previous year*/
%let year_b = %sysevalf(&fiscal_year.-1);
%let year_e = &fiscal_year.;

/*Add leading zero to days of month for days 1-10*/
%let start_day = %sysfunc(putn(&start_day.,z2.));
%let end_day = %sysfunc(putn(&end_day.,z2.));

/*Define start & end of fiscal year in DDMMMYYY format*/
data _null_;
	call symput('start_date',"'"||put((mdy(&start_month.,&start_day.,&year_b.)),date9.)||"'d");
	call symput('end_date',"'"||put((mdy(&end_month.,&end_day.,&year_e.)),date9.)||"'d");
run;
/*Write the start & end dates to the SAS log*/
%put &start_date. &end_date.;

%mend;

/************************************************************************************
Examples: Data Setup
************************************************************************************/

/*Fictious dataset representing the fluctuation of total customers per month*/
%macro monthly_increment(iterations);
data number_of_customers;
%do i = 0 %to &iterations.;
	month=intnx('month',"31DEC2024"d,-&i.,'s');
	number_of_customers=rand("integer",10000,10500);
	output;
%end;
format month date9.;
run;
%mend;
%monthly_increment(36);

/************************************************************************************
Example 1: Macro Usage (U.S. 2023 fiscal year)
************************************************************************************/

/*Call macro to define the start & end of U.S. 2023 fiscal year*/
%custom_fiscal_year(
fiscal_year=2023,
start_day=1,
start_month=10,
end_day=30,
end_month=9
);

/*Filter on output parameters to extract U.S. 2023 fiscal year*/
data number_of_customers_2023;
	set number_of_customers;
	where month between &start_date. and &end_date.;
run;

/************************************************************************************
Example 2: Macro Usage (New Zealand 2024 fiscal year)
************************************************************************************/

/*Call macro to define the start & end of NZ 2024 fiscal year*/
%custom_fiscal_year(
fiscal_year=2024,
start_day=1,
start_month=4,
end_day=31,
end_month=3
);

/*Filter on output parameters to extract as at end of NZ 2024 fiscal year*/
proc sql; 
select 
	number_of_customers as number_of_customers_2024 
from 
	number_of_customers
where
	month = &end_date.
;
quit;
