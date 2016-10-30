---
layout: post
title: SAS汉字转拼音解决方案
date: 2015-07-12 02:57
author: Xianhua.Zeng
comments: true
tags: [PRXCHANGE, 汉字转拼音]
categories: [程序人生]
---
<p>在数据处理的工作中，可能会碰到要把汉字转换为对应拼音的问题，如将大量的中文姓名或名称转换成对应的拼音。之前写过一个简单的SAS程序来实现此目的，其主要步骤为：首先要用到<span style="text-decoration: underline;"><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/07/Hanzi_Pinyin.zip">汉字拼音对照表</a></span>，然后将汉字设为宏变量，解析的值为其对应的拼音，接着将处理变量中的每个汉字前插入一个宏解析符号“&amp;”，最后用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/mcrolref/61885/HTML/default/viewer.htm#a000210258.htm" target="_blank">RESOLVE</a></span>函数在DATA步执行时解析得到对应的拼音，代码（SAS 9.2 for Windows）如下：<!--more--></p><pre><code>/*导入汉字拼音对照表*/                                                                  
proc import datafile="D:\Demo\GB2312汉字拼音对照表（6727字）.txt"                       
    out=Hanzi_Pinyin(rename=(VAR1=HANZI VAR2=PINYIN))                                  
    dbms=dlm                                                                           
    replace;                                                                           
    guessingrows=1419;                                                                 
    delimiter=' ';                                                                     
    getnames=no;                                                                       
run;          
                                                                         
/*创建汉字宏变量*/                                                                      
data _null_;                                                                           
    set Hanzi_Pinyin;                                                                  
    call symputx(HANZI, PINYIN);                                                       
run;         
                                                                          
/*汉字列表*/                                                                           
proc sql noprint;                                                                      
    select distinct HANZI into :Hanzilst separated by "|"                              
        from Hanzi_Pinyin                                                              
    ;                                                                                  
quit;                                                                                  
                                                                 
/*防止Log有字符串比262个字符长的警告*/                                                   
options noquotelenmax;                                                                 

/*例子*/
data demo;                                                                             
    length HANZI $200.;                                                                
    HANZI='生活就像一台老虎机，你永远不会知道会蹦出什么来';                                
run;                                                                                   
                                                 
data want;                                                                             
    set demo;                                                                          
    PINYIN=resolve(prxchange("s/(&amp;Hanzilst)/ &amp;\1./", -1, HANZI));
    PINYIN=prxchange('s/(，| |-|_)\s/\1/', -1, cats(PINYIN));                      
run;
</code></pre><p>结果如下：</p><p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/07/Result.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/07/Result.jpg" alt="Result" /></a>这个方法的优点是简洁且不用考虑分隔符，缺点是暂时不能解决汉字多音字拼音的问题。此方法还可以巧妙地用在很多地方，比如这个<span style="text-decoration: underline;"><a href="http://bbs.pinggu.org/thread-2328507-1-1.html" target="_blank">帖子</a></span>。</p>