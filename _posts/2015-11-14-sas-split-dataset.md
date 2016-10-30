---
layout: post
title: 根据变量值拆分SAS数据集
date: 2015-11-14 16:02
author: Xianhua.Zeng
comments: true
tags: [CALL EXECUTE, FILENAME, Hash Object]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/11/Splitting.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/11/Splitting.jpg" alt="Splitting" /></a></p><p>前几天看到一个群友（QQ群：<span style="text-decoration: underline;"><a href="http://www.xianhuazeng.com/cnwp-content/uploads/2015/09/QQ.png" target="_blank">144839730</a></span>）提的一个问题，根据数据集中的某一个变量的值将一人大数据集拆分为多个小数据集（见上图第15题），实现这一目的的方法有多种，最常见的方法应该是宏循环，下面以根据变量SEX来拆分数据集SASHELP.CLASS为例介绍其他几种方法：<!--more--></p><ol><li><span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/mcrolref/61885/HTML/default/viewer.htm#a000543697.htm" target="_blank">CALL EXECUTE</a></span>，程序如下：<pre><code>proc sql;
    create table sex as
        select distinct SEX 
    	from sashelp.class
        ;
quit;

data _null_;
    set sex;
    call execute('data sex_'||cats(SEX)||'(where=(SEX='||quote(cats(SEX))||')); set sashelp.class; run;');
run;
</code></pre></li><li><span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a000211297.htm" target="_blank">FILENAME</a></span>，程序如下：<pre><code>proc sql;
    create table sex as
        select distinct SEX 
    	from sashelp.class
        ;
quit;

filename code temp;
data _null_;
    file code;
    set sex;
    put ' sex_' SEX '(where=(SEX="' SEX '"))' @@;
run;

data %inc code;;
    set sashelp.class;
run;
</code></pre></li><li><a href="http://support.sas.com/documentation/cdl/en/lrcon/65287/HTML/default/viewer.htm#n1b4cbtmb049xtn1vh9x4waiioz4.htm" target="_blank"><span style="text-decoration: underline;">HASH</span></a>，程序（SAS9.2+）如下：<pre><code>proc sort data=sashelp.class out=class;
	by SEX;
run;

data _null_;
    dcl hash h(multidata:'y');
    h.definekey('SEX');
    h.definedone();
    do until(last.SEX);
        set class;
        by SEX;
        h.add();
    end;
    h.output(dataset:cats('sex_', SEX));
run;
</code></pre></li></ol><p>上面几种方法中第一种方法程序行数最少，第二种方法行数最多，但是我们可以看到第一、第三种方法有多次SET的操作，所以当要拆分的数据集较大时建议用第二种方法以提高效率。</p>