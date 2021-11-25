---
title: 完整學習機器學習實錄2——安裝 Nvidia 機器學習環境
date: 2019-09-13 22:31:13
tags:
- 機器學習
- 完整學習機器學習實錄
categories: 機器學習
thumbnail: https://img-blog.csdnimg.cn/20190117174859505.png?
---

# 完整學習機器學習實錄2——安裝 Nvidia 機器學習環境
###### tags : `完整學習機器學習實錄`
# 前言 —— 本文值得一讀之處
>本篇將繼續介紹，如何以一個有效的思路，成功的安裝 Nvidia 機器學習環境。

**不同於其他文章，本篇以概觀介紹為主、細節為輔，希望以清晰的思路，培養大家思考的能力；跳脫 step by step 的框架，使未來的學習中能夠以飛快的速度向前，即便遇到版本更新、也得以與時俱進。不再拘泥於完善的教程，也得以不斷自我成長。**

# 前情提要
在上一篇[完整學習機器學習實錄 1 —— 安裝 Ubuntu 18.04](https://blog.csdn.net/weixin_39777507/article/details/85596643) ，我們安裝 Ubuntu 18.04 系統於 X299 及 1080ti 上，同時記錄了幾個有關於 ACPI 及 NVME 的基本知識和問題迴避。

這次，將來安裝學習機器學習時，最常遇見的環境坑，在 N 卡的環境上，需要安裝的包含顯示卡的驅動程式，Nvidia 提供的 CUDA 與 cuDNN，以及機器學習的套件包，舉凡 Tensorflow、caffe 等。在這裡以 Tensorflow 為例。

# 在安裝前
如果讀者有閱讀過其他文章，想必非常清楚這三者 ``Tensorflow, CUDA, cuDNN`` 的安裝順序通常是先安裝 `CUDA` 然後補上 `cuDNN`  的 `lib`，最後再以 `Python` 套件的形式，安裝 `Tensorflow` ，而實際執行上，這樣的順序的確是良好的。

但是，於思考的邏輯上，依照這個順序去選擇安裝版本、去查資料，卻容易造成嚴重的版本錯誤，理由是，`Tensorflow` 依賴 `CUDA` 去調用 `GPU`，而 `CUDA` 又需要 `cuDNN` 作為 `library` 來實現深度神經網路。所以，要成功的安裝學習環境，也是就是要能順利運行 `Tensorflow` ：
>必須依照 `Tensorflow` 的需求，去安裝相對應的 `CUDA` ，再依照 `CUDA` 的需求，去選擇對應的 `cuDNN` 作為函數庫。

在這邊，容我對 `Tensorflow` `CUDA ` `cuDNN` 稍作展開，避免讀者在接下來的學習中遇到相關問題沒了個底。
## Tensorflow
想必會來閱讀這篇文章的大家，對於 Tensorflow 肯定是耳熟能詳了，但是 Tensorflow 的本質究竟是什麼？在接下來的段落裡，我們希望讓大家對於 Tensorflow 能夠有更近一步的認識，而不再是 ：
>Tensoflow？ 做機器學習的啊？
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190117174743739.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)

打開 Tensorflow 官網，我們便能清晰地看到官方對於 Tensorflow 的定位，`An open source machine learning framework for everyone.` 就我的理解為，「一個面向所有人的、開源的、機器學習框架。」
> 其實不止 Tensorflow ，多數的軟體都有這麼一句話，位於官網的顯眼處，只要你願意去打開官網，就能夠快速地理解其究竟是什麼定位，能夠拿來解決什麼問題？

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190117174859505.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
是的，Tensorflow 是一個機器學習的「框架」`framework`，框架是一個大家公認的規範，也就是在茫茫程式大海中，你可以有自己的習慣、有自己的開發方式、有自己的 API 接法等等。但是，若你與大家使用了共同的規範、共同的習慣，那所有人開發起來就會方便許多，你們可以共用某支程式，共用某些 API ，彼此間也能夠迅速成長。

而 Tensorflow 究竟定義了什麼樣的規範，使之成為機器學習的框架呢？其實官網往下轉，就給出了我們想知道的答案。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190117175929289.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)這段告訴你，Tensorflow 既是一個機器學習的框架，更是一個實現機器學習算法的接口。
* 就高層次而言，Tensorflow 主要提供您：
	* 以計算圖的思考方式，去規劃與設計機器學習。
	* 以 session 作為一個窗口，讓使用者快速的設計計算圖。
* 就低層次的意義而言， Tensorflow 實現了以下幾點：
	* 消弭了不同 CPU、GPU 及更多類型間的硬體差異。
	* 實現了多 worker（不同電腦）、多 device（多張 GPU）的優化，包括記憶體、運算核心、資料傳遞等。
	* 實現了自動的反向傳播算法，由 Tensorflow 去智能計算反向傳播。
	* 性能優化：包括了一些計算庫及不同的並行運算方式。
> 這邊大略的提到它的功用，至於再往下展開，就是如合實現這些目標的概念解釋，有興趣得讀者，可以參考 「Tensorflow 實戰」，這本書，裡頭開篇便有詳細的說明。

## CUDA

## cuDNN















https://www.tensorflow.org/
https://developer.nvidia.com/cudnn


