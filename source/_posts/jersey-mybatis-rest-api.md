---
layout: post
title: "如何使用Java Jersey MyBatis 编写微服务 REST API"
date: 2014-10-10 20:22:50 +0800
categories: java mybatis rest api
tags: java mybatis rest api
excerpt: jersey 和 mybatis 做为 java 界的扛把子，我们应该如何一步一步的通过测试驱动开发的方式来完成一个API的实现过程。这篇文章会给以一个详细的介绍
description: jersey 和 mybatis 做为 java 界的扛把子，我们应该如何一步一步的通过测试驱动开发的方式来完成一个API的实现过程。这篇文章会给以一个详细的介绍
---

具体代码库请见[jersey tdd](https://github.com/sjkyspa/order_jersey)

###### 安装需要的库
```
compile 'javax.ws.rs:javax.ws.rs-api:2.0'
compile 'org.glassfish.jersey.containers:jersey-container-grizzly2-http:2.10.1'
compile 'org.glassfish.jersey.core:jersey-server:2.10.1'
compile 'org.glassfish.jersey.media:jersey-media-json-jackson:2.10.1'
compile "org.mybatis:mybatis:3.2.7"

testCompile "org.glassfish.jersey.test-framework:jersey-test-framework-core:2.10.1"
testCompile 'org.glassfish.jersey.test-framework.providers:jersey-test-framework-provider-grizzly2:2.10.1'
testCompile "org.mockito:mockito-core:1.9.5"
```
###### gradle 安装所有文件

##### Product

###### 200 测试
在intelij中，需要注意的是只有把测试目录设置为test root的时候才能跑测试。
只需要测试200，保证get能够找到正确的路径

###### 404 测试
与200测试相同的代码，但是此时需要表示404，此时就需要mock一个repository，而且在特定的情况下抛出相应的异常，使得程序返回404,此时可以驱动出来需要调用repository来拿相应的product，此时接口应该为

```
Product getProductById(@Param("productId") int productId);
```

###### Post 测试
1. 测试201，以一个很简单的Map来当做product的数据来测试route的正确性
2. 测试uri，此时可以驱动出来需要使用指定的repository来createproduct，此时createProduct的接口应该为：

	```
int createProduct(@Param("product")Product product
```
2. 测试以一定的参数保存product

	此时如何测post接口呢？可以使用test spy来测试，我们查看我们spy的对象接到了相应的调用参数，这样就保证我们的api是调用了指定的repository去保存我们的domain对象的，但是至于后面保存正确与否，这就是由repository的测试来保证。下面的ArgumentCaptor就是我们的TestSpy

```
@Captor
ArgumentCaptor<Product> productArgumentCaptor;
    
Map<String, Object> product = new HashMap<>();
product.put("name", "productName");
product.put("description", "description");
       
assertThat(productArgumentCaptor.getValue().getName(), is("productName"));
assertThat(productArgumentCaptor.getValue().getDescription(), is("description"));
```

2. 以一定的参数保存Price
	
	```
Map<String, Object> price = new HashMap<>();
price.put("amount", 1.0);
price.put("effectDate", "2014-01-01");
product.put("price", price);
assertThat(priceArgumentCaptor.getValue().getAmount(), is(1.0));
assertThat(priceArgumentCaptor.getValue().getEffectDate(), is(new SimpleDateFormat("yyyy-MM-dd").parse("2014-01-01")));
```

###### 补齐200 测试
3. get basic info
4. get uri
5. get price info
6. get price uri


##### Price

###### /products/1/prices/1 200
同product

###### /products/999/prices/1 404
此时驱动出来需要在我们的price的route中需要调用product.getProductById(productID),但是由于jersey可以使用subresource，此时我们可以在product resource将构造好的product作为参数传给subresource，所以我们在subresource中，就不用再次getProduct，再多一份处理异常的代码

###### /products/1/prices/999 404
此时驱动出来一个方法product.getProductPriceById(Product, priceId)

###### /products/1/prices post 201
1. 201
2. uri  
 	此时可以驱动出来需要使用指定的repository来保存我们需要创建的资源，因为此时我们需要使用如下的方面去测试。我们在stub中返回了我们创建的price的ID。驱动出我们需要在我们的controller中调用这个方法来创建我们的资源
 ```
 when(productRepository.createProductPrice(any(Product.class), any(Price.class))).thenReturn(2);
 ```
2. product的captor的测试
3. price captor的测试


##### Order

###### /users/1/orders/1 200

###### /users/999/orders/1 404
此时可以驱动出调用userRepository.findUserById()

###### /users/1/orders/999 404
此时可以驱动出userRepository.findUserOrderById()

###### post /users/999/orders 201
此时可以驱动出userRepository.createOrderForUser(User, Order),
也可以驱动出需要将user，和userRepository传入subResource
1. 201
2. uri(mock repo return created order id)
3. user argument captor 
4. order argument captor 

##### Payment
当资源不是集合的时候此时post的驱动方式就会有一定的不同

###### get /users/1/orders/1/payment

1. 200
2. 404

###### post /users/1/orders/1/payment

1. post /users/1/orders/1/payment {type: "CASH"} return 201
2. uri,但是此时驱动不出来以repository来保存相应的payment
3. user argument captor
4. order argument captor
5. payment argument captor

#### Reposotory 测试

###### Configure file
```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <!--<settings>-->
    <!--<setting name="logImpl" value="LOG4J"/>-->
    <!--</settings>-->
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="org.postgresql.Driver"/>
                <property name="url" value="jdbc:postgresql://localhost:5432/order0625"/>
                <property name="username" value="twer"/>
                <property name="password" value=""/>
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <mapper resource="org/thoughtworks/com/provider/ProductMapper.xml"/>
    </mappers>
</configuration>
```

###### config load

```
InputStream resourceAsStream = Resources.getResourceAsStream("mybatis.xml");
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(resourceAsStream);
```

###### Mapper file
```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="thoughtworks.com.repository.ProductRepository">
</mapper>
```

###### Migration
```

buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath "org.flywaydb:flyway-gradle-plugin:3.0"
        classpath 'org.postgresql:postgresql:9.3-1101-jdbc41'
    }
}


apply plugin: 'flyway'

flyway {
    driver = 'org.postgresql.Driver'
    url = 'jdbc:postgresql://localhost:5432/orderjersey'
    user = 'twer'
    password = ''
    locations = ['filesystem:src/main/resources/dbmigration']
    sqlMigrationPrefix = '0'
    sqlMigrationSeparator = '_'
}
```

###### mybatis sql log

1. gradle  
	`compile "log4j:log4j:1.2.16"`
2. mybatis config	
	```
	<settings>
		<setting name="logImpl" value="LOG4J"/>
	</settings>
	```
3. gradle idea
4. log4.properties
	```
	log4j.rootLogger=ERROR, stdout
	# MyBatis logging configuration...
	log4j.logger.thoughtworks.com.repository.ProductRepository=TRACE
	# Console output...
	log4j.appender.stdout=org.apache.log4j.ConsoleAppender
	log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
	log4j.appender.stdout.layout.ConversionPattern=%5p [%t] - %m%n
	```
其中log4j.logger.thoughtworks.com.repository.ProductRepository=TRACE 必须是mapper中存在的namespace才可以

###### 插入多个表
```
<insert id="createProduct" parameterType="thoughtworks.com.domain.Product">
        <selectKey keyProperty="product.id" resultType="Integer" order="BEFORE">
            select NEXTVAL('products_id_seq');
        </selectKey>
        insert into products (id, name, description) values (#{product.id}, #{product.name}, #{product.description});
        insert into prices (amount, effectDate, productId) values (#{price.amount}, #{price.effectDate}, #{product.id});
</insert>
```
这时候我们的selectKey会将product上的id置为我们生成的id。此时就可以通过product.id。
此时price也可以同时被插入进去。
insert 的时候，我们的如果selectKey上的order为BEFOR，此时mybatis会首先取得插入的key，然后再将我们keyProperty设置为对应的ID，然后再进行insert操作，所以在insert的时候我们需要制定我们插入的id primary key.

###### 查询多个表
有时候我们对象上的数据可能是来自多个数据库表，此时可以使用如下的方式来获取。比如此时我需要获取product上当前的price，我可以使用以下方式来获得product，或得到的product上就会默认的带上currentPrice

```
<resultMap id="productDetail" type="thoughtworks.com.domain.Product">
        <id property="id" column="product_id"></id>
        <result property="name" column="product_name"></result>
        <result property="description" column="product_description"></result>
        <association property="currentPrice" javaType="thoughtworks.com.domain.Price">
            <id property="id" column="price_id"/>
            <result property="amount" column="price_amount"/>
            <result property="effectDate" column="price_effect_date"/>
        </association>
</resultMap>    
<select id="getProductById" resultMap="productDetail">
      select
        product.id as product_id,
        product.name as product_name,
        product.description as product_description,
        a.id as price_id,
        a.amount as price_amount,
        a.effectDate as price_effect_date
      from products product
      left join (
	    select price.amount, price.productId, price.effectDate, price.id from prices price
	    inner join (select price.productId, max(effectDate) as effectDate from prices price group by price.productId) as p on p.productId=price.productId and p.effectDate=price.effectDate
	  ) as a on product.id = a.productId where product.id = #{productId}
</select>
```

###### 插入集合对象
比如我们有个order，但是order上有个集合的orderItems，此时我们可以使用如下的方式来插入orderItems

```
<insert id="createOrderForUser" parameterType="thoughtworks.com.domain.Order">
        <selectKey keyProperty="order.id" resultType="Integer" order="BEFORE">
            select NEXTVAL('orders_id_seq');
        </selectKey>
        insert into orders (id, name, phone, address, userId) values (#{order.id}, #{order.name}, #{order.phone},
        #{order.address}, #{user.id});
        <foreach collection="order.orderItems" item="orderItem">
            insert into order_items(orderId, productId, quantity) values (#{order.id}, #{orderItem.productId}, #{orderItem.quantity});
        </foreach>
</insert>
```
其中order的结构如下

```
public class Order {
    private int id;
    private String address;
    private String name;
    private String phone;
    private List<OrderItem> orderItems;
}

int createOrderForUser(@Param("user") User user, @Param("order") Order order);
```


#### 使用gradle来启动我们的server
```
apply plugin:'application'
mainClassName = "thoughtworks.com.Server"
```

1. Failed to load class "org.slf4j.impl.StaticLoggerBinder"  
```
  // use to log slf4j
  compile 'org.slf4j:slf4j-api:1.7.5'
  compile 'org.slf4j:slf4j-log4j12:1.7.5'
```



#### 常见错误
###### Error instantiating class thoughtworks.com.domain.Order with invalid types () or values (). Cause: java.lang.NoSuchMethodException: thoughtworks.com.domain.Order.<init>()
mybatis默认使用的是默认的构造函数来反射我们的类，然后将值一个一个的塞到我们相应的字段上，所以在我们的类中需要有一个默认参数的构造函数，出现这个错误的原因是因为我们重新声明了构造函数，没有默认参数的构造函数存在，所以mybatis不知道如何去初始化我们的domain对象。


###### 当总是出现500错误的时候，很有可能是repository没有注册

还有可能是因为返回了一个对象，但是没有加@produce(MediaType.APPLICATION_JSON)
