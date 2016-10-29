---
layout: post
title: SAS宏程序中的查询
tags: [Macro, PIPE, 宏]
categories: [程序人生]
---
<p>      我们在写相对复杂的宏的时候，通常会在开始位置加一些判断，比如判断某个变量是否在、一个路径是否存在、一个路径下面某种文件是否存在。。。</p><p>      前面两个在<span style="text-decoration: underline;"><a href="http://www.sascommunity.org/" target="_blank">sascommunity</a></span>中已经有了，链接分别为<span style="text-decoration: underline;"><a href="http://www.sascommunity.org/wiki/Tips:Check_if_a_variable_exists_in_a_dataset" target="_blank">变量</a></span>、<span style="text-decoration: underline;"><a href="http://www.sascommunity.org/wiki/Tips:Check_if_a_directory_exists" target="_blank">路径</a></span>。搬运如下：</p><ol><li> 判断某个变量是否在<pre lang="SAS">%macro VarExist(ds,var);
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
</pre></li><li>判断一个路径是否存在<pre lang="SAS">%macro DirExist(dir) ; 
   %LOCAL rc fileref return; 
   %let rc = %sysfunc(filename(fileref, &amp;dir)) ; 
   %if %sysfunc(fexist(&amp;fileref))  %then %let return=1;    
   %else %let return=0;
   &amp;return
%mend DirExist;
</pre></li><li>判断一个路径下面某种文件(txt)是否存在的Code如下：<pre lang="SAS">%let gcr_fe=1;

filename fe pipe "ls &amp;dir.*.txt";

data _null_;
    infile fe truncover end=eof;
    input;
    if prxmatch('/(\*\.txt not found)/', _INFILE_) then call symputx('gcr_fe', 0);
run;
</pre></li></ol>
