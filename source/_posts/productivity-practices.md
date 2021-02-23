---
layout: post
title: "高效能实践"
date: 2019-10-29 12:40:20
categories: 
- productivity
tags: 
- productivity
excerpt: 'ex'
description: 'des' 
---

1. autohotkey

```
^Space: ^@
```

2. gnome shortcut

```
yum install dconf-editor
```
使用 dconf-editor
修改  /org/gnome/mutter/keybindings/switch-monitor
如果当前的值是： `['<Super>p', 'XF86Display']` 此时， Disable Use default value(禁用默认值), 然后插入默认值 `[]`
修改  /org/gnome/settings-daemon/plugins/media-keys/video-out
如果当前值是： `<Super>p`
则禁用默认值，然后清除所有的值即可

### 键位映射

Caps Lock -> Ctrl 键位

### 键盘操作

#### window control

1. left & right
2. max

#### chrome vimium

1. switch tab
2. search tab
3. open tab & close tab
4. open url
5. find history & open
6. scroll up & scroll down
7. search content & copy content & use copied content search

#### tmux

1. tmux select
2. tmux scroll (c-a [ c - ])
3. tmux select & copy & paste(c-a [ c-spc c-n alt-w ctrl-w | c-a ])
4. tmux search (c-r / c-s)
5. tmux panel split & switch & manager (c-a " | c-a % | c-a o | c-a z)
6. tmux window create & window search (c-a f, c-a c , c-a &)


#### bash

1. array keys (ctrl-f, ctrl-b, ctrl-n, ctrl-p)
2. move by word (alt-f, alt-b)
3. begin & end ( ctrl-a, ctrl-e)
4. delete char (ctrl-d, backspace)
5. delete word (alt-d, alt-w)
6. scroll up & scroll down (shift-pageup, shift-pagedown)

#### tig
1. view history
2. view diff


#### array keys in other place

1. chrome
2. sublime
3. wechat
4. alfred

### 搜索

#### alfred
##### 应用程序搜索
##### 文件搜索
##### 菜单搜索
##### clipboard 搜索
##### 有道


#### autojump

1. autojump 模糊查询 folder

#### vim / emacs 文件

1. vim ctrlp
2. emacs projectifle


### 快捷键

#### clion

1. 常见快捷键
   1. 生成实现（ alt+enter）
   2. 跳转实现 / 定义（ctrl-b）
   3. find file
   4. find symbol


2. 重构快捷键
    1. extra method
    2. extra variable
    3. auto complete
    4. inline variable
    5. inline function call
    6. rename

#### alias

```lang=bash
alias gst="git status"
alias gco="git checkout"
```
##### git status xxx vs gst
##### git commit -m vs gc -m
##### git checkout . vs gco .
##### git pull --r vs gl -r
##### git diff vs gd
##### git push vs gp
##### git add vs ga
##### git add --amend vs gca

### 云化
#### brewfile
#### chocolate
#### github

<https://github.com/sjkyspa/env>




