//RESTRUCTURED TO ALLOW FOR RESHAPING

**PART 1
clear all 

cap log close

unzipfile player_data.zip, replace

cd player_data

log using "python-espncricinfo_final (1).log", append

numlabel, add
pwd // Shows the current directory

ssc install filelist

ssc install missings

ssc install egenmore

ssc install regsave

ssc install outreg2


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
    import delimited using "`f'", varnames(1) stringcols(_all)
    gen source = "`source'"

    tempfile save`i'
    qui save "`save`i''"

}

forvalues i=1/`obs' {
    append using "`save`i''"
}


gen vfirst = v1
gen vend = v1


order vfirst, first
order vend, before(source)

drop vfirst-vend
drop v1


save cricinfo_all_data.dta, replace

//CLEANING CSV DATA

replace grouping = "Overall" if v16 == "Profile"

drop v2 v16

label var span "Span"


rename mat matches
label var matches "Matches Played"

label var runs "Runs Scored"

label var hs "Highest Score"

rename batav bat_ave
label var bat_ave "Batting Average"

rename v8 hundreds

label var hundreds "Hundreds Scored"

label var wkts "Wickets Taken"

label var bbi "Best Bowling Figures"

rename bowlav bowl_ave

label var bowl_ave "Bowling Average"

label var ct "Catches"

label var st "Stumpings (Wicketkeeper)"

rename avediff ave_diff

label var ave_diff "Difference in Averages (Batting minus Bowling)"

rename source player_id

order grouping, first

gen dash_pos = strpos(player_id, "_")
gen player_id1 = substr(player_id, 1, dash_pos -1)

replace player_id1 = player_id if missing(player_id1)

save cricinfo_all_data.dta, replace 

//missings dropvars * , force

drop player_id
drop dash_pos
drop if missing(grouping)

destring matches, replace force
destring runs, replace force
destring bat_ave, replace force
destring hundreds, replace force
destring wkts, replace force
destring bowl_ave, replace force
destring ct, replace force
destring st, replace force
destring ave_diff, replace force

replace matches = 0 if missing(matches)
replace runs = 0 if missing(runs)
replace hs = "DNB" if hs == "-"
replace bat_ave = (runs/matches) if missing(bat_ave)
replace hundreds = 0 if missing(hundreds)
replace wkts = 0 if missing(wkts)
replace bowl_ave = 0 if missing(bowl_ave)
replace ct = 0 if missing(ct)
replace st = 0 if missing(st)
replace ave_diff = 0 if missing(ave_diff)

replace ave_diff=(bat_ave - bowl_ave) if ave_diff==0

keep if  grouping == "One-Day Internationals" |grouping == "Overall" |grouping == "Test matches" | grouping == "Twenty20 Internationals"   | grouping == "Men's T20 World Cup" | grouping == "World Cup"| grouping == "in India"| grouping == "is captain" | grouping == "tournament finals"| grouping == "v India" | grouping == "year 2019"| grouping == "year 2020"| grouping == "year 2021"| grouping == "year 2022"| grouping == "year 2023"| grouping == "year 2024" | grouping == "is not captain"| grouping == "year 1998"| grouping == "year 1999"| grouping == "year 2000"| grouping == "year 2001"| grouping == "year 2002"| grouping == "year 2003"| grouping == "year 2004"| grouping == "year 2005"| grouping == "year 2006"| grouping == "year 2007"| grouping == "year 2008"| grouping == "year 2009"| grouping == "year 2010"| grouping == "year 2011"| grouping == "year 2012"| grouping == "year 2013"| grouping == "year 2014"| grouping == "year 2015"| grouping == "year 2016"| grouping == "year 2017"| grouping == "year 2018"

destring player_id1, replace

encode grouping, gen(grouping_num)

duplicates report player_id grouping   // Identify duplicates
duplicates tag player_id grouping, generate(dup_tag)   // Tag duplicates
drop if dup_tag > 0   // Remove duplicates
duplicates report player_id grouping   // Verify no duplicates remain
drop dup_tag

save cricinfo_all_data, replace


*IPL AUCTION DATA CLEANING

import excel "IPL Auction Data stata", firstrow clear
save "IPL Auction.dta", replace

rename AUCTIONYEAR auction_year
rename Name name
rename NATIONALITY nationality
rename TYPE type
rename PRICEBID saleprice
rename TEAM team
rename SOLD sold
rename MinimumBidIfUnsold base_price
replace team = "Delhi Capitals" if team =="Dehli Capitals"
replace team = "Gujarat Titans" if team == "Gujurat Titans"
drop auctiondate DateforFollowerCount

duplicates report player_id auction_year   // Identify duplicates
drop if name == "Amit Mishra" & base_price==2000000.00

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


//saleprice
replace saleprice = "0" if saleprice == "None"
destring saleprice, replace
gen log_saleprice = log(saleprice+1)
*histogram log_saleprice, normal

*how useful is this?

//nationality
encode nationality, gen(nat_cat)

drop nationality

//team

encode team, gen(team_cat)
drop team

//sold
label define sold 1 "Yes" 0 "No"
replace sold = "1" if sold == "Yes"
replace sold = "0" if sold == "No"
destring sold, replace
numlabel, add
label define soldlbl 0 "no" 1 "yes"
label values sold soldlbl

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

//dob
drop DateofBirth


*name
egen unique_name = tag(name)
egen unique_player_id = tag(player_id)
gen problem = 1 if unique_player_id ==0 & unique_name ==1
tab player_id if unique_player_id ==0 & unique_name ==1
//drop problem
*nationality and type
//decode nat_cat, gen(nat)
//decode type_cat, gen(typ)

//sort name
//gen conc = strtrim(name)+ nat + typ
//egen unique_conc = tag(conc)
//gen problem = 1 if unique_player_id==0 & unique_conc==1
//replace problem = 1 if unique_player_id ==0 & unique_conc ==1



*type
//egen unique_nat = tag(nationality)
//tab player_id if unique_player_id ==0 & unique_type ==1

tab name if player_id == 974109
replace name = "Rassie Van Der Dussen" if name == "Rassie Van der Dussen"
replace name = "James Neesham" if name == "Jimmy Neesham"
replace name = "Ben McDermott" if name == "Ben Mcdermott"
replace name = "Obed McCoy" if name == "Obed Mccoy"
replace name = "Mujeeb Rahman" if name == "Mujeeb Zadran"

replace nat_cat = 2 if name == "Chris Lynn"
replace nat_cat = 13 if name == "Isuru Udana"
replace nat_cat = 13 if name == "Maheesh Theekshana"
replace nat_cat = 1 if name == "Mujeeb Rahman"



drop unique_name unique_player_id problem
rename player_id player_id1

 reshape wide age saleprice team sold base_price ig_followers log_saleprice log_ig_followers nat_cat type_cat, i(player_id1) j(auction_year) 
 //(j = 2021 2022 2023 2024)
 
 save "IPL Auction.dta", replace

*-------------------------------------------------------------------------------
*MERGING and RESHAPING DO FILE
*--------------------------------------------------------------------------

//RESHAPING OF CRICINFO DATA (if necessary)

*do we really want wide format for this??

* if we want wide form: reshape wide span matches runs hs bat_ave wkts hundreds bbi bowl_ave ct st ave_diff grouping, i(player_id) j(grouping_num)



//RESHAPING OF IPL AUCTION DATA





//MERGING

use "cricinfo_all_data.dta", clear
merge m:1 player_id1 using "IPL Auction.dta"
drop _merge
save merged_data.dta, replace

zipfile merged_data.dta, saving(merged_data.zip, replace) 

unzipfile merged_data.zip, replace
use merged_data.dta, clear

drop if missing(grouping)

drop R

destring player_id, replace

order player_id, first
order grouping, first

order name, first




drop player_id1
save analysis.dta, replace
zipfile analysis.dta, saving(analysis.zip, replace) 

unzipfile analysis.zip, replace

use analysis.dta, clear

**Post-Merge cleaning
//type_cat

replace type_cat2021 = type_cat2022 if missing(type_cat2021) & !missing(type_cat2022)
replace type_cat2021 = type_cat2023 if missing(type_cat2021) & !missing(type_cat2023)
replace type_cat2021 = type_cat2024 if missing(type_cat2021) & !missing(type_cat2024)

replace type_cat2022 = type_cat2021 if missing(type_cat2022) & !missing(type_cat2021)
replace type_cat2022 = type_cat2023 if missing(type_cat2022) & !missing(type_cat2023)
replace type_cat2022 = type_cat2024 if missing(type_cat2022) & !missing(type_cat2024)

replace type_cat2023 = type_cat2021 if missing(type_cat2023) & !missing(type_cat2021)
replace type_cat2023 = type_cat2022 if missing(type_cat2023) & !missing(type_cat2022)
replace type_cat2023 = type_cat2024 if missing(type_cat2023) & !missing(type_cat2024)

replace type_cat2024 = type_cat2021 if missing(type_cat2024) & !missing(type_cat2021)
replace type_cat2024 = type_cat2023 if missing(type_cat2024) & !missing(type_cat2023)
replace type_cat2024 = type_cat2022 if missing(type_cat2024) & !missing(type_cat2022)


generate all_same_value = (type_cat2021 == type_cat2022) & (type_cat2022 == type_cat2023) & (type_cat2023 == type_cat2024)
tab all_same_value

drop type_cat2021 type_cat2022 type_cat2023 all_same_value
rename type_cat2024 type_cat

//nat_cat

replace nat_cat2021 = nat_cat2022 if missing(nat_cat2021) & !missing(nat_cat2022)
replace nat_cat2021 = nat_cat2023 if missing(nat_cat2021) & !missing(nat_cat2023)
replace nat_cat2021 = nat_cat2024 if missing(nat_cat2021) & !missing(nat_cat2024)

replace nat_cat2022 = nat_cat2021 if missing(nat_cat2022) & !missing(nat_cat2021)
replace nat_cat2022 = nat_cat2023 if missing(nat_cat2022) & !missing(nat_cat2023)
replace nat_cat2022 = nat_cat2024 if missing(nat_cat2022) & !missing(nat_cat2024)

replace nat_cat2023 = nat_cat2021 if missing(nat_cat2023) & !missing(nat_cat2021)
replace nat_cat2023 = nat_cat2022 if missing(nat_cat2023) & !missing(nat_cat2022)
replace nat_cat2023 = nat_cat2024 if missing(nat_cat2023) & !missing(nat_cat2024)

replace nat_cat2024 = nat_cat2021 if missing(nat_cat2024) & !missing(nat_cat2021)
replace nat_cat2024 = nat_cat2023 if missing(nat_cat2024) & !missing(nat_cat2023)
replace nat_cat2024 = nat_cat2022 if missing(nat_cat2024) & !missing(nat_cat2022)

drop nat_cat2021 nat_cat2022 nat_cat2023 PlayingRole
rename nat_cat2024 nat_cat


