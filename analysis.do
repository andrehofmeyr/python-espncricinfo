*notes: not using bowl_style_cat
clear all 

cap log close

cd player_data

log using "python-espncricinfo_final (1).log", append


use analysis.dta, clear

misstable summarize
drop if missing(auction_year)

tab name if missing(runs)
save analysis.dta, replace

*** PRECEEDING YEAR's PERFORMANCE ***

* Simple logit of sold
logit sold c.matches c.runs c.bat_avg c.wickets c.bowl_avg
margins, dydx(*) post

outreg2 using panel_logit.doc, replace label ctitle(Logit Model 1)

* Logit of sold with more covariates
logit sold c.matches c.runs c.bat_avg c.wickets c.bowl_avg i.type_cat i.nat_cat 
margins, dydx(*) post

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat

outreg2 using panel_logit.doc, append label ctitle(Logit Model 2)

* Simple regression of log_saleprice
reg log_saleprice c.matches c.runs c.bat_avg c.wickets c.bowl_avg 
outreg2 using panel_reg.doc, replace label ctitle(Regression Model 1)

* Regression of log_saleprice with more covariates
reg log_saleprice c.matches c.runs c.bat_avg c.wickets c.bowl_avg c.age##c.age  i.rhb i.type_cat i.nat_cat log_ig_followers
vif
outreg2 using panel_reg.doc, append label ctitle(Regression Model 2)

estat summarize

margins nat_cat


* Panel regression (RE)

xtlogit sold c.matches c.runs c.bat_avg c.wickets c.bowl_avg i.type_cat i.nat_cat, re
outreg2 using panel_logit.doc, append label ctitle(Panel Random Effects)


xtreg log_saleprice c.matches c.runs c.bat_avg c.wickets c.bowl_avg c.age##c.age  log_ig_followers, re

outreg2 using panel_reg.doc, append label ctitle(Panel Random Effects)

xtsum
xtdescribe



*** CROSS FORMAT PERFORMANCE *** 

///////T20


* Simple logit of sold
logit sold c.matches5 c.runs5 c.bat_ave5 c.wkts5 c.bowl_ave5
margins, dydx(*)
outreg2 using format_logit.doc, replace label ctitle(T20 Model 1)

//batting average and wickets significant


* Logit of sold with more covariates
logit sold c.matches5 c.runs5 c.bat_ave5 c.wkts5 c.bowl_ave5  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers

margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(T20 Model 2)

//wickets, batting average significant as well as nationality

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat


* Simple regression of log_saleprice
reg log_saleprice c.matches5 c.runs5 c.bat_ave5 c.wkts5 c.bowl_ave5 
outreg2 using format_reg.doc, replace label ctitle(T20 Model 1)

//batting average significant


* Regression of log_saleprice with more covariates
reg log_saleprice c.matches5 c.runs5 c.bat_ave5 c.wkts5 c.bowl_ave5  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers
outreg2 using format_reg.doc, append label ctitle(T20 Model 2)

//only nationality significant


estat summarize

margins nat_cat






//////ODIs


* Simple logit of sold
logit sold c.matches2 c.runs2 c.bat_ave2 c.wkts2 c.bowl_ave2
margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(ODI Model 1)

//batting average and wickets significant


* Logit of sold with more covariates
logit sold c.matches2 c.runs2 c.bat_ave2 c.wkts2 c.bowl_ave2  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers

margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(ODI Model 2)
//wickets, batting average significant as well as nationality and LH spin

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat

** need to perform tests like this for all categoricals that are not binary


* Simple regression of log_saleprice
reg log_saleprice c.matches2 c.runs2 c.bat_ave2 c.wkts2 c.bowl_ave2 
outreg2 using format_reg.doc, append label ctitle(ODI Model 1)
//batting average significant


* Regression of log_saleprice with more covariates
reg log_saleprice c.matches2 c.runs2 c.bat_ave2 c.wkts2 c.bowl_ave2  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers
outreg2 using format_reg.doc, append label ctitle(ODI Model 2)
//only nationality significant


estat summarize

margins nat_cat




//////Test


* Simple logit of sold
logit sold c.matches4 c.runs4 c.bat_ave4 c.wkts4 c.bowl_ave4
margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(Test Model 1)

//only wickets significant


* Logit of sold with more covariates
logit sold c.matches4 c.runs4 c.bat_ave4 c.wkts4 c.bowl_ave4  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers

margins, dydx(*) post
outreg2 using format_logit.doc, append label ctitle(Test Model 2)

//age highly significant for the first time. Nationality and LH spin also significant.

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat


* Simple regression of log_saleprice
reg log_saleprice c.matches4 c.runs4 c.bat_ave4 c.wkts4 c.bowl_ave4 
outreg2 using format_reg.doc, append label ctitle(Test Model 1)
//batting average significant


* Regression of log_saleprice with more covariates
reg log_saleprice c.matches4 c.runs4 c.bat_ave4 c.wkts4 c.bowl_ave4  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers
outreg2 using format_reg.doc, append label ctitle(Test Model 2)

//batting_average significant, also other from nationality? 


estat summarize

margins nat_cat

*Other nations don't really play test matches so I imagine this would be why the log_saleprice decreases so substantially. Seems that Afghan players who play test matches are at a premium, but this isn't necessarily massively different to other bigger nations. 

*** T20 World Cup Performance ***


* Simple logit of sold
logit sold c.matches1 c.runs1 c.bat_ave1 c.wkts1 c.bowl_ave1
margins, dydx(*) post 
outreg2 using worldcup_logit.doc, replace label ctitle(T20 World Cup Model 1)

//batting average significant


* Logit of sold with more covariates
logit sold c.matches1 c.runs1 c.bat_ave1 c.wkts1 c.bowl_ave1  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers

margins, dydx(*) post
outreg2 using worldcup_logit.doc, append label ctitle(T20 World Cup Model 2)

//wickets, age batting average significant as well as nationality and log_ig_followers

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat


* Simple regression of log_saleprice
reg log_saleprice c.matches1 c.runs1 c.bat_ave1 c.wkts1 c.bowl_ave1 
outreg2 using worldcup_reg.doc, replace label ctitle(T20 World Cup Model 1)

//nothing


* Regression of log_saleprice with more covariates
reg log_saleprice c.matches1 c.runs1 c.bat_ave1 c.wkts1 c.bowl_ave1  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers
outreg2 using worldcup_reg.doc, append label ctitle(T20 World Cup Model 2)
//only nationality significant


estat summarize

margins nat_cat


*** 50 Over World Cup Performance ***

* Simple logit of sold
logit sold c.matches6 c.runs6 c.bat_ave6 c.wkts6 c.bowl_ave6
margins, dydx(*) post
outreg2 using worldcup_logit.doc, replace label ctitle(ODI World Cup Model 1)

//wickets significant


* Logit of sold with more covariates
logit sold c.matches6 c.runs6 c.bat_ave6 c.wkts6 c.bowl_ave6  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers

margins, dydx(*) post
outreg2 using worldcup_logit.doc, append label ctitle(ODI World Cup Model 2)

//wickets, age, batting average significant as well as nationality and log_ig_followers

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat


* Simple regression of log_saleprice
reg log_saleprice c.matches6 c.runs6 c.bat_ave6 c.wkts6 c.bowl_ave6 
outreg2 using worldcup_reg.doc, replace label ctitle(ODI World Cup Model 1)

//nothing


* Regression of log_saleprice with more covariates
reg log_saleprice c.matches6 c.runs6 c.bat_ave6 c.wkts6 c.bowl_ave6  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers
outreg2 using worldcup_reg.doc, append label ctitle(ODI World Cup Model 2)

//only nationality significant


*** OVERALL CAREER PERFORMANCE ***

* Simple logit of sold
logit sold c.matches3 c.runs3 c.bat_ave3 c.wkts3 c.bowl_ave3
margins, dydx(*) post
outreg2 using overall.doc, replace label ctitle(Overall Stats Simple Logit)

//batting average and wickets significant


* Logit of sold with more covariates
logit sold c.matches3 c.runs3 c.bat_ave3 c.wkts3 c.bowl_ave3  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers

margins, dydx(*) post
outreg2 using overall.doc, append label ctitle(Overall Stats Complex Logit)

//age, batting average significant as well as nationality and log_ig_followers

test 2.type_cat == 3.type_cat
test 2.type_cat == 4.type_cat
test 3.type_cat == 4.type_cat


* Simple regression of log_saleprice
reg log_saleprice c.matches3 c.runs3 c.bat_ave3 c.wkts3 c.bowl_ave3 
outreg2 using overall.doc, append label ctitle(Overall Stats Simple Regression)

//batting average significant


* Regression of log_saleprice with more covariates
reg log_saleprice c.matches3 c.runs3 c.bat_ave3 c.wkts3 c.bowl_ave3  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers
outreg2 using overall.doc, append label ctitle(Overall Stats Complex Regression)

////HURDLES

* Simple Hurdle
churdle linear log_saleprice = c.bat_avg c.wickets i.type_cat i.nat_cat, select(sold = c.bat_avg c.wickets i.type_cat i.nat_cat) ll(0) 
estimates store hurdle

margins, dydx(*) predict(pr(0,.)) post
outreg using 

* Hurdle with More Covariates

churdle linear log_saleprice c.runs c.bat_avg c.wickets c.bowl_avg  c.age##c.age i.rhb i.type_cat i.nat_cat log_ig_followers, select(c.matches c.runs c.bat_avg c.wickets c.bowl_avg i.type_cat i.nat_cat log_ig_followers) ll(0)

*churdle linear log_saleprice2021 matches bat_ave hundreds log_ig_followers2021 i.rhb i.nat_cat i.team_cat2021 if type_cat == 1, select(matches bat_ave hundreds log_ig_followers2021 i.rhb i.nat_cat) ll(0)



//only nationality significant

save analysis.dta, replace

