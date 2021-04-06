---
layout: post
title: "RPM 安装包制作"
date: 2019-09-12 19:18:20 +0800
updated: 2021-04-05
categories: 
- linux 
- package 
- devops
tags: linux package devops
excerpt: rpm 包是预先在Linux主机上编译好并打包的文件，可以在离线的情况下进行安装。这边文件总结了笔者的 rpm 包的构建过程以及构建过程中遇到的各种问题，希望能帮助到各位。
description: rpm 包是预先在Linux主机上编译好并打包的文件，可以在离线的情况下进行安装。这边文件总结了笔者的 rpm 包的构建过程以及构建过程中遇到的各种问题，希望能帮助到各位。
---

## RPM 安装包制作教程

### 安装必要的软件包

```
yum install rpm-build
yum install rpmdevtools
# 创建 rpm build 的目录结构
rpmdev-setuptree
```

我们可以通过如下命令来找到 rpmbuid 工作目录（rpm 所有的构建，运行命令都是在这个目录下进行）

```
rpmbuild --showrc | grep topdir
# 类似 _topdir %{echo $HOME}/rpmbuild
```

rpmbuild 典型的目录结构为

```
rpmbuild
├── BUILD
├── BUILDROOT
├── RPMS
├── SOURCES
├── SPECS
└── SRPMS
```

### 准备要构建的源码包

因为 rpmbuild 只支持 tar.gz 格式的源文件包， 所以我们需要将源码包以 tar.gz 的方式进行打包

假设我们想要打包的软件名称为 wechat, 我们现在的目录结构如下所示

```
wechat
├── include
│   └── wechat.h
└── lib
    ├── libwechat.so
    └── libwechat.so.0
```

这种情况下我们可以可以使用如下的命令将所有文件进行压缩

```
cd wechat
tar -czvf wechat-1.0.0.tar.gz *
```

因为 rpm 默认的会在 SOURCES 文件下找到所有的源码包，所以我们需要将我们的源码包移动到 ```${HOME}/rpmbuild/SOURCES``` 目录下

```
mv wechat-1.0.0.tar.gz ${HOME}/rpmbuild/SOURCES
```

### 准备 rpm 构建描述文件（spec文件）

假设我们的 spec 的文件名为 wechat.spec. 一般情况下我们会将 rpm 包描述文件放置在 ```${HOME}/rpmbuild/SPECS``` 目录下


```
Name: wechat
Version: 1.0.0
Release: 1%{?dist}
Summary: wechat software

Group: Tencent
License: GPL
URL: https://github.com/sjkyspa/wechat.git
Source0: %{name}-%{version}.tar.gz

%description
The test wechat software rpm build package

%prep
%setup -c -n %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/usr/lib
mkdir -p %{buildroot}/usr/include
cp -rf lib/* %{buildroot}/usr/lib
cp -rf include/* %{buildroot}/usr/include

%files
/usr/include/*
/usr/lib/*
```

上面有集中类型的描述信息

* rpm 包的元信息：包括 Name， Version，Release，Summary， Group，License， URL， %description
* rpm 构建信息：包括 Source0， 用来指定构建用到的源码包
* rpm 构建阶段指令信息： 包括 %prep，%build，%install，%files


rpm 包的元信息主要用来描述 rpm 包的基本信息，这个字段在后面可以通过对应环境变量来进行访问，比如：%{name}，%{version}

rpm 构建阶段的指令, rpmbuild 将构建分为了多个阶段，每个阶段解释如下：

1. %prep (准备阶段 prepare）

	最先开始的阶段，一般情况下我们使用 %setup 指令将源码包进行解压缩。这里着重解释下两个参数，-c 就是解压前先创建相应的目录，然后在解压缩，-n 就是以这个名字命名目录，所以 %setup -c -q 就是将代码包解压到 %{name}-%{version} 的目录下。解压后的文件会被放到 ```${HOME}/rpmbuild/BUILD``` 目录下

2. %build (构建阶段）

	在解压后，rpmbuild 会在 ```${HOME}/rpmbuild/BUILD``` 目录下运行构建指令，常见的指令有 make，当然 rpmbuild也提供了一个 %make 宏来完成 make 命令
	
3. %install （安装阶段）

	整个 install 的阶段就是将构建好的文件从 ```${HOME}/rpmbuild/BUILD``` 目录转移到 ```${HOME}/rpmbuild/BUILDROOT``` 下的过程，rpm 相当于把 ```${HOME}/rpmbuild/BUILDROOT``` 下编译好的文件直接进行打包。 一般在这个阶段下会运行 ```make install``` 命令，但是我们此处只需要将一些文件放在指定的目录，所以我们可以直接使用 cp 命令将我们的文件拷贝到指定的目录。此处的 %{buildroot} 就是 ```${HOME}/rpmbuild/BUILDROOT```, 当被安装的时候，就会变成 /
	
4. %files （指定文件）

	整个打包的过程首先在 ```${HOME}/rpmbuild/BUILDROOT``` 完成整个安装过程。rpmbuild 会将 %files 节指定的文件都放进打出的 rpm 包
	
当然整个 rpmbuild 还有一些其他的阶段，在这里就不多做介绍了，详细请参见 [rpm 指南](https://rpm-guide.readthedocs.io/en/latest/rpm-guide.html)

### 打包

```
cd ${HOME}/rpmbuild/SPECS
rpmbuild -bb wechat.spec
```

如果运行正常就会在 ```${HOME}/rpmbuild/RPMS``` 出现我们用 rpmbuild 打好的安装包


### 常见的问题
##### Installed （but unpackaged） file(s) found

这种情况一般是因为 %files 章节没有指定需要 rpmbuild 放进 rpm 包的文件，所以 rpmbuild 包不知道包内包含什么内容，所以报错。

##### rpm conflict with existing xxx

这种情况一般是因为我们在我们 %files 章节， 指定文件的时候，使用了 ```/usr/include/``` 这种方式，但是一般情况下，这个目录是系统自己带的目录，所以会产生冲突。所以指定文件的时候，如果需要指定一个目录的文件可以通过 ```/usr/include/*``` 的方式指定

### 打包过程中常会用到的命令

```
# 查询安装包内的文件情况
rpm -qpl xxx.rpm

# 查询系统中安装包的情况，一般出现冲突的时候，查看
rpm -ql xxxx

# 查询源码包中文件情况
tar -tf wechat.tar.gz

# 安装 rpm 包, 不安装依赖，并且强制安装
rpm -ivh --nodeps --froce xxx.rpm
```

### 调试 rpm 包中会用到的 RPM 的命令

```
# 查询已经安装的包的 rpm 包的 pre 和 post hook
rpm -q --scripts xxx
# 查询 rpm 文件的 hook
rpm -qp --script xxx.rpm
# 安装到自定义的目录
yum install --installroot=/custom/dir xxxx
# 安装的时候，显示 hook 执行的详细信息
yum install --installroot=/custom/dir --rpmverbosity=debug xxxx 
```

