---
layout: post
title: 如何用SAS发送邮件
date: 2016-06-11 15:53
author: 曾宪华
comments: true
tags: [Email, FILENAME, 发邮件]
categories: [程序人生]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2016/06/Email.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2016/06/Email.jpg" alt="Email" /></a></p>
<p>SAS程序猿/媛在工作中可能会碰到需要用SAS来发送邮件通知的问题，如将一个宏程序执行信息或者某个程序生成的结果发送给指定用户。如上图，就是一个宏执行完毕后发送的一个邮件通知，内容包括宏程序是否正确执行完毕、生成结果的路径以及结果的一个简单的概括。下面记录下我用到的两种SAS发送邮件方法：</p>
<ol>
	<li><span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/lestmtsref/63323/HTML/default/viewer.htm#n0ig2krarrz6vtn1aw9zzvtez4qo.htm" target="_blank">FILENAME_+ EMAIL</a></span>，这个语句可以实现有FORMAT的内容在邮件正文中。比如上图中定义的颜色。程序如下：

<pre><code>filename sende email to='huazizeng@gmail.com' subject='Demo';

ods listing close;
ods html body=sende;

options nocenter;

ods text='Execution of gmCompareReport has completed.';
ods text=' ';
ods text="Full report can be found here: &amp;epath";
ods text=' ';

proc report data=summary nowd missing spacing=0 split="@" contents="";
run;

ods html close;
ods listing;</code></pre>

上面是不需要设置邮件信息的，设置的程序如下：

<pre><code>options emailsys='smtp' emailauthprotocol='login' emailhost='smtp.163.com' emailid='uemailid@163.com' emailpw='XXXXXXXX';

filename sende email to='huazizeng@gmail.com' subject='Demo';

data _null_;
    file sende;
    put 'Hello world!';
run;
</code></pre>
</li>
	<li><a href="https://en.wikipedia.org/wiki/Mailx" target="_blank"><span style="text-decoration: none;">MAILX</span></a>，程序如下：

<pre><code>/*正文*/
x 'cat test.txt | mailx -m -s "subject" huazizeng@gmail.com';
/*附件*/
x 'uuencode test.txt attach.txt | mailx -m -s "subject" huazizeng@gmail.com';
/*正文 + 附件*/
x '(cat test.txt; uuencode test.txt attach.txt) | mailx -m -s "subject" huazizeng@gmail.com';</code></pre>
</li>
</ol>
<p>需要注意的是，第二种方法中的文本如果有格式（比如有对齐的格式），那么在邮件正文中的格式可能会不正确，对于这种情况建议用第一种方法。</p>