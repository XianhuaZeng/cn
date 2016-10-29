---
layout: post
title: SAS数据集中重复记录问题
tags: [Hash Object, NODUPKEY, 去重]
categories: [程序人生]
---
<p>      SAS程序猿在处理数据的时候，经常会遇到要处理有关重复记录的问题，其中有些重复记录是我们需要的，而有的则是多余的。如果是多余的直接去重：</p><ol><li><span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a000146878.htm" target="_blank">PROC SORT</a></span>，其中有两个选项NODUPKEY、NODUPRECS（NODUP），第一个是按照BY变量来去重，第二是比较整条记录来去重，重复的记录可以用DUPOUT=来保留。程序如下：<pre lang="SAS">proc sort data=sashelp.class out=unq nodupkey dupout=dup;
    by WEIGHT;
run;
</pre></li><li><a href="http://support.sas.com/documentation/cdl/en/lrcon/65287/HTML/default/viewer.htm#n1b4cbtmb049xtn1vh9x4waiioz4.htm" target="_blank"><span style="text-decoration: underline;">HASH</span></a>，程序如下：<pre lang="SAS">data _null_;
    if 0 then set sashelp.class;
    if _n_=1 then do;
        declare hash h(dataset: 'sashelp.class', ordered: 'y');
        h.definekey('WEIGHT');
        h.definedata(all:'y');
        h.definedone();
    end;
    h.output(dataset: 'uni');
run;</pre></li></ol><p>如果重复记录是需要保留以备后用则可以用下面几种方法：</p><ol><li>DATA步，程序如下：<pre lang="SAS">proc sort data=sashelp.class out=class;
    by WEIGHT;
run;

data uni dup;
    set class;
    by WEIGHT;
    if first.WEIGHT and last.WEIGHT then output uni;
    else output dup;
run;
</pre></li><li><span style="text-decoration: underline;"><a href="https://support.sas.com/documentation/cdl/en/proc/61895/HTML/default/viewer.htm#a002473669.htm" target="_blank">PROC SQL</a></span>，程序如下：<pre lang="SAS">proc sql;
    create table uni as
        select * 
        from sashelp.class
        group by WEIGHT
        having count(*) = 1
        ;

    create table dup as
        select * 
        from sashelp.class
        group by WEIGHT
        having count(*) &gt; 1
        ;
quit;
</pre></li><li><a href="http://support.sas.com/documentation/cdl/en/lrcon/65287/HTML/default/viewer.htm#n1b4cbtmb049xtn1vh9x4waiioz4.htm" target="_blank"><span style="text-decoration: underline;">HASH</span></a>，程序（SAS9.2+）如下：<pre lang="SAS">data uni(drop=rc: i);
    if _n_=1 then do;
        if 0 then set sashelp.class;
        dcl hash h1(dataset: 'sashelp.class', multidata:'y');
        h1.definekey('WEIGHT');
        h1.definedata(all: 'yes');
        h1.definedone();

        dcl hash h2(dataset: 'sashelp.class');
        dcl hiter hi('h2');
        h2.definekey('WEIGHT');
        h2.definedone();
    end;
    rc1=hi.first();
    do while(rc1=0);
        rc2= h1.find();
        i=0;
        do while(rc2=0 and i &lt; 2);
            i+1;
            rc2=h1.find_next();
        end;
        if i &lt; 2 then do;
            output;
            if i &lt; 2 then h1.remove();
        end;
        rc1=hi.next();
    end;
    h1.output(dataset: 'dup');
run;
</pre></li></ol><p>      不管是去重还是保留重复的记录，上面几种方法中HASH行数都是最多的，但是这种方法在去重之前不用排序，故当处理的数据集较大时建议使用此方法以提高效率。</p>
