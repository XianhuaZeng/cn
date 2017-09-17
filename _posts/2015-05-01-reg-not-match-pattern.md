---
layout: post
title: 正则表达式之非捕获匹配(?:...)
date: 2015-05-01 21:42
author: 曾宪华
comments: true
tags: [PRXCHANGE, Regular Expression, 正则表达式]
categories: [程序人生]
---
<p>当我们在做Tables、Listings以及SDTM Datasets时，有的时候需要用<span style="text-decoration: none;"><a href="http://zh.wikipedia.org/zh/%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F" target="_blank">正则表达式</a></span>来处理一个较长的字符串，即每隔一定长度插入一个分隔符，进而实现变量换行对齐（Tables、Listings）或者生成新的变量（SDTM Datasets）。而当字符串中有连字符的时候，在写正则表达式时就要用到非捕获匹配(?:...)。</p><p>如下图中的数据集，我们的目的是对变量STRING每隔14个字符插入分隔符‘~’而不将完整的单词分开。</p><p><a href="http://www.xianhuazeng.com/cn/images/2015/05/Demo.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2015/05/Demo.jpg" alt="Demo" /></a></p><ol><li>当表达式为：<pre><code>STRING_=prxchange("s/(.{1,14})(?:([-])|(?:[\s]|$))/\1\2~/", -1, STRING);
</code></pre><p>STRING_ = "Baseline is~defined as the~last non-~missing~assessment~recorded on~the date of~first stu dy~drug injection~"，解释：第一个?:表示所在的括号不捕获匹配，即在整个表达式中，\2表示([-])，而不是 (?:([-])|(?:[\s]|$)，同理\3为空。即?:只对所在括号起作用。</p></li><li>当表达式为：<pre><code>STRING_=prxchange("s/(.{1,14})(([-])|(?:[\s]|$))/\1\2~/", -1, STRING);
</code></pre><p>STRING_ = "Baseline is ~defined as the ~last non-~missing ~assessment ~recorded on ~the date of ~first study ~drug injection~"，解释：在整个表达式中，\2表示(([-])|(?:[\s]|$)，则\2包括\s，因为?:只对第四对括号起作用，而第二对括号没有?:，因而整体是捕获匹配的。</p></li><li>当表达式为：<pre><code>STRING_=prxchange("s/(.{1,14})(?:([-])|(?:[\s]))/\1\2~/", -1, STRING);
</code></pre><p>STRING_ = "Baseline is~defined as the~last non-~missing~assessment~recorded on~the date of~first study~drug~injection"，解释：表达式中没有$来表示字符串的结尾，则最后一段14长度字符串遇到空格就加~，因为{n,m}是贪婪匹配（在整个表达式成立的前提下尽量多的匹配），即可以理解为(.{1,14})先匹配到字符串结尾，然后因为要保证后面的表达式\s能匹配上，就从右往左“分配”（实际匹配顺序是从左往右），所以在遇到单词"drug"后面的空格就加~，而如果表达式中加上$，\s|$是选择关系，则选择$以便表达式(.{1,14})能匹配最多的字符串。</p></li></ol>