/* I used this file in conjunction with the CleaningUpData.sh bash file*/
/* This file harmonizes datasets from 2000 to 2012 */

global loc= "~/Downloads/ipeds"
cd $loc

* Merge enrollment and institutional datasets
* from IPEDS for each year 2000 through 2012

forv i = 0/1 {
	quietly do fa200`i'hd.do  // manually commented out improper syntax
	quietly do ef200`i'a.do
	clear
	use dct_ef200`i'a
	keep if line==1 // Full-time (==1) or Part-time (==15), first-time, first-year, degree-seeking undergraduates
	merge 1:1 unitid using dct_fa200`i'hd.dta
	drop if obereg==9
	keep unitid city stabbr deggrant/*instead of instcat*/ efrace01 efrace02 efrace09 efrace10
	collapse (sum) efrace01 efrace02 efrace09 efrace10, by(stabbr)
	rename efrace01 efnralm200`i'
	rename efrace02 efnralw200`i'
	rename efrace09 efhispm200`i'
	rename efrace10 efhispw200`i'
	save enrollment200`i', replace
	label drop _all
}

forv i = 2/3 {
	insheet using hd200`i'_data_stata.csv, comma clear
	save dct_hd200`i'

	insheet using ef200`i'a_data_stata.csv, comma clear
	save dct_ef200`i'a

	keep if efalevel==24  // All (==4) or Full-time (==24) students, Undergraduate, Degree/certificate-seeking, First-time
	merge 1:1 unitid using dct_hd200`i'.dta
	drop if obereg==9   // ("Outlying areas AS FM GU MH MP PR PW VI")
	
	keep unitid city stabbr deggrant /* instead of instcat */ efrace01 efrace02 efrace09 efrace10
	label variable unitid "unitid"
	label variable city "City location of institution"
	label variable stabbr "USPS state abbreviation"	
	label variable efrace01 "Nonresident alien men"
	label variable efrace02 "Nonresident alien women"
	label variable efrace09 "Hispanic men"
	label variable efrace10 "Hispanic women"

	rename efrace01 efnralm200`i'
	rename efrace02 efnralw200`i'
	rename efrace09 efhispm200`i'
	rename efrace10 efhispw200`i'
	
	collapse (sum) efnralm efnralw efhispm efhispw, by(stabbr)

	save enrollment200`i', replace
	label drop _all
}

forv i = 4/7 {
	insheet using hd200`i'_data_stata.csv, comma clear
	save dct_hd200`i'

	insheet using ef200`i'a_data_stata.csv, comma clear
	save dct_ef200`i'a

	keep if efalevel==24  // All (==4) or Full-time (==24) students, Undergraduate, Degree/certificate-seeking, First-time
	merge 1:1 unitid using dct_hd200`i'.dta
	drop if obereg==9   // ("Outlying areas AS FM GU MH MP PR PW VI")
	
	keep unitid city stabbr instcat efrace01 efrace02 efrace09 efrace10 //uses instcat instead of deggrant
	label variable unitid "unitid"
	label variable city "City location of institution"
	label variable stabbr "USPS state abbreviation"	
	label variable efrace01 "Nonresident alien men"
	label variable efrace02 "Nonresident alien women"
	label variable efrace09 "Hispanic men"
	label variable efrace10 "Hispanic women"
	
	rename efrace01 efnralm200`i'
	rename efrace02 efnralw200`i'
	rename efrace09 efhispm200`i'
	rename efrace10 efhispw200`i'
	
	collapse (sum) efnralm efnralw efhispm efhispw, by(stabbr)

	save enrollment200`i', replace
	label drop _all
}

forv i = 8/9 {
	insheet using hd200`i'_data_stata.csv, comma clear
	save dct_hd200`i'

	insheet using ef200`i'a_data_stata.csv, comma clear
	save dct_ef200`i'a

	keep if efalevel==24  // All (==4) or Full-time (==24) students, Undergraduate, Degree/certificate-seeking, First-time
	merge 1:1 unitid using dct_hd200`i'.dta
	drop if obereg==9   // ("Outlying areas AS FM GU MH MP PR PW VI")
	
	keep unitid city stabbr instcat efnralm efnralw efhispm efhispw //uses efnral rather than efrace
	label variable unitid "unitid"
	label variable city "City location of institution"
	label variable stabbr "USPS state abbreviation"	
	label variable efnralm "Nonresident alien men"
	label variable efnralw "Nonresident alien women"
	label variable efhispm "Hispanic men - new"
	label variable efhispw "Hispanic women - new"

	rename efnralm efnralm200`i'
	rename efnralw efnralw200`i'
	rename efhispm efhispm200`i'
	rename efhispw efhispw200`i'
	
	collapse (sum) efnralm efnralw efhispm efhispw, by(stabbr)

	save enrollment200`i', replace
	label drop _all
}

forv i = 10/12 {   // transition to double digit (2010s)
	quietly do hd20`i'.do
	quietly do ef20`i'a.do
	keep if efalevel==4
	merge 1:1 unitid using dct_hd20`i'.dta
	drop if obereg==9
	keep unitid city stabbr instcat efnralm efnralw efhispm efhispw
	collapse (sum) efnralm efnralw efhispm efhispw, by(stabbr)
	rename efnralm efnralm20`i'
	rename efnralw efnralw20`i'
	rename efhispm efhispm20`i'
	rename efhispw efhispw20`i'
	save enrollment20`i', replace
	label drop _all
}


use enrollment2000,clear

forv i = 1/9 {
	merge 1:1 stabbr using enrollment200`i'
	drop _merge
}

forv i = 10/12 {
	merge 1:1 stabbr using enrollment20`i'
	drop _merge
}

*drop efnralt*

save college_enrollment, replace
