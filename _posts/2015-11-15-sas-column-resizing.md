---
layout: post
title: 批量改变SAS数据集字符型变量的长度
date: 2015-11-15 11:22
author: Xianhua.Zeng
comments: true
tags: [CDISC, Column Resizing, DICTIONARY Tables, SASHELP Views]
categories: [程序人生]
---
<p>      临床试验的SAS程序猿/媛都知道，<span style="text-decoration: underline;"><a href="http://www.fda.gov/downloads/ForIndustry/DataStandards/StudyDataStandards/UCM312964.pdf" target="_blank">FDA</a></span>对所提交的数据集的大小是有限定的，因为数据集过大在操作时会有点麻烦（比如打开会很慢），所以当我们生成最终的数据集时就要进行一个操作：按照字符型变量值的最大长度来重新定义变量的长度，以删除多余的空格从而减少数据集的大小。下面贴上我去年写的实现这一目的的宏程序：<!--more--></p><pre lang="SAS">%macro relngth(slib=, mem=);
proc sql noprint;
    select cats(n(NAME)) into :vnum
        from dictionary.columns
        where LIBNAME=upcase("&amp;slib") and MEMNAME=upcase("&amp;mem") and  TYPE='char'
        order VARNUM
        ;

    select cats(NAME) into :var1 -:var&amp;vnum
        from dictionary.columns
        where LIBNAME=upcase("&amp;slib") and MEMNAME=upcase("&amp;mem") and  TYPE='char'
        order VARNUM
        ;

    select %do i=1 %to %eval(&amp;vnum-1); "&amp;&amp;var&amp;i"||' char('||cats(max(lengthn(&amp;&amp;var&amp;i)))||'), '|| %end;
                                       "&amp;&amp;var&amp;vnum"||' char('||cats(max(lengthn(&amp;&amp;var&amp;i)))||')'
        into :modlst
        from &amp;slib..&amp;mem
        ;

    alter table &amp;slib..&amp;mem
        modify &amp;modlst
        ;
quit;
%mend relngth;

/*SDTM数据集所在的逻辑库名字*/
%let slib=TRANSFER;

options NOQUOTELENMAX;

data _null_;
    set sashelp.vtable(where=(LIBNAME="&amp;slib"));
    call execute('%nrstr(%relngth(slib=&amp;slib, mem='||cats(MEMNAME)||'))');
run;
</pre><p>      注意，上面的程序中我并没有直接用METADATA中的DATADEF这个数据集，而是用了视图SASHELP.VTABLE，这是为了说明另一个问题：SASHELP.VTABLE虽然可以直接在DATA步中使用，但是不建议使用，因为在我们使用这个视图时SAS后台执行视图的操作并没有优化，而且在LOG中有可能看到类似下面的<span style="text-decoration: underline;"><a href="http://support.sas.com/kb/15/379.html" target="_blank">CEDA</a></span>信息：</p><blockquote><p>INFO: Data file libref.member.DATA is in a format native to another host or the file encoding does not match the session encoding. Cross Environment Data Access will be used, which may require additional CPU resources and reduce performance.</p></blockquote><p>这些都会大大的影响程序运行效率，故建议使用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/sqlproc/62086/HTML/default/viewer.htm#a001385596.htm" target="_blank">数据字典</a></span>，原因在SAS在线文档中有说明，搬去如下：</p><blockquote><p>When querying a DICTIONARY table, SAS launches a discovery process that gathers information that is pertinent to that table. Depending on the DICTIONARY table that is being queried, this discovery process can search libraries, open tables, and execute views. Unlike other SAS procedures and the DATA step, PROC SQL can mitigate this process by optimizing the query before the discovery process is launched. Therefore, although it is possible to access DICTIONARY table information with SAS procedures or the DATA step by using the SASHELP views, it is often more efficient to use PROC SQL instead.</p></blockquote><p>程序如下：</p><pre lang="SAS">/*SDTM数据集所在的逻辑库名字*/
%let slib=TRANSFER;

options NOQUOTELENMAX;

proc sql;
    create table datadef as
        select MEMNAME
        from dictionary.tables
        where LIBNAME=upcase("&amp;slib")
        ;
quit;

data _null_;
    set datadef;
    call execute('%nrstr(%relngth(slib=&amp;slib, mem='||cats(MEMNAME)||'))');
run;
</pre><p>当然还可以使用<span style="text-decoration: underline;"><a href="http://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a000085768.htm" target="_blank">PROC CONTENTS</a></span>来得到数据集DATADEF，不过还是直接使用METADATA中的DATADEF这个数据集最方便了，程序如下：</p><pre lang="SAS">/*SDTM数据集所在的逻辑库名字*/
%let slib=TRANSFER;

/*METADATA所在的逻辑库名字*/
%let mlib=META;

options NOQUOTELENMAX;

data _null_;
    set &amp;mlib..datadef(keep=DATASET);
    call execute('%nrstr(%relngth(slib=&amp;slib, mem='||cats(DATASET)||'))');
run;
</pre><p>      最后推荐几个链接：<span style="text-decoration: underline;"><a href="http://www.fda.gov/BiologicsBloodVaccines/DevelopmentApprovalProcess/ucm209137.htm" target="_blank">传送门一</a></span>、<span style="text-decoration: underline;"><a href="http://www.fda.gov/downloads/Drugs/DevelopmentApprovalProcess/FormsSubmissionRequirements/ElectronicSubmissions/UCM254113.pdf" target="_blank">传送门二</a></span>、<span style="text-decoration: underline;"><a href="http://www.phusewiki.org/wiki/index.php?title=Data_Sizing_Best_Practices_Recommendation" target="_blank">传送门三</a></span>。</p>
