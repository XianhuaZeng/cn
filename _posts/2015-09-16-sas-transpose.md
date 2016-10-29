---
layout: post
title: 一个关于SAS转置的问题
date: 2015-09-16 20:57
author: Xianhua.Zeng
comments: true
tags: [PROC TRANSPOSE, 转置]
categories: [程序人生]
---
<p>  <a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/Transpose.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/Transpose.jpg" alt="Transpose" /></a>      <span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a000063663.htm" target="_blank">PROC TRANSPOSE</a></span>是SAS中用来对数据集进行行列转置的过程步，有时候可能需要经过多次PROC TRANSPOSE才能得到我们想的结果。今天无意中看到一篇博文，其中的<span style="text-decoration: underline;"><a href="http://saslist.net/archives/255" target="_blank">例2</a></span>（见上图），博主采用辅助变量加PROC TRANSPOSE来实现。下面我介绍另外两种方法。<!--more--></p>
<ol>
	<li>不用PROC TRANSPOSE，代码如下：

<pre><code>data want;
    array VARL[6] DATE1 RES1 DATE2 RES2 DATE3 RES3;
    NUM=1;
    do until(last.NAME);
        set ex1;
        by NAME;
        VARL[NUM]=DATE;
        VARL[NUM+1]=RES;
        NUM=NUM+2;
    end;
    drop NUM DATE RES;
run;</code></pre>
</li>
	<li>只用一次PROC TRANSPOSE，代码如下：

<pre><code>data temp;
    set ex1;
    array varlist DATE RES;
    do I=1 to dim(varlist);
        VAR1=varlist(i);
        output;
    end;
run;

proc transpose data=temp out=want;
    by NAME;
    var VAR1;
run;
</code></pre>
</li>
</ol>
