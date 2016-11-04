---
layout: post
title: 正则表达式之贪婪匹配 VS 非贪婪匹配
date: 2015-04-24 22:31
author: Xianhua.Zeng
comments: true
tags: [Regular Expression, 正则表达式]
categories: [程序人生]
---
<p>我们知道，许多程序设计语言都支持利用功能强大的<span style="text-decoration: none;"><a href="http://zh.wikipedia.org/zh/%E6%AD%A3%E5%88%99%E8%A1%A8%E8%BE%BE%E5%BC%8F" target="_blank">正则表达式</a></span>进行字符串操作，SAS中也有用正则表达式的<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002601591.htm" target="_blank">PRX Function</a></span>，平时在写正则表达式的时候会常碰到贪婪匹配与非贪婪匹配的问题。</p><p>贪婪匹配是指在保证后面的表达式都能匹配上的前提下尽可能多匹配，如有字符串STRING='Table 1.1 Subject Disposition including Screening Failures - All Screened Subjects                     3';</p><p>表达式：</p><pre><code>"s/(Figure|Listing|Table)\s(.+)\s(.+)\s+\d/"
</code></pre><p>对于第二个括号，因为是贪婪匹配，可以理解为先匹配到字符串结尾，然后因为要保证后面的表达式都能匹配上，就从右往左“分配”（实际匹配顺序是从左往右），\d对应为3，\s+对应为紧挨3之前的一个空格（记为空格1），第三个括号(.+)对应为紧挨空格1前面的一个空格（记为空格2），\s对应为紧挨空格2前面的一个空格（记为空格3），那第二个括号匹配的就是1.1 Subject Disposition including Screening Failures - All Screened Subjects + Subjects与数字3之间除了空格1、2、3外的空格（如果这之间的空格数大于3）。</p><p><!--more--></p><p>当然，这是对应原字符串数字3前面至少有3个空格，如果少于三个的话结果就变了，例如原字符串数字3前面只有有2个空格，即：STRING='Table 1.1 Subject Disposition including Screening Failures - All Screened Subjects  3'; 表达式同上，则结果就是：对于第二个括号，因为是贪婪匹配，可以理解为先匹配到字符串结尾，然后因为要保证后面表达式都能匹配上，就从右往左“分配”（实际匹配顺序是从左往右），\d对应为3，\s+对应为紧挨3之前的一个空格，第三个括号(.+)对应为Subjects+紧随其后的空格，\s对应为紧挨Subjects前面的一个空格，那第二个括号匹配的就是1.1 Subject Disposition including Screening Failures - All Screened。</p><p>非贪婪匹配是在保证后面的表达式都能匹配上的前提下尽可能少匹配。</p>