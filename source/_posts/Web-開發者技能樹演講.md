---
title: Web 開發者技能樹演講
date: 2018-08-24 21:20:19
tags:
- Firefox
- Web
categories: 資訊講座
thumbnail: https://cdn-images-1.medium.com/max/2000/1*EBXc9eJ1YRFLtkNI_djaAw.png
---


# Web 開發者技能樹演講 2018/08/24

原筆記網址：https://hackmd.io/S_BIlfpyRxGJWiLb5E7Nvg?view


[我要提問](https://docs.google.com/presentation/d/e/2QANgcCBGbT_hNqwB1mcwXogq0qK3sZhsV4MKjyMZypSr6B-OpwM45Nx7Bibyv4YB6xu4p1ktabLmLzDOMSQ/askquestion?seriesId=66e91f97-35bd-44a0-960f-af8938f8656e)

## 關於我
- 宏碁
- 摩茲工程師
- 今年年初遭到裁員（自由的狐狸）


## 今天你將學到
- web 開發基礎
- 前端技術
- 後端技術
- 開發及維護
    - 以上的概要

>看完就九死一生,不看就十死無生
![](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOOkq8htZelWEUUUMao9qkx5KuCnsqvYosrDfucGyHZMzVN7ul)
> web 的好處：全公開標準
> 很多資源很多工作，不怕找不到工作

## 前端？後端？開發及維運？
![](https://cdn-images-1.medium.com/max/1600/1*qRmCzyBNzyE87_TE06oADA.png)
### 前端
前端就是你看到很美的東西。
### 後端
後端就是後面很醜的東西你看不到。
### 開發及維運
十萬個正妹及十萬個看不見的東西如何維護。當專案變大後，會變得相對重要。

踏入 Web 這塊，你可以先選擇你要走前端還是後端。
如果你走後端，但又沒有走太深入，可以試試看走 DevOps（開發及維運）

## Web 開發基礎
* 資料結構及演算法
* HTTP / HTTPS 和 Web API
* SSH 及簡單的命令列操作
* Git / GitHub

## 資料結構與演算法
可以自行 Google，總之很重要

## HTTP / HTTPS 和 Web API
### HTTP 協定 1.0/1.1/2，HTTPS加密
* 要寫 Web 要很清楚 HTTP 協定是甚麼
* 要知道 HTTP 是怎麼加密的
### HTTP 請求方法

### HTTP 狀態碼
- 2XX：成功
- 3XX：重新導向
- 4XX：使用者錯誤
- 5XX：伺服器錯誤
發送對的狀態碼給用戶很重要

## Cookie & Cache
### Cookie
因為 HTTP 沒有狀態，因此 Cookie 被發明出來，可以用來記錄狀態
### Cache
快取可以讓用戶在下次瀏覽時更加快速，也減輕伺服器負擔


## SSH 及簡單的命令列操作
### SSH 相關指令、金鑰控管
如題
### Shell Script（BASH, zsh.. 等）
可以透過 Shell Script 自動執行一些指令

### Linux 服務及運作原理
要知道其原理，以及如何去開關一些服務，才能有效管理你的程式與服務


## Git / GitHub(全球最大男性工程師交友網站)
最近最流行的版本控制是 Git，但也有其他的版本控制軟體
### 個人
可以透過版本控制來管理複雜的版本
### 團隊
把所有人寫的程式合起來，可以有效解決空間與時間的限制。

### 了解 git 的運作方式
以下略，總之就是 Git，我相信大家都已經會了 OwO
### GitHub
GitHub 是用 issue 的方式來管理


> 進階開始

## Web 服務流程
> 有人會畫 Markdwon 流程圖嗎QQ 
> 使用者 - 前端 - 後端

## Web 前端技術的概要
* HTML：標題與目錄，一個簡單的 document 檔案：語法、元素、建立 DOM tree 和相關屬性
* CSS：網站的外觀與美化，用於潤飾網站，進階一點的內容有 Flexbox、Grid 等
* JavaScript：如何操作 DOM、事件傳遞、物件、Ajax&XHR、ES6
* 選修 jQuery：可以讓你寫 JS 的時候更簡單

> VBScript 已死 [name=蔡孟達]

## 基礎練習

如果沒基礎，可以嘗試構思不同的響應式網頁（RWD）來練習，使用 JavaScript 加入互動
 
如果不會可以在 GitHub 上找開源專案，找找 Good First Bug 可以解
 
 

##  進階
- **NPM** / **Yarn** 套件管理腳本，講者喜歡用 NPM，可是我是 Yarn 派的
- **PostCSS** CSS 的前處理器，讓 CSS 更好管理
- **Bootstrap** 響應式網頁的框架，可以快速開發出響應式網頁
- **Webpack** 打包靜態網站所需要的資源
- **ESLint** JavaScript 程式碼檢查工具
## 進階練習
可以嘗試新增一個專案，讓自己充分了解並練習如何將複雜網站從開發到釋出的流程


## 高級
- 熱門前端框架：
    - React：開發者滿意度最高，可是他背後的公司(FB)很母湯，有問題可以問江俊廷
    - Vue：壯哉我大 Vue，是最近最熱門的前端框架，有問題可以問陳威任/姚韋辰（其實還有火柴）
    - Angular：Google 出產，目前最冷門的ㄏ，Angular和 Angular2是不同的東西，Angular 已經過時了，時代的眼淚，千萬別搞錯ＸＤ

- 測試工具：單元測試、整合測試及功能測試

- **伺服器端渲染**
- 更多：Canvas、HTML 5 Web API、WebGL、SVG

>人家大神ni 前 Mozila 台灣區產品經理

## Web 後端技術
- Scripting：**Python**、Ruby、~~PHP~~、**Node.js**
- Commercial：**Java**、~~.Net~~
- New：**Golang**、**Rust**、~~Kotlin~~、~~Swift~~


## 基礎練習
學習使用套件管理，開始練習簡單的輸入輸出、封裝及釋出專案
在 GitHub 上找技術開源專案,找找 Good First Bug 可以解
## 進階
### 框架
### 資料庫
- 關連式：MySQL、PostgreSQL
- 非關連式：NoSQL、MongoDB
- 快取：Redis、Memcached
- 授權及認證：OAuth、JWT
> OAuth 介紹：https://www.dcard.tw/f/tku/p/227852547
## 進階練習
- 實作一個部落格 RESTful API 來完成
    - 登入
    - 文章

## 高級
-  搜尋引擎：ElasticSearch、Solr
    -  如果常規的資料庫無法應付的話，可以考慮用這個
-  訊息接收器：RabbitMQ、Kafka
    -  不可能讓使用者在等待，所以會用 Message Queue
-  其他：Docker、Nginx、Apache、GraphQL、Graphic 資料庫
    -  Docker：可以把系統環境包起來，讓你可以快速在任何地方建置起來你的服務，也可以提升安全性
    - Nginx、Apache：網頁伺服器
## 開發及維運（DevOps）
![DevOps](https://cdn-images-1.medium.com/max/2000/1*EBXc9eJ1YRFLtkNI_djaAw.png)


## 基礎
不適合新手跳進來的領域
- 作業系統概念：
    - I/O 管理
    - 虛擬化
    - 記憶體和儲存空間
    - 檔案系統
    - 處理程序管理
    - 線程和並行處理
    - Socket
* 網路和安全: 
    * DNS
    * HTTP
    * HTTPS
    * FTP
    * SSL
    * TLS
* 伺服器管理: Linux Server 
    * Ubuntu：新手向（？
    * Debian：穩定到爆的伺服器系統，但軟體都喜歡用舊一點的（因為穩定）
    * CentOS：背後有大公司支援的伺服器系統，也滿穩的
    * Red Hat Enterprise Linux（RHEL）：大公司支援的，但超貴，
    * OpenSUSE：大蜥蜴（？ 是變色龍!

## 基礎練習
* 安裝或是使用已有的 Linux Server
* 練習命令列操作：Shell Script、文字編輯、編譯 App、調校系統效能、監控管理程序、網路管理指令

## 進階
* 架設服務
    * Web Server
    * Cache
    * Proxy
    * 負載平衡
    * 防火牆
* 如何擴展服務
    * 容器（Docker）
    * 組態管理（Ansible）
    * 架構管理（Terraform）
* 學習持續整合與持續發佈(佈署)
> example: [某訂房網站](https://www.booking.com)：完成開發後送到雲端上，若有問題則自動下架，回到前一個版本。
* 監控:
    * 紀錄檔
    * 基礎設施
    * 應用程式
* 雲端服務廠商: 
    * AWS（Amazon）
    * GCP（Google）
    * Azure（Microsoft）
    * Heroku：和上面的有點差別，滿陽春的，但勝在方便和快速

## 額外資源
> 持續學習,持續進步!(謝謝)(...)
> Mozila 講很多～
> 
[Free Code Camp](https://www.freecodecamp.org)

[RealWorld](https://github.com/gothinkster/realworld)

[系統設計入門](https://github.com/donnemartin/system-design-primer)

[JavaScript Testing in 2018](https://goo.gl/D77a4K)

[系統設計入門(繁中)](https://github.com/donnemartin/system-design-primer/blob/master/README-zh-TW.md)

## 提問：
> Ｑ：我想知道現在 Web 工程師寫網頁時通常都在哪個瀏覽器上測試OuO
> Ａ：Google Chrome 先測，Firefox 和 Safari Mobile 。
先測當前版本，往前往後兩個

> Ｑ：台灣 Firefox 社群最近有哪些坑，有哪些適合後端開發者關注的？
> Ａ：[Rust](https://zh.wikipedia.org/wiki/Rust)

> Ｑ：有什麼推薦的 GitHub 開源專案或 Good First Bug 嗎？
哪裡容易找到 Good First Bug 呢？

# Python 網路爬蟲

## 今天你將會學到
- 什麼是爬蟲
- Python 虛擬環境
- 用爬蟲抓取網頁內容的程式
-  用爬蟲抓取 [iCook](https://icook.tw/) 最新食譜並建檔 

## 什麼是網路爬蟲
- 自動抓取網頁內容的程式
- 代替人進行重複且繁瑣的資料收集工作且不出錯
- 例如:收集十萬筆Google搜尋結果的標題

## 為什麼要學習 Python
- 使用時機
    - 大數據資料分析和呈現
    - 人工智慧模型訓練
    - ex: 熱門話題分析、價格歷史波動和預測

- Python 易於上手，且在各領域被廣泛使用

## 建立開發環境
- Python3、Pip3
- VirtualEnv [學習資源](https://www.openfoundry.org/tw/tech-column/8516-pythons-virtual-environment-and-multi-version-programming-tools-virtualenv-and-pythonbrew)
- Requests
- BeautifulSoup4 (bs4)
- requirements.txt


## 更多
* 瀏覽器開發者工具
* 處理登入狀態
* 前端動態渲染內容
* 其他爬蟲常用框架或是涵式庫
* 使用爬蟲的正確禮儀
* **構思甚麼是你/你想的第一個爬蟲**?
