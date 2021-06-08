* stata version
version 16

********************************************************************************
* Jan Brink Valentin
* Summer 2021
********************************************************************************


* Varlist should be ordered according to priority in case of overlapping event times
capture program drop firstevent
program define firstevent
version 16
    
    syntax varlist [if] [in] , indicator_values(numlist) timevar(name) eventvar(name) [followup(real -1) adm_censoring(integer 0)]
	* followup < 0: no administrative censoring
	
	* Check length of indicator_values is the same as length of varlist
    local cn: word count `varlist'
    assert `cn' == `: word count `indicator_values''
	
	tempname fu
	scalar `fu' = cond(`followup'<=0,.,`followup')
	
	* Set timevar to the earlist of varlist
    egen `timevar' = rowmin(`varlist')
    
	* Set eventvar to the corresponding indicator value in indicator_values
	generate `eventvar' = `: word `cn' of `indicator_values''
    forvalues c = `=`cn'-1'(-1)1 {
        replace `eventvar' = `: word `c' of `indicator_values'' if `: word `c' of `varlist'' == `timevar'
    }
    
	* Set eventvar and timevar to the adm_censoring value and followup value, respectively, if time of event exceeds followup
	replace `eventvar' = `adm_censoring' if `timevar' > `fu'
    replace `timevar' = `fu' if `timevar' > `fu'
end