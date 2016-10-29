---
layout: post
title: SAS中产生笛卡尔积的几种方法
tags: [Cartesian Product, Hash Object, PROC SQL, 笛卡尔积]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/Cartesian.png"><img class="aligncenter size-full wp-image-474" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/Cartesian.png" alt="Cartesian" /></a></p><p>      在平时写程序的时候，有时候我们在LOG中会看到类似下图的提示，而实际上<span style="text-decoration: underline;"><a href="https://zh.wikipedia.org/zh/%E7%AC%9B%E5%8D%A1%E5%84%BF%E7%A7%AF" target="_blank">笛卡尔积</a></span>可能又的确是我们所要的结果。下面介绍几种产生笛卡尔积的方法。</p><p><img class="aligncenter size-full wp-image-464" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/Cartesian1.png" alt="Cartesian1" /></p><p>      设有两个数据集如下，假设我们要的结果是A &lt;= ID &lt;= C：</p><p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/Cartesian2.png"><img class="aligncenter size-full wp-image-463" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/Cartesian2.png" alt="Cartesian2" /></a></p><ol><ol><li><span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/sqlproc/63043/HTML/default/viewer.htm#titlepage.htm" target="_blank">PROC SQL</a></span>：<pre lang="SAS">proc sql;
    create table want as
        select a.*, b.*
        from demo1 a, demo2 b
        where A &lt;= ID &lt;= B
        ;
quit;
</pre></li><li>DATA步：<pre lang="SAS">data want;
    set demo1;
    do i=1 to n;
        set demo2 point=i nobs=n;
        if A &lt;= ID &lt;= B then output;
    end;
run;
</pre></li><li><a href="http://support.sas.com/documentation/cdl/en/lrcon/65287/HTML/default/viewer.htm#n1b4cbtmb049xtn1vh9x4waiioz4.htm" target="_blank"><span style="text-decoration: underline;">HASH</span></a>：<pre lang="SAS">data want;
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
</pre></li></ol></ol><p>      通过RUN程序我们可以发现后面两种方法在LOG中不会有产生笛卡尔积的提示，故当LOG有要求检查关键字'Cartesian Product'的时候可以使用后面两种方法。</p>
