---
layout: post
title: SAS统计一篇文章中各字母的出现频率
date: 2018-02-17 10:01
author: 曾宪华
comments: no
tags: [PROC FREQ, 正则表达式, CALL PRXNEXT, PRXCHANGE]
categories: [程序人生]
---, 
<p>今天偶然看到一个古老的<a href="http://bbs.pinggu.org/thread-1570329-1-1.html" target="_blank"><span style="text-decoration: none;">帖子</span></a>：统计一篇文章中各字母的出现的次数和频率。先说统计单词的问题。最直接的方法应该是将文章按单词分成多行，每行一个单词，再用<a href="https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_freq_sect006.htm" target="_blank"><span style="text-decoration: none;">PROC FREQ</span></a>即可求得频数和频率。程序如下：
<pre><code>data have;
    TEXT="It is Teacher's Day today. On this special occasion I would like to extend my heartfelt congratulations to all teachers, Happy Teacher's Day! Of all teachers who have taught me since my early childhood, the most unforgettable one is my first English teacher in college, Ms. Zhang. It is she who has aroused my keen interest in the learning of English and helped me realize the importance of self-reliance. Born into a poor farmer's family in a mountainous area and educated in relatively primitive surroundings, I found myself lagging far behind in the first class in college, which happened to be Ms. Zhang's English class. I was really discouraged and frustrated, so I decided to drop out. Ms. Zhang was so keenly insightful that she had noticed my embarrassment in class. After class, she called me into the Teacher's Room and discussed the situation with me, earnestly and kindly, citing the example of Robinson Crusoe to motivate me to go ahead in spite of all kinds of difficulties. Be a man and rely on yourself, she nudged me. The next time we met, she brought me a simplified version of Robinson Crusoe and recommended that I finish reading it in a week and write a book report. Under her consistent and patient guidance, not only has my English been greatly improved, but my confidence and courage enhanced considerably. Rely on yourself and be a man, Ms. Zhang's inspiring words have been echoing in my mind. I will work harder and try my utmost to lay a solid foundation for my future career. Only by so doing can I repay Ms. Zhang's kindness and live up to her expectations of me, that is, to become a useful person and contribute to society.";
    i=1;
    do until(scan(TEXT, i)='');
        WORD=scan(TEXT, i);
        output;
        i+1;
    end;
run;

proc freq;
    tables WORD / noprint out=counts;
run;
</code></pre>
结果如下：<a href="http://www.xianhuazeng.com/cn/images/2018/02/Frequency_w.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/02/Frequency_w.jpg" alt="Frequency_w" /></a>
上面的方法也可以用来处理统计字母频率的问题，但是有点LOW。因为文章一长，行数就会非常多。下面介绍使用<a href="http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002295965.htm" target="_blank"><span style="text-decoration: none;">CALL PRXNEXT</span></a>的方法：
<pre><code>data have;
    TEXT="It is Teacher's Day today. On this special occasion I would like to extend my heartfelt congratulations to all teachers, Happy Teacher's Day! Of all teachers who have taught me since my early childhood, the most unforgettable one is my first English teacher in college, Ms. Zhang. It is she who has aroused my keen interest in the learning of English and helped me realize the importance of self-reliance. Born into a poor farmer's family in a mountainous area and educated in relatively primitive surroundings, I found myself lagging far behind in the first class in college, which happened to be Ms. Zhang's English class. I was really discouraged and frustrated, so I decided to drop out. Ms. Zhang was so keenly insightful that she had noticed my embarrassment in class. After class, she called me into the Teacher's Room and discussed the situation with me, earnestly and kindly, citing the example of Robinson Crusoe to motivate me to go ahead in spite of all kinds of difficulties. Be a man and rely on yourself, she nudged me. The next time we met, she brought me a simplified version of Robinson Crusoe and recommended that I finish reading it in a week and write a book report. Under her consistent and patient guidance, not only has my English been greatly improved, but my confidence and courage enhanced considerably. Rely on yourself and be a man, Ms. Zhang's inspiring words have been echoing in my mind. I will work harder and try my utmost to lay a solid foundation for my future career. Only by so doing can I repay Ms. Zhang's kindness and live up to her expectations of me, that is, to become a useful person and contribute to society.";
    TEXT_TEMP=TEXT;
    if _N_=1 then do;
        RE1=prxparse('s/(\b.+?\b)(\s.*?)(\b\1+\b)/\2\3/i');
        RE2=prxparse('/(\b.+?\b)(\s.*?)(\b\1+\b)/i');
    end;
    /*Remove repeated values*/
    do i=1 to 1000;
        TEXT=prxchange(RE1, -1, cats(TEXT));
        if not prxmatch(RE2, cats(TEXT)) then leave;
    end;
    do i=1 to countw(TEXT);
        WORD=scan(TEXT, i);
        COUNT=0;
        RE=prxparse('/\b'||cats(WORD)||'\b/i');
        START=1;
        STOP=length(TEXT_TEMP);
        call prxnext(RE, START, STOP, TEXT_TEMP, POSITION, LENGTH);
        do while(POSITION>0);
            COUNT+1;
            call prxnext(RE, START, STOP, TEXT_TEMP, POSITION, LENGTH);
        end;
        FREQ=COUNT/countw(TEXT_TEMP)*100;
        keep WORD COUNT FREQ;
        output;
    end;
run;
</code></pre>
值得注意的是，第一种方法会区分大小写，比如会分别统计‘Be’和‘be’的频率（见下图)。
<a href="http://www.xianhuazeng.com/cn/images/2018/02/Compare.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/02/Compare.jpg" alt="Compare" /></a>
第二种方法有使用<a href="https://zh.wikipedia.org/zh/正则表达式" target="_blank"><span style="text-decoration: none;">正则表达式</span></a>去重，所以会有点慢。当然也可以在最后使用<a href="http://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a002473666.htm" target="_blank"><span style="text-decoration: none;">PROC SORT</span></a>去重。第二种方法同样可以用来处理统计字母的问题，程序如下：</p>
<pre><code>data have;
    TEXT="It is Teacher's Day today. On this special occasion I would like to extend my heartfelt congratulations to all teachers, Happy Teacher's Day! Of all teachers who have taught me since my early childhood, the most unforgettable one is my first English teacher in college, Ms. Zhang. It is she who has aroused my keen interest in the learning of English and helped me realize the importance of self-reliance. Born into a poor farmer's family in a mountainous area and educated in relatively primitive surroundings, I found myself lagging far behind in the first class in college, which happened to be Ms. Zhang's English class. I was really discouraged and frustrated, so I decided to drop out. Ms. Zhang was so keenly insightful that she had noticed my embarrassment in class. After class, she called me into the Teacher's Room and discussed the situation with me, earnestly and kindly, citing the example of Robinson Crusoe to motivate me to go ahead in spite of all kinds of difficulties. Be a man and rely on yourself, she nudged me. The next time we met, she brought me a simplified version of Robinson Crusoe and recommended that I finish reading it in a week and write a book report. Under her consistent and patient guidance, not only has my English been greatly improved, but my confidence and courage enhanced considerably. Rely on yourself and be a man, Ms. Zhang's inspiring words have been echoing in my mind. I will work harder and try my utmost to lay a solid foundation for my future career. Only by so doing can I repay Ms. Zhang's kindness and live up to her expectations of me, that is, to become a useful person and contribute to society.";
    do i=1 to 26;
        CHAR=byte(i+64);
        COUNT=0;
        RE=prxparse('/'||CHAR||'/i');
        START=1;
        STOP=length(TEXT);
        call prxnext(RE, START, STOP, TEXT, POSITION, LENGTH);
        do while(POSITION>0);
            COUNT+1;
            call prxnext(RE, START, STOP, TEXT, POSITION, LENGTH);
        end;
        if COUNT>0 then do;
            FREQ=COUNT/length(compress(prxchange('s/\W//', -1, TEXT)))*100;
            output;
        end;
    end;
    keep CHAR COUNT FREQ;
run;
</code></pre>
结果如下：<a href="http://www.xianhuazeng.com/cn/images/2018/02/Frequency_c.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/02/Frequency_c.jpg" alt="Frequency_c" /></a>
当然，SAS有现成的函数<a href="http://support.sas.com/documentation/cdl/en/lrdict/64316/HTML/default/viewer.htm#a002260840.htm" target="_blank"><span style="text-decoration: none;">COUNTC</span></a>可以用来统计字母频率，程序如下：
<pre><code>data have;
    TEXT="It is Teacher's Day today. On this special occasion I would like to extend my heartfelt congratulations to all teachers, Happy Teacher's Day! Of all teachers who have taught me since my early childhood, the most unforgettable one is my first English teacher in college, Ms. Zhang. It is she who has aroused my keen interest in the learning of English and helped me realize the importance of self-reliance. Born into a poor farmer's family in a mountainous area and educated in relatively primitive surroundings, I found myself lagging far behind in the first class in college, which happened to be Ms. Zhang's English class. I was really discouraged and frustrated, so I decided to drop out. Ms. Zhang was so keenly insightful that she had noticed my embarrassment in class. After class, she called me into the Teacher's Room and discussed the situation with me, earnestly and kindly, citing the example of Robinson Crusoe to motivate me to go ahead in spite of all kinds of difficulties. Be a man and rely on yourself, she nudged me. The next time we met, she brought me a simplified version of Robinson Crusoe and recommended that I finish reading it in a week and write a book report. Under her consistent and patient guidance, not only has my English been greatly improved, but my confidence and courage enhanced considerably. Rely on yourself and be a man, Ms. Zhang's inspiring words have been echoing in my mind. I will work harder and try my utmost to lay a solid foundation for my future career. Only by so doing can I repay Ms. Zhang's kindness and live up to her expectations of me, that is, to become a useful person and contribute to society.";
    do i=1 to 26;
        CHAR=byte(i+64);
        COUNT=countc(TEXT, CHAR, 'i');
        if COUNT>0 then do;
            FREQ=COUNT/length(compress(prxchange('s/\W//', -1, TEXT)))*100;
            output;
        end;
    end;
    keep CHAR COUNT FREQ;
run;
</code></pre>
