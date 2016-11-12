---
layout: post
title: 创建SAS Format的几种方法
date: 2015-05-08 21:37
author: 曾宪华
comments: true
tags: [CALL EXECUTE, FILENAME, PROC FORMAT]
categories: [程序人生]
---
<p>不管是做AD还是TFL，我们经常会碰到要创建Format。当Format中条目不多时我们可以直接用PROC FORMAT来创建，但是当条目很多时，这种方法就不方便了。下面详细介绍其他几种方法：</p>
<p>设有数据集如下，假设要创建START为AVISITN，LABEL为AVISIT的Format：</p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Format.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Format.jpg" alt="Format" /></a></p>
<ol>
	<li>通过<a href="http://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#n1q1527d51eivsn1ob5hnz0yd1hx.htm" target="_blank"><span style="text-decoration: none;">CALL EXECUTE</span></a>创建。
<pre><code>/*方法1: CALL EXECUTE*/
data _null_;
    set demo end=eof;
    if _n_=1 then call execute('proc format; value vs1t');
    call execute(cats(AVISITN)||' = '||quote(cats(AVISIT)));
    if eof then call execute('; run;');
run;
</code></pre>
</li>
	<li>通过宏变量创建。

<pre><code>/*方法2: macro variable*/
proc sql noprint;
    select catx(' = ', cats(AVISITN), quote(cats(AVISIT))) into :fmtlst separated by ' '
        from demo
        order by AVISITN;
quit;

proc format;
    value vs2t
    &amp;fmtlst;
run;
</code></pre>
</li>
	<li>通过<a href="http://support.sas.com/documentation/cdl/en/proc/65145/HTML/default/viewer.htm#n1e19y6lrektafn1kj6nbvhus59w.htm" target="_blank"><span style="text-decoration: none;">CNTLIN=</span></a>选项创建。

<pre><code>/*方法3: CNTLIN= option*/
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
</code></pre>
</li>
	<li>通过<a href="https://support.sas.com/documentation/cdl/en/lestmtsref/63323/HTML/default/p05r9vhhqbhfzun1qo9mw64s4700.htm" target="_blank"><span style="text-decoration: none;">FILENAME</span></a>创建。

<pre><code>/*方法4: FILENAME*/
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
</code></pre>
</li>
</ol>
