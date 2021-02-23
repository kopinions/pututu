---
layout: post
title:  "Linux emacs clangd 配置"
date: 2019-10-08 19:09:20 +0800
categories: 
- emacs
tags: 
- emacs
excerpt: 笔者的因为工作的原因需要使用 centos 工作， 并且工作的主要语言是 c/c++, 但是笔者比较习惯的 IDE 是 Intellij 或者 emacs。 所以笔者需要在 centos 上配置相应的 emacs 环境。但是在 centos 上使用 yum 安装 emacs 下只能安装 emacs 24.2, 所以笔者需要配置 emacs ,并且配置 emacs c++ 的环境。 
description: 笔者的因为工作的原因需要使用 centos 工作， 并且工作的主要语言是 c/c++, 但是笔者比较习惯的 IDE 是 Intellij 或者 emacs。 所以笔者需要在 centos 上配置相应的 emacs 环境。但是在 centos 上使用 yum 安装 emacs 下只能安装 emacs 24.2, 所以笔者需要配置 emacs ,并且配置 emacs c++ 的环境。 
---

### 准备工作

笔者的因为工作的原因需要使用 centos 工作， 并且工作的主要语言是 c/c++, 但是笔者比较习惯的 IDE 是 Intellij 或者 emacs。 所以笔者需要在 centos 上配置相应的 emacs 环境。但是在
centos 上使用 yum 安装 emacs 下只能安装 emacs 24.2, 所以笔者需要配置 emacs ,并且配置 emacs c++ 的环境。

### compile emacs

```
tar -xf emacs-26.3.tar.xz
cd emacs-26.3
./configure
make
make install
```

### compile llvm 9.0.0

```
curl -sjklL https://github.com/llvm/llvm-project/archive/llvmorg-9.0.0.tar.gz -O llvmorg.tar.gz

tar -zxf llvmorg.tar.xz --transform s/llvmorg-9.0.0/llvmorg/
cd llvmorg
mkdir build
cd build
cmake -G "Unix Makefiles"  -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=true -DLLVM_ENABLE_PROJECTS="clang-tools-extra" -DCMAKE_BUILD_TYPE=MinSizeRel ../llvm
make -j8
```



### 遇到的问题
##### collect2: error: ld terminated with signal 9 [Killed]

这个问题出现的元应主要是因为， llvm c++ 写的大型应用，在链接阶段，非常消耗内存，这种情况下如果内存不够用，会导致 link 进程被杀死。解决办法就是增加
swap 分区，用来补齐需要的内存。对于 llvm 的编译，最好让内存和 swap 相加超过 16GB. 创建增加 swap 分区的命令如下所示

```
# 因为 swap 分区需要较高的权限，直接使用 root 操作

sudo su
dd -if /dev/zero -of /tmp/swap1 bs=1M count=8192
mkswap /tmp/swap1
swapon /tmp/swap1
# 查看 swap 分区是否变成 8G
free -g
```

##### can not find clang-tools-extra, or clang

这个问题主要是我们目录结构没有遵从 llvm 预期的目录结构放置，导致没有 llvm 没法找到 clang , 和 clang-tools-extra 的代码目录，请严格按照 compile llvm 9.0.0 进行操作
