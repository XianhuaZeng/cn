---
layout: post
title: .sas7bdat文件与.xpt文件批量转换
date: 2015-04-26 22:17
author: Xianhua.Zeng
comments: true
tags: [CALL EXECUTE, CALL SYSTEM, PIPE, PRXCHANGE]
categories: [程序人生]
---
<p>      当我们拿到的原始数据为.xpt格式时，就需要批量转换成.sas7bdat文件以便后续处理，而当我们要准备SDTM Package时，我们又要将.sas7bdat文件批量转换成.xpt文件。</p>
<ol>
	<li>xpt2sas.sas<!--more-->
<pre lang="SAS">/*SAS文件路径*/
libname sdata "/home/users/zenga/code/sas/";

/*XPT文件路径*/
%let dir=/home/users/zenga/code/xpt/;

filename xpts pipe "ls &amp;dir.*.xpt";

data _null_;
    infile xpts truncover;
    input;
    XPTFILE=prxchange('s/(.+)\/(.+)(\.xpt)/\2/',-1, _INFILE_);
    call execute('libname xptin xport "&amp;dir.'||strip(XPTFILE)||'.xpt";'
                 ||'proc copy in=xptin out=sdata mt=all; run;');
run;

filename xpts clear;
</pre>
</li>
	<li>sas2xpt.sas
<pre lang="SAS"> 
/*XPT文件路径*/
%let dir=/home/users/zenga/code/xpt/;

proc sql;
    create table vtable as
        select * 
        from dictionary.tables
        where LIBNAME='SDATA'
        ;
quit;

data _null_;
    set vtable end=eof;
    MEMNAME=lowcase(MEMNAME);
    call execute('libname temp xport "&amp;dir.'||cats(MEMNAME)||'.xpt";'
                 ||'data '||cats(MEMNAME)||'(sortedby=_null_ label="'||cats(MEMLABEL)||'"); set sdata.'||cats(MEMNAME)||'; run;'
                 ||'proc copy in=work out=temp mt=data; select '||cats(MEMNAME)||'; run;');
    if eof then call execute('libname temp clear;');
run;
</pre>
</li>
</ol>
<p>      对于第一个程序xpt2sas.sas，获取某一路径下某种文件的文件名也可以用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/hostwin/63285/HTML/default/viewer.htm#win-callrout-system.htm" target="_blank">CALL SYSTEM</a></span>，不过这种方法会产生一个临时文件，所以推荐使用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/hostunx/61879/HTML/default/viewer.htm#pipe.htm" target="_blank">PIPE</a></span>。</p>
