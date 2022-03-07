clear
graph drop _all
clear
set more off

****GENERATE DATA*****
****IPUMS ASEC EXTRACT USING THE VARIABLES LISTED BELOW, FOR 2000-2020

/* this dataset is ASEC supplement to the CPS, data downloaded from IPUMS https://usa.ipums.org/usa/.
// The following variables were downloaded:
// 
// Contains data from G:/mcr/scratch-m1cls01/data/cps/IPUMS/ASEC/cps_00137.dta
//   obs:     3,092,993                          
//  vars:             8                          09 MAR 2021 20:54
// ---------------------------------------------------------------------------------------
//               storage   display    value
// variable name   type    format     label      variable label
// ---------------------------------------------------------------------------------------
// year            int     %8.0g                 survey year
// gq              byte    %8.0g      GQ         group quarters status
// asecwt          double  %12.0g                annual social and economic supplement
//                                                 weight
// age             byte    %8.0g      AGE        age
// whymove         byte    %8.0g      WHYMOVE    reason for moving
// migrate1        byte    %8.0g      MIGRATE1   migration status, 1 year
// qmigrat1        byte    %8.0g      QMIGRAT1   data quality flag for migrate1
// qwhymove        byte    %8.0g      QWHYMOVE   data quality flag for whymove
// ---------------------------------------------------------------------------------------


*/

use gq qwhymove year asecwt qmigrat1 qwhymove age whymove migrate1 using cps_00137 if age>=16, clear

drop if gq==2
keep if qwhymove==0
keep if year>=2000
keep if asecwt>0

gen imputea=(qmigrat1!=0 & qmigrat1!=.) 
gen imputeb=(qwhymove!=0 & qwhymove!=.)
gen impute=imputea==1 | imputeb==1 
keep if impute==0

gen jobmove=((whymove>=4 & whymove<=6) | whymove==8)
gen retiremove=(whymove==7)
gen familymove=(whymove>=1 & whymove<=3)
gen housemove=(whymove>=9 & whymove<=13)
gen collegemove=(whymove==14)
gen othermove=(whymove>=15 & whymove<=20)

gen withincounty=(migrate1==3)   
gen withinstate=(migrate1==4)   
gen xstate=(migrate1==5)  
gen longmove=migrate1==4 | migrate1==5
gen move=(migrate1==3 | migrate1==4 | migrate1==5)  

foreach m of varlist withincounty-move {
foreach r of varlist jobmove-othermove {
gen `m'_`r'=(`r'==1 & `m'==1)
}
}

sort year
collapse (mean) withincounty_jobmove-move_othermove withincounty withinstate xstate longmove move [aw=asecwt], by(year) fast

save figure3-reasonmove-data.dta, replace


***PLOTTING DATA FOR FIG 3 IN JIA, MOLLOY, SMITH, WOZNIAK JEL 2022

use figure3-reasonmove-data.dta, clear

replace year=year-1
foreach v of varlist xstate_jobmove-xstate_othermove longmove_jobmove-longmove_othermove withincounty_jobmove-withincounty_othermove withinstate_jobmove-withinstate_othermove  {
replace `v'=`v'*100
}

gen c2=1.25 if (year==2001 | year==2002)
gen c3=1.25 if (year==2007 | year==2008 | year==2009)

replace xstate_housemove=. if year>=2011 & year<=2014
replace xstate_retire=. if year>=2011 & year<=2014
replace xstate_college=. if year>=2011 & year<=2014
replace xstate_other=. if year>=2011 & year<=2014

# delimit ;
	
twoway 
    (area c2 year, bcolor(gs13)) 
    (area c3 year, bcolor(gs13)) 
	(connected xstate_jobmove year , msymbol(square) mcolor(black) msize(small) lcolor(black) lwidth(medium) lpattern(solid))
	(connected xstate_familymove year , msymbol(square) mcolor(navy) msize(small) lcolor(navy) lwidth(medium) lpattern(solid))
	(connected xstate_housemove year if year<=2010, msymbol(square) mcolor(maroon) msize(small) lcolor(maroon) lwidth(medium) lpattern(solid))
	(connected xstate_retire year  if year<=2010, msymbol(square) mcolor(dkorange) msize(small) lcolor(dkorange) lwidth(medium) lpattern(solid))
	(connected xstate_college year  if year<=2010, msymbol(square) mcolor(forest_green) msize(small) lcolor(forest_green) lwidth(medium) lpattern(solid))
	(connected xstate_othermove year  if year<=2010, msymbol(square) mcolor(cranberry) msize(small) lcolor(cranberry) lwidth(medium) lpattern(solid))
	(connected xstate_housemove year if year>=2015, msymbol(square) mcolor(maroon) msize(small) lcolor(maroon) lwidth(medium) lpattern(solid))
	(connected xstate_retire year  if year>=2015, msymbol(square) mcolor(dkorange) msize(small) lcolor(dkorange) lwidth(medium) lpattern(solid))
	(connected xstate_college year  if year>=2015, msymbol(square) mcolor(forest_green) msize(small) lcolor(forest_green) lwidth(medium) lpattern(solid))
	(connected xstate_othermove year  if year>=2015, msymbol(square) mcolor(cranberry) msize(small) lcolor(cranberry) lwidth(medium) lpattern(solid))
,
	subtitle(,bcolor(white) size(small))
	ytitle("",  size(small) margin(small)) 
	ylabel(0(.25)1.25, labsize(small) nogrid angle(horizontal) ) 
	xtitle("", size(small)) 
	xlabel(2000(2)2018, labels labsize(vsmall) ticks) 
	xmtick(2000(1)2019, nolabels) 
	legend(order(3 "Job-related" 4 "Family-related" 5 "Housing-related" 6 "Retired" 7 "College" 8 "Other") rows(2) size(vsmall) region(style(none)))
	title("", size(small))
	graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) 
	plotregion(fcolor(white) lcolor(black) ifcolor(white) ilcolor(white) margin(small))
	ysize(4.00)
	xsize(6.2)
	name("xstate_reason", replace)
	saving("figure3-reasonmove.gph", replace)
	;

graph export "figure3-reasonmove.pdf", 
	as(pdf) 
	orientation(landscape) 
	logo(off) 
	replace;

graph export "figure3-reasonmove.eps", 
	as(eps) 
	orientation(landscape) 
	logo(off) 
	replace;
	