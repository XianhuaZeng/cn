---
layout: post
title: SAS删除字符串中的重复项
date: 2016-11-26 15:54
author: 曾宪华
comments: true
tags: [Regular Expression, 正则表达式, PRXCHANGE]
categories: [程序人生]
---
SAS程序猿/媛有时候会碰到去除字符串中重复值的问题，用常用的字符函数如SCAN，SUBSTR可能会很费劲，用正则表达式来处理就简单了。示例程序如下：
<pre><code>data _null_;
    infile cards truncover;
    input Column1 $32767.;
    REX1=prxparse('s/([a-z].+?\.\s+)(.*?)(\1+)/\2\3/i');
    REX2=prxparse('/([a-z].+?\.\s+)(.*?)(\1+)/i');
    do i=1 to 100;
        Column1_=prxchange(REX1, -1, compbl(Column1));
        Column1=Column1_;
    end;
    put Column1=;
cards;
a. The cow jumps over the moon.
a. The cow jumps over the moon. b. The chicken crossed the road. c. The quick brown fox jumped over the lazy dog. a. The cow jumps over the moon. 
b. The chicken crossed the road. a. The cow jumps over the moon. b. The chicken crossed the road. c. The quick brown fox jumped over the lazy dog.
a. The cow jumps over the moon. a. The cow jumps over the moon. b. The chicken crossed the road. b. The chicken crossed the road. c. The quick brown fox jumped over the lazy dog. c. The quick brown fox jumped over the lazy dog.
a. The cows jump over the moon. a. The cows jump over the moon. b. The chickens crossed the road. b. The chickens crossed the road. c. The quick brown foxes jumped over the lazy dog. c. The quick brown foxes jumped over the lazy dog.
a. The cow jumps over the moon. b. The chicken crossed the road.  c. The quick brown fox jumped over the lazy dog. a. The cow jumps over the moon.  b. The chicken crossed the road. c. The quick brown fox jumped over the lazy dog.
;
run;
</code></pre>
可以看到上面的重复项是一整个句子，如果重复项是单词，上面的表达式就要改了：
<pre><code>data _null_;
    STRING='cow chicken fox cow chicken fox cows chickens foxes';
    REX1=prxparse('s/(\b\w+\b)(.*?)(\b\1+\b)/\2\3/i');
    REX2=prxparse('/(\b\w+\b)(.*?)(\b\1+\b)/i');
    do i=1 to 100;
        STRING_=prxchange(REX1, -1, compbl(STRING));
        STRING=STRING_;
        if not prxmatch(REX2, compbl(STRING)) then leave;
    end;
    put STRING=;
run;
</code></pre>
注意上面的表达式中第一个括号中的<a href="http://www.xianhuazeng.com/cn/2015/11/06/reg-word-boundary-pattern/" target="_blank"><span style="text-decoration: none;">\b</span></a>是用来限定只匹配单词而不是单个字母。第三个括号中的<code>\b</code>表示精确匹配，即匹配一模一样的单词。