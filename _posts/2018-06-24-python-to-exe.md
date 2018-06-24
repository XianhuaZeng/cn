---
layout: post
title: Python转exe
date: 2018-06-24 15:59
author: 曾宪华
comments: true
tags: [Python, py2exe， PyInstaller]
categories: [程序人生]
---
<p>上一篇<span style="text-decoration: none;"><a href="hhttp://www.xianhuazeng.com/cn/2018/06/18/modify-word-with-python/" target="_blank">博文</a></span>介绍了一个自动更新.docx文件的<span style="text-decoration: none;"><a href="https://www.python.org" target="_blank">Python</a></span>脚本。当时通宵（通宵看葡萄牙VS西班牙顺带码的）码好的时候想着怎么分享给整个部门使用，考虑到公司电脑并没有Python环境（没有安装权限），于是我就找有没有办法可以让我的这个Python脚本在一台没有安装Python的电脑上执行。经过Google发现有<span style="text-decoration: none;"><a href="http://www.py2exe.org" target="_blank">py2exe</a></span>、<span style="text-decoration: none;"><a href="http://www.pyinstaller.org" target="_blank">Pyinstaller</a></span>可以将Python脚本编译成Windows（Pyinstaller支持多平台）可执行文件。经过比较发现Pyinstaller安装使用更简单（见下图），所以我选择了Pyinstaller，现记录一下转换过程。</p>
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller01.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller01.jpg" alt="Pyinstaller01" /></a></p>
首先是安装，在控制台输入命令<code>pip install pyinstaller</code>回车，成功安装如下图所示：
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller02.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller02.jpg" alt="Pyinstaller02" /></a></p>
接下来是使用，在脚本所在目录下输入命令<code>pyinstaller Checklist.py</code>回车，转换成功如下图所示：
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller03.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller03.jpg" alt="Pyinstaller03" /></a></p>
打开脚本所在目录，可以看到多了三个文件夹和一个文件，截图如下：
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller04.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller04.jpg" alt="Pyinstaller04" /></a></p>
根据官网的说明，exe文件会保存在dist文件夹中（见下图），所以我们只需要带着这一个文件夹，就可以在没有Python环境的机器上执行Python脚本了。
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller05.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller05.jpg" alt="Pyinstaller05" /></a></p>
大家可能会觉得整个文件夹看起来不够简洁，我们可不可以只带着一个exe文件呢？当然是可以的，只需要在转换的时候加上选项<span style="text-decoration: none;"><a href="https://pyinstaller.readthedocs.io/en/v3.3.1/usage.html#what-to-generate" target="_blank">-F</a></span>就可以实现只生成一个exe文件，截图如下：
<p><a href="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller06.jpg"><img class="aligncenter size-full" src="http://www.xianhuazeng.com/cn/images/2018/06/Pyinstaller06.jpg" alt="Pyinstaller06" /></a></p>
我们可以看到上面两种方法所生成的exe文件大小有很大差别（第一个是1.52MB，第二个6.99MB），但是经过测试，发现两种方法exe文件启动时间并没有明显的差别，可能是因为我的这个脚本简单。但是对于一个复杂的Python脚本，加选项-F转换后的exe文件肯定会比不加选项生成的exe文件要大很多，启动也会慢很多，故建议在转换一个复杂的Python脚本时不要加选项-F以提高exe启动速度。