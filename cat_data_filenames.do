**PART 1
clear all 
log using "\\technet.wf.uct.ac.za\profiledata$\BVMSAM001\Documents\Honours\Thesis\python-espncricinfo_final (1).log", append

cap log close

numlabel, add
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
rename player_id1 player_id
use "IPL Auction.dta", clear



tostring player_id, gen(player_id1)
tostring player_id1, replace
save "IPL Auction.dta", replace

use "cricinfo_all_data.dta", clear
merge m:m player_id1 using "IPL Auction.dta"
drop _merge
save merged_data.dta, replace

zipfile merged_data.dta, saving(merged_data.zip, replace) 

unzipfile merged_data.zip, replace
use merged_data.dta, clear

generate grouping_full = grouping

foreach variable of varlist(grouping vireland-vscotland) {
    replace grouping_full = `variable' if grouping_full == ""
}

drop grouping vireland-vscotland

drop R

destring player_id, replace

drop if missing(player_id)
drop if grouping_full == ""


order player_id, first
order grouping_full, first

rename Name name
rename NATIONALITY nationality
rename TYPE type
rename PRICEBID saleprice
rename TEAM team
rename AUCTIONYEAR auction_year
rename SOLD sold
rename MinimumBidIfUnsold base_price
rename Fifers fifers

sort grouping_full

keep if grouping_full == "ICC Champions Trophy" | grouping_full == "ICC World Test Champ" | grouping_full == "Men's T20 World Cup" | grouping_full == "The Ashes"| grouping_full == "World Cup"| grouping_full == "in India"| grouping_full == "is captain"| grouping_full == "season 2020/21"| grouping_full == "season 2020"| grouping_full == "season 2021/22"| grouping_full == "season 2021"| grouping_full == "season 2022/23"| grouping_full == "season 2022"| grouping_full == "season 2023/24"| grouping_full == "season 2023"| grouping_full == "season 2024"| grouping_full == "tournament finals"| grouping_full == "v India" | grouping_full == "year 2019"| grouping_full == "year 2020"| grouping_full == "year 2021"| grouping_full == "year 2022"| grouping_full == "year 2023"| grouping_full == "year 2024"

destring matches, replace force
destring runs, replace force
destring hs, replace force
destring bat_ave, replace force
destring hundreds, replace force
destring wkts, replace force
destring best_figures, replace force
destring bowl_ave, replace force
destring fifers, replace force
destring ct, replace force
destring st, replace force
destring ave_diff, replace force

replace matches = 0 if missing(matches)
replace runs = 0 if missing(runs)
replace hs = 0 if missing(hs)
replace bat_ave = 0 if missing(bat_ave)
replace hundreds = 0 if missing(hundreds)
replace wkts = 0 if missing(wkts)
replace best_figures = 0 if missing(best_figures)
replace bowl_ave = 0 if missing(bowl_ave)
replace fifers = 0 if missing(fifers)
replace ct = 0 if missing(ct)
replace st = 0 if missing(st)
replace ave_diff = 0 if missing(ave_diff)

replace saleprice = "0" if saleprice == "None"
destring saleprice, replace

replace team = "Delhi Capitals" if team =="Dehli Capitals"

replace team = "Gujarat Titans" if team == "Gujurat Titans"



label define sold 1 "Yes" 0 "No"
replace sold = "1" if sold == "Yes"
replace sold = "0" if sold == "No"
destring sold, replace
numlabel, add
label define soldlbl 0 "no" 1 "yes"
label values sold soldlbl


save analysis.dta, replace
zipfile analysis.dta, saving(analysis.zip, replace) 

unzipfile analysis.zip, replace

use analysis.dta, clear


//sold variable still needs work


* look at xtset
* keep if grouping == "xyz" | "xyz"


*//////////////////////////////////////////////////////////////////////////////

* More Cleaning

misstable sum

//note to work on base_price


//matches

drop if matches <5
* done this to ensure sufficient explanatory power
* average of 15.45 matches per player per category

//runs

* should I clean runs less than a certain value? Intuitively yes but practically I am less sure.

//hs
* hs of zero is weird... especially if they then have runs?
*either need to drop this variable entirely or simply drop those observations... probably better to drop the variable entirely

drop hs

//bat_ave
* similar thing to above

//hundreds
*hundreds should be fine as is

//wkts

//similar to runs, but perhaps less important to drop these. Will need to think about running regressions differently for bowlers vs batters and potentially including different types in my model. 

*eg regress price wkts if type=="Bowler"


//bowl_ave
* same as bat_ave

//fifers
* similar to hundreds

//ct
*no real cleaning necessary

//st
*similar to wickets... specific player type

//ave_diff
*this is a problematic one

replace ave_diff=(bat_ave - bowl_ave) if ave_diff==0

*br if ave_diff <-100 | ave_diff>100

*above has some large outliers. Worth sorting out?

//age
*happy with age

//dob
drop DateofBirth

//auction date
drop auctiondate

//playing role
rename PlayingRole playing_role
tab playing_role
replace playing_role="All-Rounder" if playing_role=="Allrounder"
replace playing_role="Wicket-Keeper" if playing_role=="Wicketkeeper" |  playing_role=="Wicketkeeper Batter"

tab playing_role if playing_role == "Occasional Wicketkeeper"

*come back to this, being really weird

encode playing_role, gen(playing_role_cat)

label define role 1 "All-Rounder" 2 "Batter" 3 "Bowler" 4 "Bowling All-Rounder" 5 "Middle Order Batter" 6 "Occasional Wicket-Keeper" 7 "Opening Batter" 8 "Top Order Batter" 9 "Wicket-Keeper" 10 "Batting All-Rounder"
lab val playing_role_cat role

replace playing_role_cat = 9 if playing_role_cat==6

//batting role

* creating dummy

rename BattingRole bat_style
gen rhb = .
encode bat_style, gen(bat_style_num)
replace rhb = 1 if bat_style_num == 2
replace rhb = 0 if bat_style_num == 1
drop bat_style
lab val rhb bat_style

tab bat_style, missing
label var rhb "Batting Style"
label define bat_style 0 "left handed" 1 "right handed", modify

* could try to split up all=rounder's a bit more into bowling and batting all-rounders, but would be difficult to split up the 50 'batter's
tab type playing_role_cat //can help to visualise this

//bowling role

rename BowlingRole bowl_style

tab bowl_style
encode bowl_style, gen(bowl_style_cat)
recode bowl_style_cat (1 4 = 1)(2 5 6 =2)(3 7 8 9 21 =3)(12 13 =4)(14 15 16 17 =5)(18 19 20 =6)(10 11 =7)

label define bowl_style_lbl 1 "LH Fast" 2 "LH Medium" 3 "LH Spin" 4 "RH Fast" 5 "RH Medium" 6 "RH Spin" 7 "None", modify

lab val bowl_style_cat bowl_style_lbl
drop bowl_style

//type

tab type
replace type = "Wicket-Keeper" if type == "Wicket Keeper"
replace type = "Batter" if type == "Batsman"

encode type, gen(type_cat)
drop type


* need to somehow combine this with the playing_role_cat variable

//saleprice
gen log_saleprice = log(saleprice+1)
*histogram log_saleprice, normal

//auctionyear

*how useful is this?

//sold
*done this previously I think

//base_price
*what to do with the missing values here?


//instagram followers
rename InstagramFoll~s ig_followers
codebook ig_followers
replace ig_followers = trim(ig_followers)
replace ig_followers = "0" if ig_followers=="none" | ig_followers == "None"

destring ig_followers, replace
drop if missing(ig_followers)

reg saleprice ig_followers if sold==1 & ig_followers>0

*335 people with no available instagram account information. Should these be removed or treated as zeroes?

//date for follower count
drop DateforFollow~t

save analysis.dta, replace
