---
layout: post
title: 正则表达式之正向预查(?=...)
date: 2016-11-11 22:54
author: 曾宪华
comments: true
tags: [PRXCHANGE, Regular Expression, 正则表达式]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/QQ.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/09/QQ.jpg" alt="QQ" /></a>最近看到一个群友（QQ群：144839730，加群请扫上面的二维码）的问题：如何提取宏调用的参数和参数值？这个问题用常规的字符函数可能要多行才能解决，用<span style="text-decoration: none;"><a href="http://zh.wikipedia.org/zh/%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F" target="_blank">正则表达式</a></span>就相对简单了，程序如下：
<pre><code>data demo;
    STRING='%test(var1=123, var2=abc, var3=abc123);';
    REX=prxparse('/(\w+\s*=\s*.+?[,|\)])/');
    START=1;
    STOP=length(STRING);
    call prxnext(REX, START, STOP, STRING, POSITION, LENGTH);
    do while(POSITION > 0);
        TEMP=substr(STRING, POSITION, LENGTH);
        PARAM=scan(TEMP, 1, '=');
        VALUE=substr(TEMP, length(PARAM)+2);
        VALUE=prxchange('s/[\)|,]$//', -1, cats(VALUE));
        output;
        call prxnext(REX, START, STOP, STRING, POSITION, LENGTH);
    end;
    keep PARAM VALUE;
run;</code></pre>
我们可以看到上面的宏调用的参数值都是简单的字符，如果参数值中包含逗号上面的程序就不能用了。
比如下面这样的：
<pre><code>STRING='%test(var1=123, var2=%nrstr(NOTE: Y=Yes, N=No, U=Unkonw), var3=%nrstr(NOTE: (Y=Yes (or true))));';</code></pre>
所以我们可以借助正则表达式中的<span style="text-decoration: none;"><a href="https://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a003288497.htm" target="_blank">正向预查</a></span><code>(?=...)</code>先转换一下参数中的逗号，程序如下：
<pre><code>STRING=prxchange('s/,(?=[^\(]*\)[,|\)])/~/', -1, STRING);</code></pre>
<code>(?=...)</code>表示正向匹配，且不保存所匹配的内容。我们可以将它理解为自定义的边界(\b)，这个边界位于表达式末。上面的表达式中<code>[^\(]*</code>表示匹配非括号字符零次或多次，<code>\)[,|\)]</code>表示匹配<code>),</code>或者<code>))</code>，整个表达式的意思是只替换后面是<code>),</code>或者<code>))</code>的逗号，比如第一个逗号，因为后面有<code>%nrstr(</code>，包含有<code>(</code>，所以匹配不成功，逗号不会被替换。第二个逗号，因为后面有<code>),</code>，所以匹配成功。
完整的程序如下：
<pre><code>data demo;
    STRING='%test(var1=123, var2=%nrstr(NOTE: Y=Yes, N=No, U=Unkonw), var3=%nrstr(NOTE: (Y=Yes (or true))));';
    STRING=prxchange('s/,(?=[^\(]*\)[,|\)])/~/', -1, STRING);
    REX=prxparse('/(\w+=.+?[,|\)]+)/');
    START=1;
    STOP=length(STRING);
    call prxnext(REX, START, STOP, STRING, POSITION, LENGTH);
    do while(POSITION > 0);
        TEMP=substr(STRING, POSITION, LENGTH);
        PARAM=scan(TEMP, 1, '=');
        VALUE=substr(TEMP, length(PARAM)+2);
        VALUE=prxchange('s/[\)|,]$//', -1, cats(VALUE));
        VALUE=prxchange('s/~/, /', -1, VALUE);
        output;
        call prxnext(REX, START, STOP, STRING, POSITION, LENGTH);
    end;
    keep PARAM VALUE;
run;</code></pre>