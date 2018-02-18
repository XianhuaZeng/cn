---
layout: post
title: SAS矩阵重组
date: 2018-01-04 22:02
author: 曾宪华
comments: no
tags: [FILENAME, CALL EXECUTE, PRXCHANGE, IML]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/images/2018/01/Shape.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/01/Shape.jpg" alt="Shape" /></a></p>
<p>最近看到一个群友（QQ群：<span style="text-decoration: none;"><a href="http://www.xianhuazeng.com/cn/images/2015/09/QQ.jpg" target="_blank">144839730</a></span>）提的一个问题：将上图中的名为HAVE的数据集转置成名为WANT的数据集。实现的方法有多种，最易懂的方法应该是<a href="http://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#transpose-overview.htm" target="_blank"><span style="text-decoration: none;">TRANSPOSE</span></a>，下面介绍其他几种方法：</p>
<ol><li><a href="https://support.sas.com/documentation/cdl/en/lestmtsref/63323/HTML/default/p05r9vhhqbhfzun1qo9mw64s4700.htm" target="_blank"><span style="text-decoration: none;">FILENAME：</span></a>
<pre><code>data have;
    a_t1=1; b_t1=2; a_t2=3; b_t2=4; a_t3=5; b_t3=6; a_t4=7; b_t4=8;
run;

filename code temp;
data _null_;
    file code;
    set have;
    array vlst{*} _numeric_;
    do i=1 to dim(vlst) BY 2;
        N1=vname(vlst{i});
        N2=vname(vlst{i+1});
        N3=prxchange('s/(\w+?)_(\w+)/\1_\2=\1/', -1, catx(' ', N1, N2));
        N4=scan(N1, 2, '_');
        put ' SET have(keep=' N1 N2' rename=(' N3 '));' @@;
        put ' NAME="' N4 '"; output;'; 
    end;   
run;

data want;
    length NAME $32;
    %inc code;
run;
</code></pre></li>
<li><a href="http://support.sas.com/documentation/cdl/en/mcrolref/67912/HTML/default/viewer.htm#n1q1527d51eivsn1ob5hnz0yd1hx.htm" target="_blank"><span style="text-decoration: none;">CALL EXECUTE：</span></a>
<pre><code>data temp;
    set have;
    array vlst{*} _numeric_;
    do i=1 to dim(vlst) BY 2;
        N1=vname(vlst{i});
        N2=vname(vlst{i+1});
        N3=prxchange('s/(\w+?)_(\w+)/\1_\2=\1/', -1, catx(' ', N1, N2));
        N4=scan(N1, 2, '_');
        keep N:;
        output;
    end;   
run;

data want;
    set temp end=last;
    if _n_=1 then call execute('data want; length NAME $32;');
    call execute('SET have(keep='||catx(' ', N1, N2)||' rename=('||cats(N3)||')); NAME="' ||cats(N4)||'"; output;');
    if last then call execute('run;');
run;
</code></pre></li></ol>
可能大家会觉得上面两种方法代码行数都有点多，那请看下面采用<a href="https://support.sas.com/documentation/cdl/en/imlug/66845/PDF/default/imlug.pdf" target="_blank"><span style="text-decoration: none;">SAS/IML</span></a>的方法：
<pre><code>proc iml;
    use have;
    read all var _NUM_ into M1[c=VARNAMES];
    close;
    NAME1=scan(VARNAMES, 1, '_');
    NAME2=scan(VARNAMES, -1, '_');
    ROW=unique(NAME1);
    NAME=unique(NAME2);
    M2=shape(M1, 0, 2);
    create want from M2[c=ROW r=NAME];
    append from M2[r=NAME];
    close;
quit;
</code></pre>
注意，上面函数<a href="http://support.sas.com/documentation/cdl/en/imlug/66112/HTML/default/viewer.htm#imlug_langref_sect386.htm" target="_blank"><span style="text-decoration: none;">SHAPE</span></a>中的行数我写成0，这样真正的行数就由列数决定，即重组1行8列的矩阵，转成2列的情况下，行数只能是4了。故在行列很多的情况下把行或列数设为0会简单点，因为不用去算行或列数。