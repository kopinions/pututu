---
layout: post
title:  "Devops之Ansible 入门"
date:   2014-07-25 16:17:59 +0800
categories: 
- devops
tags: 
- devops
excerpt: ansible是个什么东西呢？官方的title是“Ansible is Simple IT Automation”——简单的自动化IT工具。这个工具的目标有这么几项：自动化部署APP；自动化管理配置项；自动化的持续交互；自动化的（AWS）云服务管理。Ansible 的免安装特性，使得 ansible 在 devops 中获得了非常广泛的使用。
description: ansible是个什么东西呢？官方的title是“Ansible is Simple IT Automation”——简单的自动化IT工具。这个工具的目标有这么几项：自动化部署APP；自动化管理配置项；自动化的持续交互；自动化的（AWS）云服务管理。Ansible 的免安装特性，使得 ansible 在 devops 中获得了非常广泛的使用。
---

ansible是个什么东西呢？官方的title是“Ansible is Simple IT Automation”——简单的自动化IT工具。这个工具的目标有这么几项：自动化部署APP；自动化管理配置项；自动化的持续交互；自动化的（AWS）云服务管理
Ansible 的免安装特性，使得 ansible 在 devops 中获得了非常广泛的使用。

### inventory 配置
---
```
local ansible_ssh_host=127.0.0.1 ansible_ssh_port=2222

ci ansible_ssh_host=127.0.0.1 ansible_ssh_port=2221

[localenv]
local

[cienv]
ci

[all_groups:children]
localenv
cienv
```
### Playbook

```
---
- hosts: localenv
  user: vagrant
  sudo: True
  tasks:
    - name: update env 
      apt: update_cache=yes 

    - name: install postgres
      apt: pkg={{item}} state=present
      with_items:
        - postgresql
        - postgresql-contrib
        - python-psycopg2

    - name: Make sure postgres running
      service: name=postgresql state=started enabled=yes

    - name: mange postgres user
      sudo_user: postgres
      postgresql_user: name=twer password=twer role_attr_flags=SUPERUSER 
    - name: create default db
      sudo_user: postgres
      postgresql_db: name=order
	
```

### Include tasks
---
我们可以将我们所有的task都写在一个文件中，就如上面所示，让这个文件处理我们整个环境的初始化，这样做是可以被ansible所支持的。但是如果这样做我们的初始化脚本将很难扩展与复用。比如我们的整个环境的部署中需要安装1. java，2. postgres，如果我们将他们都写在一个文件中，如果我现在需要安装1. java 2. mysql，我必须重新写一个Playbook，这个playbook必须包括java安装，和mysql的安装。不能复用我们以前就有的java安装的逻辑。此时就可以将我们安装java和postgres

1. 安装java

	```
	# tasks/java.yml
	- name: placeholder for install java
	  apt: pkg=java
	```
2. 安装postgres
	
	```
	# tasks/postgres.yml
	- name: placeholder for install postgres
	  postgres_user: name=test password=test 
	```
3. 复用java模块

	```
	tasks:
	  - include tasks/java.yml
	  - name: install mysql
	  	# to install mysql here
	```
	
如果在我们task中需要使用某种参数，那么此时在我们includetask的时候我们可以通过以下的几种方式来传递参数,在tasks/java.yml中可以直接使用{{dest}}来使用参数

1. 直接传递

	```
	tasks:
	  - include tasks/java.yml dest=/user/local/java
	  - include tasks/postgres.yml dest=/user/local/postgres
	# ansible 1.4之后参数可以为复合参数
	tasks:
	  - {include: tasks/java.yml, dest=/user/local/java check=[javac, java]}
	  # include 中参数可以为List，也可以为dictory
	```
2. 通过vars模块来传递
	
	```
	tasks:
	  - include tasks/java.yml
	    vars:
	       dest: /user/local/java
	```
---
### Role in ansible
ansible中的role的机制很简单。他的作用就是基于指定的目录结构，自动加载的相应的文件var_files, tasks,handlers，其实就相当于自动的include。指定的目录结构如下

```
site.yml
webservers.yml
fooservers.yml
roles/
   common/
     files/
     templates/
     tasks/
     handlers/
     vars/
     meta/
     defaults/
   webservers/
     files/
     templates/
     tasks/
     handlers/
     vars/
     meta/
     defaults/
```

webserver的写法如下

```
---
- hosts: webservers
  roles:
    - common
    - webservers
```
具体的加载规则(来自[ansible官网](http://docs.ansible.com/playbooks_roles.html#roles))

```
If roles/x/tasks/main.yml exists, tasks listed therein will be added to the play
If roles/x/handlers/main.yml exists, handlers listed therein will be added to the play
If roles/x/vars/main.yml exists, variables listed therein will be added to the play
If roles/x/meta/main.yml exists, any role dependencies listed therein will be added to the list of roles (1.3 and later)
Any copy tasks can reference files in roles/x/files/ without having to path them relatively or absolutely
Any script tasks can reference scripts in roles/x/files/ without having to path them relatively or absolutely
Any template tasks can reference files in roles/x/templates/ without having to path them relatively or absolutely
Any include tasks can reference files in roles/x/tasks/ without having to path them relatively or absolutely
```

##### 参数化role
```
---
- hosts: webservers
  roles:
    - common
    - { role: foo_app_instance, dir: '/opt/a',  port: 5000 }
    - { role: foo_app_instance, dir: '/opt/b',  port: 5001 }

#给webservers添加tag
---
- hosts: webservers
  roles:
    - { role: foo, tags: ["bar", "baz"] }    
```
##### 执行顺序
如果在playbook中，没有特别指定的tasks，则role总是会被首先执行。如果需要在role执行前执行特定的任务，可以使用pre_tasks,post_tasks来指定

```
---

- hosts: webservers

  pre_tasks:
    - shell: echo 'hello'

  roles:
    - { role: some_role }

  tasks:
    - shell: echo 'still busy'

  post_tasks:
    - shell: echo 'goodbye'
```

##### Role 默认参数
Role有时候需要一些默认的参数，用来当使用者没有指定相应参数的时候可以完成预定的初始化。这些默认的参数放在role/defaults/main.yml,这些参数的优先级是最低的，当在其他地方指定相同的参数的时候，这个默认的参数就会被覆盖。

##### role dependence
如果我们的app需要依赖java，我们的java安装作为一个role存在，这种情况下就用到role的dependence. dependence被存在role/meta/main.yml中，格式如下
```
---
dependencies:
  - { role: java, dest: /usr/local/java }
```
如果java此时还有依赖，如下所示
```
---
dependencies:
  - { role: xxx}
```
则在加载我们app的时候，会递归的加载dependence。加载顺序如下  
**xxx -> java -> app**

### 实例 --rails + postgres


### rails
---
###### 安装make,因为gem 的有的模块需要编译
```
-
 name: install env 
      apt: pkg={{item}} state=present
      with_items:
        - make
```
        
        
### 注意事项
---

###### add java repository no writable keyring found: eof
需要使用sudo来进行repository的添加

###### role中必须有一个目录不为空，负责会报错
###### 死活都找不到bundle的解决方法
gem install 的bundle在我们bundle install的时候总是会找不到我们的bundle，尽管我们使用rbenv 装的ruby，此时可以通过(添加sudo_user的方法)
```
- name: install gems for app
  gem: name={{item}} state=present
  sudo_user: vagrant
  with_items:
    - bundler
```
###### Could not find a JavaScript runtime

gem 'therubyracer'
gem 'execjs'

###### make: g++: Command not found
apt-get install g++

###### migration are pending
rake db:migrate

###### run rails server in production and daemon mode
```
rails server -e production -d 
```
###### Can't find the 'libpq-fe.h header
安装pg gem包的时候需要编译，编译过程中可能需要依赖文件，pg gem会进行一层包装，所有的依赖都在libpq-dev. 使用apt模块安装即可。
###### Missing `secret_key_base` for 'production' environment, set this value in `config/secrets.yml`
此时可以通过dotenv-rails管理env配置文件。所有的配置都会卸载一个.env的配置文件中。
gem 'dotenv-rails'

```
// file .env
SECRET_KEY_BASE=3eb6db5a9026c547c72708438d496d942e976b252138db7e4e0ee5edd7539457d3ed0fa02ee5e7179420ce5290462018591adaf5f42adcf855da04877827def2
``` 
 在config/enviroment.rb中添加  

```
require 'dotenv'
Dotenv.load
```
###### 用以下代码来生成secret_key_base
require 'securerandom'
SecureRandom.hex(64)


ssh -i /Users/twer/.vagrant.d/insecure_private_key vagrant@127.0.0.1 -p 2222

scp -P 2222 -i /Users/twer/.vagrant.d/insecure_private_key ./.env vagrant@127.0.0.1:~

###### rails migrate db
```rake db:migrate RAILS_ENV=production```

###### Peer authentication failed for user "twer"
尝试psql -U twer -W -h localhost -d database, 如果这条命令可以正确执行，则配置database的配置如下

rdms production database configuration
```
production:
  adapter: postgresql
  pool: 5
  timeout: 5000
  database: order
  username: twer
  password: twer
  host: localhost
```

mongoid production configration

```
production:
  sessions:
    # Defines the default session. (required)
    default:
      # Defines the name of the default database that Mongoid can connect to.
      # (required).
      database: mongodb_production
      # Provides the hosts the default session can connect to. Must be an array
      # of host:port pairs. (required)
      hosts:
        - localhost:27017
      options:

```


xml test
```
Hash.from_xml(x)["message"]["param"].inject({}) do |result, elem| 
  result[elem["name"]] = elem["value"] 
  result 
end
```
