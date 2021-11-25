---
title: CNN-實作練習
date: 2018-11-13 18:16:53
tags: 
- AIJT
- 機器學習
categories: 機器學習
thumbnail: https://i.imgur.com/ikCd8vZ.png
---

# CNN 神經網路實作
###### tags: `AI Junior Talk 人工智慧青年論壇` `機器學習`
> 比賽介紹 imagenet


# 神經網路介紹
## AlexNet 網路
> 成功率提高至  83.6% 至此開始發展電腦視覺
* 使用 ReLU
* LRN層（後來被淘汰，例如 BN）
* overlapping pooling
* Dropout

## VGG16
* 優點
    * 相對淺
    * 構造簡單
    * 易入門
* 缺點
    * 權重多
    * 肥(吃較多記憶體)
* VGG16 paper

## Google Net
> 當年已經勝過 Google Net
* 較為複雜
* 由 Inception 組成
* 神經網路具有分支
    * 避免深層網路過多過長時，早期權重無法被修正
    * 可以直接以分支的 softmax 去反向傳播修正權重

## ResNet
* 同 VGG16 構造較為簡單
* 但是較深，所以新增捷徑
* 透過捷徑反向傳播修正前面權重
* 曾樹效果是有上限的

![](https://i.imgur.com/ikCd8vZ.png)
* 優點：參數少
* 缺點：使用者容易設定過多層

![](https://i.imgur.com/IHSPSKT.jpg)

## 預訓練權重應用
[資料集來源](https://www.kaggle.com/c/dogs-vs-cats)
課程架構
![](https://i.imgur.com/K5NLuGg.jpg)


