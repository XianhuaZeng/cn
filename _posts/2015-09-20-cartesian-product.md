---
layout: post
title: SAS中产生笛卡尔积的几种方法
date: 2015-09-20 19:02
author: 曾宪华
comments: true
tags: [Cartesian Product, Hash Object, PROC SQL, 笛卡尔积]
categories: [程序人生]
---
<p>在平时写程序的时候，有时候我们在LOG中会看到类似下图的提示，而实际上<span style="text-decoration: none;"><a href="https://zh.wikipedia.org/zh/%E7%AC%9B%E5%8D%A1%E5%84%BF%E7%A7%AF" target="_blank">笛卡尔积</a></span>可能又的确是我们所要的结果。下面介绍几种产生笛卡尔积的方法。</p>
<p><a href="http://www.xianhuazeng.com/cn/images/2015/09/Cartesian1.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2015/09/Cartesian1.jpg" alt="Cartesian1" /></a></p>
<p>设有两个数据集如下，假设我们要的结果是A &lt;= ID &lt;= C：</p>
<p><a href="http://www.xianhuazeng.com/cn/images/2015/09/Cartesian2.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2015/09/Cartesian2.jpg" alt="Cartesian2" /></a></p>
<ol>
<ol>
	<li><span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/sqlproc/63043/HTML/default/viewer.htm#titlepage.htm" target="_blank">PROC SQL</a></span>：
<pre><code>proc sql;
    create table want as
        select a.*, b.*
        from demo1 a, demo2 b
        where A &lt;= ID &lt;= B
        ;
quit;
</code></pre>
</li>
	<li>DATA步：
<pre><code>data want;
    set demo1;
    do i=1 to n;
        set demo2 point=i nobs=n;
        if A &lt;= ID &lt;= B then output;
    end;
run;
</code></pre>
</li>
	<li><a href="http://support.sas.com/documentation/cdl/en/lrcon/65287/HTML/default/viewer.htm#n1b4cbtmb049xtn1vh9x4waiioz4.htm" target="_blank"><span style="text-decoration: none;">HASH</span></a>：
<pre><code>data want;
    if _n_=1 then do;
        if 0 then set demo2;
        dcl hash h(dataset:'demo2');
        dcl hiter hit('h');
        h.definekey('C');
        h.definedata('A', 'B', 'C');
        h.definedone();
    end;
    set demo1;
    do while(hit.next()=0);
        if A &lt;= ID &lt;= B then output;
    end;
run;
</code></pre>
</li>
</ol>
</ol>
<p>通过RUN程序我们可以发现后面两种方法在LOG中不会有产生笛卡尔积的提示，故当LOG有要求检查关键字'Cartesian Product'的时候可以使用后面两种方法。</p>