---
layout: post
title: SAS获取某目录下所有指定类型的文件名称
date: 2016-02-25 22:30
author: Xianhua.Zeng
comments: true
tags: [AWK, FILENAME, PIPE, sed]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/QQ.jpg"><img class="aligncenter size-full wp-image-500" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/QQ.jpg" alt="QQ" width="302" height="302" /></a>      今天看到一个群友（QQ群：144839730，加群请扫上面的二维码）提的一个问题：SAS中如何简单地获取某一目录下所有指定类型的文件名称并赋值为宏变量？用常规的方法可能要20多行代码，如果用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/hostunx/61879/HTML/default/viewer.htm#pipe.htm" target="_blank">FILENAME</a></span>+PIPE只需要9行代码就可以轻松解决，语法如下：<!--more--></p><blockquote><span class="strong">FILENAME</span><span class="emph"> fileref</span> PIPE '<span class="emph">UNIX-command'</span> ;<dl><dt><a name="a000503150"></a><span class="emph">fileref</span></dt><dd><p><a name="a000503151"></a>is the name by which you reference the pipe from SAS.</p></dd><dt><a name="a000503152"></a>PIPE</dt><dd><p><a name="a000503153"></a>identifies the device-type as a UNIX pipe.</p></dd><dt><a name="a000503154"></a>'<span class="emph">UNIX-command</span>'</dt><dd><p><a name="a000503155"></a>is the name of a UNIX command, executable program, or shell script to which you want to route output or from which you want to read input. The commands must be enclosed in either double or single quotation marks.</p></dd></dl></blockquote><p>      以获取程序所在目录下所有TXT文件名为例，实现代码如下：</p><pre lang="SAS">filename filelst pipe "ls ./*.txt | sed -e 's#.*/##; s#\..*$##' | paste -sd '|' -";

data _null_;
    infile filelst lrecl=32767;
    input;
    call symputx('filelst', _INFILE_, 'L');
run;

filename filelst clear;
</pre><p>简单介绍一下上面的UNIX命令：其中的<code>s#.*/##</code>是用来去掉目录；<code>s#\..*$##</code>是用来去掉文件后缀；命令<span style="text-decoration: underline;"><code><a href="https://en.wikipedia.org/wiki/Paste_(Unix)" target="_blank">paste</a></code></span>，顾名思义就是将几个文件连接起来；选项<code>-s</code>的作用是将每个文件作为一个处理单元；选项<code>-d</code>的作用是用来设定间隔符。连接功能也可以用<span style="text-decoration: underline;"><code><a href="https://en.wikipedia.org/wiki/AWK" target="_blank">AWK</a></code></span>来实现，即：</p><pre lang="SAS">filename filelst pipe "ls ./*.txt | sed -e 's#.*/##; s#\..*$##' | awk 'ORS=""|""'";
</pre><p>不过这个命令有一个小问题，就是在最后会多出一个间隔符，需要在后续的DATA步中处理一下。</p>
