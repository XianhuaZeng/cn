---
layout: post
title: SAS中哈希表的连接问题
date: 2015-09-13 18:47
author: 曾宪华
comments: true
tags: [Hash Object, Inner join, Left join, Right join, 哈希表]
categories: [程序人生]
---
<p><span style="text-decoration: none;"><a href="https://zh.wikipedia.org/wiki/%E5%93%88%E5%B8%8C%E8%A1%A8" target="_blank">哈希表</a></span>即散列表（Hash table），是根据关键码值(Key value)而直接进行访问的数据结构。也就是说，它通过把关键码值映射到表中一个位置来访问记录，以加快查找的速度。这个映射函数叫做散列函数，存放记录的数组叫做散列表。在SAS中使用哈希表十分简单，你并不需要知道SAS内部是怎么实现的，只需要知道哈希表是存储在内存中的，查找是根据key值直接获得存储的地址的精确匹配。加上使用哈希表合并数据集时不用排序的优点，在实际应用中可以极大的提高程序运行效率，尤其是数据集较大的时候。但是由于哈希表是放到内存中的，因此对内存有一定要求！</p>
<p>在实际应用中，我们通常会碰到要选择把哪个数据集放到哈希表中的问题。在<span style="text-decoration: none;"><a href="http://support.sas.com/publishing/authors/burlew.html" target="_blank">Michele M. Burlew</a></span>的《<span style="text-decoration: none;"><a href="https://www.sas.com/store/books/categories/usage-and-reference/sas-hash-object-programming-made-easy/prodBK_62230_en.html" target="_blank">SAS® Hash Object Programming Made Easy</a></span>》一书有这样一段话：</p>
<blockquote>
<p>While it may seem counterintuitive, it may be more efficient to load your larger data set into the hash object, especially if it is your lookup data set. The action of reading your smaller data set sequentially and looking up information in a large hash object is likely to process more quickly than if you read your larger data set sequentially and look up information for each of its observations in a small hash object.</p>
</blockquote>
<p>从这句话可以看出，将最大的数据集放到哈希表中更为高效，但是在实际应用中根据程序的目的还是需要做出选择，即选择左连接（A left join B）还是右连接（A right join B）。其实很简单，如果数据集不是很大的时候可以这样处理：如果是左连接那么就把数据集B放到哈希表中；如果是右连接就把数据集A放到哈希表中；如果是内接连（A inner join B）那么就把大的放到哈希表中。对于前两种连接如果不按上述处理，那么就需要多写几行额外的代码来修改哈希表里的内容。</p>
<p>另外，我们还会碰到多个数据集用哈希表进行合并的情况，如果KEY是同一个变量，那么任意放N-1个数据集放到哈希表中，直接用以下语句即可实现：</p>
<pre><code>if h1.find()=0 and h2.find()=0 and ... and hn.find()=0;
</code></pre>
<p>如果KEY是不是同一个变量，那么就要单独指定KEY，语句如下：</p>
<pre><code>rc=h1.find();
rc=h2.find(key: VAR);
...
rc=hn.find(key: VAR_N);
</code></pre>
