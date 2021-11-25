---
title: 完整學習機器學習實錄1——安裝 Ubuntu 18.04
date: 2019-09-13 22:28:12
tags:
- 機器學習
- 完整學習機器學習實錄
categories: 機器學習
thumbnail: https://docs.microsoft.com/zh-cn/windows-hardware/drivers/bringup/images/oem-boot-flow-detail.png
---

# 完整學習機器學習實錄1——安裝 Ubuntu 18.04

# 前言
　　本系列將紀錄作者在學習機器學習的同時，曾經踩過的坑與詳細的操作記錄。
> 一方面希望之後能夠在不久的未來回顧過去所為、遇到相同的問題時能夠讓迅速找到答案；同時也希望幫助在類似環境下學習的朋友，能夠有一套較詳細的學習筆記，共同勉勵與成長！
* 一篇重要的雙系統筆記與安裝前置作業，有需要雙系統的讀者請建議閱讀：https://medium.com/caesars-study-review-on-web-development/win10-and-ubuntu-%E9%9B%99%E7%B3%BB%E7%B5%B1%E5%AE%89%E8%A3%9D%E7%AD%86%E8%A8%98-bc824bef7fb4

# 硬體配置
```
MB : X299 AORUS Gaming 9
CPU: Intel I9-7920X
RAM: DDR4 HyperX 128G
SSD: Kingston A1000 NVMe PCIe SSD 960G
GPU: Nvidia GTX 1080ti (ROG-STRIX-GTX1080TI-O11G-GAMING)
```
## 這邊需要注意的
* MB 與 CPU 經由老外實測[^1]，是可以運行 Ubuntu 的，所以如果出問題，不需要先去考慮是主板與 CPU 不支持。
* SSD 是 NVME 協議，LINUX 理論上是支持的[^2]，組配時需確定主板支持才行。
* GPU 是 Nvidia ，自古以來 Nvidia 這類外接顯卡在 LINUX 上都需要另外安裝驅動，比較麻煩些，但也不得不用是吧。

# 系統安裝
筆者打算安裝此時最新的 Ubuntu 18.04 ，並且實現 Windows 10 與 Ubuntu 雙系統。雖然可能會遇到不少坑，但畢竟他是 LTS 版本，選用還是有點保障的。

##  基本知識
安裝系統涉及主板等許多基礎知識，這邊以條列式記錄，並且附上連結，有興趣大家可以自行研讀，但至少要了解它的功用與存在意義。
* UEFI：Unified Extensible Firmware Interface 統一可延伸韌體介面，用來定義**作業系統**與**韌體**的中介	[^3]，過去舊稱為 EFI，是用來取代 BIOS 的一種新定義。[^4]
	* 韌體的階層位置![韌體的階層位置](https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Efi-simple_zh-tw.svg/1920px-Efi-simple_zh-tw.svg.png =400x) 	
	* BIOS 與 UEFI 的外觀差別
![BIOS 與 UEFI 的外觀差別](https://www.howtogeek.com/wp-content/uploads/2017/05/img_5913820521683.png)
* 韌體（固件）：firmware 顧名思義，韌體的所在是位於軟體和硬體之間的。像軟體一樣，他是一個被電腦所執行的程式。現已演進為一個硬體裝置當中的可程式化的內容，通常可用 *電流清除並重寫* 或 *更換儲存媒介* 的方式更新。
>俗稱刷 BIOS 就是在刷韌體
* Legacy/CSM：在 UEFI 普及後，我們時常可以在主機板選項中看到這兩者之一，開啟、關閉分別代表**是否兼容傳統 BIOS** 。這是在標準整合的時代，必然會出現的混亂選項，之後有望完全脫離 CSM[^5]
	* 微軟的 UEFI 推廣計畫：
	![在这里插入图片描述](https://cdn0.techbang.com/system/images/420883/original/0e448957d310d541d9a2606797e833c5.jpg?1511214698) 		
		* 類別0，這類系統使用x86 BIOS韌體，只支援傳統作業系統。
		* 類別1，這類系統採用支援UEFI和Pi規範的韌體，啟用CSM層功能，只支援傳統作業系統。
		* 類別2，這類系統採用支援UEFI和Pi規範的韌體，啟用CSM層功能，同時支援傳統和UEFI啟動的作業系統。
		* 類別3，這類系統採用支援UEFI和Pi規範的韌體，不再提供或完全關閉CSM層功能，只支援由UEFI啟動的作業系統。
		* 類別3+，在類別3的系統基礎上提供並啟用Secure Boot功能。 
> 若您的系統都以 UEFI 安裝，理論上開啟與否都不影響，但是為了更好的兼容，通常建議開啟 CSM 後選擇 UEFI 優先。（金士頓的官方說明[^6] 與 SSD 疑惑[^7]）
* Secure Boot：中文稱安全啟動，也就是主機板只認定「安全的系統」，才能夠順利啟動，目前被認定為安全的系統有以下等，不少 Linux 發行版也通過「安全」認證。
	* Windows 8 and 8.1
	* Windows Server 2012, and 2012 R2
	* Windows 10, VMware vSphere 6.5[52] 
	* Fedora (since version 18)
	* openSUSE (since version 12.3)
	* RHEL (since RHEL 7)
	* CentOS (since CentOS 7[53]) 
	* Ubuntu (since version 12.04.2)
	* FreeBSD

而更詳記得內容如下文所述[^8]：
>The UEFI 2.3.1 Errata C specification (or higher) defines a protocol known as secure boot, which can secure the boot process by preventing the loading of drivers or OS loaders that are not signed with an acceptable digital signature. The mechanical details of how precisely these drivers are to be signed are not specified.[49] When secure boot is enabled, it is initially placed in "setup" mode, which allows a public key known as the "platform key" (PK) to be written to the firmware. Once the key is written, secure boot enters "User" mode, where only drivers and loaders signed with the platform key can be loaded by the firmware. Additional "key exchange keys" (KEK) can be added to a database stored in memory to allow other certificates to be used, but they must still have a connection to the private portion of the platform key.[50] Secure boot can also be placed in "Custom" mode, where additional public keys can be added to the system that do not match the private key.[51]
>Secure boot is supported by Windows 8 and 8.1, Windows Server 2012, and 2012 R2, and Windows 10, VMware vSphere 6.5[52] and a number of Linux distributions including Fedora (since version 18), openSUSE (since version 12.3), RHEL (since RHEL 7), CentOS (since CentOS 7[53]) and Ubuntu (since version 12.04.2).[54] As of January 2017, FreeBSD support is in a planning stage.[55]
![在这里插入图片描述](https://1.bp.blogspot.com/-utBmke02KrE/UHaaPshfyqI/AAAAAAAABDs/Nuz-Dldc18A/s1600/Windows-8s-Secure-Boot.jpg)
* MBR 與 GPT：兩者分別為傳統 BIOS 與新型 UEFI 的分區結構，狹義的MBR 可以單止 BIOS 的系統引導程序，與之相對應的是 UEFI 的系統引導程序分區 ESP（EFI system partition）。
	* GPT 好處為近乎無限的分區數量以及識別無限硬碟大小。
	* MBR 僅限制 2T 與 4 個主要分區，但存在較好的相容性。
	* 單以一張圖可以這麼解釋兩者差別，MBR 主要受限於其分區、引導等內容都儲存在第一個分區，而這個分區的大小會影響其發展可能性：
![](http://www.mustbegeek.com/wp-content/uploads/2018/04/Difference-between-MBR-and-GPT.png)
> 這部分較為複雜，牽扯到系統啟動時所需要查找的硬碟分區、以及其紀錄方式等，詳細內容可以查看這篇文章[^9]或是較口語化的這篇[^10]。

* 在 windows 以 UEFI 啟動電腦的流程：
![在这里插入图片描述](https://docs.microsoft.com/zh-cn/windows-hardware/drivers/bringup/images/oem-boot-flow-detail.png)
Bootloader（引導）代碼及配置文件存於系統盤的ESP中。其中如圖深灰色層，Win10自帶的 Bootloader 為 Windows Boot Manager ，而同屬相同層次 ubuntu18.04 自帶的 Bootloader 為 GRUB2 。

目前實現 win10 / ubuntu18.04 雙系統有兩種方案：

1. 在深灰色層，仍染以 Windows Boot Mananger 為主引導，但需要關閉 UEFI 和 Secure Boot，開啟Legacy / CSM，最後通過 EasyBCD 手動添加 Ubuntu 入口。
2. 在淺灰色層，就交給以 GRUB2 作為主引導，使其生成開機選單。

顯而易見的，第二種方案更省時省力。

> 前面有提到，Ubuntu 已經通過 Secure Boot 的認證，所以如果以 GRUB2 為主導，其實不需要關閉 Secure Boot 依照邏輯也得以正常啟動。

## 製作與開始安裝 Ubuntu 
1. 使用 [Ultraiso](http://tw.ezbsystems.com/ultraiso/)  選用「寫入硬碟映象」製作一支 ubuntu 18.04 的開機碟
2. 使用 Win10 自帶的硬碟管理（開始鍵 + X ➡️ 選磁碟管理），在 C 磁碟（系統盤），右鍵「壓縮卷」，依個人狀況選擇留給 Ubuntu 的大小。
3. 到 BIOS 將 Legacy / CSM 兼容打開，Secure Boot 可以保持原設定，將帶有 UEFI 前綴字樣的隨身碟設為首選開機。F10 存擋並重新啟動。
4. 此時會進入 Ubuntu GRUB2 的引導開機介面，選擇 install Ubuntu 後正常情況會順利安裝。
5. 這兒筆者遇到兩個狀況，第一是點選 install 後卻因為 ACPI error 而導致黑屏死機，必須強壓電源關機。在此紀錄筆者排除此狀況的流程。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190104021917884.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
## 釐清問題 --- ACPI 是啥？
- 進階組態與電源介面（英文：Advanced Configuration and Power Interface，縮寫：ACPI），是1997年由英特爾、微軟、東芝公司共同提出、制定提供作業系統應用程式管理所有電源管理埠，是一種工業標準，包括了軟體和硬體方面的規範[^11]。 
	- 換句話說，這又是一個 UEFI 社群的新規章，他定義了一些特殊的電源使用方式，例如下面這些功能[^12]:
		1. 用戶可以使外設在指定時間開關。
		2. 使用筆記本電腦的用戶可以指定電腦在低電壓的情況下進入 低功耗狀態，以保證重要的應用程式運行。
		3. 作業系統可以在應用程式對時間要求不高的情況下降低時鐘頻率。
		4. 作業系統可以根據外設和主板的具體需求為它分配能源。
		5. 在無人使用電腦時可以使電腦進入休眠狀態，但保證一些通 信設備打開。
		6. 即插即用設備在插入時能夠由ACPI來控制。 
- 問題的發生
	- Ubuntu 18.04 沒有原裝 Nvidia 顯卡的圖形驅動，導致無法正確透過 ACPI 調用電源管理而出錯。[^13]
- 問題的解決
	- 我們可以透過更改 GRUB2 的啟動參數來「迴避」這個問題。[^14]
	- 再進入選擇 Try Ubuntu 或 install Ubuntu 的頁面，在選項上按下 `e` ，隨後可以進入 GRUB2 的參數修改介面，在 Linux 那行，後方刪除三個 `---` 後加入 `acpi=off` 

		- 錯誤示範：![acpi=off 錯誤示範](https://img-blog.csdnimg.cn/20190105181527458.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
		- 正確示範：![在这里插入图片描述](https://img-blog.csdnimg.cn/20190105181851441.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
		- 接著在開機時，要壓住 `shift` ，再次進入 GRUB2 並且做相同的設定。如圖片中倒數第二行，一樣加在 Linux 那行。
	![在这里插入图片描述](https://img-blog.csdnimg.cn/20190105190941750.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
	- 開機後可以使用以下指令安裝 Nvidia 驅動
	`sudo add-apt-repository ppa:graphics-drivers/ppa`
`sudo apt-get update`
`nvidia-smi` 後可獲得建議安裝指令
`sudo apt-get install nvidia-381` (後面請選擇適當的或最新版本)
	- 如果仍然出現問題可以編輯 `/etc/default/grub` ，加入 `acpi=off` 
但是要注意可能發生 CPU 風散停止的問題。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190105192421291.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
- 問題補充
	- 網路上有人有遇到循環 GRUB2 而無法進入系統的情形，詳情可參考此篇：https://www.ubuntu-tw.org/modules/newbb/viewtopic.php?post_id=209042
	- 筆者建議可以安裝 `Psensor` 這個圖形化的軟體，在安裝完成後的一段時間，觀測硬體溫度。[^15]
		`sudo apt-get install lm-sensors hddtemp`
		`sudo sensors-detect`
		`sensors`

6. 接著，順利進入安裝程序後後，卻發現無法正確抓到 NVME SSD。
## 釐清問題 --- NVME SSD 
根據這篇文章`把 Ubuntu 16.04 及 18.04 安裝到幾款特殊的 NVMe SSD`[^16] 上，可以知道大概是 APST(Autonomous Power State Transitions) 的問題，可見作者在  [Arch Linux Wiki](https://wiki.archlinux.org/index.php/Solid_state_drive/NVMe) 上可以找到解決方法
- 問題的發生
	- 而問題的細節是因為 NVME 的省電模式似乎因為驅動的問題而掛了，近一步可以閱讀`PMC NVMe主控动态电源管理`[^17]理解更多有關於 NVME 電源管理代碼的問題。 
-  問題的解決
	- 在剛剛相同的頁面，相同行，空格後接續補上此參數`nvme_core.default_ps_max_latency_us=5500` 開機後 installer 就能偵測到 NVMe SSD 了。
	![在这里插入图片描述](https://img-blog.csdnimg.cn/2019010519232869.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
	- 因為 Ubuntu 預設是不會出現 GRUB 選單，會自動進入系統，所以安裝完第一次開機時要按住 shift 強制讓 GRUB 出現，再次加上 `nvme_core.default_ps_max_latency_us=5500` 參數開機，如果不加上還是能進系統，但會隨機遇到系統完全 hang 住無法動彈，只能強制重新開機的狀況，例如執行 `lscpi` `uname` 等指令都有可能引發。
	- 成功第一次穩定進入系統，要去編輯 `/etc/default/grub` 把 `nvme_core.default_ps_max_latency_us=5500` 參數加上去，再執行 `sudo update-grub` 更新 GRUB 設定。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190105192410895.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zOTc3NzUwNw==,size_16,color_FFFFFF,t_70)
# 結論
至此為止，已經成功了安裝必備的基本環境，可開始 Ubuntu 18.04 的機器學習之旅。接著，可以開始安裝相對應的 CUDA 以及 cuDNN，以及自己熟悉的機器學習框架與庫，Here we go！

[^1]:https://youtu.be/WpKPw56ABQU
[^2]:https://zh.wikipedia.org/wiki/NVM_Express
[^3]:https://zh.wikipedia.org/wiki/%E7%B5%B1%E4%B8%80%E5%8F%AF%E5%BB%B6%E4%BC%B8%E9%9F%8C%E9%AB%94%E4%BB%8B%E9%9D%A2
[^4]:https://www.howtogeek.com/56958/htg-explains-how-uefi-will-replace-the-bios/
[^5]:https://www.techbang.com/posts/55248-intel-will-completely-remove-csm-simulation-legacy-bios2020-year-full-transfer-to-uefi-class-3
[^6]:https://www.kingston.com/tw/ssd/resources/dcp1000-boot-configurations-and-recommendations
[^7]:https://askubuntu.com/questions/882346/cant-boot-into-linux-on-2nd-ssd
[^8]:https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface#SECURE-BOOT
[^9]:https://tw.saowen.com/a/64f464b3ebc85f9dd9209dd767d4aed957fb91746e98d4265969ffbbbe212075
[^10]:https://kknews.cc/zh-tw/collect/jva4zl.html
[^11]:https://zh.wikipedia.org/wiki/%E9%AB%98%E7%BA%A7%E9%85%8D%E7%BD%AE%E4%B8%8E%E7%94%B5%E6%BA%90%E6%8E%A5%E5%8F%A3
[^12]:https://blog.xuite.net/mmmminst/mouthfire/30682165-%E7%8F%BE%E5%AD%B8%E7%8F%BE%E8%B3%A3%EF%BC%9A%E4%BB%80%E9%BA%BC%E6%98%AFACPI%E9%98%BF%3F%3F
[^13]:https://www.cnblogs.com/handsomer/p/9310559.html
[^14]:https://www.itread01.com/articles/1502056813.html
[^15]:https://www.ubuntu-tw.org/modules/newbb/viewtopic.php?post_id=75694
[^16]:https://medium.com/@honglong/%E6%8A%8A-ubuntu-16-04-%E5%8F%8A-18-04-%E5%AE%89%E8%A3%9D%E5%88%B0%E5%B9%BE%E6%AC%BE%E7%89%B9%E6%AE%8A%E7%9A%84-nvme-ssd-%E4%B8%8A-504a519ab729
[^17]:http://www.10tiao.com/html/609/201608/2652239581/1.html