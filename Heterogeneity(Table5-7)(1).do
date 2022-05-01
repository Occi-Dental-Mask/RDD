************
***Table8***
************
use "Firm_Endb_2004_2007_clean.dta",clear
foreach h of numlist 10 15 30 45{
	 rdrobust $y zc if soes==1,h(`h')  //国有企业
	 rdrobust $y zc if soes==0,h(`h')  //非国有企业
}

************
***Table9***
************
use "Firm_Endb_2004_2007_clean.dta",clear
gen labint=L/K
astile labint3=labint,nq(3)
gen labint_group2=(labint3==2)
gen labint_group3=(labint3==3)
gen d_labint_group2=d*labint_group2
gen d_labint_group3=d*labint_group3
foreach num of numlist 10 15 20 30 45{
     replace weights=(1-abs(zc/`num'))
     reghdfe $y zc d zc_d d_labint_group2 d_labint_group3 capt lqrat mang profit soes [aw=weights] if zc>=-`num' & zc<=`num',absorb(i.city i.year i.city#i.year)
}

*************
***Table10***
*************
gen LS=L/Y
gen mkup=est_l/LS
astile mkup3=mkup,nq(3)
gen mkup_group2=(mkup3==2)
gen mkup_group3=(mkup3==3)
gen d_mkup_group2=d*mkup_group2
gen d_mkup_group3=d*mkup_group3
foreach num of numlist 10 15 20 30 45{
     replace weights=(1-abs(zc/`num'))
     reghdfe $y zc d zc_d d_mkup_group2 d_mkup_group3 capt lqrat mang profit soes [aw=weights] if zc>=-`num' & zc<=`num',absorb(i.city i.year i.city#i.year)
}
