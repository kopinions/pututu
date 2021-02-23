---
layout: post
title:  "NodeJS Express 入门"
date:   2014-07-07 12:20:01 +0800
categories: 
- frontend
tags: frontend
excerpt: Express 是一个简洁而灵活的 node.js Web应用框架, 提供了一系列强大特性帮助你创建各种 Web 应用，和丰富的 HTTP 工具。使用 Express 可以快速地搭建一个完整功能的网站。
description: Express 是一个简洁而灵活的 node.js Web应用框架, 提供了一系列强大特性帮助你创建各种 Web 应用，和丰富的 HTTP 工具。使用 Express 可以快速地搭建一个完整功能的网站。
---

Express 是一个简洁而灵活的 node.js Web应用框架, 提供了一系列强大特性帮助你创建各种 Web 应用，和丰富的 HTTP 工具。
使用 Express 可以快速地搭建一个完整功能的网站。

Express 框架核心特性：

* 可以设置中间件来响应 HTTP 请求。
* 定义了路由表用于执行不同的 HTTP 请求动作。
* 可以通过向模板传递参数来动态渲染 HTML 页面。


###### 安装express 脚手架
sudo npm install -g express-generator

如果以前安装过express-generator, 有可能会出现以下错误   
	
	Refusing to delete: /usr/local/bin/express
此时可以去删除/usr/local/bin/express link所指定的目录

```
cd /usr/local/bin/express
ls -ltrch express
// 此时的结果如下
express -> ../lib/node_modules/express/bin/express
rm -rf ../lib/node_modules/express/bin/express
rm -rf express
// 此时安装应该就可以成功了
sudo npm install -g express-generator
```

###### 1. 初始化项目
npm install

##### Express Test
npm install supertest --save-dev
npm install should --save-dev

```
request = require('supertest');
require("should");
var app = require("../app");

describe("Product", function () {
    describe("GET", function () {
        describe("with exist product", function () {
            it('should get 200', function (done) {
                request(app)
                    .get('/products/1')
                    .expect(200)
                    .end(function(err, res) {
                        if(err) {
                            done(err);
                        }
                        done();
                    });
            });
        });
    });
});
    
```

##### Express mongoose

**特别要注意require(app) 和require（Product）的顺序**
有以下两种顺序
```
var Order = require('../models/order');
var User = require("../models/user");
var Product = require("../models/product");

var app = require("../app");
```

```
var app = require("../app");
var Product = moogoose.model("Product");
var User = moogoose.model("User");
var Order = moogoose.model("Order");
```

npm install mockgoose --save-dev
npm install mongoose --save


mockgoose 和require的app的顺序有很强的联系，如果出现timeout，很有可能是因为mockgoose和app的require顺序写反了。此时可以使用如下方式解决

```
var Product = mongoose.model("Product")
```



一般我们会在app.js中初始化我们的connection，但是这个connection在APP中初始化，所以每次我们require一次app.js，就会出现连接一次，如果第二次require没有将mongoose mock掉，此时会出现原来的测试挂掉的情况。
此时有两种解决方法：

1. 在runner里面直接将mongoose mock掉

	```
gulp.task('test', function() {
    var mockgoose = require('mockgoose');
    var mongoose = require('mongoose');
    mockgoose(mongoose);
    gulp.src('./test/*.js')
        .pipe(jasmine())
});
```

2. 在所有的测试中添加mongoose的mock代码   

	```
var mongoose = require('mongoose');
var mockgoose = require('mockgoose');
mockgoose(mongoose);
```

##### Mongo
添加一个embeded的resource
使用schema

Object {} has no method 'cast'
很多时候是由于mongoose没有指定对相应的schema
可以使用如下的方法添加schema

```
var User = new Schema({
    name: {type: String, required: true},
    phone: {type: String, required: true},
    orders: [mongoose.model("Order").schema]
});
```

然后使用如下的方法为user,创建一个order

```
var order = new Order({address: req.param("address"), phone: req.param("phone"), name: req.param("name")});
user.orders.push(order);
```


MissingSchemaError: Schema hasn't been registered for model "Product"
product: {type: ObjectId, ref: mongoose.model("Product").schema}
这是由于Product还没有被实例化，可以使用require（"./product"）来解决



TypeError: Invalid value for schema path `product.type`
这是因为我们定义的时候使用的一下的方式
```
var ObjectId = mongoose.ObjectId
product: {type: ObjectId, ref: Product.schema},
// 需要使用的一下的方式
var ObjectId = mongoose.Schema.ObjectId
product: {type: ObjectId, ref: Product.schema},
```
##### Express Gulp
```
npm install -g gulp
npm install --save-dev gulp



// gulpfile.js
var gulp = require('gulp');

gulp.task('default', function() {
});
```
上面就是一个很简单的没有任何配置的gulp的环境，我们可以在上面加些简单的任务让gulp帮我们跑起来

```
var jasmine = require('gulp-jasmine');

gulp.task('test', function() {
	glup.src('./app/test/**/*.js')
		.pipe(jasmine())
});
```

