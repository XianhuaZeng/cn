---
layout: post
title: Annotate Facility之生存曲线
date: 2015-08-29 16:55
author: Xianhua.Zeng
comments: true
tags: [Annotate, Kaplan-Meier estimate, PROC GPLOT, Survival Curve, 生存分析]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/KM-Plot-1.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/KM-Plot-1.jpg" alt="KM Plot 1" /></a>      在研究肿瘤的临床实验中，通常要进行生存分析。其中最重要的分析方法之一就是<span style="text-decoration: underline;"><a href="https://en.wikipedia.org/wiki/Kaplan%E2%80%93Meier_estimator" target="_blank">乘积极限法</a></span>（product-limit），简称积限法或PL法，它是由统计学家Kaplan和Meier提出来的，故又称为<span style="text-decoration: underline;"><a href="https://en.wikipedia.org/wiki/Kaplan%E2%80%93Meier_estimator" target="_blank">Kaplan-Meier</a></span>法，是用来估计生存曲线的方法。下面就介绍如何用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/graphref/63022/HTML/default/viewer.htm#annodata-creating-grelem.htm" target="_blank">Annotate Facility</a></span>来画上面的生存曲线。<!--more--></p>
<p>      在画图之前，有两个选项需要弄清楚，即<span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/graphref/63022/HTML/default/viewer.htm#axischap.htm" target="_blank">AXIS</a></span>语句中的ORIGIN和OFFSET选项。从下图可以看出，ORIGIN指原点的位置，当我们需要在X轴或Y轴外侧预留更多空间时，就需要调整ORIGIN(x, y)的值；OFFSET用来指定原点与第一个刻度或者最后一刻度与X轴（或Y轴）之间的距离。当首尾刻度标签很长时以及曲线和整个图形的框架的顶部线条重合时为了显示美观就要调整OFFSE(x, y)的值。</p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/Axes.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/Axes.jpg" alt="Axes" /></a></p>
<p>      如果在上述生存曲线中不设置OFFSET，那么结果将会是这样的：</p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/KM-Plot-2.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/KM-Plot-2.jpg" alt="KM Plot 2" /></a></p>
<p>      从上图可以看出，当X轴没有设置OFFSET时，第一个刻度和原点重合了；当Y轴没有设置OFFSET时，第一个刻度和原点重合了，最后一个刻度与整个图形的框架的顶部线条重合了，这也就导致了曲线开始一段和整个图形的框架的顶部线条重合了，这样的图不就美观了。</p>
<p>      理解了ORIGIN和OFFSET用法之后，我们就要开始做Annotation的数据集了。首先是通过宏%LABEL将字符串‘NUMBER OF SUBJECTS AT RISK’、'TRT A'、'TRT B'写到图片上；接着通过宏%LABEL将‘NUMBER OF SUBJECTS AT RISK’对应的具体数字写到图片上；最后是用宏%LINE画X轴的刻度。因为图中X轴的刻度显示是不连续的，故无法使用AXIS语句中MAJOR选项。生成上述三个数据集的程序如下：</p>
<pre><code>/*字体*/
%let ftext ='Albany AMT/roman/medium';

/*编译宏*/
%annomac;

data anno1;
    length TEXT $200.;
    %system(3, 3);
    %label(7, 10, "NUMBER OF SUBJECTS AT RISK", black, 0, 0, 1, &amp;ftext., 6);
    %label(0, 6, "TRT A", black, 0, 0, 1, &amp;ftext., 6);
    %label(0, 2, "TRT B", black, 0, 0, 1, &amp;ftext., 6);
run;

data anno2;
    set demo;
    length TEXT $200.;
    %system(2, 3);
    if not missing(LEFT) then do;
        if TRT=1 then do; %label(TIME, 6, cats(LEFT), black, 0, 0, 1, &amp;ftext., 5); end;
        else if TRT=2 then do; %label(TIME, 2, cats(LEFT), black, 0, 0, 1, &amp;ftext., 5); end;
    end;
run;

data anno3;
    %system(2, 3);
    %line(0, 23.9, 0,  22.7, black, 1, 1);
    %line(1, 23.9, 1,  22.7, black, 1, 1);
    %line(2, 23.9, 2, 22.7, black, 1, 1);
    %line(4, 23.9, 4, 22.7, black, 1, 1);
    %line(8, 23.9, 8, 22.7, black, 1, 1);
    %line(12, 23.9, 12, 22.7, black, 1, 1);
    %line(16, 23.9, 16, 22.7, black, 1, 1);
    %line(20, 23.9, 20, 22.7, black, 1, 1);
    %line(24, 23.9, 24, 22.7, black, 1, 1);
run;

data anno;
    set anno1 anno2 anno3;
run;
</code></pre>
<p>      接下来就是设置坐标和图例的属性了，程序如下：</p>
<pre><code>/*曲线属性*/
symbol1 c=black l=1 w=1 v=none i=steplj;
symbol2 c=blue l=3 w=1 v=none i=steplj;

/*坐标轴*/
axis1 minor=none order=(80 to 100 by 5) label=(a=90 j=c h=1 "SUBJECTS REMAINING ON THERAPY (%)")
offset=(1, 1) origin=(8.0, 7.5) value=("80" "85" "90" "95" "100");

axis2 minor=none major=none order=(0 to 25 by 1) label=(a=0 j=c h=1 "STUDY WEEKS")
origin =(8.0, 7.5) offset=(2,0) value=("B/L" "1" "2" "" "4" "" "" "" "8" "" "" "" "12" "" "" "" "16" "" "" "" "20" "" "" "" "24" "") ;

/*图例*/
legend1  position=(left inside) label=none frame mode=share across=1
         value =(h=1 c=black t=1 "TRT A"
                             t=2 "TRT B")  
         offset=(1, 1);

goptions ftext=&amp;ftext hsize=24cm vsize=10cm noborder;

/*画图*/
ods listing close;
proc gplot data=demo(where=(not missing(SURVIVAL)));
    plot SURVIVAL*TIME=TRT
                      /haxis=axis2
                      vaxis=axis1
                      anno=anno
                      legend=legend1;
run ;
quit;

ods rtf close;
</code></pre>
<p>      到这里整个图形就算画好了，当然有的时候我们还会碰到要用特殊的符号来显示删失（Censored）的情况，比如用小长方形，那我们就可以用以下的程序来实现：</p>
<pre><code>data anno;
    set productlimitestimates(where=(CENSOR=1));
    %system(2, 2);
    if TRT=1 then do;
        %BAR(TIME-0.03, SURVIVAL-0.5, TIME+0.03, SURVIVAL+0.5, black, 0, s);
        %BAR2(TIME-0.03, SURVIVAL-0.5, TIME+0.03, SURVIVAL+0.5, black, 0, s, 0.5);
    end;
    else if TRT=2 then do;
        %BAR(TIME-0.03, SURVIVAL-0.5, TIME+0.03, SURVIVAL+0.5, black, 0, e);
        %BAR2(TIME-0.03, SURVIVAL-0.5, TIME+0.03, SURVIVAL+0.5, black, 0, e, 0.5);
    end;
run;
</code></pre>
<p>      结果如下：<a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/KM-Plot-3.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/08/KM-Plot-3.jpg" alt="KM Plot 3" /></a></p>
