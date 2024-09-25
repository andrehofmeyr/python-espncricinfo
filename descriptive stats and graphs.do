cd "player_data"

set scheme s2color, permanently
use analysis.dta, clear

//egen pid_one=tag(player_id)
//sort pid_one

//tab name if pid_one==1

*Some outlier issues to highlight

//br if bowl_ave >50 & type_cat ==3
//br if bat_ave <10 & type_cat ==2

//suggested additions

//vif

*Sale price summary
summarize saleprice if sold==1, detail


summarize saleprice if sold==1 & auction_year==2021, detail
summarize saleprice if sold==1 & auction_year==2022, detail
summarize saleprice if sold==1 & auction_year==2023, detail
summarize saleprice if sold==1 & auction_year==2024, detail

//2024 most rightward skewed. 2023 lowest mean, 2024 highest mean.

*generate ave_interaction = bat_ave * bowl_ave

//egen mean_price_year = mean(saleprice), by(auction_year)

save analysis.dta, replace

//NATIONALITY TABLE 

tab nat_cat sold, row column
//India the only nation that has a higher portion of players sold compared to unsold


tab nat_cat sold if auction_year==2021, column
tab nat_cat sold if auction_year==2022, column
tab nat_cat sold if auction_year==2023, column
tab nat_cat sold if auction_year==2024, column




//SOLD UNSOLD TABLE

* Create a table to show the count of sold and unsold players for each year

sum sold if auction_year==2021
sum sold if auction_year==2022
sum sold if auction_year==2023
sum sold if auction_year==2024

//PLAYER TYPE TABLE

tab (type_cat) (auction_year sold), nototals 
tab type_cat sold2022 if grouping=="Overall"
tab type_cat sold2023 if grouping=="Overall"
tab type_cat sold2024 if grouping=="Overall"

tab nat_cat if grouping=="Overall"


//GRAPHS 

graph hbar sold, over(auction_year)
graph hbar sold, over(auction_year) by(type_cat)

graph pie if sold==1, over(nat_cat) by(auction_year) pie(5, explode(10))

graph hbar log_saleprice if sold==1, over(type_cat) over(auction_year) 

graph pie, over(type_cat) plabel(_all percent, gap(-5))


graph pie, over(nat_cat) legend(pos(3) cols(1) stack) sort

scatter log_saleprice age if sold==1, msymbol(point) jitter(3) || lfit log_saleprice age if sold==1

histogram age, normal

histogram saleprice, normal
histogram ig_followers, normal

histogram saleprice if sold==1, normal
histogram ig_followers if sold==1, normal

histogram log_saleprice if sold==1, normal
histogram log_ig_followers if sold==1 & log_ig_followers>0, normal

twoway scatter log_saleprice log_ig_followers if sold==1 & log_ig_followers>0, msymbol(p)  jitter(3) || lfit log_saleprice log_ig_followers if sold==1 & log_ig_followers>0



*Super Simple Models

reg log_saleprice2024 i.type_cat if grouping =="Twenty20 Internationals"



* Modelling

//LPM

regress sold2021 c.age2021##c.age2021 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2021 i.rhb i.bowl_style_cat i.nat_cat if grouping =="year 2020" | grouping == "year 2021"

regress sold2021 c.age2021##c.age2021 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2021 i.rhb i.bowl_style_cat i.nat_cat if grouping =="Overall" 

regress sold2022 c.age2022##c.age2022 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2022 i.rhb i.bowl_style_cat i.nat_cat if grouping =="year 2021" | grouping == "year 2022"

regress sold2022 c.age2022##c.age2022 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2022 i.rhb i.bowl_style_cat i.nat_cat if grouping =="Overall" 

regress sold2023 c.age2023##c.age2023 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2022 i.rhb i.bowl_style_cat i.nat_cat if grouping =="year 2022" | grouping == "year 2023"

regress sold2023 c.age2022##c.age2023 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2023 i.rhb i.bowl_style_cat i.nat_cat if grouping =="Overall" 

regress sold2024 c.age2024##c.age2024 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2022 i.rhb i.bowl_style_cat i.nat_cat if grouping =="year 2023" | grouping == "year 2024"

regress sold2024 c.age2024##c.age2024 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2024 i.rhb i.bowl_style_cat i.nat_cat if grouping =="Overall" 

*Not significant, which is expected. 

//OLS Models
use analysis.dta, clear

*should I put age and age_squared in?

reg log_saleprice2021 c.age2021##c.age2021 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st c.ave_diff i.type_cat c.log_ig_followers2021 i.rhb i.bowl_style_cat i.nat_cat if grouping == "Men's T20 World Cup"
vif


//Logit
logit sold2024 c.age2024##c.age2024 c.matches c.runs c.bat_ave c.hundreds c.wkts c.bowl_ave  c.ct c.st i.type_cat c.log_ig_followers2024 i.rhb i.bowl_style_cat i.nat_cat if grouping =="Twenty20 Internationals"
margins, dydx(*)


//batter hurdle: 

churdle linear log_saleprice2021 matches bat_ave hundreds log_ig_followers2021 i.rhb i.nat_cat i.team_cat2021 if type_cat == 1, select(matches bat_ave hundreds log_ig_followers2021 i.rhb i.nat_cat) ll(0)

regress log_saleprice age#age matches runs bat_ave hundreds wkts bowl_ave ct st ave_diff i.type_cat log_ig_followers i.rhb i.bowl_style_cat i.nat_cat i.team ave_interaction if sold==1

churdle linear log_saleprice c.age##c.age matches runs bat_ave hundreds wkts bowl_ave ct st ave_diff i.type_cat log_ig_followers i.rhb i.bowl_style_cat i.nat_cat i.team ave_interaction, select(c.age##c.age matches runs bat_ave hundreds wkts bowl_ave ct st ave_diff i.type_cat log_ig_followers i.rhb i.bowl_style_cat i.nat_cat ave_interaction) ll(0)

margins, dydx(*) 
regsave using "margins.xls", replace

//treat variables as continuous. Fix factor variable syntax.



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
correlate c.age##c.age matches runs bat_ave hundreds wkts bowl_ave ct st ave_diff type_cat log_ig_followers rhb bowl_style_cat nat_cat team ave_interaction saleprice sold
outreg2 using correlation_matrix.xls, replace ctitle("Correlation Matrix")

* Histograms
//reason for using hurdle model:
histogram saleprice, normal saving(saleprice_all_hist, replace)



histogram log_saleprice if sold==1, normal saving(saleprice_hist, replace)
histogram bat_ave, normal saving(battingaverage_hist, replace)
histogram bowl_ave if wkts>0, normal saving(bowling_average_hist, replace)
histogram matches, normal saving(matches_hist, replace)

* Box plots
graph box saleprice, saving(saleprice_box, replace)
graph box bat_ave, saving(battingaverage_box, replace)

* Bar charts
graph bar (count), over(type_cat) saving(player_type_bar, replace)
graph bar (count) if team_cat!=7, over(team_cat)  saving(team_bar, replace)
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



twoway (line mean_price_year auction_year if sold==1), saving(saleprice_trend, replace)

//Graph recommendations book

twoway kdensity saleprice

twoway lfit saleprice bat_ave if sold==1

twoway (scatter saleprice bat_ave) (lfit saleprice bat_ave) if sold==1

graph hbar saleprice if sold==1, over(team_cat, label(nolabels)) blabel(group, position(base))

graph hbox saleprice if sold==1, over(team_cat)

graph hbox saleprice if sold==1, over(team_cat) asyvar 

//graph hbar saleprice, over(nat_cat) asyvar legend (rows(3))


//options:
* title("This is a title for the graph")
*title ("Title", box size(small))
* xlabel(0(5)40) - x axis labelled from 0 to 40 in increments of 5
*legend(cols(1)) which symbols 

//Regression fits

twoway (lfitci log_saleprice log_ig_followers if sold==1 & grouping=="Overall", stdf) (scatter log_saleprice log_ig_followers if sold==1 & grouping=="Overall")


//vars of interest -> want mean, sum, max, min
* saleprice
* matches
*runs
*bat_ave
*hundreds
* wkts
*bowl_ave


//bowlers: age matches wkts bowl_ave ave_diff bowl_style_cat ig_followers saleprice sold

//batters: age matches runs bat_ave hundreds ave_diff ig_followers rhb saleprice sold

//keepers: age matches runs bat_ave hundreds ave_diff ct st ig_followers rhb saleprice sold

//all-rounders: age matches runs bat_ave hundreds wkts bowl_ave ave_diff bowl_style_cat ig_followers saleprice sold

//Desc Stats

set scheme s2color, permanently



* Overall
use analysis.dta, clear
keep if grouping == "Twenty20 Internationals" 
keep matches runs bat_ave hundreds wkts bowl_ave ct st ave_diff age saleprice sold age rhb 
outreg2 using "summary_stats.xls", replace ctitle("Summary Statistics") ///
    sum(log) dec(2) stat(n mean sd min max)

//Formats
	***** Tests

//Overall

//Batters

//Bowlers

//All-Rounders


//Keepers

	* ODI's

//Overall

	
//Batters





//Bowlers




//All-Rounders


	***** T20's

//Overall

//Batters

//Bowlers

//All-Rounders

//Keepers

//Tournaments

	* Men's T20 World Cup

	* World Cup

	* Tournament Finals

*in India

//Leadership
	* Captain

	* Not Captain
	
//Player type
	* Bowlers

	* Batters

	* Wicket-Keepers

	* All-Rounders

//Teams



//Sold vs Unsold
	* Sold Players

	* Unsold Players

* By bowler type

* By nationality

* By Year

	//1998
	
	//1999
	
	//2000
	
	//2001

	//2002

	//2003
	
	//2004

	//2005

	//2006

	//2007

	//2008

	//2009

	//2010
	
	//2011

	//2012

	//2013

	//2014

	//2015

	//2016

	//2017

	//2018

	//2019

	//2020

	//2021


	//2022

	//2023

	//2024

