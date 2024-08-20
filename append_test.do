/* [> Import each of the three test CSV files <] */
clear all

* 5334
import delimited using "5334_allround_career_summary.csv", varnames(1) stringcols(_all)

tempfile 1
qui save `1'

* 5961
clear
import delimited using "5961_allround_career_summary.csv", varnames(1) stringcols(_all)

tempfile 2
qui save `2'

* 6883
clear
import delimited using "6683_allround_career_summary.csv", varnames(1) stringcols(_all)

tempfile 3
qui save `3'

append using `1'
append using `2'

/* [> All appears to be working correctly: the issue was that varnames(11) was
used as opposed to varnames(1) <] */
