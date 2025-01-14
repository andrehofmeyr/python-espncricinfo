pwd // Shows the current directory

ssc install filelist

ssc install missings


filelist , dir(.) pattern(*.csv) //getting files that i need for 15sec epoch

gen player_id=substr(filename,1,7) // generating student id from file name taking the first 8 characters

* gen grade_pa=regexs(0) if regexm(dirname,"[0-9]") //generating grade variable by taking the number included in the directory

* destring grade_pa, replace //destringing grade variable

*saving a a temporary file
tempfile cricinfo
save "`cricinfo'"

*trying all this on all file
local obs=_N
*directory for stata file
* cap mkdir cricinfo_stata

**PART 2
forvalues i=1/`obs' {

    use "`cricinfo'" in `i', clear
    local source = player_id
    local f = filename

    clear
    import delimited using "`f'", varnames(11) stringcols(_all)
    gen source = "`source'"

    tempfile save`i'
    qui save "`save`i''"

}

forvalues i=1/`obs' {
    append using "`save`i''"
}

save cricinfo_appendment_test.dta, replace