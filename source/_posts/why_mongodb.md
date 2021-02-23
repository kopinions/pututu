---
layout: post
title: "为什么我们需要NoSQL -- mongodb"
date: 2014-07-28 10:50:22 +0800
categories: 
- architecture 
- db
tags: 
- architecture 
- db
excerpt: 关系型数据库可以保证我们操作可以在一个事务中完成，即便这些数据来自不同不同表中的不同的行。(Atomic Consistent Isolated Durable) No-SQL中没有事务来保证夸多个聚合根的一致性。只有事务用来保证单一聚合的Atomic的属性。也就是说如果我们需要夸聚合根的一致性的时候，我们需要在应用程序级别来保证。
description: 关系型数据库可以保证我们操作可以在一个事务中完成，即便这些数据来自不同不同表中的不同的行。(Atomic Consistent Isolated Durable) No-SQL中没有事务来保证夸多个聚合根的一致性。只有事务用来保证单一聚合的Atomic的属性。也就是说如果我们需要夸聚合根的一致性的时候，我们需要在应用程序级别来保证。
---

###  集群的冲击
集群的冲击使得关系型数据库的优势：1. 查询，2.事务，3，一致性控制，收到了影响。
以及关系型数据库的价格是根据单台server来算的对关系型数据库也有相当大的影响。

### 选择的原因
1. 需要集群来处理数据
2. 使用更方便的数据交互方式来提高生产效率

### 聚合数据模型

#### Data Model vs Storage Model

> A Data model is the model through which we perceive and manipulate our data.
For people using a database, the data model describes how we interact with data in the database. Often the data model means the model of the specific data in an application. A developer might point to an entity0relationship diagram of their database and refer to that as their data model containing customers, orders, products, and the like.

> Storage model describes how the database stores and manipulates the data internally

1. data model 
是用来感知和操作数据的接口，即如何与数据库中的数据进行交互。

>In software engineering, the term data model is used in two related senses. In the sense covered by this article, it is a description of the objects represented by a computer system together with their properties and relationships; these are typically "real world" objects such as products, suppliers, customers, and orders. In the second sense, covered by the article database model, it means a collection of concepts and rules used in defining data models: for example the relational model uses relations and tuples, while the network model uses records, sets, and fields.

storage model是用来描述数据库内部如何存储及操作data的。

Aggregates支持对Aggreate中的单一元素进行原子操作。

#### Product Order 两种模型间的对比

### KeyValue vs Document Database
keyvalue经常用来存放一些大块的二进制快的数据，所以聚合关系对于数据库来说是不透明的，即你不可以通过查看数据库，知道这些数据的准确的意思。或者得到聚合关系中的一块信息  
document 数据库，可以通过查看数据库很明确的知道数据的聚合关系，及结构

不透明性的优点是可以在聚合中存放任何东西，但是缺点是很明显的，只能通过key来获取聚合关系。
document database可以在聚合上定义允许的数据结构，优点是可以使用查询来查询到所有符合条件的document，但是缺点是限制了我们可以存放的数据结构。  
所以很多时候keyvalue的数据库会在数据上加上metadata用来做aggreate的查询。

他们俩最大的区别就是一个主要是用来以key 查找的，一个主要是以结构化的query来查找的

### Key of NOSQL
所有的数据共享中心的聚合关系，这个聚合关系被一个中心节点以key的形式做index，这个中心节点就是集群的中心节点，集群需要确保某个聚合实体的数据都被存放在单一的节点上。这时候这个单一实体的操作都发生在某个单一的节点上。所以单一实体的操作的原子性由某个聚合实体所在的节点来保证。
****
我们在对数据建模其实很多时候只是在对我们的数据使用场景的一种表现，如果我们经常的到一个用户信息的时候我就需要知道他的所有的Order，那么此时我们就可以将oders embed到我们的customer中。但是如果我们经常只需要知道一个用户的基本信息，他的order不care，那此时如果把orders embed到customer中，此时就会造成查询的性能非常低下。
如果用mogoose的话，他们的schema分别入下

1. embed

将所有的order embed到user资源上面  

    var User = new Schema({
    	name: {type: String, required: true},
	    phone: {type: String, required: true},
    	orders: [mongoose.model("Order").schema]
	});

产生的json如下

    {
    	"name": "name",
    	"phone": "phone",
    	"orders": [
    		{
    			"productId": "1",
    			"quantity": 2
    		}
    	]	
    }

2. has_many

将所有的orders资源单独出来，在user中只是存放order的reference，这样我们可以通过customer中order 的reference来获取到customer的所有order。

    var User = new Schema({
    	name: {type: String, required: true},
        phone: {type: String, required: true},
    	orders: [{objectId: Schema.ObjectId, ref: mongoose.model("Order").schema}]
    });

产生的json如下
	

	// user
	{
    	"name": "name",
    	"phone": "phone",
    	"orders": [
    		{
    			"orderId": "xxxxxxxxxx"
    		}
    	]	
    }
    //order
    {
    	"orderId": "xxxxxxxx",
    	"orderItems":[]
    }

### NoRelation vs relation
---

1. Storage model 不相同
    1. 对于关系型数据库来讲，所有的数据都是一系列的表(table), 这些表里都是值数据，这些数据可能引用自其他表中的某一行。
    2. 对于NoSql来讲，主要的存储模型分为以下两种：
        *. aggregate orientation（key-value, documentDB, column-family）
            在db中我们可以在单个记录中保存复杂的数据类型，包括lists，也可以内嵌(embed)其他的数据类型。
            Aggreate可以理解为一个集合，这个集合中包括了所有与aggreate功能相关的对象的集合，这个集合对于外界来说就是一个单一的操作的实体(unit)。对于这个collection的任何的操作都是通过这个unit来进行操作。这个unit是数据操作和保证数据一致性的最小的单元
        *. 
    

1. 对于非关系型数据库，他的字段内可以存任何种类的值，所以字段里可以embed其他类型。比如一个person可以embed多个地址，如下所示，这样在取出person的时候，person.address就会被取出来。
	
    class Person
    	include Mongoid::Document
    	embeds_many :address
    end

如果是对于以下模型:

    class Person
        include Mongoid::Document
        has_many: orders
    end

但是如果说我们取出person的时候不需要知道所有的orders,并且有可能这个orders的数量成千上万，那我们此时就可以将我们的embeds_many改为has_many，此时取person的时候的到的就是一系列的Reference,你可以通过这些reference来得到对应的order。

对于Customer-Order系统来说 
> The link between the customer and the order is not within either aggregate-it is and relation between aggregates. Similarly, the link from an order item would cross into a seprate aggreate structure for products. We've shown the prouct name as part of the orderitem here. this kind of denormalization is similar to the tradoffs with relational database, but is more common with aggreagates because we want to minimize the number of aggregates we access during a data interation.

从上面的一段话可以看出，在我们订单系统中，Customer和Order是一个引用的关系，同样的OrderItem和product也是引用的关系。但是在设计中我们会在orderItem的对象上保存一些product的基础数据，这种操作类似于在关系型数据库中我们在order_items表中存放一些冗余的字段（productname）来获取性能的提升。这种性能和数据之间的平衡在aggreate oriented database 中会更常见。因为在面向聚合的数据库中我们更倾向于在访问数据的时候，使用尽量少的聚合根。

> The important thing to notice here isn't the particular way we,ve drawn the aggregate bondary so much as （but rather）the fact that you have to think about accessing that data-and make that part of your thinking when developing the application data model(meta model). Indeed we could draw our aggregate boundaries differently. putting all the orders for a customer into the customer aggregate.

对于面向聚合的数据库，在我们设计系统的data model 的时候，重要的不是如何画出聚合的边界。重要的是我们需要在设计data model的时候需要考虑如何访问和操作这些数据。在Customer-Order中我们可以将的order聚合到Customer上，那么随之产生的json数据如下所示

    {
        "customer" : {
            "name": "name",
            "id": 1
            "address": [{"address": "beijign"}],
            "orders": [
                {
                    "id": 100,
                    "customerId": 1,
                    "orderItems": [
                        {
                            "productId": 200,
                            "price": 31,
                            "productName": "little apple"
                        }
                    ],
                    "payment": {
                        "paytime": "2014-01-01",
                    }
                }
            ]
        }
    }

在画出整个聚合的边界的时候，针对同样的模型，在不同的场景下可能会划定出不同的聚合边界。聚合的边界唯一的取决条件只有一个，你如何去access&manipulate你的数据。换句话来讲，就是你的业务场景下，哪种数据的操作更多。如果更多的时候你获取到user的时候，你需要知道user的所有order，那么此时可以将所有的order聚合到user上，使用单一的user聚合来获取和操作所有的数据。如果更多的时候我们都是访问单一的order，则我们就需要将order设计为单一的聚合，可以独立的获取user的order。


在领域层我们可以说一个order由多个orderItem，一个地址，一个payment组成，这在关系型数据库中可以被表示为一系列的外键。我们无法将这个聚合关系和那些不是聚合关系的关系区分出来。所以说关系型数据库对于聚合是不敏感的(Aggreate ignorance).在关系型数据库中我们不能使用聚合结构来保存数据。

不同的数据建模的技术提供不同的方法来表述组合或者聚合结构。但是建模者很少能表达出聚合关系不同于其他关系的语意。但是在aggregate-roiented db中，我们有明确的语意，我们需要考虑以什么样的数据单元来与数据data storage 进行交互。

当我们的领域模型中没有一个明显的，主要的，操作数据的结构，那此时也许No-SQL并不适合你。

面相聚合的数据库存在及流行的主要原因是因为集群。当我们需要在集群中保存数据的时候我们必须知道哪些数据应该被当成单一的数据块来进行操作，那么这些数据应该被保存到一起，保存到一个节点上。

### 事务
关系型数据库可以保证我们操作可以在一个事务中完成，即便这些数据来自不同不同表中的不同的行。(Atomic Consistent Isolated Durable)
No-SQL中没有事务来保证夸多个聚合根的一致性。只有事务用来保证单一聚合的Atomic的属性。也就是说如果我们需要夸聚合根的一致性的时候，我们需要在应用程序级别来保证。

### More
聚合关系把相关联的数据作为数据单元来进行操作。但是仍然存在使用不同的存取和操作这些相关联的数据的场景。在customer-order的关系中，有的程序在访问order的时候就需要order history，这种场景可以将order聚合到customer中，这样我们就只有一个aggreate。但是在我们的货运系统中我们就需要就对每个订单进行单独存取。此时就需要order作为单一的聚合。这种情况下我们可以将customer和order作为两个单独的聚合。但是在这两个聚合上存在某种关系，以便我们可以获取customer的order，和获取order的customer。最简单的方法就是在customer上聚合order的id，在order上embed customer_id. 但是这种情况下db对这种关系是ignorant。所以此时我们只能通过aggreate 上的query来对这种关系提供支持，此时可以order上建立customer_id的index和在customer上建立order_id的index来提高query的执行效率。

