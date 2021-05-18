* stata version
version 16

********************************************************************************
* Jan Brink Valentin
* Spring 2021
********************************************************************************


program define balance_diagnostics_categorical

    syntax varname(numeric) [if] [in] [iweight] [, continuous_covar(varlist numeric) categorial_covar(varlist numeric)]
    
    marksample touse
	
	local weight_phrase = ""
	if "`exp'" != "" {
		local weight_phrase = "[`weight'`exp']"
	}
	
	levelsof `varlist' if `touse'
    local levels = r(levels)
    gettoken base levels : levels
	
    foreach var in `continuous_covar' {
		quietly: regress `var' i.`varlist' `weight_phrase' if `touse'
		display "`var': " 
        matlist 1.96*r(table)[3,1..`=colsof(r(table))-1']/sqrt(e(df_r))
    }
    
    foreach var in `categorial_covar' {    
        foreach j in `levels' {
            quietly {
                tabulate `var' `varlist' `weight_phrase' if `touse' & (`varlist' == `base' | `varlist' == `j'), matcell(table)
                scalar number_of_rows = rowsof(table)
                matrix table_total = J(1,number_of_rows,1)*table
                matrix table_left = table[....,1]/table_total[1,1]
                matrix table_right = table[....,2]/table_total[1,2]
                matrix table_denominator = (diag(table_right)*(J(number_of_rows,1,1)-table_right) + diag(table_left)*(J(number_of_rows,1,1)-table_left))/2
                mata st_matrix("table_denominator",sqrt(st_matrix("table_denominator")))
                matrix table_denominator = inv(diag(table_denominator))
            }
			display "`var' (exposure = `j', ref; exposure = `base'):"
            matlist table_denominator*(table_right-table_left)
        }
    }
    
end

* Reference:
* Zhang Z, Kim HJ, Lonjon G, Zhu Y; written on behalf of AME Big-Data Clinical Trial Collaborative Group. Balance diagnostics after propensity score matching. Ann Transl Med. 2019 Jan;7(1):16. doi: 10.21037/atm.2018.12.10. PMID: 30788363; PMCID: PMC6351359.

* Example:
/*

clear
set obs 200
generate exposure = runiformint(0,2)
generate con1 = cond(exposure==0,rnormal()+0.1,cond(exposure==1,rnormal()-0.1,rnormal()))
generate cat2 = cond(exposure==0,floor(runiform()*2.7),cond(exposure==1,runiformint(0,2),ceil(runiform()*2.3-1.0)))
generate con3 = 1.6*cond(exposure==0,rnormal()+0.4,cond(exposure==1,rnormal(),rnormal()-0.05))

*capture program drop balance_diagnostics_categorical
balance_diagnostics_categorical exposure, continuous_covar(con1 con3) categorial_covar(cat2)
*/