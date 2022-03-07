* calculate gross in-migration, gross out-migration and net migration by metropolitan area for Figure 2
set trace off
set more 1 
capture log close
clear
set linesize 200
clear matrix 
clear mata 
set maxvar 10000

log using fig2.log, replace

/* this dataset is the 1-year 2019 ACS data downloaded from IPUMS https://usa.ipums.org/usa/.
The following variables were downloaded:
year            int     %8.0g      YEAR       census year
sample          long    %12.0g     SAMPLE     ipums sample identifier
serial          long    %12.0g                household serial number
cbserial        double  %12.0g                original census bureau household serial number
hhwt            int     %8.0g                 household weight
cluster         double  %12.0g                household cluster for variance estimation
region          byte    %8.0g      REGION     census region and division
statefip        byte    %8.0g      STATEFIP   state (fips code)
countyfip       int     %8.0g                 county (fips code)
metro           byte    %8.0g      METRO      metropolitan status
met2013         long    %12.0g     MET2013    metropolitan area (2013 omb delineations)
strata          long    %12.0g                household strata for variance estimation
gq              byte    %8.0g      GQ         group quarters status
farm            byte    %8.0g      FARM       farm status
ownershp        byte    %8.0g      OWNERSHP   ownership of dwelling (tenure) [general version]
ownershpd       byte    %8.0g      OWNERSHPD
                                              ownership of dwelling (tenure) [detailed version]
hhincome        long    %12.0g                total household income
pernum          byte    %8.0g                 person number in sample unit
perwt           int     %8.0g                 person weight
relate          byte    %8.0g      RELATE     relationship to household head [general version]
related         int     %8.0g      RELATED    relationship to household head [detailed version]
sex             byte    %8.0g      SEX        sex
age             byte    %8.0g      AGE        age
marst           byte    %8.0g      MARST      marital status
marrinyr        byte    %8.0g      MARRINYR   married within the past year
divinyr         byte    %8.0g      DIVINYR    divorced in the past year
widinyr         byte    %8.0g      WIDINYR    widowed in the past year
race            byte    %8.0g      RACE       race [general version]
raced           int     %8.0g      RACED      race [detailed version]
hispan          byte    %8.0g      HISPAN     hispanic origin [general version]
hispand         int     %8.0g      HISPAND    hispanic origin [detailed version]
bpl             int     %8.0g      BPL        birthplace [general version]
bpld            long    %12.0g     BPLD       birthplace [detailed version]
citizen         byte    %8.0g      CITIZEN    citizenship status
school          byte    %8.0g      SCHOOL     school attendance
educ            byte    %8.0g      EDUC       educational attainment [general version]
educd           int     %8.0g      EDUCD      educational attainment [detailed version]
empstat         byte    %8.0g      EMPSTAT    employment status [general version]
empstatd        byte    %8.0g      EMPSTATD   employment status [detailed version]
labforce        byte    %8.0g      LABFORCE   labor force status
classwkr        byte    %8.0g      CLASSWKR   class of worker [general version]
classwkrd       byte    %8.0g      CLASSWKRD
                                              class of worker [detailed version]
occ             int     %8.0g                 occupation
ind             int     %8.0g                 industry
wkswork2        byte    %8.0g      WKSWORK2   weeks worked last year, intervalled
inctot          long    %12.0g                total personal income
incbus00        long    %12.0g                business and farm income, 2000
migrate1        byte    %8.0g      MIGRATE1   migration status, 1 year [general version]
migrate1d       byte    %8.0g      MIGRATE1D
                                              migration status, 1 year [detailed version]
migplac1        int     %8.0g      MIGPLAC1   state or country of residence 1 year ago
migcounty1      int     %8.0g                 county of residence 1 year ago
migmet131       long    %12.0g     MIGMET131
                                              metropolitan area of residence 1 year ago (2013 delineations)
vetstat         byte    %8.0g      VETSTAT    veteran status [general version]
vetstatd        byte    %8.0g      VETSTATD   veteran status [detailed version]
*/

use ~/data_house/usa_00108, clear
drop if statefip==15 | statefip==2
drop if farm==2
gen kid = age<=18
egen nkid = sum(kid), by(serial)
keep if relate==1 & age>=21 & age<=60
sum nkid, det


* variable indicating that someone moved across metro areas, is made missing for people who lived outside the US in the previous year
gen dmet = 1 if migmet131~=met2013 & migmet131~=.
replace dmet = 0 if migmet131==met2013 & migmet131~=.
replace dmet = 0 if migrate1==1
replace dmet = . if migrate1==4

preserve
collapse (sum) perwt if dmet==1, by(met2013)
rename perwt inmig
save temp, replace
restore
preserve
collapse (sum) perwt if dmet==1, by(migmet131)
rename perwt outmig
rename migmet131 met2013
merge 1:1 met2013 using temp
drop _merge
save temp, replace
restore
preserve
collapse (sum) perwt if dmet==0 | dmet==1, by(met2013)
rename perwt pop
merge 1:1 met2013 using temp
drop _merge
replace outmig = -1*outmig
sort pop
gen netmig = inmig + outmig
drop if met2013==0
gsort -netmig
l met2013 pop inmig outmig netmig , nod noobs
gen netmigrank = _n if netmig~=.

gen migdiff = outmig-netmig if netmig<0
replace migdiff = inmig - netmig if netmig>0
gen migopp = outmig if netmig>0
replace migopp = inmig if netmig<0

quietly for var netmig migdiff migopp: replace X = X/1000


lab def cbsa 38060 "Phoenix" 26420 "Houston" 19100 "Dallas" 39580 "Raleigh" 12420 "Austin" 12060 "Atlanta" 40900 "Sacramento" 29820 "Las Vegas" 45300 "Tampa" 42660 "Seattle"  12580 "Baltimore" 47900 "Washington DC" 44140 "Springfield MA" 47260 "Virginia Beach" 41740 "San Diego" 16980 "Chicago" 41860 "San Francisco" 33100 "Miami" 31080 "Los Angeles" 35620 "New York"
lab val met2013 cbsa
graph bar netmig migdiff migopp if netmigrank<=10 | (netmigrank>=231 & netmigrank~=.), stack saving(fig2, replace) graphregion(color(white)) over(met2013, lab(angle(45)) sort(netmigrank)) bar(1,color(navy)) bar(2,color(gray*.5)) bar(3,color(gray*.5)) legend(lab(1 "Net Migration") lab(2 "In/Out Migration") order(1 2)) ytitle("Thousands")

save fig2, replace



quietly log close
