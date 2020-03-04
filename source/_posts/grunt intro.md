---
layout: post
title: "Grunt 配置"
date: 2014-05-27 21:20:20 +0800
categories: frontend
tags: frontend
excerpt: grunt是一个node下的自动构建工具。他可以实现任务构建的自动化。
description: grunt是一个node下的自动构建工具。他可以实现任务构建的自动化。可以直接使用node原生的包管理工具npm来安装。
---

grunt是一个node下的自动构建工具。
他可以实现任务构建的自动化。
### 1. 安装
grunt作为node平台下的自动构建工具，可以直接使用node原生的包管理工具Npm来安装。
首先安装grunt的全局的启动脚本

```
npm install -g grunt-cli
```
这条命令为你在全局安装了一个启动grunt的脚本，使得你可以在任何目录都可以运行grunt命令。但是此时我们还需要再我们项目本地安装grunt。

```
npm install grunt --save-dev
```
此处假设你的项目中已经有了npm 的配置文件package.json. 因为我们的构建是在开发环境中使用的，所以我们的依赖一概是dev-dependence, 所以我们使用--save-dev 将这个安装保存为开发依赖。
此时我们的grunt就安装成功了。

### 2. 配置
一个标准的Grunt的配置文件主要包括几大块：

1. 一个Wrapper函数  
	
	```
	module.exports = function(grunt){
		// grunt的所有配置都应该在这个wrapper方法里面完成。
	};
	```
	
2. 任务配置

	```
	grunt.initConfig({
		mocha: { 
	       option: {  	
	       		reporter: 'mocha'
	       },
	       src: ['test/**/*.js'],
	       dst: ".tmp",
	   	}
	});
	```
	如前面所讲，这坨代码也是在wrapper函数中的。有些构建任务在构建的时候，需要一些参数。比如我们想要跑一个自动化测试的任务，那我们需要告诉任务：
	1. 我们的测试代码在哪里
	2. 我们的测试依赖的东西有哪些
	3. 我们测试生成的东西放哪里

	这些参数都是通过grunt.initConfig来初始化的。 initConfig接受一个对象作为参数，来完成认为配置的初始化。  
	需要注意的是这里的mocha，mocha作为任务配置的一项，必须与注册的任务使用同样的名字。
3. 载入构建任务
	
	```
	grunt.loadNpmTasks("grunt-mocha");
	```
	加载grunt-mocha插件，这个插件为我们的项目提供了mocha的构建任务。在加载之前我们需要先将我们所依赖的插件安装到本地。继续使用npm来安装我们的依赖
	
	```
	npm install grunt-mocha --save-dev
	```
	

### 3. 运行

我们的配置文件放在项目根目录的Gruntfile.js中，此时我们就可以切换到项目的根目录通过运行下面的命令来完成我们的测试任务的构建了

```
   grunt mocha
```

### 4. 自定义任务
如果标准的插件不能提供你所要功能，比如你想要一个任务(start-app)，这个任务需要完成下面的三个子任务：

1. 首先对所有的代码进行一遍检查（jshint）
2. 运行所有的测试代码（mocha）
3. 启动程序(start)

此时可以使用如下方式：

```
	grunt.registerTask("start-app", ['jshint', 'mocha', 'start']);
```
上面的代码注册了一个名为“start-app”的任务，这个任务可以划分为三个子任务，分别为："jshint", "unittest", "start".当运行start-app任务时，三个子任务会根据数组的顺序依次执行。三个子任务分别为插件注册的任务，代码如下

```
	grunt.loadNpmTasks('grunt-contrib-jshint');
	
	grunt.registerTask('start', 'start app', function() {
		grunt.log.writeln("start app");
		actualStartCmd();
	});
```

### 4. 例子

```
module.exports = function(grunt) {
	grunt.initConfig({
		mocha: { 
	       option: {  	
	       		reporter: 'mocha'
	       },
	       src: ['test/**/*.js'],
	       dst: ".tmp",
	   	}
	});
	
	grunt.loadNpmTasks("grunt-mocha");
}
```