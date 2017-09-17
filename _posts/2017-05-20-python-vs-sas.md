---
layout: post
title: Python函数与SAS宏
date: 2017-05-20 22:11
author: 曾宪华
comments: true
tags: [Python, PROC FCMP, 自定义函数]
categories: [程序人生]
---
今天在群里和同事讨论了<span style="text-decoration: none;"><a href="https://www.python.org/" target="_blank">Python</a></span>函数与SAS宏的问题，现记录一下。在Python中函数是组织好的，可以重复使用的代码段。Python提供了许多内建函数，比如print()。用户也可以自己创建函数，即自定义函数。这一点和SAS宏类似。下面以要计算x的n次方为例来比较两者的区别，Python代码如下：
<pre><code>def power(x, n):
    s = 1
    while n > 0:
        n = n - 1
        s = s * x
    print s
    return

power(2, 3)
</code></pre>
SAS程序如下：
<pre><code>/*Method 1*/
%macro power(a, n);
data _null_;
    POWER=1;
    INC=&n;
    do while (INC>0);
        INC=INC-1;
        POWER=POWER*&a;
    end;
    put POWER=;
run;
%mend power;

%power(2, 3);

/*Method 2*/
%macro power(a, n);
%let power=1;
%let inc=&n;
%do %while (&inc>0);
    %let inc=%eval(&inc-1);
    %let power=%eval(&power*&a);
%end;
&power;
%mend power;

data _null_;
    DEMO=%power(2, 3);
    put DEMO=;
run;

/*Method 3*/
%macro power();
%let power=1;
%let inc=&n;
%do %while (&inc>0);
    %let inc=%eval(&inc-1);
    %let power=%eval(&power*&a);
%end;
%mend power;

proc fcmp outlib=work.functions.demo;
    function pow(a, n);
    rc=run_macro('power', a, n, POWER);
    return(POWER);
    endsub;
run;

options cmplib=work.functions;

data _null_;
    POWER=pow(2, 3);
    put POWER=;
run;
</code></pre>
通过比较，我们可以看出Python的函数定义要比SAS简便很多。