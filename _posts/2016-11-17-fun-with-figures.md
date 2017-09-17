---
layout: post
title: 一道小学生的趣味数学题
date: 2016-11-17 22:54
author: 曾宪华
comments: true
tags: [PRXCHANGE]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2016/11/Fun.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2016/11/Fun.jpg" alt="Fun" /></a></p>据说上图（来源于网络）中这道小学生趣味题只要聪明一点的小学生都可以解出来，成年人估计只要一分钟。我也试着用SAS来解答， 思路如下：首先获取所有的数字出现的位置，然后与完整的位置（1234）比较，去重存异；根据题中的提示每次输入有两位数字正常且位置都不对，故排除只出现一次或者出现4次的数字；最后将数字的多个位置和已被占的单一位置进行比较，去重存异。重复这一操作直到得到每个数字的正确位置。完整的程序如下：
<pre><code>%let code=6087 5173 1358 3825 2531;

data temp;
    length CODE $200;
    retain INC 0;
    CODE="&code";
    do I=1 to length(CODE);
        CODE_IND=cats(substr(CODE, I, 1));
        if missing(CODE_IND) then INC=I;
        POSITION=cats(I-INC);
        if ^missing(CODE_IND) then output;
    end;
    keep CODE_IND POSITION;
    proc sort nodupkey;
    by CODE_IND POSITION;
run;

data temp;
    set temp;
    by CODE_IND;
    retain POSITION_;
    if first.CODE_IND then POSITION_=POSITION;
    else POSITION_=cats(POSITION_, POSITION);
    POSITION=prxchange('s/['||cats(POSITION_)||']//', -1, '1234');
    if last.CODE_IND and length(POSITION_) ^ in (1, 4);
    keep CODE_IND POSITION;
run;

%macro unipos();
proc sql noprint;
    select distinct POSITION into :pos separated by '|'
        from temp
        where length(POSITION)=1
        ;
quit;

data temp;
    set temp;
    if length(POSITION)>1 then POSITION=prxchange("s/&pos//", -1, POSITION);
run;
%mend unipos;

%macro check();
%do i=1 %to 4;
    %if "&pos"^="1|2|3|4" %then %unipos;
%end;
%mend check;

%let pos=;

%check

proc sql noprint;
    select distinct CODE_IND, POSITION into :code separated by ' ', :dummy
        from temp
        order by POSITION
        ;
quit;

%put &code;
</code></pre>
一道简单的题，我却写了这么多，我得多无聊啊。。。