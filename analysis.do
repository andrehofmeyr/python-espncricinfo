*notes: not using bowl_style_cat
clear all 

cap log close

log using "python-espncricinfo_final (1).log", append

use analysis.dta, clear

misstable summarize
drop if missing(auction_year)

tab name if missing(runs)

drop grouping1-ave_diff1 grouping7-ave_diff7 grouping8-ave_diff13

save analysis.dta, replace

*** PRECEEDING YEAR's PERFORMANCE ***

* Model 1 Simple logit of sold
logit sold c.matches c.runs c.bat_avg c.wickets c.bowl_avg
margins, dydx(*) post

outreg2 using panel_logit.doc, replace label ctitle(Model 1: Simple Logit)

* Model 2 Logit of sold with more covariates
logit sold c.matches c.bat_avg c.bowl_avg i.nat_cat c.runs##i.type_cat c.wickets##i.type_cat 



//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat

margins, dydx(*) post
outreg2 using panel_logit.doc, append label ctitle(Model 2: Logit with More Covariates)

* Model 3 Simple regression of log_saleprice
reg log_saleprice c.matches c.runs c.bat_avg c.wickets c.bowl_avg 
outreg2 using panel_reg.doc, replace label ctitle(Model 3: Simple OLS)

* Model 4 Regression of log_saleprice with more covariates
reg log_saleprice c.matches c.bat_avg c.bowl_avg c.age##c.age  i.nat_cat log_ig_followers c.runs##i.type_cat c.wickets##i.type_cat


//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


//Visualising Margins

margins type_cat, at(runs=(0(400)2000))
marginsplot, x(runs) recast(line) noci saving(model4_runstype, replace)

margins type_cat, at(wickets=(0(10)70))
marginsplot, x(wickets) recast(line) noci saving(model4_wktstype, replace)


outreg2 using panel_reg.doc, append label ctitle(Model 4: OLS with More Covariates)




* Model 5 and 6 Panel regression (RE)

xtlogit sold c.matches c.runs c.bat_avg c.wickets c.bowl_avg, re
margins, dydx(*) post
outreg2 using panel_logit.doc, append label ctitle(Model 5: Simple Logit Panel Random Effects)


xtlogit sold c.matches c.bat_avg c.bowl_avg  i.nat_cat c.runs##i.type_cat c.wickets##i.type_cat , re

//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


margins, dydx(*) post
outreg2 using panel_logit.doc, append label ctitle(Model 6: Logit Panel Random Effects)


*Model 7 and Model 8

xtreg log_saleprice c.matches c.runs c.bat_avg c.wickets c.bowl_avg, re
outreg2 using panel_reg.doc, append label ctitle(Model 7: Simple OLS Panel Random Effects)

xtreg log_saleprice c.matches c.bat_avg c.bowl_avg c.age##c.age i.nat_cat log_ig_followers c.runs##i.type_cat c.wickets##i.type_cat, re

//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


margins type_cat, at(runs=(0(400)2000))
marginsplot, x(runs) recast(line) noci saving(model8_runstype, replace)

margins type_cat, at(wickets=(0(10)70))
marginsplot, x(wickets) recast(line) noci saving(model8_wktstype, replace)

outreg2 using panel_reg.doc, append label ctitle(Model 8: OLS Panel Random Effects)



*** CROSS FORMAT PERFORMANCE *** 

///////T20


* Model 9 Simple logit of sold
logit sold c.matches5 c.runs5 c.bat_ave5 c.wkts5 c.bowl_ave5
margins, dydx(*)
outreg2 using format_logit.doc, replace label ctitle(Model 9: T20 Model 1)

//batting average and wickets significant


* Model 10 Logit of sold with more covariates
logit sold c.matches5 c.bat_ave5 c.bowl_ave5  c.age##c.age i.nat_cat log_ig_followers c.runs5##i.type_cat c.wkts5##i.type_cat 

//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(Model 10: T20 Model 2)

//wickets, batting average significant as well as nationality


* Model 11 Simple regression of log_saleprice
reg log_saleprice c.matches5 c.runs5 c.bat_ave5 c.wkts5 c.bowl_ave5 
outreg2 using format_reg.doc, replace label ctitle(Model 11: T20 Model 1)

//batting average significant


* Model 12 Regression of log_saleprice with more covariates
reg log_saleprice c.matches5 c.bat_ave5 c.bowl_ave5  c.age##c.age i.nat_cat log_ig_followers c.runs5##i.type_cat c.wkts5##i.type_cat 

//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


outreg2 using format_reg.doc, append label ctitle(Model 12: T20 Model 2)

//only nationality significant






//////ODIs


*Model 13 Simple logit of sold
logit sold c.matches2 c.runs2 c.bat_ave2 c.wkts2 c.bowl_ave2
margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(Model 13: ODI Model 1)

//batting average and wickets significant


* Model 14 Logit of sold with more covariates
logit sold c.matches2 c.bat_ave2 c.bowl_ave2  c.age##c.age i.nat_cat log_ig_followers c.runs2##i.type_cat c.wkts2##i.type_cat

//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(Model 14: ODI Model 2)
//wickets, batting average significant as well as nationality and LH spin



*Model 15 Simple regression of log_saleprice
reg log_saleprice c.matches2 c.runs2 c.bat_ave2 c.wkts2 c.bowl_ave2 
outreg2 using format_reg.doc, append label ctitle(Model 15: ODI Model 1)
//batting average significant


*Model 16 Regression of log_saleprice with more covariates
reg log_saleprice c.matches2 c.bat_ave2 c.bowl_ave2  c.age##c.age i.nat_cat log_ig_followers c.runs2##i.type_cat c.wkts2##i.type_cat

//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat



outreg2 using format_reg.doc, append label ctitle(Model 16: ODI Model 2)
//only nationality significant


estat summarize

margins nat_cat




//////Test


*Model 17 Simple logit of sold
logit sold c.matches4 c.runs4 c.bat_ave4 c.wkts4 c.bowl_ave4 
margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(Model 17: Test Model 1)

//only wickets significant


*Model 18 Logit of sold with more covariates
logit sold c.matches4 c.bat_ave4 c.bowl_ave4  c.age##c.age i.nat_cat log_ig_followers c.runs4##i.type_cat c.wkts4##i.type_cat


//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(Model 18: Test Model 2)

//age highly significant for the first time. Nationality and LH spin also significant.




* Model 19 Simple regression of log_saleprice
reg log_saleprice c.matches4 c.runs4 c.bat_ave4 c.wkts4 c.bowl_ave4 
outreg2 using format_reg.doc, append label ctitle(Model 19: Test Model 1)
//batting average significant


*Model 20 Regression of log_saleprice with more covariates
reg log_saleprice c.matches4 c.bat_ave4 c.bowl_ave4  c.age##c.age i.nat_cat log_ig_followers c.runs4##i.type_cat c.wkts4##i.type_cat

//Comparing Categorical Variables

margins type_cat
margins nat_cat


//Joint Test

test 2.type_cat 3.type_cat 4.type_cat
test 2.nat_cat 3.nat_cat 4.nat_cat 5.nat_cat 6.nat_cat 7.nat_cat 8.nat_cat 9.nat_cat

//Testing Sets of Coefficients
*Nationality

test 1.nat_cat== 2.nat_cat
test 1.nat_cat== 3.nat_cat
test 1.nat_cat== 4.nat_cat
test 1.nat_cat== 5.nat_cat
test 1.nat_cat== 6.nat_cat
test 1.nat_cat== 7.nat_cat
test 1.nat_cat== 8.nat_cat
test 1.nat_cat== 9.nat_cat

test 2.nat_cat== 3.nat_cat
test 2.nat_cat== 4.nat_cat
test 2.nat_cat== 5.nat_cat
test 2.nat_cat== 6.nat_cat
test 2.nat_cat== 7.nat_cat
test 2.nat_cat== 8.nat_cat
test 2.nat_cat== 9.nat_cat

test 3.nat_cat== 4.nat_cat
test 3.nat_cat== 5.nat_cat
test 3.nat_cat== 6.nat_cat
test 3.nat_cat== 7.nat_cat
test 3.nat_cat== 8.nat_cat
test 3.nat_cat== 9.nat_cat

test 4.nat_cat== 5.nat_cat
test 4.nat_cat== 6.nat_cat
test 4.nat_cat== 7.nat_cat
test 4.nat_cat== 8.nat_cat
test 4.nat_cat== 9.nat_cat

test 5.nat_cat== 6.nat_cat
test 5.nat_cat== 7.nat_cat
test 5.nat_cat== 8.nat_cat
test 5.nat_cat== 9.nat_cat

test 6.nat_cat== 7.nat_cat
test 6.nat_cat== 8.nat_cat
test 6.nat_cat== 9.nat_cat

test 7.nat_cat== 8.nat_cat
test 7.nat_cat== 9.nat_cat

test 8.nat_cat== 9.nat_cat


*Type

test 1.type_cat== 2.type_cat
test 1.type_cat== 3.type_cat
test 1.type_cat== 4.type_cat

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat

test 3.type_cat == 4.type_cat


outreg2 using format_reg.doc, append label ctitle(Model 20: Test Model 2)

//batting_average significant, also other from nationality? 


estat summarize

margins nat_cat

*Other nations don't really play test matches so I imagine this would be why the log_saleprice decreases so substantially. Seems that Afghan players who play test matches are at a premium, but this isn't necessarily massively different to other bigger nations. 



*** OVERALL CAREER PERFORMANCE ***

* Simple logit of sold
logit sold c.matches3 c.runs3 c.bat_ave3 c.wkts3 c.bowl_ave3
margins, dydx(*) post
outreg2 using overall.doc, replace label ctitle(Model 21: Overall Stats Simple Logit)

//batting average and wickets significant


* Logit of sold with more covariates
logit sold c.matches3 c.bat_ave3 c.bowl_ave3  c.age##c.age i.nat_cat log_ig_followers c.runs3##i.type_cat c.wkts3##i.type_cat

margins, dydx(*) post
outreg2 using overall.doc, append label ctitle(Model 22: Overall Stats Complex Logit)

//age, batting average significant as well as nationality and log_ig_followers

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat


* Simple regression of log_saleprice
reg log_saleprice c.matches3 c.runs3 c.bat_ave3 c.wkts3 c.bowl_ave3 
outreg2 using overall.doc, append label ctitle(Model 23: Overall Stats Simple Regression)

//batting average significant


* Regression of log_saleprice with more covariates
reg log_saleprice c.matches3 c.bat_ave3 c.bowl_ave3  c.age##c.age i.nat_cat log_ig_followers c.runs3##i.type_cat c.wkts3##i.type_cat
outreg2 using overall.doc, append label ctitle(Model 24: Overall Stats Complex Regression)


save analysis.dta, replace

