* stata version
version 16

********************************************************************************
* Jan Brink Valentin
* Spring 2021
********************************************************************************

program define dataframe_browse
    version 16
    syntax name(name=dataframe)
    frame change `dataframe'
    browse
end
