---
layout: post
title: 用Python操控Word
date: 2018-06-18 21:01
author: 曾宪华
comments: true
tags: [Python, python-docx, PharmaSUG, PharmaSUG 2018]
categories: [程序人生]
---
<p>4月底，我带着自己水的一篇<span style="text-decoration: none;"><a href="http://www.pharmasug.org/proceedings/2018/QT/PharmaSUG-2018-QT08.pdf" target="_blank">文章</a></span>，从深圳奔赴美帝西雅图参加了一个<span style="text-decoration: none;"><a href="http://www.pharmasug.org/us/index.html" target="_blank">制药行业软件用户组会议</a></span>。听了一些报告，收获不少。在众多报告中，有一篇题目为<span style="text-decoration: none;"><a href="http://www.pharmasug.org/proceedings/2018/AD/PharmaSUG-2018-AD12.pdf" target="_blank">Why SAS Programmers Should Learn Python Too</a></span>的文章有点意思。不过在我看来，文章中的例子并没有很好地体现出<span style="text-decoration: none;"><a href="https://www.python.org" target="_blank">Python</a></span>的强大，因为那几个例子用<span style="text-decoration: none;"><a href="https://en.wikipedia.org/wiki/Shell_script" target="_blank">Linux Shell脚本</a></span>实现也很简单。不可否认，如果你想选择一种语言来入门编程，那么Python绝对是首选！但是对于SAS程序猿/媛来说，我觉得现阶段没有太多必要去学Python，因为行业的原因，Python对SAS程序猿/媛日常的编程工作几乎没有什么用。除非你和我一样，喜欢折腾代码，或者你想转行业做深度码农，那Python是必须掌握的语言，因为Python有各种强大的库。下面就让我们来感受下<span style="text-decoration: none;"><a href="https://python-docx.readthedocs.io/en/latest/" target="_blank">python-docx</a></span>库的强大之处吧！
<p>我们知道，带项目的SAS程序猿/媛在交项目时候需要准备一个时间戳的文件（假定这个文件是行业都要用到的），用来证明各项工件是有序进行的，如下图（注：因为是公司内部文件，所以单元格内容有做删减）。<p>
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Checklist.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Checklist.jpg" alt="Checklist" /></a></p>
在没有程序实现的情况下，我们每次交项目更新这个文件只能是一个一个地复制和粘贴。虽然要更新的单元格不多，但是手动更新还是有点费时。我能想象到用SAS实现（我不会，囧）肯定要比Python麻烦，所以我就用Python来实现。简单介绍一下用Python实现的思路：首先我们要找出需要更新单元格的位置。代码如下：
<pre><code># coding=utf-8

from docx import Document

chklst = Document('C:\\Users\\Xianhua\\Documents\\Python\\Checklist.docx')

table = chklst.tables[2] # 第三个表格

for i in range(1,len(table.rows)): # 限定从表格第二行开始循环读取数据
    for j in range(1,2): # 限定只读取表格第二列数据
        # 输出单元格的位置
        print(i, j)
        # 输出单元格的内容
        print(table.rows[i].cells[j].text)</code></pre>
当然你也可以通过直接打开文档查看来获取位置，比如上图中的第一行第二列的单元格的坐标就是（1，1）。代码执行结果如下图：
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Position.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Position.jpg" alt="Position" /></a></p>
然后根据位置直接赋值。以下代码有一个前提：即各个时间戳已经被获取并保存在一个TXT文件中（可以通过<span style="text-decoration: none;"><a href="http://support.sas.com/documentation/cdl/en/hostunx/61879/HTML/default/viewer.htm#pipe.htm" target="_blank">FILENAME</a></span>+PIPE获取最新时间戳），如下图：
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Time.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Time.jpg" alt="Time" /></a></p>
更新时间戳的代码如下：
<pre><code># coding=utf-8

from docx import Document
import re
from datetime import datetime
from docx.shared import Pt
from docx.enum.text import WD_PARAGRAPH_ALIGNMENT

timestamp = open('C:\\Users\\Xianhua\\Documents\\Python\\Checklist.txt', 'r')

# 将TXT转化为字典
mydic = dict() 

for line in timestamp:
    line = re.split('(\w+?)\s+(.+)', line)
    mydic[line[1]] = line[2]
    
timestamp.close()

chklist = Document('C:\\Users\\Xianhua\\Documents\\Python\\Checklist.docx')

table = chklist.tables[0] # 第一个表格

for i in range(1, len(table.rows)): # 限定从表格第二行开始循环读取数据
    # Transfer date
    if i == 3:
        table.rows[i].cells[2].text = datetime.now().date().strftime('%d %b %Y')

table = chklist.tables[2] 

for i in range(1, len(table.rows)):
    # Raw data
    if i == 1:
        table.rows[i].cells[2].text = mydic['raw']
        
    # Vendor data
    if i == 2:
        table.rows[i].cells[2].text = mydic['edat']
        
    # Transfer datasets
    if i == 3:
        table.rows[i].cells[2].text = mydic['transfer']
        
    # Logcheck
    if i == 4:
        table.rows[i].cells[2].text = mydic['logcheck']
        
    # Spec and Define
    if i == 5:
        table.rows[i].cells[2].text = mydic['spec'] + '\n' + mydic['define']
        
    # 更改字体 
    run = table.rows[i].cells[2].paragraphs[0].runs
    font = run[0].font
    font.name = 'Courier New'

    # 居中单元格
    table.rows[i].cells[2].paragraphs[0].alignment = WD_PARAGRAPH_ALIGNMENT.CENTER

chklist.save('C:\\Users\\Xianhua\\Documents\\Python\\Checklist '+ datetime.now().date().strftime('%Y%m%d')+'.docx')</code></pre>