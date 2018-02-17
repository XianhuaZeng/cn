---
layout: post
title: SAS求子集
date: 2017-11-26 23:01
author: 曾宪华
comments: no
tags: [PROC SUMMARY, CALL ALLCOMB, BAND]
categories: [程序人生]
---
<p>前几天在微信群里看到一个问题：求一个数组的子集。SAS中实现排列的方法有多种，最易懂的方法应该是<a href="http://support.sas.com/documentation/cdl/en/proc/65145/HTML/default/viewer.htm#p1nq9wozc7uw3hn1uni965howprl.htm" target="_blank"><span style="text-decoration: none;">PROC SUMMARY</span></a>以及<a href="http://support.sas.com/documentation/cdl/en/lefunctionsref/63354/HTML/default/viewer.htm#p0yx35py6pk47nn1vyrczffzrw25.htm" target="_blank"><span style="text-decoration: none;">CALL ALLCOMB</span></a>，两种方法的代码在<a href="https://stackoverflow.com/questions/29340151/generate-all-unique-permutations-of-an-array-in-sas" target="_blank"><span style="text-decoration: none;">这里</span></a>。下面介绍一个DATA步一步到位的方法：</p>
<pre><code>data subsets;
    array set1[*] $ a b c d e ('a', 'b', 'c', 'd', 'e');
    array set2[*] bin1-bin5;
    array set3[*] $ ele1-ele5;
    do i=0 to dim(set1)-1;
        set2(i+1)=2**(dim(set1)-(i+1));
    end;
    do j=0 to 2**dim(set1)-1;
        call missing(of ele:);
        do i=1 to dim(set1);
            if band(j, set2(i)) then set3(i)=set1(i);
        end;
        SUBSETS=cats(of ele:);
        keep SUBSETS;
        output;
    end;
run;
</code></pre>
简单说下上面方法的思路，我们知道一个具有n个元素的集合的子集个数是2的n次方，因为每个元素只有出现不出现两种情况。首先将数组元素转换成二进制值，‘abcde’对应的值为‘00011111’，各元素对应的值分别为：2的4次方16，2的3次方8，2的2次方4，2的1次方2，2的0次方1。然后用函数<a href="http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a000245865.htm" target="_blank"><span style="text-decoration: none;">BAND</span></a>将数字0-31（0代表空集）分别和各元素做位运算，返回结果为真则将元素值赋值给新的数组，最后将新数组连接起来即为子集。