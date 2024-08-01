**PART 1
clear all 

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


missings dropobs v1-v15, force



save cricinfo_all_data.dta, replace

rename vnetherlands grouping

label var grouping "Grouping"


rename v3 span

label var span "Span"


rename v4 matches

label var matches "Matches Played"


rename v5 runs

label var runs "Runs Scored"



rename v6 hs

label var hs "Highest Score"

rename v7 bat_ave

label var bat_ave "Batting Average"

rename v8 hundreds

label var hundreds "Hundreds Scored"

rename v9 wkts

label var wkts "Wickets Taken"

rename v10 best_figures

label var best_figures "Best Bowling Figures"

rename v11 bowl_ave

label var bowl_ave "Bowling Average"

rename v12 Fifers

label var Fifers "Number of Five Wicket Hauls"

rename v13 ct

label var ct "Catches"

rename v14 st

label var st "Stumpings (Wicketkeeper)"

rename v15 ave_diff

label var ave_diff "Difference in Averages (Batting minus Bowling)"

rename source player_id


gen dash_pos = strpos(player_id, "_")
gen player_id1 = substr(player_id, 1, dash_pos -1)



save cricinfo_all_data.dta, replace 

missings dropvars * , force

drop player_id
drop dash_pos


*-------------------------------------------------------------------------------
*MERGING and RESHAPING DO FILE
*--------------------------------------------------------------------------

save cricinfo_all_data, replace
import excel "\\technet.wf.uct.ac.za\profiledata$\bvmsam001\Documents\Honours\Thesis\python-espncricinfo_final (1)\player_data\IPL Auction Data stata", firstrow clear
save "IPL Auction.dta", replace
use cricinfo_all_data
use "IPL Auction.dta", clear
rename player_id1 player_id



tostring player_id, gen(player_id1)
tostring player_id1, replace

-----
use "cricinfo_all_data.dta", clear
merge m:m player_id1 using "IPL Auction.dta"
drop _merge
save merged_data.dta, replace

use merged_data.dta

rename player_id1 player_id

generate grouping_full

foreach variable of varlist(grouping vireland-vscotland) {
    replace grouping_full = `variable' if grouping_full == ""
}

drop grouping vireland-vscotland


browse

*to be continued//questions for Andre: combining grouping related columns into one

