---
layout: post
title: 认识Annotate Facility
date: 2015-05-23 01:25
author: Xianhua.Zeng
comments: true
tags: [Annotate, Figure, Graph]
categories: [程序人生]
---
<p>说到<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/graphref/63022/HTML/default/viewer.htm#annodata-creating-grelem.htm" target="_blank">Annotate Facility</a></span>，首先要感谢我的同事<span style="text-decoration: none;"><a href="https://cn.linkedin.com/pub/jason-cai/82/8b6/757" target="_blank">Jason</a></span>，是他让我认识了Annotate Facility。Jason不仅是个画图高手，他的统计更是强到”令人发指“！现简单地介绍一下Annotate Facility的基本信息，希望能给想要学Annotate的SASers一点帮助。</p>
<p>Annotate Facility是SAS系统自带的一系列宏，常用的有以下几个：</p>
<ul style="list-style-type: disc;">
	<li>%LINE(x1, y1, x2, y2, color, line, size); --&gt; 画一条从(x1, y1)到(x2, y2)的线</li>
	<li>%LABEL(x, y, text, color, angle, rotate, size, style, position); --&gt; 在坐标为(x, y)处写上字符（text）</li>
</ul>
<p>其中的<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/graphref/63022/HTML/default/viewer.htm#annotate_position.htm" target="_blank">Position</a></span>的详细信息见下图：</p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Position.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Position.jpg" alt="Position" /></a></p>
<p>比如我们要为柱状图添加95%可信区间（见下图），则参数POSITION='B'。</p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Histogram.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Histogram.jpg" alt="Histogram" /></a></p>
<pre><code>%label(TRTN, UPPERCL, "_", black, 0, 0, 1, simplex, B);
</code></pre>
<ul style="list-style-type: disc;">
	<li>%SYSTEM(xsys, ysys, hsys); --&gt; 通过设定xsys, ysys和hsys（仅限3D图）的值来指定操作在画布中的位置变量 </li>
</ul>
<p>其中的<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/graphref/63022/HTML/default/viewer.htm#annodata-creating-grelem.htm#annodata-varcoord-sys" target="_blank">xsys, ysys和hsys</a></span>的值所代表的具体位置见下图：</p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/System.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/System.jpg" alt="System" /></a></p>
<p>比如要用坐标轴的值来确定Data Area中的位置就可以用 %system(2, 2)，而要用X轴的值加画布的百分比值来确定Graphics Output Area中的位置就可以用%system(2, 3)。</p>
<p>以上宏的详细信息大家可以调用下面这个宏来查询：</p>
<pre><code>%HELPANO(ALL)
</code></pre>
<p>使用Annotate Facility具体步骤如下：</p>
<ol>
	<li>调用宏%annomac，编译相关的宏以便后续直接调用；</li>
	<li>建立Annotate的Dataset（如名为anno），设置color、text等变量的属性；</li>
	<li>调用宏%system(xsys, ysys)，以确定操作在画布中的具体位置；</li>
	<li>调用宏%line和宏%label来画目的线条和字符；</li>
	<li>在PROC GPLOT的plot语句后面加上annotate=anno。</li>
</ol>
<p>接下来的博文我会介绍临床试验中几种常见的图，以实例来展示Annotate Facility强大功能。未完待续。。。</p>
<p>参考文献：<span style="text-decoration: none;"><a href="http://www.lexjansen.com/phuse/2006/tu/tu05.pdf" target="_blank">How to annotate graphics</a></span></p>
