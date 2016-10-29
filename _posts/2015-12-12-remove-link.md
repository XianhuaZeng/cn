---
layout: post
title: WordPress4.4删除侧栏功能版中的WordPress.org链接
date: 2015-12-12 15:23
author: Xianhua.Zeng
comments: true
tags: [WordPress, WordPress.org]
categories: [杂七杂八]
---
<p><a href="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/12/WordPress.jpg" rel="attachment wp-att-671"><img class="aligncenter size-full wp-image-671" src="http://www.xianhuazeng.com/cn/wp-content/uploads/2015/12/WordPress.jpg" alt="WordPress" width="831" height="241" /></a>      今天刚升级了WordPress 4.4，对于有强迫症的我来说，早已习惯了把侧栏功能版块中的<span style="text-decoration: underline;"><a href="https://cn.wordpress.org/" target="_blank">WordPress.org</a></span>链接删掉，因为在博客底部已经加了一个WordPress.org链接。之前版本的删除方法是在博客安装目录下的wp_includes文件夹下面，找到一个名为default-widgets.php文件，注释或者直接删掉其中的以下代码：<!--more--></p><pre><code>&lt;?php
 /**
 * Filter the "Powered by WordPress" text in the Meta widget.
 *
 * @since 3.6.0
 *
 * @param string $title_text Default title text for the WordPress.org link.
 */
 echo apply_filters( 'widget_meta_poweredby', sprintf( '&lt;li&gt;&lt;a href="%s" title="%s"&gt;%s&lt;/a&gt;&lt;/li&gt;',
 esc_url( __( 'https://wordpress.org/' ) ),
 esc_attr__( 'Powered by WordPress, state-of-the-art semantic personal publishing platform.' ),
 _x( 'WordPress.org', 'meta widget link text' )
 ) );

wp_meta();
 ?&gt;</code></pre><p>      故在本次升级后我也就直接用之前的default-widgets.php文件覆盖新的文件，但是发现博客却打不开了。打开/wp-includes/default-widgets.php文件，发现改的面目全非了：</p><pre><code>&lt;?php
/**
 * Widget API: Default core widgets
 *
 * @package WordPress
 * @subpackage Widgets
 * @since 2.8.0
 */

/** WP_Widget_Pages class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-pages.php' );

/** WP_Widget_Links class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-links.php' );

/** WP_Widget_Search class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-search.php' );

/** WP_Widget_Archives class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-archives.php' );

/** WP_Widget_Meta class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-meta.php' );

/** WP_Widget_Calendar class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-calendar.php' );

/** WP_Widget_Text class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-text.php' );

/** WP_Widget_Categories class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-categories.php' );

/** WP_Widget_Recent_Posts class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-recent-posts.php' );

/** WP_Widget_Recent_Comments class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-recent-comments.php' );

/** WP_Widget_RSS class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-rss.php' );

/** WP_Widget_Tag_Cloud class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-widget-tag-cloud.php' );

/** WP_Nav_Menu_Widget class */
require_once( ABSPATH . WPINC . '/widgets/class-wp-nav-menu-widget.php' );
</code></pre><p>      可以看到侧边栏的代码已经不在/wp-includes/default-widgets.php文件中了。通过查看网页源代码，发现侧边栏的代码放在/wp-includes/widgets/class-wp-widget-meta.php这个文件中。接下来我们要做的就和之前的方法一样了，即注释或者直接删掉此文件中的那一段代码。</p>
