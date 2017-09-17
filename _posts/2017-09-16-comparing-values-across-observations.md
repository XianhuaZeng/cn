---
layout: post
title: SAS数据集中一行与多行的比较
date: 2017-09-16 10:02
author: 曾宪华
comments: no
tags: [SET, Hash Object]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2017/09/Compare.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2017/09/Compare.jpg" alt="Compare" /></a></p>
<p>前几天看到一个群友（QQ群：<span style="text-decoration: none;"><a href="http://www.xianhuazeng.com/cnwp-content/uploads/2015/09/QQ.jpg" target="_blank">144839730</a></span>）提的一个问题：求上图中X小于等于所有Y值的个数。比如，第一个Y为0，则5个X中小于等于0的个数为0。实现这一目的的方法有多种，最易懂的方法应该是转置加数组，下面介绍其他两种方法：</p>
<ol><li>双SET：<pre><code>data have;
    input ID X Y;
cards;
1 1000 0
2 2000 0
3 3000 3000
4 4000 3500
5 5000 4000
;

data want;
    set have nobs=totobs;
    NUM=0;
    do i = 1 to totobs;
        set have(keep=X rename=X=X_) point=i;
        if X_ <= Y then NUM=NUM+1; 
    end ;
    drop X_;
    output;
run;
</code></pre></li>
<li><a href="http://support.sas.com/documentation/cdl/en/lrcon/65287/HTML/default/viewer.htm#n1b4cbtmb049xtn1vh9x4waiioz4.htm" target="_blank"><span style="text-decoration: none;">HASH</span></a>，程序（SAS9.2+）如下：<pre><code>data have;
    set have;
    BYVAR=1;
run;

data want;
    if _n_=1 then do;
        dcl hash h(dataset:'have(keep=BYVAR X rename=X=X_)', multidata: 'y');
        h.definekey('BYVAR');
        h.definedata(all:'y');
        h.definedone();
        call missing(X_);
    end;
    set have;
    NUM=0;
    rc=h.find();
    do while(rc=0);
        if X_ <= Y then NUM=NUM+1; 
        rc=h.find_next();
    end;
    drop BYVAR X_ RC;
run;
</code></pre></li></ol>
<p>上面第一种方法程序行数少，但是有多次SET的操作，所以当数据集较大时建议用第二种方法以提高效率。</p>