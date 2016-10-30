---
layout: post
title: 正则表达式模式修饰词
date: 2015-12-06 12:35
author: Xianhua.Zeng
comments: true
tags: [Modifier, Regular Expression, 正则表达式]
categories: [程序人生]
---
<p>在介绍修饰符之前，首先介绍一下在<span style="text-decoration: underline;"><a href="https://www.perl.org/" target="_blank">Perl</a></span>中的两个基本函数：</p>
<blockquote>
<p>match( $string, $pattern );<br />
 subst( $string, $pattern, $replacement );</p>
</blockquote>
<p>即匹配和替换，缩写为<code>m//</code>和<code>s///</code>（或<code>s###</code>），对应到SAS中的函数就是<span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002296115.htm" target="_blank">PRXMATCH</a></span>和<span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002601591.htm" target="_blank">PRXCHANGE</a></span>，即<code>m/PATTERN/</code>和<code>s/PATTERN/REPLACEMENT/</code>（或<code>s#PATTERN#REPLACEMENT#</code>）。<!--more-->注意其中的字母m（表示开始匹配的操作）可以省略而字母s不能省略。模式修饰词也称为选项，是指放在<code>m//</code>和<code>s///</code>最后一个分隔符后的一个字母，例如字母<code>/o/i/s/m/g</code>。由于SAS并没有包含整个Perl语言，所以SAS中只支持部分的模式修饰词，下面简单介绍一下两个常用的修饰符：</p>
<ol>
	<li><code>/o</code>，只编译表达式一次，这样可提高效率。如果我们将表达式写在函数<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002295977.htm" target="_blank">PRXPARSE</a></span>中，如下所示：
<pre><code>re=prxparse('/(.+?)\s+(\d+)/');
</code></pre>
这种写法SAS只编译表达式一次，等同于下面这种写法：
<pre><code>pattern='/(.+?)\s+(\d+)/o'; 
re=prxparse(pattern);</code></pre>
</li>
	<li><code>/i</code>，忽略字母大小写，如下面的表达式的第一个组，可以成功匹配字符串PERL也可以匹配字符串Perl。
<pre><code>pattern='/(Perl)\s+(\d+)/io'; 
re=prxparse(pattern);</code></pre>
</li>
</ol>
<p>上面有提到另一种替换的操作符：<code>s###</code>（<code>s#PATTERN#REPLACEMENT#</code>），下面介绍一下这个操作符的用处。我们知道在表达式中如果要匹配一些元字符的时候，如<code>/, (, .</code>，则需要在元字符前面加一个转义符\来屏蔽元字符的特殊含义以达到匹配元字符本身的目的。而当<code>PATTERN</code>或<code>REPLACEMENT</code>中含有多个元字符，则需要写多个转义符<code>\</code>，这样就会有点麻烦。所以这种情况就可用<code>s###</code>（<code>s#PATTERN#REPLACEMENT#</code>），因为在这种操作符中可以不用使用转义符。如下例：</p>
<pre><code>path=prxchange("s/.*\/(.*)\/\w*\.jpg/\/home\/cn\/picture\/$1\/Cheshire_cat.jpg/", 1, "http://www.xianhuazeng.com/cnuploads/2015/Cheshire_cat.jpg");
path=prxchange("s#.*/(.*)/\w*.jpg#/home/cn/picture/$1/Cheshire_cat.jpg#", 1, "http://www.xianhuazeng.com/cnuploads/2015/Cheshire_cat.jpg");
</code></pre>