---
layout: post
title: 一个关于Define.xml的奇怪问题
date: 2015-05-19 20:07
author: Xianhua.Zeng
comments: true
tags: [CDISC, Define.xml, PRXCHANGE, Regular Expression, 正则表达式]
categories: [程序人生]
---
<p>今天一个同事和我说，她在做<span style="text-decoration: underline;"><a href="http://www.cdisc.org/define-xml" target="_blank">Define.xml</a></span>时碰到一个奇怪的问题：最后要生成Define.xml的数据集中已经去除了各种特殊字符，但是生成的Define.xml文件有些地方仍然会有空格（经查询为‘ODOA’x即回车和换行符），见下图：</p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Define.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/Define.jpg" alt="Define" /></a></p>
<p><!--more--></p>
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/0A0D.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/05/0A0D.jpg" alt="0A0D" /></a></p>
<p>接着看了下她的程序：</p>
<pre><code>data _null_;
    set xmlall end=done;
    file xmlout;
    put LINE;
    if not done then return;
    else do;
        LINE = ' ';                                                                                                  put LINE;
        LINE = '<!-- ***************************************************************************************** -->'; put LINE;
        LINE = '<!-- Close the container elements -->';                                                              put LINE;
        LINE = '<!-- ***************************************************************************************** -->'; put LINE;
        LINE = '';                                                                                                   put LINE;
        LINE = '';                                                                                                   put LINE;
        LINE = '';                                                                                                   put LINE;
    end;
run;
</code></pre>
<p>发现以上程序没有问题，一开始我也觉得奇怪，仔细想了下，发现原来是PUT语句搞的鬼，原来PUT语句一行最多可以写255个字符串，所以对于长度超过255的行会自动PUT成多行，这样就会导致最后的Define.xml有回车和换行符了。</p>
<p>对于这个问题，又要用到强大的正则表达式了，即将变量LINE每隔固定的长度（这里取200）插入一个分隔符，然后生成多行，这样再PUT就不会出问题了。代码如下：</p>
<pre><code>data xmlall;
    set xmlall;
    LINE=prxchange("s/(.{1,200})([\s]|$)/\1@/", -1, cats(LINE));
    LINE=prxchange('s/(.+)\@/\1/', -1, LINE);
    i=1;
    do until(scan(LINE, i, '@')='');
        LINE_=scan(LINE, i, '@');
        output;
        i+1;
    end;
    drop LINE;
    rename LINE_=LINE;
run;
</code></pre>
