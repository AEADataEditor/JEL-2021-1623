* Migration rates of homeowners and renters in 2019 for Figure 4
set trace off
set more 1 
capture log close
clear
set linesize 200
clear matrix 
clear mata 
set maxvar 10000

log using fig4.log, replace

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

gen owner = ownershp==1 if ownershp>=1 & ownershp<=2
gen dstate = migrate1==3 if migrate1>=1 & migrate1<=3
* variable indicating that someone moved across metro areas, is made missing for people who lived outside the US in the previous year
gen dmet = 1 if migmet131~=met2013 & migmet131~=.
replace dmet = 0 if migmet131==met2013 & migmet131~=.
replace dmet = 0 if migrate1==1
replace dmet = . if migrate1==4

tab dmet dstate
sum owner dstate dmet [w=perwt]
table owner [w=perwt], c(m dstate m dmet)

gen agedum = 1 if age>=21 & age<=24
replace agedum = 2 if age>=25 & age<=30
replace agedum = 3 if age>=31 & age<=40
replace agedum = 4 if age>=41 & age<=50
replace agedum = 5 if age>=51 & age<=60
quietly tab agedum, gen(agedum)
gen female = sex==2 if sex~=.
gen inschool = school==2 if school~=.
gen lths = educ<=5 if educ~=.
gen hsdeg = educ==6 if educ~=.
gen somecol = educ>=7 & educ<=8 if educ~=.
gen colplus = educ>=9 if educ~=.
gen hisp = hispan>=1 & hispan<=4 if hispan~=.
gen black = race==2 & hisp==0 if hisp~=. & race~=.
gen asian = race>=4 & race<=6 & hisp==0 if hisp~=. & race~=.
gen married = marst==1 if marst~=.
gen sep = marst>=2 & marst<=3 if marst~=.
gen div = marst>=4 & marst<=5 if marst~=.
gen vet = vetstat==2 if vetstat>=1 & vetstat<=2
gen unemp = empstat==2 if empstat~=.
gen nlf = empstat==3 if empstat~=.
gen selfemp = classwkr==2
gen notcit = citizen==3 if citizen~=.
gen natcit = citizen==2 if citizen~=.
gen bornab = citizen==1 if citizen~=.
gen mil = ind>=9670 & ind<=9870 
gen kiddum = nkid>=1 
gen divkid = div*kiddum
gen sepkid = sep*kiddum

reg dmet owner [w=perwt]
reg dmet owner agedum2-agedum5 female school lths somecol colplus hisp black asian married sep div vet unemp nlf selfemp notcit natcit bornab mil kiddum divkid sepkid [w=perwt]
*gen mighat = dmet-dmet+_b[_cons]+_b[agedum4]+_b[colplus] if owner==0 & female==1
*replace mighat  = _b[_cons]+_b[agedum4]+_b[colplus]+_b[owner] if owner==1 & female==1
reg dmet agedum2-agedum5 female school lths somecol colplus hisp black asian married sep div vet unemp nlf selfemp notcit natcit bornab mil kiddum divkid sepkid [w=perwt]
predict migresid if e(sample), resid
gen regsample = 1 if e(sample)
sum dmet[w=perwt] if  owner==0
gen mighatb = r(mean) if owner==0 & state==1
sum dmet[w=perwt] if  owner==1 
replace mighatb = r(mean) if owner==1 & state==1
sum dmet [w=perwt] if regsample==1
replace mighatb = r(mean) if state==4
sum migresid [w=perwt] if owner==0
replace mighatb = r(mean)+mighatb if owner==0 & state==4
sum migresid [w=perwt] if owner==1
replace mighatb = r(mean)+mighatb if owner==1 & state==4
sum dmet [w=perwt] if regsample==1 & age>=25 & age<=35
replace mighatb = r(mean) if state==6
sum migresid [w=perwt] if owner==0 & age>=25 & age<=35
replace mighatb = r(mean)+mighatb if owner==0 & state==6
sum migresid [w=perwt] if owner==1 & age>=25 & age<=35
replace mighatb = r(mean)+mighatb if owner==1 & state==6
sum dmet [w=perwt] if regsample==1 & age>=36 & age<=55
replace mighatb = r(mean) if state==8
sum migresid [w=perwt] if owner==0 & age>=36 & age<=55
replace mighatb = r(mean)+mighatb if owner==0 & state==8
sum migresid [w=perwt] if owner==1 & age>=36 & age<=55
replace mighatb = r(mean)+mighatb if owner==1 & state==8
sum dmet [w=perwt] if regsample==1 & educ<=8
replace mighatb = r(mean) if state==12
sum migresid [w=perwt] if owner==0 & educ<=8
replace mighatb = r(mean)+mighatb if owner==0 & state==12
sum migresid [w=perwt] if owner==1 & educ<=8
replace mighatb = r(mean)+mighatb if owner==1 & state==12
sum dmet [w=perwt] if regsample==1 & educ>=9 & educ~=.
replace mighatb = r(mean) if state==13
sum migresid [w=perwt] if owner==0 & educ>=9 & educ~=.
replace mighatb = r(mean)+mighatb if owner==0 & state==13
sum migresid [w=perwt] if owner==1 & educ>=9 & educ~=.
replace mighatb = r(mean)+mighatb if owner==1 & state==13
sum dmet [w=perwt] if regsample==1 & black==1
replace mighatb = r(mean) if state==17
sum migresid [w=perwt] if owner==0 & black==1
replace mighatb = r(mean)+mighatb if owner==0 & state==17
sum migresid [w=perwt] if owner==1 & black==1
replace mighatb = r(mean)+mighatb if owner==1 & state==17
sum dmet [w=perwt] if regsample==1 & hisp==1
replace mighatb = r(mean) if state==18
sum migresid [w=perwt] if owner==0 & hisp==1
replace mighatb = r(mean)+mighatb if owner==0 & state==18
sum migresid [w=perwt] if owner==1 & hisp==1
replace mighatb = r(mean)+mighatb if owner==1 & state==18
graph bar mighatb if state<=18 & state~=5 & state~=9 & state~=10 & state~=11 & state~=16, saving(fig4, replace) over(owner, gap(10) relab(1 "Renter" 2 "Owner") lab(angle(45))) over(state,  gap(100) relab(1 `""No" "Controls""' 2 "Controls" 3 `""Age" "25-35""' 4 `""Age" "36-55""' 5 `""No Coll." "Degree""' 6 `""Coll." "Degree +""' 7 "Black" 8 "Hispanic") lab(labsize(medsmall)))  bar(1, color(navy)) ylab(, nogrid) graphregion(color(white)) ytitle("Average Migration Rate")



quietly log close
