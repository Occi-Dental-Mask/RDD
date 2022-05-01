use "Firm_Endb_2004_2007_clean.dta",clear
global y ln_d_mpl_b //结果变量名字太长了
gen zc=(toc_y-2004)*12+toc_m-3 //驱动变量
gen d=(zc>=0) //处理变量
gen zc_d=zc*d
save Firm_Endb_2004_2007_clean.dta,replace

*************
***Figure1***
*************
set seed 135
sample 20
rdplot $y zc if zc>=-45,c(0) p(1) graph_options(title(线性拟合)) //20%样本线性拟合图
graph save rd1,replace
use "Firm_Endb_2004_2007_clean.dta",clear
set seed 100
sample 20
rdplot $y zc if zc>=-45,c(0) p(2) lowwerend(-45) upperend(45) graph_options(title(二次型拟合)) //20%样本二次型拟合图
graph save rd2,replace
use "Firm_Endb_2004_2007_clean.dta",clear
set seed 250
sample 20
rdplot $y zc if zc>=-45,c(0) p(3) lowwerend(-45) upperend(45) graph_options(title(三次型拟合)) //20%样本三次型拟合图
graph save rd3,replace
graph combine rd1.gph rd2.gph rd3.gph

************
***Table2***
************
use "Firm_Endb_2004_2007_clean.dta",clear
drop city
gen city=substr(cpcc, 1, 4)
destring city,replace force
*不同窗宽下应用三角核函数的高维固定效应回归（无法汇报显著性）
gen weights=.
foreach num of numlist 10 15 20 30 45{
     replace weights=(1-abs(zc/`num')) if zc<0 & zc>= -`num'
	 replace weights=(1-abs(zc/`num')) if zc>=0 & zc<`num'
     reghdfe $y zc capt lqrat mang profit soes [aw=weights] if zc<0 & zc>=-`num',absorb(i.city i.year i.city#i.year)
	 matrix coef_left=e(b)
	 local intercept_left=coef_left[1,7]
	 reghdfe $y zc capt lqrat mang profit soes [aw=weights] if zc>=0 & zc<=`num',absorb(i.city i.year i.city#i.year)
	 matrix coef_right=e(b)
	 local intercept_right=coef_right[1,7]
	 local difference=`intercept_right'-`intercept_left'
	 dis "The RD estimator is `difference' while h = `num'." 
}  
*不同窗宽下应用三角核函数的高维固定效应回归（d系数为待估参数，可汇报显著性）
foreach num of numlist 10 15 20 30 45{
     replace weights=(1-abs(zc/`num'))
     reghdfe $y zc d zc_d capt lqrat mang profit soes [aw=weights] if zc>=-`num' & zc<=`num',absorb(i.city i.year i.city#i.year)
} 
*不加入协变量
foreach num of numlist 10 15 20 30 45 {
     rdrobust $y zc,h(`num') p(1)
} 
*加入公司特征协变量
foreach num of numlist 10 15 20 30 45 {
     rdrobust $y zc,h(`num') p(1) covs(capt lqrat mang profit soes)
} 
*f(z,D)为二次设定的估计
foreach num of numlist 10 15 20 30 45 {
     rdrobust $y zc,h(`num') p(2) covs(capt lqrat mang profit soes)
} 

*********************
***Figure2&Figure3***
*********************
use "Firm_Endb_2004_2007_clean.dta",clear
rdplot B zc if zc>=-45,c(0) graph_options(title(边际劳动成本的变化))
graph save rdB,replace
rdplot MPL zc if zc>=-45,c(0) graph_options(title(边际劳动产出（MPL）的变化))
graph save rdMPL,replace
graph combine rdB.gph rdMPL.gph

*********************
***Figure2&Figure3***
*********************
*使用histogram
use "Firm_Endb_2004_2007_clean.dta",clear
#d;
histogram zc if zc>=-45,
   lcolor(blue) fcolor(gs16)
   title("平滑性检验")
   xtitle("zc")
   note("figure4");
#d cr
*使用MacGrary方法
DCdensity zc if zc>=-45,breakpoint(0) b(1) gen(Xj Yj r0 fhat se_fhat) graphname("MacGrary")
*使用rdcont
rdcont zc,threshold(0) qband(5)

************
***Table5***
************
use "Firm_Endb_2004_2007_clean.dta",clear
local vars capt lqrat profit mang soes
foreach var of varlist `vars'{
     replace weights=(1-abs(zc/10))
     reghdfe `var' zc d zc_d capt lqrat mang profit soes [aw=weights] if zc>=-10 & zc<=10,absorb(i.city i.year i.city#i.year)
} 

************
***Table6***
************
use "Firm_Endb_2004_2007_clean.dta",clear
*假设政策时间为2004.2的证伪检验（row1）
foreach h of numlist 4 8 12 16{
	 rdrobust $y zc,c(-1) h(`h')
}
*假设政策时间为2003.12的证伪检验（row2）
foreach h of numlist 4 8 12 16{
	 rdrobust $y zc,c(-3) h(`h')
}
*假设政策时间为2003.9的证伪检验（row3）
foreach h of numlist 4 8 12 16{
	 rdrobust $y zc,c(-6) h(`h')
}
*假设政策时间为2003.6的证伪检验（row4）
foreach h of numlist 4 8 12 16{
	 rdrobust $y zc,c(-9) h(`h')
}





