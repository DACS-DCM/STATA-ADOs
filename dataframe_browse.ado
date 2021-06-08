* stata version
version 16

********************************************************************************
* Jan Brink Valentin
* Spring 2021
********************************************************************************

program define dataframe_browse
    syntax name(name=dataframe)
    frame change `dataframe'
    browse
end
