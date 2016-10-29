---
layout: post
title: SAS自动打开数据集及复制变量值
date: 2016-10-08 21:36
author: Xianhua.Zeng
comments: true
tags: [DM, GSUBMIT, PharmaSUG, PharmaSUG China 2016]
categories: [程序人生]
---
<p>      上个月的今天，我从南到北，从深圳奔赴帝都参加了一个<span style="text-decoration: underline;"><a href="http://www.pharmasug.org/" target="_blank">制药行业SAS用户组会议</a></span>。听了两天的报告，收获不少。有幸见到SAS绘图大神<a href="https://support.sas.com/publishing/authors/matange.html" target="_blank"><span style="text-decoration: underline;">Sanjay Matange</span></a>，可惜当时忘记了要合影。这个名字可能大家不熟悉，但是他的博客<a href="http://blogs.sas.com/content/graphicallyspeaking/" target="_blank"><span style="text-decoration: underline;">Graphically Speaking</span></a>我相信很多人有看过。在众多报告中，印象最深的是一个大神的报告（How to give SAS ambiguous instructions and still being a big winner (literally delegate everything to SAS) -- Hui Liu, Eli Lilly）。<!--more-->他分享了几个很有用的SAS技巧，比如自动打开所标记的数据集、自动获取某个变量的值。<br />
 可惜没有分享源程序，所以我写了两个小程序，实现了自动打开数据集及复制变量值。</p>
<ol>
	<li>自动打开所选中的数据集。当我们想打开一个很长程序中间过程的一个数据集时，一般的操作是资源管理器 - 逻辑库，然后找到目标数据集双击打开。有了下面这个宏，我们只要在程序编辑器选中目标数据集，然后按快捷键就可以自动打开。
<pre><code>%macro markdsn();
gsubmit "
dm 'wcopy';

filename clip clipbrd;

data _null_;
   infile clip;
   input;
   call execute('dm ""vt '||_INFILE_||';"" continue ;');
run;

filename clip clear;";
%mend markdsn;</code></pre>
</li>
	<li>自动复制选中变量的值。当我们要在一个数据集中筛选出某一变量取特定值时的记录时，比如要筛选某一个AETERM，一般的操作是打开数据集或者从他处手动复制这个AETERM，然后粘贴到程序编辑器选中对应的语句中。有了下面这个宏，我们只要在程序编辑器选中目标变量，然后按快捷键就可以自动将目标变量的值复制到剪贴板，每按一次得到目标变量的一个值，直到得到想要的变量值，再粘贴到程序编辑器选中对应的语句中。
<pre><code>%macro vvalue();
gsubmit '
dm "wcopy";

filename clip clipbrd;

data _null_;
   infile clip;
   input;
   call symputx("var", _INFILE_);
run;

filename clip clear;

proc sql noprint;
    select distinct &amp;var into :varlst separated by "@"
    from &amp;syslast
    ;
quit;

%let increment=%eval(&amp;increment+1);

filename clip clipbrd;

data _null_;
    file clip;
    length value $32767;
	if &amp;increment &lt;= countw("&amp;varlst", "@") then value=scan("&amp;varlst", &amp;increment, "@");
	else value=scan("&amp;varlst", countw("&amp;varlst", "@"), "@");
    put value;
run;

filename clip clear;';
%mend vvalue;</code></pre>
</li>
</ol>
<p>      接下来说下设置和用法。设置如下：</p>
<ol>
	<li>将这些宏放到某一自动编译宏的逻辑库，即sasautos值对应的路径</li>
	<li>在初始化程序中设置一个名为INCREMENT，初始值为0的全局宏变量</li>
	<li>在命令行输入以下命令为宏设置对应的快捷键以便调用宏
<pre><code>keydef 'F9' '%makedsn'
keydef 'F10' '%vvalue'</code></pre>
</li>
</ol>
<p>      用法如下：</p>
<ol>
	<li>选中目标数据集按F9，选中的数据集自动打开</li>
	<li>选中目标变量按F10一次，得到目标变量的第一个值，再选中目标变量按F10一次，得到目标变量第二值，重复上述动作直到得到想要的变量值</li>
</ol>