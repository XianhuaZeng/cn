---
layout: post
title: SAS领先函数功能的实现
date: 2017-10-02 11:57
author: 曾宪华
comments: no
tags: [LAG, LEAD, HASH]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/images/2017/10/lead.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2017/10/lead.jpg" alt="lead" /></a></p>
<p>SAS程序猿/媛都知道SAS有滞后函数<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/lefunctionsref/63354/HTML/default/viewer.htm#n0l66p5oqex1f2n1quuopdvtcjqb.htm" target="_blank">LAG</a></span>。那我们会问有没有与之相反的领先函数呢？答案是否定的。但是，我们有其他的替代方法。最简单的方法就是新建一个排序变量_N_，然后逆向排序，使用LAG函数，再正向排序。方法虽然简单明了，但是要多个PROC+DATA步，而且数据较大时，效率会很低。下面介绍其他两种方法：
<ol><li>双SET：
<pre><code>data demo;
    input X @@;
cards;
1 2 3 4 5 6
;
run;

data lead;
    set demo end=eod;
    LAG=lag(X);
    if not eod then do;
        VAR_TEMP=_N_+1;
        set demo(keep=X rename=X=LEAD) point=VAR_TEMP;
    end;
    else LEAD=.;
    keep X LAG LEAD;
run;
</code></pre></li>
<li><a href="http://support.sas.com/documentation/cdl/en/lrcon/65287/HTML/default/viewer.htm#n1b4cbtmb049xtn1vh9x4waiioz4.htm" target="_blank"><span style="text-decoration: none;">HASH</span></a>：
<pre><code>data lead;
    length X LAG LEAD 8.;
    if _n_=1 then do;
    if 0 then set demo(rename=X=LEAD);
        dcl hash h(dataset: 'demo(rename=X=LEAD)', ordered: 'a') ;
        h.definekey('LEAD');
        h.definedata('LEAD');
        h.definedone();
        dcl hiter hi('h');
    end;
    set demo;
    LAG=lag(X);
    hi.setcur(key: X);
    rc=hi.next();
    if rc^=0 then LEAD=.;
    keep X LAG LEAD;
run;
</code></pre></li></ol>
<p>上面第一种方法程序行数少，但是有两次SET的操作，所以当数据集较大时建议采用第二种方法以提高效率。</p>