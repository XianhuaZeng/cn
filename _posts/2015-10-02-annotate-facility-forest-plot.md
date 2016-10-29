---
layout: post
title: Annotate Facility之森林图
date: 2015-10-02 01:25
author: Xianhua.Zeng
comments: true
tags: [Annotate, Forest plot, PROC GPLOT, 森林图]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/10/forest1.jpg"><img class="aligncenter size-full wp-image-521" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/10/forest1.jpg" alt="forest1" width="720" height="604" /></a></p><p>      森林图（<span style="text-decoration: underline;"><a href="https://en.wikipedia.org/wiki/Forest_plot" target="_blank">Forest plot</a></span>）是以统计指标和统计分析方法为基础，用数值运算结果绘制出的图型。它在平面直角坐标系中，以一条垂直的无效线(横坐标刻度为1或0)为中心，用平行于横轴的多条线段描述了每个被纳入研究的效应量和可信区间(confidence interval，CI)。森林图是<span style="text-decoration: underline;"><a href="http://baike.baidu.com/view/938263.htm" target="_blank">Meta分析</a></span>中最常用的结果表达形式，当然类似的结果也可以用森林图来展示，比如上图即展示了两处理组在各个亚组因素的反应率的差异的95%可信区间。<!--more--></p><p>      假设统计分析的结果如下：</p><p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/10/forest2.jpg"><img class="aligncenter size-full wp-image-522" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/10/forest2.jpg" alt="forest2" width="1132" height="503" /></a></p><p>在画图之前我们要构造一个变量，即图中的变量ORD2，以保证数据集中的记录在图中能按顺序来显示，如本例中可以通过以下程序来得到变量ORD2，其中的ORD1的值是根据分组因素顺序定义的：</p><pre><code>ORD2=36-_N_-(ORD1-1);
</code></pre><p>开始画图：</p><ol><li>画首尾部的字符串和X轴，因为首尾部要用到的是Graphics Output区域故要用 %system(3, 3)，而X轴用的是Data区域故要用 %system(2, 2)，代码如下：<pre><code>/*字体*/
%let ftext ='Albany AMT/roman/medium';

/*编译宏*/
%annomac;

data anno1;
    length TEXT $200.;
    %system(3, 3);
    %label(52, 97, 'Treatment Difference', black, 0, 0, 1.2, &amp;ftext., 5)
    %label(1, 92, 'Subgroup', black, 0, 0, 1.1, &amp;ftext.,6);
    %label(63, 92, 'Difference(95%CI)', black, 0, 0, 1.1, &amp;ftext.,6);
    %label(81, 95, 'Response Rates(%)', black, 0, 0, 1.2, &amp;ftext., 6) ;

    %label(82, 92, 'TRTA', black, 0, 0, 1.1, &amp;ftext., 6);
    %label(92, 92, 'TRTB', black, 0, 0, 1.1, &amp;ftext., 6);

    %label(32, 6, 'Favors TRTA', black, 0, 0, 1.1, &amp;ftext., 4);
    %label(56, 6, 'Favors TRTB', black, 0, 0, 1.1, &amp;ftext., 6);

    %label(25.5, 4, '-70', black, 0, 0, 1.0, &amp;ftext., 6);
    %label(60, 4, '70', black, 0, 0, 1.0, &amp;ftext., 6);
    %label(44.0, 5, '0', black, 0, 0, 1.0, &amp;ftext., 6);

    /*X轴*/
    %system(2, 2);
    %line(-70, 0, 70, 0, black, 1, 1);
run;
</code></pre></li><li>画分组因素、95%可信区间、反应率的值，因为要用Y轴的值加画布的百分比值来确定Graphics Output Area中的位置故用%system(3, 2)，代码如下：<pre><code>data anno2;
    set demo;
    length TEXT $200.;
    %system(3, 2);
    %label(2, ORD2, ITEM, black, 0, 0, 1, &amp;ftext., 6);
    %label(63, ORD2, DIFLU, black, 0, 0, 1, &amp;ftext., 6);
    %label(82.5, ORD2, RATE1, black, 0, 0, 1, &amp;ftext., 6);
    %label(92.5, ORD2, RATE2, black, 0, 0, 1, &amp;ftext., 6);
    drop ORD: ITEM DIFF LOW UP DIFLU RATE1 RATE2;
run;
</code></pre></li><li>画95%可信区间的线，代码如下：<pre><code>data anno3;
    set demo;
    %system(2, 2);
    %line(LOW, ORD2, UP, ORD2, black, 1, 1);
    drop ORD: ITEM DIFF LOW UP DIFLU RATE1 RATE2;
run;
</code></pre></li><li>画参考线，代码如下：<pre><code>data anno4;
    %system(2, 2);
    %line(0, 0, 0, 36, black, 2, 1);
run;
</code></pre></li><li>将Annotation的数据集连在一起：<pre><code>data anno;
    set anno1-anno4;
run;
</code></pre></li><li>设置坐标属性，通过<span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/graphref/63022/HTML/default/viewer.htm#font-font-lists.htm#a002398129" target="_blank">Marker Font</a></span>来实现菱形显示DIFF的值，代码如下：<pre><code>/*图形属性*/
symbol1 i=none v=p c=black f=marker h=1;

/*坐标轴*/
axis1 minor=none major=none order=(0 to 36 by 1) label=none value=none offset=(0, 5) origin=(0, 4) c=white;
axis2 minor=none order=(-70 to 70 by 70) label=none offset=(27, 40) origin=(0, 4) style=0 value=none;

goptions ftext=&amp;ftext htext=8pt hsize=50cm vsize=16cm noborder;

/*画图*/
ods listing close;
proc gplot data=demo;
    plot ORD*DIFF/haxis=axis2
                  vaxis=axis1
                  anno=anno
                  nolegend
                  noframe;
run ;
quit;

ods rtf close;
ods listing;</code></pre></li></ol>
