---
title: Taiwan Cyber Security Summit 2018 台灣資安大會
date: 2018-03-13 23:33:42
tags:
- 資安
- 研討會
categories: 資訊安全
thumbnail: https://i.imgur.com/NFg6ukq.png
---

# IP cam 資安標準制定與推動的經歷

### 背景
* 物聯網的資安威脅
    * HP研究：七成物聯網有被駭風險
    * 經家中螢幕跳出FBI付款通通知
* 資安產業對ICT產業的衝擊
    * 路由器網路攝影安全性不足，友訊遭美國政府告上法院
    * 華碩路由器被美國稽核20年，看如何確保物聯網安全
    * 旗下產品為DDoS打手，中國豪邁召回產品

### 計畫介紹
> 政府委任資策會通動此計劃
> 協助廠商提升資安，推動產業發展
* IOT 資安提升推動方案
    * 標準推動 ➡️ 制度建立 ➡️ 產業提升 
        * 標準推動：參照國際資安標準
        * 制度建立：推動檢測紀錄 
        * 產業提升：輔導廠商提升資安品質
> 建立產業的資安要求，並期望能協助產業發展
* 影像監控系列與資安標準說明
    * 資安標準發展與流程
    * 資安發展該念：
        * 產業需求搜集 ➡️ 選擇標準標的物 ➡️ 標的特性分析 ➡️ 標的物重要資產 ➡️ 資安威脅分析 ➡️ 資安標準需求 ➡️ 標準測試規範底稿
    * 資安實務流程：
        * 撰寫標準草稿 ➡️ 編列代表 ➡️ 專家會議 ➡️ 公開招標
    * 標準框架：
    ![](https://i.imgur.com/zh6Co84.jpg)
    * 資安標準與分級（一）
        `針對 IP CAM 的 5大安全構面訂定20大分項安全要求，並依照「一班消費」、「商用」與「關鍵任務」等應用領域訂定產品資安分級。適用不同廠商定位與使用者需求。`
        * 資訊安全
        * 系統安全
        * 通訊安全
        * 身份識別與授權安全
        * 隱私保護
    * 不合規問題案例
    ![](https://i.imgur.com/vqUVmeM.jpg)
* 實測常見不合規項目
    * 為用防拆螺絲可輕鬆破壞外殼
    * XSS injection弱點
    * 預設未加密
    * 明碼傳輸
* 認證制度架構：
    * 透過第三方檢測
* 產品認證時程推動

### 結語
* 資訊安全檢測不能達到 100%的安全，但可建立產品的資安基準，讓廠商與使用者有所依循
* 資安的提昇要資建立資安意識，不以通過檢測為目的，而是隨時注意資訊安全提升廠商資安能力。

## Response Before Incident：制敵機先！主動式資安事件處理

> 系統、surver 無法通通保持最新

![](https://i.imgur.com/wNJqoO9.jpg)
### 網站安全
> 選擇套件的同時，你就要承擔它存在的風險
![](https://i.imgur.com/jCu6YYe.jpg)

![](https://i.imgur.com/lEXcAEs.jpg)

### 系統安全 thrusted zone
`CPU重新隔一塊，儲存私密資訊`

> 建立好的防守比攻擊更困難

## New trend of user identity from cloud giants today

### In the past
* user
    * Facebook:2.12B
    * Google:2B
    * Apple iCloud:782M
    * Microsoft Offive 365:120M

* How to identify who is who?
    * IP
    * Passwords
* problem of ID/Passwords
    
    * 強制修改、後與前不重複
    `一但密碼常換`
        * 過多
        * 易忘
    * 換密碼麻煩，不方便
    `一但密碼不換`
        * 釣魚
* Data breach is worst than what we can inagine
    * 2015 - 2017 資料外洩 > 4.2B
> 90% Data breach is from ID/Password phishing 
     data source : [Risk Based Security](https://www.riskbasedsecurity.com/)
==could security ： ID/Password 儼然成為最薄弱的防線==

### What Next?
* No Password 
    * 指紋驗證
    * 綠色的銀行近月上市
* 2nd Factor Authentication
    * 驗證碼
    * 雙證件
* Options of passeordless & 2-step login
    * Microsoft 
        * Widows:Hello login (No Password )
        * Azure：MFA(2nd factor authentication)
    * Google
        * OTP-SMS and Google Authenticator
        * FIDO U2F key
        * Phone login
    * Facebook 
        * OTP - SMS, Facebook Authenticator, Google Authenticator, etc.
        * FIDO U2F Key
    * Apple 
        * MacOS:Apple watch or third party phone login (No Password)
        * SMS OTP
    > Email OTP
    >  SMS OTP
* Problem for SMS and one-time password 2-step login
    * Not user friendly for everyone
    * Third party APP is complicatrd to setup
    * SMS isn't security, it could be Interception.
* Bitcoin Wallet was hached Video 

* New trend todat & tomorrow
    * Windows Hello Passworldless login
    * FIDO - base hardware security key for 2nd factor Authentication
        * Windows - USB & NFC & BLE
        * MAcOS - USB & BLE
        * Android BLE & NFC
        * IOS -BLE
* Advantage to use FIDO-based produt
    * google, facebook, Lenovo, Paypal, Gotrust, etc. All member
    * Open standard
    * 手機硬體中做互聯互通
### END 
![](https://i.imgur.com/RVEO3bN.jpg)


## 網路自動化機器人辨識與防護
* 自動化程式類別
    * 暴力密碼猜測
        * 以限速避免
    * 網路蜘蛛-起始URL去爬每個子link
        * 檢視hyperlink
        * 檢視cookie 
        * 自動生成白名單
    * 網路爬蟲-搜集廠商數據➡️對營運造成影響
        * 透過檢視user-Agent 快速進行爬蟲模式效果管理
    * 自動化網頁機器人
        * 檢測應用程式行為，搭配rat limit、使用者輸入辨識等，進行防護
* 暴力密碼的測試
    1. 下載對應檔案內容：https://drive.google.com/drive/folders/1dODxIpFLRyuMhsGPEm6j-HqMn2JnwTSH
    2. 開啟Burp Suite Community Edition [使用方式](https://t0data.gitbooks.io/burpsuite/content/chapter3.html)
    3. 設定Burp Suite 攔截 Proxy：127.0.0.1:8080
    4. 設定Firefox 路經 Proxy：127.0.0.1:8080
    5. 開啟intercept 攔截request 內容
    6. 用正確帳號密碼登入後，得到正確的Respone內容
    7. 點選action -> send to intruder
    8. add $ 參數 $
    9. 更改成 暴力破解 cluster bomb
    10. payload引入參數集
    11. option更改比對內容為正確的Respone內容
    12. 勾選掉Exclude HTTP headers
    13. Start attack
* 網路蜘蛛的測試
    1. 開啟websphinx.jar 可直接網路蜘蛛 (含 graph)
* 網路爬蟲

## Mcafee 
* 多維度與人工智慧進階威脅分析
    * 快速過濾
        * 特徵碼
        * 信譽
        * 模擬
    * 動態分析
        * 沙箱觀察
        * 沙箱迴避
    * 靜態程式碼分析
        * 消除混淆碼
        * 反組譯並揭露執行碼
        * 比對同類家族
    * 人工智慧分析
        * 多維度的分析病毒代碼
* 自適應進階威脅聯防架構
    1. 收到包含可疑代碼之附件
    2. 送往surver確認
    3. 進入沙箱確診
    4. 即時傳回端點
    5. 於TIE比對過去存在的攻擊
    6. SIEM儲存與管理IOC
* 人工智能安全管理解決方案
`最佳化威脅與合理的安全管理(ESM+UBA)`
    * AI與智能分析
        * 即時進行分析
    * 可執行的
    * 整合式安全管理
* 政府案例分享
* CASB-skyhigh
    *  自動識別
        *  個資
        *  PCI
        *  Shadow Apps
    *  控制
    *  保護
        *  DRM
        *  加密
* 單一控制點-無摩擦部署
    * 於雲端架設單一consol
    * 不需於每台Device部署
    * 建立Sky Link 透過API 可採去監控阻擋等訪滬措施

## 量子時代下的重裝駭客
* 何謂量子力學
    * 描述圍觀物質（原子，亞原子粒子）行為的物理學理論
        * 一種數學模型
        * 一種描述物理世界的方法
        * 一種模擬世界或人腦的方式
    * 量子力學的歷史
        * 薛丁格波動方程式
        * 不確定性理論
        * 波函數塌縮
        * 迪拉克方程式
    * 量子特性：
        * 量子態疊加
            * 經典比特 | 0 | 1 |
            * 量子比特 |0> |1>
        * 量子糾纏
* 何為量子電腦
    * 是一種使用量子邏輯進行通用計算的裝置
        * 物質分子和化學反應的模擬
        * 快速解決一些傳統電腦需要長時間解決的問題
    * 涼子特性
        * 量子疊加
        * 兩子糾纏
    * 量子Gate
        * Unitary
    * 量子霸權
        * 處理器要達到49量子為元
        * 雙涼子為元錯誤率低於0.5%
        * 屆時運算能力將會超越世界上所有電腦，具有解決傳統電鬧所解決不了問題的能力
> [台大開放式課程-量子力學](http://ocw.aca.ntu.edu.tw/ntu-ocw/index.php/ocw/cou/100S221/1)
* 量子電腦哪裡找？
    * Quantum Gate 類型的
        * IBM有提供實驗性機器與API
        * Microsoft VS + Q#,Python
        * Rigetti python(Quil)+Quantum Visual Machine
    * Quantum Annealing 類型的
        * D-Wave + quantum machine instruction(QMI)
* Quantum Gate
    * Hadamard gate
    * Controlll not
    * Swap gate
> qiskit-sdk ( python3 )
> Try 'local simulator'

### 駭客如何用量子電腦做壞事
* 他可以做啥？
    * 植樹分解 
    * 對稱式演算法孤寂
    * 量子金鑰傳輸 ( QKD )
    * 量子比特幣（qBitcoin）
    * 量子數位簽章
    * :smile: Quantum machine learing
    * Traveling Salesman Problem
* 質數分解
    * 質數分解困難度為基礎ＧＧ
    * short algorithm
* RSA 
    * 仰賴質因數分解的困難度
    * 私鑰可以快速被算出
    * 傳統RSA是 non quantum-safe
    
* 橢圓曲線密碼
    
* 對稱式演算法攻擊
    * Grover's Search Algorithm

* 其實我 ( gasgas ) 從頭到尾只想用量子電腦挖比特幣:smile:
    * proof-of-work可以算快一點
    * 讓授權交易的橢圓曲線千張可以偽造/取代
* 晴天霹靂的 Hash function!
> Quantum Lower Bound for the Collision Problem
> Quantan attack at Bitcoin, and how to protect against them


[下兩篇By Jeffery Lin](https://hackmd.io/qJ_nxz77TjaNNbU4A2Gv1A?both)
## 金融數位化時代下的資訊風險與控制管理

-為什麼需要煞車？風險管理用來控管快速成長
-資訊風險管理：對資訊系統仰賴度提高、所處的環境越來越複雜（駭客、員工盜取資料、仍要符合政府法規）資訊風險管理協助管理重要資訊
-新興科技：GDPR、Fintech，需要評估導入新興科技的風險，挑戰更勝過去
-注意面向：安全性、可用性、效能（不彰導致使用者抱怨影響聲譽、可能會影響可用性）、法遵

-資訊風險管理( IT Risk Management) vs資訊安全管理( IT Security Management)

資訊風險管理( IT Risk Management)：找作業流程的風險、確保監控風險、Like 家教、協助組織通過稽核

資訊安全管理( IT Security Management)：確保資訊無外流、無沒權限人取得access
      

-好處：降低資訊風險管理發生的機率和影響、有效跨部門溝通、協助風控化繁為簡
-技巧：風險管理矩陣（要知道自己目標）、自行查核（找出問題）、風險註冊

## FinTech – 金融科技的美麗與哀愁
-演進：1991-Internet, 1995-ebay, 1998- paypal, 2007-iPhone, 2009-bitcoin, 2014-Apple Pay
-最多 Fintech 用戶地區：中國、印度（發展快速、偽幣問題）
 最多 Fimtech 使用年齡層：Y世代
-台灣概況：行動支付、跨境支付、P2P借貸、機器人理財、虛擬貨幣
-Apple Pay 代碼化（Tokenization）技術：商家、收單機構看不到卡號（減少偽卡）

-信用卡側錄裝置(Card Skimmer Device)：不一定是店家所為
QRCode  支付：偷換店家QRCode
-行動銀行：惡意app（bankbot) 覆蓋在正常行動銀行app上，騙取帳密，還可攔截簡訊
-SWIFT 系統金融犯罪（釣魚信件、水坑攻擊植入後門，再找SWIFT帳密進行攻擊）
-區塊鏈
-Smart Contract
-資安風險：交易所、Smart Contract 漏洞、盜取 private key
-金融電子化：駭客只要能控制資訊流，就能控制金流
-控制好權限（雙重認證）

圖片後補


## AI
> AI會取代我嗎？
> 如果你問這個問題，代表你不了解AI，那未來就會被取代

### 資安現況
* 資安產業鏈：
![](https://i.imgur.com/BAmne1F.jpg)

* 資安產業中使用AI的三個層次
    1. Malware識別惡意程式：識別黑名單機制
        * 可以漏判
        * 低錯誤率
    2. Icident識別攻擊活動：人為書寫規則
    3. Situation調查攻擊案情：找到駭客攻擊TPP、計劃等等
        * 不只知道這是兇刀，還要知道他是怎麼來的

### 資安現況Demo

[Demo網站](http://10.18.0.10:5601/app/kibana#/discover?_g=(refreshInterval:(display:Off,pause:!f,value:0),time:(from:'2017-08-14T04:56:48.510Z',mode:absolute,to:'2017-08-14T09:12:53.617Z'))&_a=(columns:!('@timestamp',event_data.TargetServerName,event_data.SubjectUserName,event_id,event_data.CommandLine),filters:!(),index:winlogbeat,interval:auto,query:(query_string:(analyze_wildcard:!t,query:'event_id:4688%20AND%20beat.hostname:%22EP1-PC%22')),sort:!('@timestamp',desc)))
* [event_id](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/default.aspx)
    * 連出去 4648：不保證有成功
    * 被連 
        * 4624成功
        * 4625失敗
    * 4688 CMD任何指令被記錄於此

* 106：TaskRegisteredEvent
* 200：ActionStart, with PE name
* [切換 UTF-8 編碼：chcp 65001](https://msdn.microsoft.com/en-us/library/windows/desktop/dd317756(v=vs.85).aspx)
* winlogbeat:Realtime傳送終端log to surver
* [Docker+kibana](https://peihsinsu.gitbooks.io/docker-note-book/content/bigdata-lek.html)
* 

> 兩面刃：網管與駭客都喜歡用的平行移動工具
> * psexec.exe

### 資安現況解決方案
> 工人智慧 -> 人工智慧
* AI判斷異常指令
* 神奇圖形化介面
* 判斷問題等級
* 快速勾勒回傳report
* 產生脈絡圖

> cycarrier
* 節省專家繁瑣的日誌分析時間
* 系統引導人類做決策
* 累積更豐富的專家情資來讓平台自動Hunting
* 無人能取代的專家，彼此相輔相成
