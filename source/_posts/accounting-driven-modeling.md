---
layout: post
title: "时间驱动建模"
date: 2014-07-20 20:33:50 +0800
categories: architecture modeling
tags: architecture modeling
excerpt: 对于时间驱动建模驱动力主要包括两块 1. 对于企业内部，驱动力大部分为KPI 2. 对于外部商业系统，驱动力为支出或者收入的钱
description: 对于时间驱动建模驱动力主要包括两块 1. 对于企业内部，驱动力大部分为KPI 2. 对于外部商业系统，驱动力为支出或者收入的钱
---

对于时间驱动建模驱动力主要包括两块
1. 对于企业内部，驱动力大部分为KPI
2. 对于外部商业系统，驱动力为支出或者收入的钱

<!-- more -->

### 时间驱动建模
1. MomentInteval(具有时间点或者时间段的对象)
2. Role（角色，通常做多个决策的时候会出现Role，但是最终的模型中没有Role的存在）
3. Party/Place/Thing（party为负责的人或者第三方，Place为地点，Thing为东西，抽象的东西）

驱动力主要包括两块：

1. 对于企业内部，驱动力大部分为KPI
2. 对于外部商业系统，驱动力为支出或者收入的钱

方法的关键：

1. 从一个收入或者KPI入手，反过来进行追溯
2. 将实际的业务场景带入，看模型是否能解决
3. 模型中主要关注时间点，和数据项（这些东西是可以追溯的）

例子1：

1. 有个订单系统，当前系统收入X元，这是怎么来的？
   
   是由于客户付款（Pay），此时需要产生一个Payment用来追溯这笔钱产生的时间(paytime)，及钱的数量（amount）
2. 客户所付的钱（amount）从哪里来？
   
   客户购买货物所组成的某个订单，这个订单的总价是total，快递费是deliveryFee， amount=total+deliveryFee
   
3. deliverFee 从哪里来
	
	由于选择不同供应商的不同，所以有可能会产生不同的deliveryFee，所以此时devliveryFee的来源为Delivery的一个角色，这个角色负责得到deliveryFee
4. total从哪里来

	因为订单由不同的货物（OrderItem）组成，此时order就是所有的OrderItem的所对应的产品价格（price）总和
	
5. price从哪里来？

	每个Product都有自己所对应的price，但是price跟着时间的变化而变化。所以price的来源是定价策略中ProductPrice中与OrderItem所对应的Product的对应的定价策略中的price。



例子2：

1. 系统支出Y元，用来做了什么？  
	查看记录发现是在time时，做了一个refundPayment，refundPayment的总额为Y元
2. 这个Y是怎么得到的？   
    查看refundPayment所关联到的退款记录refund的单据发现，在refundTime做了一次总额为refundTotal的退款这次退款收到货物的时间为deliveryEntryTime
3. refundTotal怎么得到？   
发现退款项有：RefundItem A，他所对应的退款项为 X
这次refund是payTime=B的Order A进行的退款，具体的退款项refundItem关联的商品OrderItem A发生退货。Product找到time=payTime=B的定价信息price（A）；Y = price（A）* quantity（A）. 

4. deliveryEntryTime怎么得到？
4. 

### 问题
1. 为什么到最后一定不存在Role？
2. Role所具有的职责？