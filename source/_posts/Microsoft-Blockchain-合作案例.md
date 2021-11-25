---
title: Microsoft Blockchain 合作案例
date: 2018-01-17 17:46:44
tags: 
- 區塊鏈
- Microsoft
categories: Blockchain
thumbnail: https://secure.meetupstatic.com/photos/event/5/2/8/c/600_476121132.jpeg
---

# 區塊鏈實作：在成功得案例上做出您的第一個應用
## WiFi access:
```msevent998dl```

# Azure Blockchain-as-a-service(Demo)-30mins

Michael Chi 軟體開發工程師

[作者GitHub](https://github.com/michael-chi/blockchain-learning):https://github.com/michael-chi/blockchain-learning

## Before we start
* What is ...
    * Blockchain
    * distributed ledger
    * smart contract
* Plus
    * have programming knowledge
    * Azure Knowledge
* 純技術 Workshop

* 區塊鏈解決方案中遇到問題如何解決，以解決的思路

* Blockchain Case：
    * 東南亞航空公司
    * 農業產銷的公司，類似台糖的農產品版本

## 農業產銷的公司
* 有數個 farmer 管理者，用以確認 農人、農地大小、產品品質
* 農民有數種、法律有數種、農地有數種，希望解決繁瑣的問題

### 解決方式
> IPFS 行星檔案系統：類似區塊鏈 p2p 的分散式檔案系統
* 將農民資訊 ID 放到 smart contract 上，而藉由 hash ID ，將個人資料儲存於資料庫，不上鏈
* 農地資料同上，ID 上鏈，其餘放到 IPFS 上

## 東南亞港口管理的機構
> 港口想要建造一艘新的船隻，非常麻煩，可能需要 30~60 張的憑證，需要 3~6 個月，而其中多數憑證需要人工申請，非常耗時耗人力。
### 解決方式
> 一家船隻的擁有者，造船時，創建一個 smart contract 放到區塊鏈上，每張 smart contract 都代表一個憑證，取得憑證後，交給監管驗證，核發後建造。

## Baseline
* 參與者多
* 資料共享者多
* 憑證可以透過區塊鏈在多個機構中流通

> 參與者越多，越適合用區塊鏈來解決問題

## How we work with the customer
* 3 週聯絡交流
* 2 週前往顧客公司討論
* 2 月 coding

## 航空公司 
> 希望多家航空公司的里程數（紅利）可以共用，多個參與者可以擁有共通的交流平台。
* 擁有一個共通的貨幣，用以交換產品或價值
* 一個開放的平台，任何人只要他想，就可以來參與這個平台
* 這個平台必須夠安全
* 必須是全球性的
* 輕易的加入這個聯盟

### 解決方式
> 我們認為區塊鏈是好的解決方案、一個安全的方式，資料在其中是分享的，且是一個分散式的系統，資料就會在節點之中去 Ledger。
> How do we
* 創建一個 Token 、 ETH 、 Hyperledger？
* 外幣交換的機制？
* Track Transaction？
* 如何與現有的會員系統做整合？
* interact with other participates？
* 如何建立一個全球可信賴的系統？
* 多國間的資料如何同步？
* 如何管理？

### 思考方向
* 先解決簡單的問題
* 設計一個給單一客戶的架構
* 延伸至其他公司

### 業務場景
* 創建一個貨幣，將各個公司的會員點數擁有一個共通的轉換媒介
* 所有透過這個貨幣的交易都必須被完整的記錄下來
* 所以的夥伴必須被管理，必須是某個航空公司的會員才能轉換

### 區塊鏈角度
* 所有的客戶、智能合約都是一個 address 。
* 需要數個 contract
    * Token contract
    * Exchange Rate Contract
    * Transaction Contract
        * 記錄一些特殊的交易邏輯
 
### We decide to 
> 微軟在 eth 有各種合作，又 因為有 80% 的 Token 都是 ERC 20 所以採取 ERC20
* smart from eth
* uses ERC 20 Standard
    * Function
        * total supply
        * balanceOf
        * Transfar
        * transferFrom
        * Approve
        * allowance
    * Events 
        * Transfer
        * Approval
* openzepplin：一個針對安全性做增強的 Token 範本

### Create Digital Token
==等補簡報中的 3 個 smart contract 的 Function==
* Transaction
* Token
* Echange Rate

### Questions
> Now we have smart contracts ready
* Q:如果邏輯需要更改時該如何是好？
    * 如何 update ？
* A:Proxy Pattern
    * 將邏輯與資料分開
    * 透過更改 Proxy contract ，判斷應該呼叫哪個版本
* Q:如何使 API、操作 smart contract ，使之呈現於終端裝置上？
* A:需要一個 
    * Library
    * API
    * Authentication
        * In smart contract
            * Function [Modifier](http://me.tryblockchain.org/blockchain-solidity-functionModifier.html)
        * In API
            * Truffle.js 部署 Smart Contracts 並測試
    * WEB3.JS
> Challenge
* Q:如何管理雲端的 eth 與離線的 Database
* A:在 Azure 上
    * Function App
    * Web App/API app
    * Vitual Machines

### 兩種解決方式
![](https://i.imgur.com/CCNCb0g.jpg)
> oracle
![](https://i.imgur.com/Md2WqbJ.jpg) 

### 小結
* 呼叫己身 API 
* 管理自己的會員
* 以 VPN 等等網路傳到區塊鏈上同步
* 需要報表時，從 Databasr 查詢
* 需要驗證時，從 Blockchain 查詢

### 未來的問題
* 區塊鏈、SQL 哪邊是主體
* 是否能夠讓網路互連
* 普通的 CI/CD 可以使用 Azure 內建的 CI/CD
* Smart Contract CI/CD
    * 當你部署一個新的版本後，對區塊鏈來說就是一個全新的事情，而究竟要不要自動使用 CI/CD 尚未有定論。

## What's Next
* 我們不希望每一個 case 都從頭開始
* 我們希望能夠有個 base ，之後的開發都由此延伸
* 我們有一個解決方案在 Azure 上，只要將它組合起來


# 
## Before Start
https://www.microsoftazurepass.com/SubmitPromoCode
https://onedrive.live.com/?authkey=%21AHCMYjJIaYWpXF0&id=E0579E51F1904020%21363386&cid=E0579E51F1904020

> 快速的建立區塊鏈並運用
> 運用 Azure 上的 template

從 60% ~ 70% 開始建立區塊鏈
之後會把代碼開源出來到 GitHub （大驚！！

For 聯盟鏈

