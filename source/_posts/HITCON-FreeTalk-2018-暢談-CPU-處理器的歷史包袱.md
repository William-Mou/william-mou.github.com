---
title: HITCON FreeTalk 2018 暢談 CPU 處理器的歷史包袱
date: 2018-01-19 13:20:00
tags:
- 資安
- HITCON
categories: 資訊安全
thumbnail: https://i.imgur.com/Lnb2D2s.jpg
---

# HITCON FreeTalk 2018 暢談 CPU 處理器的歷史包袱 共同筆記
>主辦單位:社團法人台灣駭客協會(HITCON)
時間: 2018/01/19(五) 13:20 - 17:00
報名網址: https://hitcon.kktix.cc/events/hitconfreetalk20180119
直播網址: https://www.facebook.com/HITCON/

```
議程表:
12：50 - 13：20  報到
13：20 - 13：30  開場
13：30 - 14：00  Spectre & Meltdown 漏洞原理說明與 POC 剖析（講師：Bletchley）
14：00 - 14：30  從晶片設計角度看硬體安全（講師：中原大學 黃世旭教授）
14：30 - 15：00  下午茶交流
15：00 - 15：30  Spectre & Meltdown 漏洞的修補策略與 risk mitigation（講師：gasgas）
15：30 - 16：00  詭譎多變威脅下的資安應變與治理（講師：林宏嘉協理）
16：00 - 17：00  Panel Discussion
```
歡迎大家針對這次的議題作共筆！


## [一、Spectre & Meltdown 漏洞原理說明與 POC 剖析 (講師: Bletchley) ](https://drive.google.com/file/d/1E2VXtXTTD4_-IR6sbRvP9MiADKo41zvu/view?usp=sharing==)


### Overview of Meltdown and Spectre

* Threat: adversary who can execute low privilege code can read unpermitted memory region
* Impact:
    * Meltdown: Most Intel Processors
    * Spectre: Intel, AMD, ARM processors
* Reason:
    * INconsistent between processor architecture and microarchitecture(cache)
    * Lack of permission checking when CPU optimization
* Website: meltdownattack.com

Execute low privilege code can read unpermitted memory region

Google 研究團隊發布漏洞的網站 - https://meltdownattack.com

CPU Architecture 中，frontend 是作 fetch and decode 的部分，接著才交給 backend 去做 execution，其中 code (record) buffer 也在這邊

### out-of-order execution

有時候處理器為了加速，會偷跑排在後面的指令，例如後面指令可能是一個加法指令，而且已經在 register 中，就可能會被選為偷跑項目

但有時候偷跑會發生出錯，一旦出錯，有可能被處理器丟棄，不會 commit 到  CPU 的輸出結果中(memory write)

### speculative execution

這個是 branch instruction 的一種執行方法，會去猜測 condition instrcution 的成立與否，如果猜對了，就會 commit 到 CPU 的 memory


偷跑動作的時候，會去存取記憶體，subsytem cache 不知道是偷跑的，所以還是會把獨進來的資料做處理，這就是漏洞


### Flush + Reload Attack
```
var = array[ secret* cache_line_size ]
```
256 accesses time helps discover one byte data ()

### CVEs
* CVE-2017-5753
* CVE-2017-5715
* CVE-2017-5754

### Inside the CPU

* Frontend
* Execution Engine
    * Reorder Buffer
        * 重排序缓冲区
    * Execution Unit
        * CPU執行單位
    * 漏洞的緣由
        * CPU 偷跑後面順序可以先執行的指令
        * 若發現偷跑的指令不合
        * 不commit偷跑資料回cpu
        * 但Cpu cache 仍留存資料
        * 可是於memory與cpu中無法觀察之
        * 可利用預執行cache資料

* attack-meltdown
    * Attack想法
        * 設一array
        * 若讀取過的array[x]會存於cache
        * cache資料的讀取時間<memory讀取時間
        * 統計時間即可洩漏曾讀取過的值
        * 256 accesse can discover a Byte.
    * Meldown Attack Steps
        * Cpu預先執行超出權限的資料
        * 即使資料永遠不會被程式讀取
        * 仍然有機會預先儲存於cache中
    ![](https://i.imgur.com/h9b0t23.png)
    
    ![](https://i.imgur.com/ehHen5p.png)
    
    ![](https://i.imgur.com/PqGLl1E.png)

* attack-spectre
    * Attack想法
        * No cache:array1_size,array2
        ```c++=
        if (x<array1_size )
            y = array2[array1[x]*256];
        ```
        * if後執行較慢
        * 連續數執行後
        * Cpu預先執行第二行 
        * 帶入不進入的if x
        * 會預先執行而得到y值存於cache
    * spectre Attack Steps
        ![](https://i.imgur.com/VVCC1HN.png)
        ![](https://i.imgur.com/tam7j6C.png)
        ![](https://i.imgur.com/a6dJQIa.png)
        ![](https://i.imgur.com/0SdQq3X.png)

### 文獻連結
[Meltdown Proof-of-Concept](https://github.com/IAIK/meltdown)
[Spectre POC](https://github.com/crozone/SpectrePoC)
[main differences between Meltdown and Spectre](https://www.facebook.com/ENISAEUAGENCY/photos/pb.260742884030702.-2207520000.1516342064./1316708825100764)


>筆者按
>* Branch predCiition兩種變形
    * out-of-order execution = 預測下一個要執行的程序並預處理
    * speculative execution = 在分支時預測下個要執行的分之進行預處理

### 討論
>array = [ secret * cache_line_size]
read all array and count how many element loaded to cache = secret value
看不出來這兩個漏洞的差異啊，好像都是同一個方法

> [name=CK] 雖然漏洞被區分為兩種，他們概念都以out-of-order execution為核心。可以把Spectre看成Meltdown的擴充，比較大的差異是Spectre加入branch prediction做攻擊。
> 

> [name=Ethen] 之前我看到Meltdown的特點不只是讀取數據，還可以打破隔離(寫入)，沒介紹到...
> 如果按照上面的比較表兩邊都是僅讀取，只是讀取範圍不一樣（kernel space v.s. user space any process），那為什麼Maltdown可以直接傷到虛擬化環境？ring -1不是單純讀取kernel就可以跳進去的啊


> [name=Austin]Guset攻擊Host的部份是屬於Spectre-Variant2的範疇，它其實是利用從Guest program去推敲kvm.ko, vmlinux的記憶體位置，在將資料流至user space。雖然Guset跟Host看起來是分離的，其實有很多共用的特性，可以這樣去推敲記憶體位置

> [name=Austin]我的理解沒錯的話，Spectre跟Meltdown的差異在於後者使用了Out of order execution，兩者都有使用speculative execution(branch prediction)，另外講者沒有提到的是到底如何取得secret的資料，根據POC code給的
char *secret = "The Magic Words are Squeamish Ossifrage.";
malicious_x = (size_t)( secret - (char*) array1 );
當我們推敲出array = [ array1[x] * cache_line_size] 裡面array1[x]的值後，其實就可以推導secret的內容：
array1[x] = addrress of array1 + offset x =  addrress of array1 + address of secret - address of array1 = address of secret = ‘T‘

> [name=Ethen] 站在攻擊者的立場，Meltdown對我來說會是一個不錯的攻擊輔助資訊，我可以拿到核心記憶體中的帳號密碼或知道有開啟什麼服務輔助我攻擊，但這僅限於當下的作業系統，如果能夠寫入或直接提權那會好用的多
> 單純推敲kvm.ko能做的事情有限，如果hypervisor沒有放出可攻擊的服務或權限，我會很難往上打，頂多去讀其他虛擬機器試圖利用其他虛擬機上的服務弱點去一台一台打，這樣就沒那麼好用了

## 二、從晶片設計角度看硬體安全（講師：中原大學 黃世旭教授）
### 邏輯化簡漏洞
* 進行邏輯化簡時
    * Don't care的部分可能會產生非預期的值
    * 或Dont' care的輸入會輸出=預期的答案
    
![](https://i.imgur.com/CA5dtZO.png)
![](https://i.imgur.com/mbzR21U.png)
![](https://i.imgur.com/ciuOAU3.png)
![](https://i.imgur.com/3kw7LuB.png)
![](https://i.imgur.com/clOH3xr.png)
![](https://i.imgur.com/tbuWeSK.png)
![](https://i.imgur.com/aoRWXDQ.png)
![](https://i.imgur.com/8dxdomi.jpg)
![](https://i.imgur.com/Rtaehhz.jpg)
![](https://i.imgur.com/csIKMVv.jpg)
### out of order executed
將無前後關係的排成同時運作
降低使用運算時間

![](https://i.imgur.com/2t5eT8g.png)

### branch executed
![](https://i.imgur.com/hLIw94w.png)
    可以與cache無關：透過時間差取得之前的key
    
### meltdown & spectre 探討
    * 同上
    
### 設計硬體安全的困難
![](https://i.imgur.com/qxM5kzX.png)
### 結語
![](https://i.imgur.com/CyPJNmi.png)

### [其他大大的筆記](https://hackmd.io/EwBgRiDskJwGwFpgGZmICx0gVgTAjAGaJyEAccAhmPiHAMb71A==?both)

現代CPU設計由於Multithread & Multicore的因素CPU執行指令運算之前需要peak一下CPU的狀態與看預算時需求的Memory是否會產生lock，這個過程會在CPU的底層做(注意到這裡OS已無法管理，指令並須被執行除非CPU drop這個指令，CPU drop會通知回OS)

利用這個方法去看CPU Handle的記憶體區段Peak其他區域的記憶體位置(OS無法阻擋)，或者CPU上的Memory管理機制重新回Initial state
![](https://i.imgur.com/eXEUSuc.png)


在邏輯電路裡設計狀態機(FSM)時傳統訓練方法有don't care condition可能會造成電路運行時產生你所不期望的狀態循環，例如重回initial state，所以設計時不太應該使用don't care(雖然可以節省電路成本與最邏輯複雜度最佳化)，但為了安全性，應當把所有組合列出，額外去處理不期望的例外。

PUF -> physical unclonable function
[Some basic description about PUF](https://en.wikipedia.org/wiki/Physical_unclonable_function)

電路最佳化問題
    - 電路複雜度
    - 電路成本
    - Data Store(Cache & Register )漏電問題
    - 面積

Intel identified the vulnerabilities as:

CVE-2017-5705 – Multiple buffer overflows in kernel in Intel ME Firmware allowing an attacker with local access to the system to execute arbitrary code.

CVE-2017-5708 – Multiple privilege escalations in kernel in Intel ME Firmware allowing unauthorized processes to access privileged content via unspecified vector.

CVE-2017-5711 & CVE-2017-5712 – Multiple buffer overflows in Active Management Technology (AMT) in ME Firmware allowing attacker with local access to the system to execute arbitrary code with AMT execution privilege.

CVE-2017-5706 – Multiple buffer overflows in kernel in Intel SPS Firmware 4.0 allow attacker with local access to the system to execute arbitrary code.

CVE-2017-5709 -Multiple privilege escalations in kernel in Intel SPS Firmware 4.0 allows unauthorized process to access privileged content via unspecified vector.

CVE-2017-5707 –  Multiple buffer overflows in kernel in Intel TXE Firmware 3.0 allow attacker with local access to the system to execute arbitrary code.

CVE-2017-5710 – Multiple privilege escalations in kernel in Intel TXE Firmware 3.0 allows unauthorized process to access privileged content via unspecified vector.

原文:
https://meltdownattack.com/meltdown.pdf


## 三、Spectre & Meltdown 漏洞的修補策略與 risk mitigation（講師：gasgas）

### 前言
* 你認為得資訊安全？
    * 降低風險，而不可能100%修補
    * Risk = Vulnerable X Threat X Asset
    * 風險 ＝ 資安漏洞 Ｘ 駭客進不進得來 Ｘ 資產價值

### 該怎麼做？
* 漏洞因應流程：
    * 資訊盤點 ➡️ 漏動檢查 ➡️ 測試機測試 ➡️
      系統備份 ➡️ DRP演練 ➡️ 進行修補 ➡️ 持續觀察
* 漏洞檢查：
    * Unix：GitHub大大提供
    * Windows：微軟大大提供新的PowerShell你可以檢查是  否已更新
    * Mac：Apple官網提供
    * 瀏覽器運行：javascript等程式
        * https://xlab.tencent.com/special/spectre/spectre_check.html
* 漏洞修補：
    * CPU Level修補：Firmware Update
        * 程式千萬別看錯執行錯，變磚機率爆高！
        * 目前還不是 CPU Microcode 修補的好時機，可能都只是暫時修補，後續的修補應該會比較全面也比較安全。
    * Bios Level修補：notebook機器為主的修補方式
        * 修補會是個比較好的選擇 (其中也包含 CPU Microcode)，變磚機率低一點點。
        * > [name=Wisely] BIOS Update 目前只能修補其中一個 Spectre 的弱點
        * Amazon (AWS)/(VMware) 已修補完畢
    * OS Level修補：見官網
    * Application Level修補：
        * 程式重新編譯
        ```* 未重新 comliler 的程式還是有機會有風險```
        * Google Retpoline：GCC，LLVM版本
            徹底分支
        * Visual Studio 2017 version 15.5 /Qsperctre 
            lfence ：系統執行到此會停止預先運算
    * 安全最大風險Brower：
         ``` 使用javascript打包poc放在網路上,瀏覽器看了,記憶體的資料就被偷了```
### 提醒
* 修補一定要從官方下載
* 前漏洞衍伸 ➡️ skyfall and solace：不好修

### 討論

> [name=Ethen] 不對啊，目前的弱點需要讀取變數/建立陣列/評估cache速度，這些在JS / Java翻譯成實際執行在CPU上的native code不太可能還包在同一個分支中，他是怎麼有辦法說這樣是可以攻擊的？有成功案例嗎？

> [name=Austin]如果JS注入的code(browser->OS->CPU)是在同一個process或可控制的process就可以互相做存取，簡單的範例影片在這：https://www.youtube.com/watch?v=RbHbFkh6eeE

> [name=Ethen] 這個影片看起來是在本機端執行原生程式，來撈取另一個程式的記憶體內容，好像不是JS / Java?
> 即便都在同一顆CPU上，但直譯語言被翻過去到CPU上應該會有多不少東西，如Java有GC的動作，也沒有指標可直接讀取，這些東西混進去會導致執行不是連貫的或不是同一個分支，影響分析結果
> [name=gasgas] 是..這樣的測試會有很多干擾, 也會大大地影響到結果.  所以只能參考用. 這個javascript POC 目前爭議還很大..XDDD
    
..


## 四、詭譎多變威脅下的資安應變與治理（講師：林宏嘉協理）
### 概念 & 觀念
* 對應新的威脅與正確的認知
    * can't stop all attack
    * Human Experience and Behaviors
    * Detect in mobile
      Defence in deep
* Attacker Decision Cycle:
    * Observe
    * Orient
    * Decide
    * Act
* 加速決策 & 擺脫困境
    * Maximize Visibility(
      最大化可視性
        * internal
        * external
    * reduce manual step(and error)
        減少手動步驟（錯誤）
    * Maximize human impact
        善用人力資源
        
### 使用者影響
* 受影響的CPU 
    * [skylake](https://zh.wikipedia.org/wiki/Skylake%E5%BE%AE%E6%9E%B6%E6%A7%8B)後影響微小
    * [skylake](https://zh.wikipedia.org/wiki/Skylake%E5%BE%AE%E6%9E%B6%E6%A7%8B)前依照軟體有不同影響

### 簡報節錄
![](https://i.imgur.com/apVcqmo.png)
![](https://i.imgur.com/HC3W2Ub.png)
![](https://i.imgur.com/lxJai5g.png)
![](https://i.imgur.com/7TOL4jO.png)
![](https://i.imgur.com/RDod5Hh.png)
![](https://i.imgur.com/HXZym0q.png)
![](https://i.imgur.com/yICCZBi.png)
![](https://i.imgur.com/VsUoHeV.png)
![](https://i.imgur.com/2qCPUwL.png)
![](https://i.imgur.com/MsgRd49.png)
![](https://i.imgur.com/GN73nvP.png)
![](https://i.imgur.com/f542V3X.png)
![](https://i.imgur.com/rlxt6Fu.png)
![](https://i.imgur.com/ZzNLapH.png)
![](https://i.imgur.com/9Bs6R0X.png)
![](https://i.imgur.com/v0yjLSI.png)
![](https://i.imgur.com/LHARo2D.png)
![](https://i.imgur.com/lbn4VjD.png)

## Panel 問題（歡迎大家先來填寫）
1.面對 zero day attack，如何偵查與預防
2.arm64 為何也會有同樣的問題~目前的解法是什麼??
3.今年剛舉辦的 CES 2018 上所展示的最新型筆電，同樣也使用 Intel 第八代 CPU，是否有受此次漏洞影響？畢竟很多人會猶豫是否要再等待下一代的 CPU 再購買，謝謝。
  gasgas回答: 8th Gen Intel CPU 一樣有這三個漏洞, 一樣需要修補, 請參考https://hothardware.com/news/intel-8th-gen-core-cpus-10-slowdown-javascript-spectre-meltdown-patches
  ``` 第八代正在賣，第九代再測試，第十代正在做，可能等到第十一代才沒有```
  
4.依據 ITHOME 的訊息(https://www.ithome.com.tw/news/120312)， 目前透過OS更新的方式為針對 meltdown 的弱點修補，請問關於 Spectre 漏洞是否有 OS 或是 firmware 的修補連結嗎?	
5.問題一：目前全世界尚無發生災情，如果BIOS更新會拖慢電腦效能，那公司內部先發佈KB4056892更新檔的有效阻擋程度。 問題二：台灣國內有哪些資安網站可即時發佈及提供解決方案。	
6.如何能更有效率的檢查並修補該漏洞	
7.如何進行CPU攻擊	
8.對於晶片出包的問題，未來是否有更好的因應方式？如果來不及修補該如何自保？	
9.想請問針對Meltdown & Spectre 漏洞，對於一般做為系統、網站伺服器之主機有何影響，如果不更新作業系統只單靠防火牆進行過濾控管(EX:限定某幾個ip可以連線)可以避免被駭客入侵嗎?	
10.為什麼對一般使用者電腦影響較低，對雲端業者卻衝擊很大? 作業系統修補，成效如何?會對微軟的效能有重大影響嗎？ 雲端的衝擊有何應對之道?	
11.這次Meltdown和Spectre更新檔有其必要更新嗎?看一些報導上說更新後的問題還比較多。	
12.除了CPU外，其它的GPU或TPU等，是否應該也會如此呢？該如何因應處理？	
13.針對微軟官方說明網頁:https://support.microsoft.com/en-us/help/4072698/windows-server-guidance-to-protect-against-the-speculative-execution 請問其中的 To enable the fix 部分所提到的機碼是否為安裝了微軟的 Patch，且新增這三個機碼就可修補  CVE-2017-5715、CVE-2017-5753和CVE-2017-5754 三個漏洞嗎?還是除了進行以上步驟後，仍需更新Server硬體製造商給的 BIOS 才能阻擋攻擊呢?(微軟官方建議還是要更新硬體BIOS才能完整修補漏洞，但如果只上OS Patch 就能有效防禦的話，是否就可以不用急著更新BIOS了)
14.如果在虛擬主機上，Host端打上了Patch，但是Guest端沒有打上，這樣在Guest端能引發攻擊嗎？
15.Variant2 Branch target injection, hacker是如何對Branch history buffer進行訓練以及達到修改目的地位置，使得它會進行推測執行然後執行到hacker的gadget? 跟ROP(Return oriented programming)的攻擊方式是一樣的嗎？
16.對於因CPU漏洞修補而造成其他系統運作的問題時，在整個產業生態系統方面是否有更好的解決方式，以避免MIS人員害怕系統出問題而不願意修補漏洞?
17.如何評估修補前與修補後的效能差異?網路上有人說差異不大，也有人說差異滿多的，是否有較客觀的評估方法?
18.CPU層級的弱點需要靠明確的指令碼來利用，我的理解是只有在Native code已經可以執行的情況下可以藉此竊取資料或提權，不過可以看到各大瀏覽器在第一時間就做了修補。想請問是否代表這個弱點可以在不使用native code的情況下利用？