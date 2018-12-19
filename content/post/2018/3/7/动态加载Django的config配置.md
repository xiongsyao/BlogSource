---
title: "动态加载Django的config配置"
date: 2018-03-07T14:29:58+08:00
tags: ["Django"]
categories: ["Django"]
draft: false
---

> github本章代码: **[点这里](https://github.com/xiongsyao/django-cms/tree/05879ef5f4221ed237bffe4c484d65cc27d6a05e)**

## 前言
之前想新开的一个坑，目标是从0开始写一个CMS框架，将要实现的功能应该有：

+ 媒体库
+ 导航栏配置
+ 富文本页
+ 文章及评论
+ 自定义模版样式(换肤)
+ 可视化编辑
+ ...

但是发现传统的单config.py文件记录配置信息，不方便在开发环境和生产环境中来回切换。

这里，提出一种方式，依据环境变量，自动加载当前模式下的配置
## 开始
在开始项目前，我们需要了解下开发的基本情况

+ 项目基于`python3.6`，`django 2.0`
+ 一些配置会使用到环境变量，一些帐号密码之类的配置，采用环境变量来设置是极为合理的（尤其是对于开源项目），如何设置环境变量？
  + windows:  `set KEY=VALUE`
  + Linux or Mac OS:  `export KEY=VALUE`

## 项目配置
django 的startproject命令创建的项目，结构不太合理，因为开发中与实际上线，会有一些配置上的差异，所以我们修改settings.py文件为config文件夹，来加载开发配置与生产配置。

以开发模式为例，development.py文件里的内容
```
from configs.default import *

DEBUG = True
```
我们设置`DEBUG=True`，而在production.py中设置`DEBUG=False`

同时，修改manage.py文件中
```
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings.py")
```
为
```
env = os.getenv('DJANGO_CMS', 'development')
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "configs.{}".format(env))
```
这样便实现了通过环境变量控制应用配置。

生产环境中，django 自带的server功能太弱，一般会使用uwsgi或者gunicore之类的server，所以还需要修改wsgi.py文件里配置，方法同上。
## HELLO

创建名为django_cms的数据库，之后clone项目，为项目创建虚拟环境并激活，然后进入项目文件夹，依次执行：

+ `set MYSQL_USER=<your username>`
+ `set MYSQL_PASSWOR=<your password>`
+ `python manage.py migrate`
+ `python manage.py runserver`

接着浏览器打开 http://127.0.0.1:8000/hi/ 就能看见`hello!`， 至此，项目创建成功~