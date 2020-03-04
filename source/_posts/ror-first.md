---
layout: post
title: "初尝ruby on rails"
date: 2014-08-20 22:44:20 +0800
categories: language framework
tags: language framework
excerpt: Ruby on Rails（官方简称为Rails，亦被简称为RoR），是一个使用Ruby语言写的开源Web应用框架，它是严格按照MVC结构开发的。它努力使自身保持简单，来使实际的应用开发时的代码更少，使用最少的配置。
description: Ruby on Rails（官方简称为Rails，亦被简称为RoR），是一个使用Ruby语言写的开源Web应用框架，它是严格按照MVC结构开发的。它努力使自身保持简单，来使实际的应用开发时的代码更少，使用最少的配置。
---

Ruby on Rails（官方简称为Rails，亦被简称为RoR），是一个使用Ruby语言写的开源Web应用框架，它是严格按照MVC结构开发的。它努力使自身保持简单，来使实际的应用开发时的代码更少，使用最少的配置。

<!-- more -->

### rails Rspec
###### 1. 配置rspec环境

1. echo 'gem "rspec-rails", :group => [:development, :test]' >> Gemfile
2. bundle install
3. rails generate rspec:install
4. rails generate scaffold product
5. rails generate rspec:controller product 为product controller生成测试文件
6. rake db:migrate && rake db:test:prepare
7. rake spec

测试中总是会出现： circular require considered harmful  
此时可以修改.rspec文件，将该文件中的--warnings配置删除


###### 2. 用rspec测试api的时候经常会出现以下现象：

1. 在浏览器中返回结果正常
2. 在rspec中死活都接受不到json数据

此时可以加入下面一条语句：render_views

```
describe ProductController do
	render_views
end

```

###### 3. rails rspect testing double
[rspec-mocks](https://github.com/rspec/rspec-mocks)

```
expect(Product).to receive(:new).with({:name => "name"}).and_call_original
expect_any_instance_of(Product).to receive(:save).once.and_call_original
expect(Product).to receive(:find) {Product.new(:name => "name", :id => 1)}
当需要stub一个find的exception的时候
expect(Price).to receive(:find).with(2).and_raise(ActiveRecord::RecordNotFound)
```
###### 4. 测试API GET
1. 经常我们需要测试API的json的结果，所以此时我们的代码里就不免的出现很多的JSON.parse，此时我们可以使用Monkey Patch，来讲我们的Request来扩展。代码如下：
在Spec目录下新建文件夹：support, 即/spec/support/request_helper.rb   

	```
module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end
end
```

2. 配置rspec为我们的controller测试添加我们的扩展helper，在rails_helper中添加，
	
	```
	// 我们不需要手动的require刚才写的模块，因为在我们放的目录在rail_helper中已经被require过了。
	Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
	
	config.include Requests::JsonHelpers,:type=>:controller
```
3. 在controller的spec中使用json方法 
```
	expect(json).tohave_key('test_key')
```

3. 在测试中我们需要检查uri，此时就不免会用到uri_for,此时需要注意的是，这些products，show,都必须是小写，convension over configration
	```
url_for({:controller => 'products', :action => 'show', :id => @product.id.to_s})
```
4. 404的时候可以使用mock来测试
```
expect(Order).to receive(:find).with(1).and_return(Order.new)
```
但是需要注意的是如果controller中使用到父资源，也需要测试父资源的404，而且在测试中需要注意的是Mock的时候需要Mock两个ActiveRecord的对象，不然会因为一些Exception导致测试失败。  
5.

###### 5. 测试API POST
```
expect(Product).to receive(:new).with(hash_including('name' => 'name', 'location'=> 'location'))
post :create, {format: :json, 'name' => 'name', 'location' => 'location'}
      expect(response).to have_http_status 201
```

###### 6. 
###### 7. circular dependcen
有可能是因为文件名称和module名称不一致导致
###### 8. 配置rubymine 可能是因为ruby的sdk版本不一致的原因，所以ruby需要将ruby版本调至与terminal使用ruby版本，此时就可以正常的work


### Rails Rabl
###### 1. 安装
gem 'rabl'
###### 2. 配置的tips
在config/initializers下新建文件rabl_init.rb

```	
require 'rabl'

Rabl.configure do |config|
  config.include_json_root = false
end
```

其中我们会经常用到的配置主要有：
1.include_json_root = false，当为false的时候会告诉rabl默认不为每个元素创建根
	
	object @product
	// include_json_root == true
	{"product": {"name": "name"}}
	// incldue_json_root == false
	{"name": "name"}
2. replace_nil_values_with_empty_strings 替换我们在json里的null,替换为空字符串
3. include_child_root 默认显示child的根，但是如果设置为false，此时不在结果里显示child的根

###### 3. 返回detail对象，不包括根对象
```
object false
node(:name){ @product.name}
node(:id) {@product.id}
```
###### 2. 返回集合对象，但是集合中的对象不需要有root对象
```
collection @prices, :object_root=>false
```

###### 3. 返回对象的uri
```
object false
node("price") {@price.price}
node :uri do
    product_price_url
end
```
###### 4. 返回集合对象的uri
```
collection @prices, :object_root=>false
attributes :price, :id
node :uri do |price|
    product_price_url :id => price.id
end
```


### rails postgresql
###### 1. rails new myapp --database=postgresql
如果一个项目没有用上面的命令创建的，此时我们也可以通过修改配置来使用postgres
修改Gemfile，将其中的sqllite的gem 删除,加入 gem 'pg'
然后修改database.yml将其中的adapter: sqllite3改为 adapter: postgresql. 然后把db的名称改了就好。样本如下

```
default: &default
  adapter: postgresql
  pool: 5
  timeout: 5000

development:
  <<: *default
  database: leave_development
```
###### 2. bundle install
其中有可能出问题的是

1. ERROR: Failed to build gem native extension  checking for pg_config... no  
此时是因为postgres的配置程序找不到的原因，可以配置postgres的bin的路径到path中，然后再次安装就可以了
2. pg_ext.bundle: [BUG] Segmentation fault  
此时有可能是因为在1.9.3环境下装的pg，所以pg是使用1.9.3的环境来编译的，但是如果切换到2.1.1的ruby环境，此时就会发现1.9.3编译的pg，是不能用的，所以就会报段错误。
3. 可以只安装指定环境的依赖如  
bundle install --without test development

###### 3. createuser test0629 -P -d

-d的意思是可以允许test0629创建新的database  
-P的意思指定密码，可以允许test0629登录

###### 4. 配置database.yml文件,加入usename和password配置，配置好的文件如下  
```
default: &default
  adapter: postgresql
  encoding: unicode
  database: ruby-development
  pool: 5
  username: test0629
  password: test0629

development:
  <<: *default
  datebase: ruby-test
```

###### 5. rake db:setup 此时rails就可以将database setup起来

setup

###### 6. rails generate model Model name:string

###### 7. rake db:migrate 此时所有的db的工作就完成了

Model.create! 加感叹号的意思是如果因为validation失败，model没有创建成功，此时会抛出异常。


### Rails Mongo
###### 1. rails new app --skip-active-record

跳过默认生成activerecord的模块

###### 2. 安装能支持rails 4 的mogoid模块

```
gem 'mongoid', '~> 4.0.0'
gem 'bson_ext'
```

###### 3. 生成monogid的默认的配置文件

```
rails generate mongoid:config
```

###### 4. 修改spec_helper.rb,每个测试都重新准备数据

```
RSpec.configure do |config|
  config.before(:each) do
    Mongoid::Sessions.default.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
```

###### 5. 测试404只坑

```
expect(Product).to receive(:find).and_raise(Mongoid::Errors::DocumentNotFound.new(Product, ''))
```
当mongoid mock一个没有找到的错误的时候需要raise一个Mongoid::Errors::DocumentNotFound对象。但是这个对象和我们在ActiveRecord遇到的不同，这个raise的对象必须是被初始化的。
###### 6. mongoid relation

1. embeds_one + embeded_in
	
	```
class Computer
	include Mongoid::Document
	embeds_one :cpu
end
class Cpu
	include Mongoid::Document
	embeded_in :computer
	field :name, type: String
end
// 存储的数据结构
{
  "_id" : ObjectId("4d3ed089fb60ab534684b7e9"),
  "cpu" : {
    "_id" : ObjectId("4d3ed089fb60ab534684b7e0"),
    "name" : "Intel",
  }
}
```
可以使用cpu.computer 来获取或者cpu.computer= 来为cpu的parent（computer）来赋值，需要手动的save
可以使用compter.cpu获取compter的cpu，或者使用computer.cpu = 来赋值cpu。这种情况下如果computer已经存储过，则cpu赋值后会被自动的save
2. embeds_many + embeded_in

	```
class Computer
	include Mongoid::Document
	embeds_many :cpus
end
class Cpu
	include Mongoid::Document
	embeded_in :computer
	field :name, type: String
end	
// 存储的数据结构
{
   "_id" : ObjectId("4d3ed089fb60ab534684b7e9"),
  "cpus" : [
  	{
    	"_id" : ObjectId("4d3ed089fb60ab534684b7e0"),
	    "name" : "Intel",
	}
  ]
}
	```
	同embeds_one，mongoid也为我们提供了很多函数用来维护relation。  
	1. computer.cpus 获取所有computer的cpu，computer.cpus = [Cpu.new] || computer.cpus = nil 为computer赋值，如果nil，则删除cpu。如果computer已经被save过，则computer.cpus 的赋值操作会被自动保存。  
	2. cpu.computer || cpu.computer = Cpu.new 为cpu指定parent(computer), 不需要手动保存，因为这个关系会在保存computer的时候自动保存。
	3. computer.cpus << Cpu.new || computer.cpus.push(Cpu.new),如果computer已经被持久化，那么此时cpus的赋值会被自动保存。
	4. computer.cpus.find(id) find cpus by id
	
3. has_one + belongs_to
	
	```
class Computer
	include Mongoid::Document
	has_one :display
end
class Cpu
	include Mongoid::Document
	belongs_to :computer
	field :name, type: String
end	
// 存储的数据结构
// computer
{ "_id" : ObjectId("4d3ed089fb60ab534684b7e9") }
// display
{
  "_id" : ObjectId("4d3ed089fb60ab534684b7f1"),
  "computer_id" : ObjectId("4d3ed089fb60ab534684b7e9")
}
```
可以执行的操作基本上跟embeds_one一样
	
4. has_many + belongs_to

	```
class Computer
	include Mongoid::Document
	has_many :keyboard
end
class Cpu
	include Mongoid::Document
	belongs_to :computer
	field :name, type: String
end	
// 存储的数据结构
// computer
{ "_id" : ObjectId("4d3ed089fb60ab534684b7e9") }
// keyboard，虽然在形式上没有表现出来一对多的关系，但是在存储的collection中多个keybord的computer_id对应到同一个computer
{
  "_id" : ObjectId("4d3ed089fb60ab534684b7f1"),
  "computer_id" : ObjectId("4d3ed089fb60ab534684b7e9")
}
```


### Rails ActiveRecode validation
###### 1. 不为空验证
presence: true 告诉Model的validtor，上面的字段都必须存在，并且都不为空。
```
validates :title, :description, :image_url, presence: true
```
###### 2. 数字valiation
验证price必须大于0， numericality用来验证数字
```
validates :price, numericality: {greater_than_or_equal_to: 0.01}
```
###### 3. 唯一性验证
验证我们的title必须是唯一的
```
validates :title, uniqueness: true
```
###### 4. 正则表达式验证后缀
```
validates :image_url, allow_blank: true, format: 
{ 
   with: %r{\.( gif | jpg | png)\ Z} i, 
   message: 'must be a URL for GIF, JPG or PNG image.'
}
```

### Rails Model Active 测试
###### 1. 使用error,invalid?
使用error和invalid? 来完成model的测试，我们可以通过any?来查看是否有相应attribute的error

```
test "product attributes must not be empty" do 
	product = Product.new
	assert product.invalid? 
	assert product.errors[: title]. any? 
	assert product.errors[: description]. any? 
	assert product.errors[: price]. any? 
	assert product.errors[: image_url]. any? 
end
```
###### 2. Error message
```
test "product price must be positive" do 
	product = Product.new( title: "My Book Title", description: "yyy", image_url: "zzz.jpg") 
	product.price = -1 
	assert product.invalid? 
	assert_equal ["must be greater than or equal to 0.01"], product.errors[: price] 
	product.price = 0 
	assert product.invalid? 
	assert_equal ["must be greater than or equal to 0.01"], product.errors[: price] 
	product.price = 1 
	assert product.valid? 
end
```
###### 3. Fixtures
默认的Rails会在fixture下为我们创建model的fixture文件，这个文件的名称和我们model的名字是一一对应的。
这个数据的格式yaml格式的数据文件。



### Rails MultiPart Form Upload
###### 1. 创建一个可以上传文件的Form
```
<%= form_tag(uploads_url, :multipart => true, :method => :post) do %>
    <%= file_field_tag 'name_field' %>
    <input type="submit" value="submit"/>
<% end %>
```
###### 2. 指定路径
如果此时需要两个post作为创建的入口，一个作为批量上传的POST，一个作为单个Form创建的POST，此时可以按照如下方式修改route

```
resources :uploads do
    collection do
      post 'upload'
    end
  end
```

###### 3. 创建可以接受文件的action
```
def upload
	uploaded_io = params[:picture]
    original_filename = uploaded_io.original_filename
    File.open(Rails.root.join('public', original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    csv_text = File.read(Rails.root.join('public', original_filename))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      # deal with the row
      puts row
    end
end
```

###### 4. 测试
```
describe 'upload' do
    it 'should upload file' do
      file = fixture_file_upload('price.csv', 'text/csv')
      post :upload, :picture => file
      expect(response.status).to eq(200)
    end
end
```


### Rails bootstrap
###### 1. 安装
```
gem "twitter-bootstrap-rails"

rails generate bootstrap:install static
```

###### 2. 配置
在app/assets/stylesheets下新建文件application.css.scss, 并在其中添加

```
@import "bootstrap-sprockets";
@import "bootstrap";
```
在app/assets/javascript/application.css.scss中添加

```
//= require jquery
//= require bootstrap-sprockets
```
###### 3. 编译
	rake assets:precompile
###### 4. heroku 配置
在production.rb里面添加下面的配置

```
  config.cache_classes = true
  config.serve_static_assets = true
  config.assets.compile = true
  config.assets.digest = true
```

### Rails erb
csrf
当使用jquery提交Form的时候，rail会做默认的跨站攻击检查，所以此时我们需要给我们的form表单天剑csrf的header

1. 在application.html.erb中确保有<%= csrf_meta_tag %>
2. 为jquery ajax添加csrf header   

	```
$.ajax({ url: 'YOUR URL HERE',
  type: 'POST',
  beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
  data: 'someData=' + someData,
  success: function(response) {
    $('#someDiv').html(response);
  }
});
```
###### link_to
用来创建一个连接
###### button_to
用来创建一个可以post的form


### Rails route
root "product#index", as: 'store'
这里的as将会为我们创建一个store_path的方法


如果我们有如下的route

```
resources :products do
    resources :prices
end
```
1. 则在访问/products/1的时候，需要的格式为：get :show, id: 100
2. 在访问/products/1/prices/2的时候需要是哟高 get :show, product_id: 1, id: 2,这里的show是pricecontroller上的show
3. 

sprintf("%0.02f", number) == number_to_currency(nuber)在页面上转换price


new不是用来创建的，而是用来获得创建的form。


ActiveSupport::Concern

session 对象

###### product_path vs product_url
product_url是带主机带端口的唯一的表示
而product_path是一个相对的uri，当我们使用3xx的status的时候，http协议要求我们必须使用完整的url，此时就使用product_url,或者我们需要跳转到其他站点的时候，我们需要使用product_url,其他时候我们可以使用product_path避免产生不必要的字符

###### Strong parms
当我们选择strong parameters的时候，只有完全match的东西才会出现在我们的参数中
比如

我们使用以下的post来post 数据
```
post :create, user_id: 1, order: {address: 'beijing', phone: '13211112222', name: 'kayla', order_items: [{product_id: 1, quantity: 2}]}
```
然后使用如下的方法去接收数据

```
// 接收到的order_items值为{order_items: [{product_id: 1, quantity: 2}]}
order_items = params.require(:order).permit(order_items: [:product_id, :quantity])
// 接收到的order_items 的值为{}
order_items = params.require(:order).permit(order_items: [])
```


### Rails Active Record
当ActiveRecord被当做外键引用的时候，需要做检查，不然会导致数据不一致。

```
before_destory: ensure_not_referenced_by_any_line_item

def ensure_not_referenced_by_any_line_item
	if line_items.empty?
		return true
	else
		errors.add(: base, 'Line Items present') 
		return false
	end
end
```
在上面的代码中我们直接向error中添加了一条错误信息，validation错误的信息也是存在这里。错误的信息可以和某个attribute关联起来。也可以直接和base object 关联起来

###### 名称convensition
rails默认所有的table名称都为复数，但是object都为单数，当model对象中又camelcase出现的时候，对应的表以下划线分割。如果你不喜欢种种convension，可以使用如下代码来更改对应的表名称。

```
class Sheep < ActiveRecord::Base
	this.table_name = "sheep"
end
```

###### 尽量不要用type作为关键字

### Rails 日志
每一rails的controller都有一个logger，可以直接通过logger来写log