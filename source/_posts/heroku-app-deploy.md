---
layout: post
title: "如何使用 Heroku 部署应用"
date: 2014-07-09 22:14:50 +0800
categories: 
- devops
tags: 
- devops
excerpt: 如何使用Heroku来部署一个新的应用
description: 如何使用Heroku来部署一个新的应用(Heroku App Deploy)
---

如何使用Heroku来部署一个新的应用

### 1. 申请账号
### 2. 登录账号创建一个项目
可以使用下面的命令来创建一个新的App
```
heroku create
```
但是为了不要让hero来创建一个随便什么名字的app，我们可以登录到heroku上新创建一个项目，myapp，然后拿到你新创建的git repository的地址 git@heroku.com:myapp.git  

```
git remote add heroku git@heroku.com:myapp.git  
git push heroku master
```
此处需要注意一个问题：heroku会搜索git repo的root directory来找到相应项目的配置文件，来初始化我们的项目。比如rails就会在根目录下找Gemfile，如果是nodejs项目，就会在根目录下寻找package.json. 但是如果我们的项目不在根目录就可以通过以下方法解决.详情请看[git subtree](http://apenwarr.ca/log/?m=200904#30)

```
--/
----/.git
----/build
----/myapp
----/----/requirements.txt

git subtree push --prefix myapp heroku master
```
通过这种方式提交的代码，是不能通过git subtree push --prefix myapp heroku master 再次提交到heroku上的，
总会出现以下提示：

```
rror: failed to push some refs to 'git@heroku.com:askleave.git'
hint: Updates were rejected because a pushed branch tip is behind its remote
hint: counterpart. Check out this branch and integrate the remote changes
hint: (e.g. 'git pull ...') before pushing again.
```

此时可以尝试用以下方式提交

```
	git push heroku `git subtree split --prefix pythonapp master`:master --force
```

### 3. 安装postgres
因为heroku不支持sqllite数据库，所以此时我们需要使用其他的数据库。我们可以使用heroku来提供的postgresql。使用下面命令安装

```
heroku addons:add heroku-postgresql --app=myapp
```
### 4. 配置
此时我们使用的postgresql虽然已经安装好了，但是却没有做正确的设置，所以此时我们需要对我们db进行配置

```
heroku  run --app=myapp rake db:migrate
```

### 5. 运维
可以使用下面的命令来查看服务器实时的日志信息
```
 heroku logs --tail --app=myapp
```

### 6. 更多的配置
Procfile


详细的其他信息请参考[Getting started with rails4](https://devcenter.heroku.com/articles/getting-started-with-rails4)
