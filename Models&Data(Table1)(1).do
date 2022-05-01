use "Firm_Endb_1998_2007.dta",clear
keep if year>=2004 & year<=2007
save Firm_Endb_2004_2007_clean.dta,replace
*去除异常值
drop if perseng<8
drop if si<5000
gen nvfixass=ovofa-depr //固定资产净值
drop if ta<=nvfixass
drop if ta<=twc
drop if ta<=fa //总资产小于固定资产合计
drop if acmde<=depr //累计折旧小于本年折旧
gen asslratio=tl/ta //资产负债率
drop if asslratio<=0
drop asslratio nvfixass
* 变量定义
egen id=group(crc)
gen Y = si
gen K = fa
gen L = cbnw + cwp
gen M = toipt
winsor2 Y K L M, cuts(1 99) replace by(year) //缩尾处理
gen lnY=ln(1+Y)
gen lnL=ln(1+L)
gen lnK=ln(1+K)
gen lnM=ln(1+M)
* 企业年龄
gen Age=year - toc_y + 1
drop if Age<0 | Age>60 //去掉年龄小于0的及部分建国前开业的
* soes表示企业是否为国有企业
gen soes=1 if arcs==1
replace soes = 0 if soes == .
* 行业虚拟变量
gen Ind=substr(indtype, 1, 2)
destring Ind,replace force
* 剔除缺失值
foreach i in lnY lnL lnK Age soes {
     drop if `i'==.
} 
*分行业ACF法估计beta_l
xtset id year
save Firm_Endb_2004_2007_clean.dta,replace
capture program drop one_reg
program define one_reg
prodest lnY, method(op) free(lnL) proxy(lnM) state(lnK Age) valueadded acf optimizer(nm) id(id) t(year) reps(5)
gen est_l=_b[lnL]
end
runby one_reg,by(Ind)
*计算MPL
gen MPL=est_l*Y/L
************
***Table1***
************
gen B=(cbnw+cwp)/perseng
gen ln_d_mpl_b=ln(abs(MPL-B))
gen capt=ln(ta) //总资产对数
gen lqrat=cl/tl //流动负债比
gen mang=oiime/perseng //人均管理费用
replace pos=si-sc-tnsos //数据库中销售利润缺失，用销售收入-销售成本-销售税金及附加
gen profit=pos/giov_cr //单位产值利润
logout,save(描述性统计)word replace:tabstat MPL B  ln_d_mpl_b capt lqrat mang profit soes Age,s(mean p50 sd min max) f(%12.3f) c(s)
save Firm_Endb_2004_2007_clean.dta,replace
