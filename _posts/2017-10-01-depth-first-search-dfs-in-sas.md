---
layout: post
title: SAS成语接龙
date: 2017-10-01 22:57
author: 曾宪华
comments: no
tags: [DFS, HASH, PRXCHANGE, 成语接龙]
categories: [程序人生]
---
<p>今年国庆长假没有出游计划，我只能在朋友圈周游世界了。周游世界的同时正好有点时间来博客除除草了，2017年已过四分之三，目前只留下一篇博客（囧）。今天无意间翻到3年前回复过的一个<span style="text-decoration: none;"><a href="http://bbs.pinggu.org/thread-3204728-1-1.html" target="_blank">帖子</a></span>：用SAS做成语接龙。编程思路如下：首先导入<span style="text-decoration: none;"><a href="http://www.xianhuazeng.com/cn/images/2017/10/Idiom_list.zip">成语大全</a></span>，提取首尾汉字，将所有成语放入哈希表中，然后将成语最后一个汉字去哈希表中查询匹配，如果成功匹配则把哈希表中匹配的成语最后一个汉字做为KEY去查询匹配，直到遍历整个哈希表。更新的代码（SAS 9.2 for Windows）如下：</p><pre><code>/*导入成语列表*/
proc import datafile="D:\Demo\成语大全.txt"
    out=idiom_list
    replace;
    getnames=no;
    guessingrows=32767;
run;

/*提取首尾汉字*/
data idiom_list;
    set idiom_list(rename=VAR1=IDIOM);
    length FIRST_C END_C $2.;
    FIRST_C=prxchange('s/^(.{2}).+/\1/', 1, cats(IDIOM));
    END_C=prxchange('s/.+(.{2})$/\1/', 1, cats(IDIOM));
run;

/*初始成语*/
%let start_idiom=3;

/*查询*/
data _null_;
    if _n_=1 then do;
        if 0 then set idiom_list;
        dcl hash h(multidata: 'Y');
        h.definekey('FIRST_C');
        h.definedata('IDIOM', 'FIRST_C', 'END_C');
        h.definedone();
    end;;
    do until(last);
        set idiom_list idiom_list end=last;
        h.add();
    end;
    set idiom_list(where=(IDIOM='老老实实') rename=END_C=FIRST_C keep=IDIOM END_C);
    put IDIOM=;
    if h.find(key: FIRST_C)=0 then put IDIOM=;
    do i=1 to 100;
        if h.find(key: END_C)=0 then put IDIOM=;
        if h.find(key: END_C)=0 then do;            
            rc=h.find_next(key: END_C);         
            put IDIOM=;
        end;
    end;
run;
</code></pre>
<p>结果如下：胸有成竹、竹苞松茂、茂林修竹、竹报平安、安安稳稳、稳操胜券。</p>
<p>上面的帖子其实有点像<span style="text-decoration: none;"><a href="https://zh.wikipedia.org/wiki/深度优先搜索" target="_blank">深度优先搜索</a></span>（Depth-First-Search，简称DFS）。除了<span style="text-decoration: none;"><a href="https://zh.wikipedia.org/wiki/%E5%93%88%E5%B8%8C%E8%A1%A8" target="_blank">哈希表</a></span>的方法，还可以用双SET加<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a000173782.htm" target="_blank">KEY</a></span>选项来解决。比如这个<span style="text-decoration: none;"><a href="http://www.mysas.net/forum/forum.php?mod=viewthread&tid=13154" target="_blank">帖子</a></span>。数据集如下图：</p>
<p><a href="http://www.xianhuazeng.com/cn/images/2017/10/DFS1.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2017/10/DFS1.jpg" alt="DFS1" /></a></p>
<p>楼主的问题是找最高级，如上图中ID为2的下一级是5，5的下一级是9，9的下一级是102，102没有下一级了，那么2的最高级就是102。编程思路和上面HASH方法类似，即用当前的KONZERNID作为索引ID去查找匹配，直到匹配不成功。更新的代码如下：</p>
<pre><code>data konzern;
    input ID KONZERNID;
cards;
1 18
2  5
3 18
4 24
5 9
6 9
7 15
8 12
9 102
;
run;

/*Create index*/
data konzern(index=(ID));
    set konzern;
run;

/*Lookup*/
data highestid;
    set konzern;
    ID_INIT=ID;
    KONZERNID_INIT=KONZERNID;
    HIGHESTID=ID;
    do i=1 to 100;
        ID=KONZERNID;
        HIGHESTID=ID;
        set konzern key=ID/unique;
        if _IORC_^=0 then leave;
    end;
    keep ID_INIT KONZERNID_INIT HIGHESTID;
run;
</code></pre>   
<p>结果如下：</p>
<p><a href="http://www.xianhuazeng.com/cn/images/2017/10/DFS2.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2017/10/DFS2.jpg" alt="DFS2" /></a></p>
<p>以两种方法各有利弊，因为哈希表是存储在内存中，所以当数据较大时可能会导致内存不足。而第二种方法因为有多次SET操作，数据较大时效率会大大降低。故在实际应用中应该根据具体情况而定</p>