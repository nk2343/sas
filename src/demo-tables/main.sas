libname demo 'C:\sasdata\demo-tables';

data demo_trt;
merge demo.dose(in=a) demo.demog(in=b);
by PATIENT;
if a and b;
run;

data demo_trt;
set demo_trt;
output;
drugsort=3; output;
run;

proc freq data=demo_trt noprint;
tables drugsort*sex /out=dem_sex(drop=percent);
run;

data demo_alltrt;
set demo.dose;
output;
drugsort=3; output;
run;

proc freq data=demo_alltrt noprint;
tables drugsort /out=dem_trt(drop=percent);
run;

data dem_pct;
merge dem_sex dem_trt(rename=(count=tot));
by drugsort;
pct=round(count/tot,.1);
cntpct=cat(strip(put(count,best.)),'(',strip(put(pct,best.)),')');
run;

proc sort data=dem_pct;
by sex;
run;

proc transpose data=dem_pct out=dem_pct_t prefix=trt;
by sex;
id drugsort;
var cntpct;
run;
/******************************************************agecat*************************/
data demo_trt;
set demo_trt;
if (age < 41)and (age>18) then agecat='18-40';
else if (age <65)and (age>=41) then agecat='41-64';
else if  (age>=65) then agecat='>=65';
RUN;

proc freq data=demo_trt noprint;
tables drugsort*agecat /out=dem_agecat(drop=percent);
run;

data demo_alltrt;
set demo.dose;
output;
drugsort=3; output;
run;

proc freq data=demo_alltrt noprint;
tables drugsort /out=dem_trt(drop=percent);
run;

data dem_pct;
merge dem_agecat dem_trt(rename=(count=tot));
by drugsort;
pct=round(count/tot,.1);
cntpct=cat(strip(put(count,best.)),'(',strip(put(pct,best.)),')');
run;

proc sort data=dem_pct;
by agecat;
run;

proc transpose data=dem_pct out=dem_pct_t1 prefix=trt;
by agecat;
id drugsort;
var cntpct;
run;
/***************************************************race*****/
data demo_trt;
merge demo.dose(in=a) demo.demog(in=b);
by PATIENT;
if a and b;
run;

data demo_trt;
set demo_trt;
output;
drugsort=3; output;
run;

proc freq data=demo_trt noprint;
tables drugsort*race /out=dem_race(drop=percent);
run;

data demo_alltrt;
set demo.dose;
output;
drugsort=3; output;
run;

proc freq data=demo_alltrt noprint;
tables drugsort /out=dem_trt(drop=percent);
run;

data dem_pct;
merge dem_race dem_trt(rename=(count=tot));
by drugsort;
pct=round(count/tot,.1);
cntpct=cat(strip(put(count,best.)),'(',strip(put(pct,best.)),')');
run;

proc sort data=dem_pct;
by race;
run;

proc transpose data=dem_pct out=dem_pct_t_race prefix=trt;
by race;
id drugsort;
var cntpct;
run;
/*****************************************************************************************/
%macro sumstat(var);

proc sort data=demo_trt; by drugsort; run;

proc means data=demo_trt noprint;

by drugsort;

var &var;

output out=&var._sumstat n=n_ mean=mean_ std=std_ min=min_ max=max_;

run;

 
data &var._trt;
set &var._sumstat;
n=strip(put(n_,best.));

minmax=cat(strip(put(min_,best.)),',',strip(put(max_,best.)));

std=strip(put(round(std_,.01),best.));

mean=strip(put(round(mean_,.1),best.));

run;

 

proc transpose data=&var._trt out=&var._t prefix=trt;

id drugsort;

var n std minmax mean;

run;

data &var._t;

set &var._t;

length cat $30;

if _name_='n' then do; cat='N'; catn=1; end;

else if _name_='std' then do; cat='S.D.'; catn=3; end;

else if _name_='mean' then do; cat='Mean'; catn=2; end;

else if _name_='minmax' then do; cat='Range(Min,Max)'; catn=4; end;

keep cat catn trt1-trt3;

run;


proc sql noprint;

create table &var._all as

select cat,catn,trt1,trt2,trt3

from &var._t

order catn;

quit;

//%mend sumstat;

%sumstat(var=age);
%sumstat(var=htcm);
%sumstat(var=wtkg);

