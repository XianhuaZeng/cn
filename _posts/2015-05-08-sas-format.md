---
layout: post
title: 创建SAS Format的几种方法
tags: [CALL EXECUTE, PROC FORMAT]
categories: [程序人生]
---
<p>      不管是做AD还是TFL，我们经常会碰到要创建Format。当Format中条目不多时我们可以直接用PROC FORMAT来创建，但是当条目很多时，这种方法就不方便了。下面详细介绍其他几种方法：</p><p>      设有数据集如下，假设要创建START为AVISITN，LABEL为AVISIT的Format：</p><p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/06/Format.png"><img class="aligncenter size-full wp-image-136" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/06/Format.png" alt="Format" /></a></p><ol><li>通过CALL EXECUTE创建。<pre lang="SAS">/*方法1: CALL EXECUTE*/
data _null_;
    set demo end=eof;
    if _n_=1 then call execute('proc format; value vs1t');
    call execute(cats(AVISITN)||' = '||quote(cats(AVISIT)));
    if eof then call execute('; run;');
run;
</pre></li><li>通过宏变量创建。<pre lang="SAS">/*方法2: macro variable*/
proc sql noprint;
    select catx(' = ', cats(AVISITN), quote(cats(AVISIT))) into :fmtlst separated by ' '
        from demo
        order by AVISITN;
quit;

proc format;
    value vs2t
    &amp;fmtlst;
run;
</pre></li><li>通过CNTLIN=选项创建。<pre lang="SAS">/*方法3: CNTLIN= option*/
proc sql;
    create table fmt as
        select distinct 'vs3t' as FMTNAME
             , AVISITN as START
             , cats(AVISIT) as label
        from demo
        order by AVISITN
        ;
quit;

proc format library=work cntlin=fmt;
run;
</pre></li><li>通过FILENAME创建。<pre lang="SAS">/*方法4: FILENAME*/
proc sql;
    create table fmt as
        select distinct AVISITN
             , quote(cats(AVISIT)) as AVISIT
        from demo
        order by AVISITN
        ;
quit;

/*将CODE输出到一个临时文件*/
filename code temp;
data _null_;
    file code;
    set fmt;
    if _n_=1 then put +4 'value vs4t';
    put +14 AVISITN ' = ' AVISIT;
run;

proc format;
    %inc code / source2;
    ;
run;
</pre></li></ol>