---
layout: post
title: "ruby 入门"
date:  2014-07-08 19:30:20 +0800
categories: language
tags: language
excerpt: Ruby是一种纯粹的面向对象编程语言。它由日本的松本行弘创建于1993年。Ruby 的特性与 Smalltalk、Perl 和 Python 类似。Perl、Python 和 Smalltalk 是脚本语言。Smalltalk 是一个真正的面向对象语言。Ruby，与 Smalltalk 一样，是一个完美的面向对象语言。使用 Ruby 的语法比使用 Smalltalk 的语法要容易得多。
description: Ruby是一种纯粹的面向对象编程语言。它由日本的松本行弘创建于1993年。Ruby 的特性与 Smalltalk、Perl 和 Python 类似。Perl、Python 和 Smalltalk 是脚本语言。Smalltalk 是一个真正的面向对象语言。Ruby，与 Smalltalk 一样，是一个完美的面向对象语言。使用 Ruby 的语法比使用 Smalltalk 的语法要容易得多。
---
Ruby是一种纯粹的面向对象编程语言。它由日本的松本行弘创建于1993年.

Ruby 的特性与 Smalltalk、Perl 和 Python 类似。Perl、Python 和 Smalltalk 是脚本语言。Smalltalk 是一个真正的面向对象语言。Ruby，与 Smalltalk 一样，是一个完美的面向对象语言。使用 Ruby 的语法比使用 Smalltalk 的语法要容易得多。

#### 双引号和单引号的区别
单引号仅仅是字符串，双引号，ruby会在字符串中寻找表达式，比如

```
puts "good #{name.capitalize}"
```
此时，当ruby构造这个字符串的时候，他会将name的值替换到{}占位的地方。

#### Array
###### 1. <<用来向数组append一个值

```
arr = []
arr << 'test'
```
###### 2. 创建数组
arr = ['ant', 'bee']
arr = %w{ ant bee cat}

#### Hash
```
section = {
	:book => 'book',
	:fold => 'fold'
}
```
在ruby的hash中，key和value可以是任何的物体，在上面的hash中，我们的key就是一个symbol，这是rails的convention. 所以在ruby1.9中，添加了如下的语法糖，创建一个Symbol为key的Hash.

```
section = {
	book: 'book',
	fold: 'fold'
}
```
当Hash作为最后一个参数的时候，可以省略hash的花括号。 如下

```
redirect_to action: 'show', id: product.id
```

#### Regular Expression

```
/pattern/
or
%r{pattern}
```

用上面的两个语法糖来创建ruby下的Regular 的对象

```
if line =~ /^matchstring.*/
	// matched
end
```

#### Control Structure

```
if statement
	// do something
elsif desicion
	// do other thing
end

while xxx
end


puts 'danger' if explode == true
```

#### Code Block
lambda 将一个代码宽转换成Proc的对象

#### Exception
```
begin
rescue ActiveRecord::NotFound
end
```


#### Class
```
attr_accessor :name # read and write
attr_reader :greet # read only
attr_write :age #write only
```

#### Modules
和class 相似，但是，不能创建Module的实例，
Module的两个主要用途

1. Namespace
2. Share functionlity between classes.

在rails中，Rails自动的将所有的helper mix到相应的view 的template中。


#### Require
ruby中的require方法载入一个外部源文件的方法

```
require File.expand_path('../../config/enviroment', __FILE__)
```
上面的语句用来自动include lib的code。通过相对路径。ruby会根据LOAD_PATH来寻找所有的目录。


#### Monkey Patch
**特别要注意的是Ruby的MonkeyPatch 是个module相关的，在某个module下的monkeypatch在其他的module下是不能用的，相当于不同的命名空间**



#### module include vs extend
```
module Foo
  def foo
    puts 'heyyyyoooo!'
  end
end

class Bar
  include Foo
end

Bar.new.foo # heyyyyoooo!
Bar.foo # NoMethodError: undefined method ‘foo’ for Bar:Class

class Baz
  extend Foo
end

Baz.foo # heyyyyoooo!
Baz.new.foo # NoMethodError: undefined method ‘foo’ for #<Baz:0x1e708>
```

include 使得foo里面的方法能被Bar的instance所使用
extend 使得foo方法能被Baz类使用
尽管我们经常使用include来包括类方法，但是在很多项目中都使用include来包括类方法。可以使用以下方法来包括类方法

```
module Foo
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def bar
      puts 'class method'
    end
  end
  
  def foo
    puts 'instance method'
  end
end

class Baz
  include Foo
end

Baz.bar # class method
Baz.new.foo # instance method
Baz.foo # NoMethodError: undefined method ‘foo’ for Baz:Class
Baz.new.bar # NoMethodError: undefined method ‘bar’ for #<Baz:0x1e3d4>
```