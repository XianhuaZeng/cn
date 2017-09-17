---
layout: post
title: SAS创建单级书签的PDF文件
date: 2015-07-16 22:18
author: 曾宪华
comments: true
tags: [PDF, PROC REPORT, 书签]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/images/2015/07/Bookmark1.jpg" rel="fancybox"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2015/07/Bookmark1.jpg" alt="Bookmark1" /></a></p><p>在用<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/odsug/61723/HTML/default/a002231506.htm" target="_blank">ODS PDF</a></span>生成PDF文件时，为了美观有时只要一层书签（如上图），下图为多层级书签。</p><p><a href="http://www.xianhuazeng.com/cn/images/2015/07/Bookmark2.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2015/07/Bookmark2.jpg" alt="Bookmark2" /></a><br />实现方法在SAS知识库中已经有了（<span style="text-decoration: none;"><a href="http://support.sas.com/kb/31/278.html" target="_blank">传送门</a></span>），代码（SAS 9.2 for Windows）搬运如下：</p><pre><code>data test; 
    set sashelp.class; 
    count=1; 
run; 

/* In the PROC REPORT, add this variable to the beginning of the COL 
statement, DEFINE it as either GROUP or ORDER, then add a BREAK BEFORE 
with a PAGE option and a null CONTENTS=. */
ods pdf file="test.pdf"; 
ods rtf file="test.rtf" toc_data contents ;                                            
                                                 
ods proclabel="First Node";
proc report nowd data=test contents="Second Node"; 
    col count name age height weight; 
    define count / group noprint; 
/* Note that CONTENTS= on the BREAK statement is new syntax for SAS 9.2 */
    break before count / contents="" page; 
run; 
 
ods _all_ close; 
</code></pre><p>在写代码时，需要注意一个问题，即在<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/a002473620.htm" target="_blank">PROC REPORT</a></span>下面不能使用<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a002294535.htm" target="_blank">BY</a></span>语句，否则单级书签无法实现。</p>