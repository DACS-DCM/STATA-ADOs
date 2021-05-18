* stata version
version 16

********************************************************************************
* Jan Brink Valentin
* Spring 2021
********************************************************************************


capture program drop drop_frame
program define drop_frame
    version 16
    syntax name(name=dataframe)
    
    if "`dataframe'" == "default" {
        display as error "cannot drop default"
    }
    
    mata {
        rc = st_frameexists("default")
        st_numscalar("rc",rc)
    }
    if !rc {
        mkf default
    }
    cwf default
    
    mata {
        rc = st_frameexists(st_local("dataframe"))
        st_numscalar("rc",rc)
    }
    if rc {
        frame drop `dataframe'
    }
end