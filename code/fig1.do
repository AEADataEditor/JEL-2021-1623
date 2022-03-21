set more off

log using makeJELfigure.log, replace

include "config.do"

*** Reading in narrow extract from IPUMS to make figure of share residing outside birth state by age, by cohort

/***
The following variables were downloaded:

label var year     `"Census year"'
label var sample   `"IPUMS sample identifier"'
label var serial   `"Household serial number"'
label var cbserial `"Original Census Bureau household serial number"'
label var hhwt     `"Household weight"'
label var cluster  `"Household cluster for variance estimation"'
label var statefip `"State (FIPS code)"'
label var strata   `"Household strata for variance estimation"'
label var gq       `"Group quarters status"'
label var pernum   `"Person number in sample unit"'
label var perwt    `"Person weight"'
label var age      `"Age"'
label var birthyr  `"Year of birth"'
label var bpl      `"Birthplace [general version]"'
label var bpld     `"Birthplace [detailed version]"'
label var qbpl     `"Flag for Bpl, Nativity"'
***/



* Read in extract from IPUMS

* do usa_00028.do
use "${datapath}/ipums-extract-1.dta", clear

* Confirm no GQ, no minors
summ age
tab1 gq

* Drop those with altered or imputed birthplace
drop if qbpl~=0

gen cohort=.
replace cohort=1 if birthyr>=1940 & birthyr<1949
replace cohort=2 if birthyr>=1950 & birthyr<1959
replace cohort=3 if birthyr>=1960 & birthyr<1969
replace cohort=4 if birthyr>=1970 & birthyr<1979
replace cohort=5 if birthyr>=1980 & birthyr<1989
replace cohort=6 if birthyr>=1990 & birthyr<1999
*replace cohort=7 if birthyr>=2000 & birthyr<2009

label define cohortlbl 1 "1940s" 2 "1950s" 3 "1960s" 4 "1970s" 5 "1980s" 6 "1990s"
label values cohort cohortlbl

drop if cohort==.

drop if bpl > 56 | bpl < 1
drop if statefip > 56 | statefip < 1

gen oobs=0
replace oobs=1 if bpl~=statefip

summ cohort age oobs

* Extracts should be self-weighting...

collapse (mean) oobs, by(age cohort)

save JELgraphdata.dta, replace
clear


use JELgraphdata.dta

drop if age > 59

graph twoway connect oobs age if cohort==1 || connect oobs age if cohort==2 || connect oobs age if cohort==3 || connect oobs age if cohort==4 || connect oobs age if cohort==5 || connect oobs age if cohort==6, ///
  ytitle("Share residing outside birth state") ///
  xtitle("Age") ///
  legend(label(1 "1940s") label(2 "1950s") label(3 "1960s") label(4 "1970s") label(5 "1980s") label(6 "1990s"))
graph save JELcohorts.gph, replace
graph export JELcohorts.pdf, replace

graph twoway connect oobs age if cohort==1 || connect oobs age if cohort==4 || connect oobs age if cohort==6, ///
  ytitle("Share residing outside birth state") ///
  xtitle("Age") ///
  legend(label(1 "1940s") label(2 "1970s") label(3 "1990s"))
graph save JELcohorts_few.gph, replace
graph save JELcohorts_few.pdf, replace

sort age cohort
gen ref=oobs if cohort==1  
by age: egen ref40=max(ref)
gen reloobs=oobs - ref40

graph twoway connect reloobs age if cohort==2 || connect reloobs age if cohort==3 || connect reloobs age if cohort==4 || connect reloobs age if cohort==5 || connect reloobs age if cohort==6, ///
  ytitle("Share residing outside birth state, relative to 1940") ///
  xtitle("Age") ///
  legend(label(1 "1950s") label(2 "1960s") label(3 "1970s") label(4 "1980s") label(5 "1990s"))
graph save JELcohorts_relative.gph, replace
graph export JELcohorts_relative.pdf, replace
  




