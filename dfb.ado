* stata version
version 16

********************************************************************************
* Jan Brink Valentin
* Spring 2021
********************************************************************************


program define dfb
    version 16
    syntax name(name=dataframe)
    dataframe_browse `dataframe'    
end
