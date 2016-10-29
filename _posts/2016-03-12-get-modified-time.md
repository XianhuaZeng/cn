---
layout: post
title: SAS获取某目录下某种类型文件最后修改时间
date: 2016-03-12 12:58
author: Xianhua.Zeng
comments: true
tags: [FILENAME, PIPE, sed]
categories: [程序人生]
---
<p>      上篇<a href="http://www.xianhuazeng.com/cn?p=710" target="_blank"><span style="text-decoration: underline;">博文</span></a>有介绍SAS中用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/hostunx/61879/HTML/default/viewer.htm#pipe.htm" target="_blank">FILENAME</a></span>+PIPE方法获取某目录下所有指定类型的文件名称，今天介绍一下用FILENAME+PIPE来获取某一目录下某种类型文件的最后修改时间。比如要获取程序所在目录下SAS数据集的最后修改时间，代码如下：<!--more--></p>
<pre lang="SAS">filename fdate pipe "ls -t ./*.sas7bdat | head -1";

data _null_;
    infile fdate lrecl=32767;
    input;
    call symputx('filename', _INFILE_, 'L');
run;

filename fdate "&amp;filename";

proc sql noprint;
    select cats(put(MODATE, is8601dt.)) into :file_dt
        from dictionary.extfiles
        where FILEREF='FDATE'
        ;
quit;

filename fdate clear;
</pre>
<p>      其中的<code>-t</code>是指按修改时间来排序（倒序）；<span style="text-decoration: underline;"><a href="https://en.wikipedia.org/wiki/Head_(Unix)" target="_blank"><code>head -1</code></a></span>指只输出输入结果的第一行。这个命令还可以用来获取某目录下某种类型文件的最新版本的文件名，宏程序如下：</p>
<pre lang="SAS">%macro getfname(keyword=, type=);
filename fname pipe "ls -t ./*.&amp;type | grep -i '&amp;keyword' | head -1";

data _null_;
    infile fname lrecl=32767;
    input;
    _INFILE_=prxchange("s/(.+)\/(.+)(\.&amp;type)/\2/", -1, _INFILE_);
    call symputx("fname", _INFILE_, "g");
run;

/* Close the pipe */
filename fname clear;
%mend getfname;

/*Using Example*/
%getfname(keyword=mapping specifications, type=xlsx)
</pre>
<p>      顺便介绍一下如何获取某种类型文件所在的目录。方法如下：在上级目录通过<span style="text-decoration: underline;"><a href="https://en.wikipedia.org/wiki/Find" target="_blank"><code>find</code></a></span>命令查找所有目标类型文件，然后再提取文件的目录。以获取文件define.xml的目录为例，实现代码如下：</p>
<pre lang="SAS">x 'cd /projects/study123456/';
filename fpath pipe "find . -name '*define*.xml' | head -1 | sed 's#.##'";

data _null_;
    infile fpath lrecl=32767;
    input;
    call symputx('path', prxchange("s#(.+)/(.+?)$#/projects/study123456/\1/#", -1, cats(_INFILE_)));
run;

filename fpath clear;
</pre>
<p>      其中<code>-name</code>表示使用文件名模式来匹配文件；<code>s#.##</code>表示将当前目录的点替换为空。</p>
