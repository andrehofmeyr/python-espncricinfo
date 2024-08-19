**PART 1
clear all 

cap log close

log using "\\technet.wf.uct.ac.za\profiledata$\BVMSAM001\Documents\Honours\Thesis\python-espncricinfo_final (1).log", append

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
order grouping, first
order vireland, after(ave_diff)

foreach variable of varlist(grouping vireland-vscotland) {
    replace grouping_full = `variable' if grouping_full == ""
}

order grouping_full, first
*below code causes issues if you don't change the variable names
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

keep if grouping_full == "ICC Champions Trophy" | grouping_full == "ICC World Test Champ" | grouping_full == "Men's T20 World Cup" | grouping_full == "The Ashes"| grouping_full == "World Cup"| grouping_full == "in India"| grouping_full == "is captain" | grouping_full == "tournament finals"| grouping_full == "v India" | grouping_full == "year 2019"| grouping_full == "year 2020"| grouping_full == "year 2021"| grouping_full == "year 2022"| grouping_full == "year 2023"| grouping_full == "year 2024"

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

drop player_id1
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

*drop if matches <5
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

drop if name =="Johannes Smit" & bat_ave>50
tab name if bat_ave>50


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

gen age_squared = (age*age)

//dob
drop DateofBirth

//auction date
drop auctiondate

//playing role - decided not to include this
drop PlayingRole




*rename PlayingRole playing_role
*tab playing_role
*replace playing_role="All-Rounder" if playing_role=="Allrounder"
*replace playing_role="Wicket-Keeper" if playing_role=="Wicketkeeper" |  playing_role=="Wicketkeeper Batter"

*tab playing_role if playing_role == "Occasional Wicketkeeper"

*encode playing_role, gen(playing_role_cat)

*label define role 1 "All-Rounder" 2 "Batter" 3 "Bowler" 4 "Bowling All-Rounder" 5 "Middle Order Batter" 6 "Occasional Wicket-Keeper" 7 "Opening Batter" 8 "Top Order Batter" 9 "Wicket-Keeper" 10 "Batting All-Rounder"
*lab val playing_role_cat role

*replace playing_role_cat = 9 if playing_role_cat==6

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

drop bat_style_num

* could try to split up all=rounder's a bit more into bowling and batting all-rounders, but would be difficult to split up the 50 'batter's
*tab type playing_role_cat //can help to visualise this

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

//nationality
encode nationality, gen(nat_cat)

drop nationality

//team

encode team, gen(team_cat)
drop team




//sold
*done this previously I think

//base_price
*what to do with the missing values here?


drop best_figures

//instagram followers
rename InstagramFoll~s ig_followers
codebook ig_followers
replace ig_followers = trim(ig_followers)
replace ig_followers = "0" if ig_followers=="none" | ig_followers == "None"

destring ig_followers, replace
drop if missing(ig_followers)

gen log_ig_followers = log(ig_followers + 1)

reg saleprice ig_followers if sold==1 & ig_followers>0

replace ig_followers = 200000 if name == "Adam Milne"
replace ig_followers =200000 if name =="Afif Hossain"
replace ig_followers =100000 if name =="Ali Khan"
replace ig_followers = 40000 if name =="Ashton Agar"
replace ig_followers = 5000 if name =="Blair Tickner"
replace ig_followers =20000 if name =="Colin De Grandhomme"
replace ig_followers =50000 if name =="Darren Bravo"
replace ig_followers =350000 if name =="Dasun Shanaka"
replace ig_followers =10000 if name =="Fidel Edwards"
replace ig_followers =55000 if name =="Hamid Hassan"
replace ig_followers =1000 if name =="Hamish Bennett"
replace ig_followers =270000 if name =="James Faulkner"
replace ig_followers =7500 if name =="James Vince"
replace ig_followers =25000 if name =="Josh Inglis"
replace ig_followers =15000 if name =="Keemo Paul"
replace ig_followers =14000 if name =="Lewis Gregory"
replace ig_followers =5000 if name =="Lizaad Williams"
replace ig_followers =350000 if name =="Mark Wood"
replace ig_followers =80000 if name =="Matthew Wade"
replace ig_followers =1500000 if name =="Mayank Agarwal"
replace ig_followers =1250000 if name =="Moeen Ali"
replace ig_followers =215000 if name =="Morne Morkel"
replace ig_followers =1500000 if name =="Mushfiqur Rahim"
replace ig_followers =35000 if name =="Nathan Coulter-Nile"
replace ig_followers =50000 if name =="Neil Wagner"
replace ig_followers =100000 if name =="Qais Ahmad"
replace ig_followers =600000 if name =="Quinton De Kock"
replace ig_followers =15000 if name =="Roston Chase"
replace ig_followers =15000 if name =="Scott Kuggelijn"
replace ig_followers =17500 if name =="Seekkuge Prassanna"
replace ig_followers =3000 if name =="Shamarh Brooks"
replace ig_followers =50000 if name =="Thisara Perera"
replace ig_followers =40000 if name =="Tim Seifert"
replace ig_followers =2000 if name =="Todd Astle"
replace ig_followers =80000 if name =="Tom Latham"
replace ig_followers =3000 if name =="Zubayr Hamza"

*49 people with no instagram account. Should these be removed or treated as zeroes? Intution suggests treat as zeroes.

//date for follower count
drop DateforFollow~t

*Some outlier issues to highlight

br if bowl_ave >50 & type_cat ==3
br if bat_ave <10 & type_cat ==2

save analysis.dta, replace


* Modelling

*should I put age and age_squared in?

//Hurdle 
logit sold age_squared matches runs bat_ave hundreds wkts bowl_ave fifers ct st ave_diff i.type_cat log_ig_followers rhb i.bowl_style_cat i.nat_cat ave_interaction

regress log_saleprice age_squared matches runs bat_ave hundreds wkts bowl_ave fifers ct st ave_diff i.type_cat log_ig_followers rhb i.bowl_style_cat i.nat_cat i.team ave_interaction if sold==1


//suggested additions

vif

summarize log_saleprice if sold==1, detail

ssc install egenmore

ssc install regsave

ssc install outreg2

ssc install missings

egen career_bat_ave = mean(bat_ave), by(player_id)

egen career_bowl_ave = mean(bowl_ave), by(player_id)

generate ave_interaction = bat_ave * bowl_ave



*Potentially skewed data to consider cleaning?

//Very long time spans. 
//Players with high numbers of matches played or low numbers of matches played
//should I log matches played and runs scored? Currently not normally distributed...
//use IQR to remove skewed performance metrics. eg:

//quietly summarize Runs
//gen IQR = r(p75) - r(p25)
//gen lower_bound = r(p25) - 1.5 * IQR
//gen upper_bound = r(p75) + 1.5 * IQR
//drop if Runs < lower_bound | Runs > upper_bound	

*Xtset? Will this be useful?

//panel identifier will be player_id. What will the time identifier be? Problem is that the data spans over multiple years (except in the case of 'year 2019' etc)

//xtset player_id timingvariable
//xtdescribe
//xtreg SalePrice CareerSpan Matches Runs HighScore BattingAverage Hundreds Wickets BestFigures BowlingAverage Fifers Caught Stumpings AvgDifference BasePrice, fe
//xtreg SalePrice CareerSpan Matches Runs HighScore BattingAverage Hundreds Wickets BestFigures BowlingAverage Fifers Caught Stumpings AvgDifference BasePrice, re
//hausman fe re
//including lagged variables: xtreg SalePrice L.SalePrice CareerSpan Matches Runs HighScore BattingAverage Hundreds Wickets BestFigures BowlingAverage Fifers Caught Stumpings AvgDifference BasePrice, fe

//graphs and summary statistics

outreg2 using "summary_stats.xls", replace ctitle("Summary Statistics") ///
    sum(log) dec(2) stat(n mean sd min max)


graph pie if sold==1, over(type_cat)

graph pie if sold==1, over(team_cat)

graph pie if sold==1, over(nat_cat)

*Cross-tabulation table
tabulate type_cat team_cat, chi2 

* Correlation matrix
correlate age_squared matches runs bat_ave hundreds wkts bowl_ave fifers ct st ave_diff type_cat log_ig_followers rhb bowl_style_cat nat_cat team ave_interaction saleprice base_price sold
outreg2 using correlation_matrix.doc, replace ctitle("Correlation Matrix")

* Histograms
histogram log_saleprice if sold==1, normal saving(saleprice_hist, replace)
histogram bat_ave, normal saving(battingaverage_hist, replace)
histogram bowl_ave if wkts>0, normal saving(bowling_average_hist, replace)
histogram matches, normal saving(matches_hist, replace)

* Box plots
graph box saleprice, saving(saleprice_box, replace)
graph box bat_ave, saving(battingaverage_box, replace)

* Bar charts
graph bar (count), over(type_cat) saving(player_type_bar, replace)
graph bar (count), over(team_cat) saving(team_bar, replace)
graph bar (count), over(rhb) saving(battinghand_bar, replace)
graph bar (count), over(nat_cat) saving(nationality_bar, replace)
graph bar (count), over(bowl_style_cat) saving(bowl_style_bar, replace)
graph bar (count), over(auction_year) saving(auction_year_bar, replace)
graph bar (count), over(sold) saving(sold_bar, replace)
graph bar mean_price_year, over(auction_year) saving(mean_price_year, replace)


//graphs to jpeg for mac
graph bar (count), over(type_cat) saving(player_type_bar.pdf, as(pdf) replace)
graph bar (count), over(team_cat) saving(team_bar, replace)
graph bar (count), over(rhb) saving(battinghand_bar, replace)
graph bar (count), over(nat_cat) saving(nationality_bar, replace)
graph bar (count), over(bowl_style_cat) saving(bowl_style_bar, replace)
graph bar (count), over(auction_year) saving(auction_year_bar, replace)
graph bar (count), over(sold) saving(sold_bar, replace)
graph bar mean_price_year, over(auction_year) saving(mean_price_year, replace)


* Scatter plots
scatter log_saleprice runs if sold==1 & runs>0, saving(saleprice_runs_scatter, replace)
scatter log_saleprice bat_ave if sold==1 & runs>0 & type_cat!=3, saving(saleprice_battingaverage_scatter, replace)


* Line plots - needs work

egen mean_price_year = mean(saleprice), by(auction_year)

twoway (line mean_price_year auction_year if sold==1), saving(saleprice_trend, replace)






