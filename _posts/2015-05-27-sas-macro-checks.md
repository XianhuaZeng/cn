---
layout: post
title: SAS宏程序中的查询
date: 2015-05-27 20:49
author: Xianhua.Zeng
comments: true
tags: [Macro, PIPE, 宏]
categories: [程序人生]
---
<p>我们在写相对复杂的宏的时候，通常会在开始位置加一些判断，比如判断某个变量是否在、一个路径是否存在、一个路径下面某种文件是否存在。。。</p>
<p>前面两个在<span style="text-decoration: none;"><a href="http://www.sascommunity.org/" target="_blank">sascommunity</a></span>中已经有了，链接分别为<span style="text-decoration: none;"><a href="http://www.sascommunity.org/wiki/Tips:Check_if_a_variable_exists_in_a_dataset" target="_blank">变量</a></span>、<span style="text-decoration: none;"><a href="http://www.sascommunity.org/wiki/Tips:Check_if_a_directory_exists" target="_blank">路径</a></span>。搬运如下：</p>
<ol>
	<li> 判断某个变量是否在

<pre><code>%macro VarExist(ds,var);
    %local rc dsid result;
    %let dsid=%sysfunc(open(&amp;ds));
    %if %sysfunc(varnum(&amp;dsid, &amp;var)) &gt; 0 %then %do;
        %let result=1;
        %put NOTE: Var &amp;var exists in &amp;ds;
    %end;
    %else %do;
        %let result=0;
        %put NOTE: Var &amp;var not exists in &amp;ds;
    %end;
    %let rc=%sysfunc(close(&amp;dsid));
    &amp;result
%mend VarExist;
</code></pre>
</li>
	<li>判断一个路径是否存在

<pre><code>%macro DirExist(dir) ; 
   %local rc fileref return; 
   %let rc = %sysfunc(filename(fileref, &amp;dir)) ; 
   %if %sysfunc(fexist(&amp;fileref))  %then %let return=1;    
   %else %let return=0;
   &amp;return
%mend DirExist;
</code></pre>

当然，如果是UNIX SAS我们还可以直接用函数<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/hostunx/61879/HTML/default/viewer.htm#a000351867.htm" target="_blank">FILEEXIS</a></span>T来判断。程序如下：

<pre><code>%if %sysfunc(fileexist(%nrbquote(&amp;dir))) %then ...;
</code></pre>
</li>
	<li>判断一个路径下面某种文件(txt)是否存在的Code如下：

<pre><code>%let fexist=1;

filename fexist pipe "ls &amp;dir.*.txt";

data _null_;
    infile fexist truncover end=eof;
    input;
    if prxmatch('/(\*\.txt not found)/', _INFILE_) then call symputx('fexist', 0);
run;

filename fexist clear;
</code></pre>
</li>
</ol>
