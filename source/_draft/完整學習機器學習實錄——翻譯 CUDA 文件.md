---
title: 完整學習機器學習實錄——翻譯 CUDA 文件
date: 2019-09-13 22:33:51
tags:
- 機器學習
- 完整學習機器學習實錄
categories: 機器學習
thumbnail: https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkJ2VNU7zsYecbcb5I3CjjU9Z8oddyFiahjmHUaYztekXn9nYZafpyrpw/640?wx_fmt=png&wxfrom=5&wx_lazy=1
---

# 翻譯 CUDA 文件
###### tags: `完整學習機器學習實錄` `機器學習` 
文章出處：[[分享] CUDA 程式設計(10) -- 速成篇(上)](https://ppt.cc/DWrS)
![](https://i.imgur.com/N83OSAh.jpg)

[[分享] CUDA 程式設計(1) -- 簡介](https://www.ptt.cc/bbs/C_and_CPP/M.1224075534.A.C49.html)
![](https://i.imgur.com/snIj425.jpg)

[[分享] CUDA 程式設計(2) -- SIMT概觀](https://ppt.cc/dx2Z)
![](https://i.imgur.com/W3oGn4K.jpg)

[[分享] CUDA 程式設計(3) -- CUDA 安裝](https://www.ptt.cc/bbs/C_and_CPP/M.1224075605.A.0ED.html)
![](https://i.imgur.com/6FrEWmV.jpg)

![](https://i.imgur.com/IoJljTd.jpg)
[[分享] CUDA 程式設計(4) -- 硬體規格簡介](https://www.ptt.cc/bbs/C_and_CPP/M.1224075621.A.9AA.html)
![](https://i.imgur.com/O2wUCwe.jpg)


[[分享] CUDA 程式設計(5) -- 第一支程式 (向量加法)](https://ppt.cc/ul,R)
![](https://i.imgur.com/bKH4qDj.jpg)






# CUDA C Programming Guide

Author:William Mou

---
# DAY1
----
## 1. 概述
### 1.1 從圖形處理到通用並行運算
在實時高清3D圖形的貪婪市場需求推動下，可編程圖形處理單元或GPU已發展成高度並行、多線程、眾核處理器，且具有巨大的計算能力和非常高的內存帶寬，如圖1和圖2所示。

圖1. CPU和GPU的每秒浮點運算
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkUPKicN3n5gvbjj1mP0z9iaalibddu7AqSIQZUXVfQCZ1sS3to43MQnODQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

圖2. CPU和GPU的內存帶寬
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vk5cQpN8ypsr06MhCHO1ptOvgXm4LOFpAxxolohtMDj1JZrictgG2XkQQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

GPU與GPU之間浮點能力差異的原因，在於GPU專門用於計算密集，高度並行計算（究竟圖形渲染所關注的是什麼），因此這樣的設計，使得更多晶體管致力於數據處理而不是數據緩存和流量控制，如圖3所示。

圖3. GPU為數據處理提供更多晶體管
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkjce79Y8icyPdweZ8Q9ibsQASbc9Zlnjax3eibGQfmLGU9zHcZMDaIQZGQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

更具體地說，GPU特別適合用高算數強度（算術和內存操作的比率）解決資料並行計算（同一程序在許多數據元素上並行執行）的程序。由於每個數據元素都執行對複雜的流控制要求較低的相同程序，並且由於它在許多數據元素上執行並且具有較高的算力，內存訪問延遲可以用於計算而不是大數據緩存。

數據並行處理將數據元素映射到並行處理線程。許多處理大型數據集的應用程序可以使用數據並行編程模型來加速計算。在3D渲染中，大量的像素和頂點被映射到並行線程。類似的，圖像和媒體處理應用，例如渲染圖像的後處理、視頻編碼和解碼、圖像縮放、立體視覺和模式識別中，都可以將圖像塊和像素映射到並行處理線程。事實上，除了圖像渲染和處理領域以外，許多算法都是通過數據並行處理來加速的，從一般信號處理或物理模擬到計算金融或計算生物學。

### 1.2 CUDA®：一個通用並行計算平台和編程模型

在2006年十一月，NVIDIA 採用CUDA，一個通用型並行運算平台，其編程模型利用NVIDIA GPU中的並行計算引擎，以比CPU更高效的方式，解決許多複雜的計算問題。

CUDA帶有一個軟件環境，允許開發人員使用C作為高級編程語言。如圖4所示，
同時也支持其他語言、應用程序編程接口或指令為主的方法，例如FORTRAN、DirectCompute、OpenACC。

圖4. GPU計算應用程序。CUDA設計於支持各種語言和應用程序編程接口。
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkJ2VNU7zsYecbcb5I3CjjU9Z8oddyFiahjmHUaYztekXn9nYZafpyrpw/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

### 1.3 可擴展的編程模型
隨著多核CPU與並行GPU的出現，意味著主流的處理器芯片已成為並行系統。與此同時，並行運算仍符合著摩爾定律。此時的挑戰是開發一個可以兼容硬體的並行運算應用軟件，以利用越來越多的處理器內核，如同3D圖形應用程序需兼容變化量大的GPU內核數量。

CUDA 並行編程模型被設計用來應對如上的挑戰，同時，也為熟悉同時為熟悉標準編程語言（例如C語言）的程序員，保持一個較為平緩的學習曲線。

CUDA 有三個關鍵的抽象概念，線程組的層次結構、共享內存、柵欄同步。這對程序員來說相當簡單，僅如同一語言擴展集。

這些抽象的概念提供精細的數據並行與線程並行，而其被鑲嵌在粗粒度數據並行和任務並行中。他們使程序員得以將問題劃分為可由線程塊並行獨立解決的粗子問題，並將每個子問題劃分為更精細部分，可由塊內的所有線程並行解決。

這種分解通過允許線程在解決每個子問題時，進行協作來保持語言表達性，並同時實現自動擴展性。確實，每個線程區塊可以被任一個可用的多處理器（包含GPU）調度，不論任何順序、同時或順序的，一個已編譯的CUDA程序可以在任何數量的多處理器上執行，如圖5所示。並且只有在運行系統時，需要知道多處理器的總數。

藉由簡單地擴展多處理器和內存分區的數量，這種可擴展的編程模型允許GPU架構跨越廣泛的市場範圍：從「愛好者」GeForce、「專業者」Quadro、「計算產品」Tesla 到各種廉價的主流GeForce GPU。（請參閱支持CUDA的GPU以獲取所有支持CUDA的GPU的列表）

圖5.自動可伸縮性
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkyQNwpPxiargjibRR3RhiaxZSbKEgVBDyIicauZxmzIlyK9LJ3o5RGOg00A/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

注意：GPU是被建造來圍繞一多流的陣列（SMs）（請參閱硬件實現了解更多詳情）。一個多線程程序被劃分為彼此獨立執行的線程塊，因此具有更多處理器的GPU，將以比具有更少處理器的GPU運用更少的時間自動執行程序。

* 原文網址：[DAY 1: 学习CUDA C Programming Guide](https://mp.weixin.qq.com/s/q2GrCt67VuCHYfhEVcX34g)
* 原文备注/经验分享：
>CUDA对于C++的支持不完善。有各种限制的。
>算术和内存操作的比率，这个是衡量一张卡计算性能和访存性能比率的指标。 有两种单位。一个是指令对字节（或者4B）， 另外一个是指令对指令。但是这ratio实际上不用自己记住的。因为一般情况下profiler会告诉你是你卡计算，还是卡访存。
>有不明白的地方，请在本文后留言
或者在我们的技术论坛bbs.gpuworld.cn上发帖
![](https://mmbiz.qpic.cn/mmbiz_jpg/X0xSWHRkgXS0nDnkJynibeY7JZ6t3fL3j1VsdgmjNbSs9a1cMIAOH0UtX5hEzHP42sJpL6g7nabkLSiamFa9gBkw/640?wx_fmt=jpeg&wxfrom=5&wx_lazy=1)

---
# DAY2
----
## 2. 編程模型
* 此章節介紹CUDA編程模型背後的主要概念，概述如何使用C表達他們
* 所有在此章節與次個章節使用的向量加法範例，皆可以在 CUDA 範例中 `vectorAdd` 裡找到。

### 2.1 內核
CUDA C 允許程序員藉由定義 C 語言的方法與呼叫核心，延伸 C 語言，當被呼叫時，被 N 個不同的 CUDA 線程並行執行 N 次，而不是像普通的 C 函數一樣只有一次。

一個核心使用 `__global__` 聲明說明符定義，而對於特定的內核調用，執行該內核的CUDA線程的數量是使用新的 `<<< ... >>>` 執行配置語法。每一個執行內核的線程被賦予一個獨一無二的線程ID，以此通過內置的 `threadIdx` 變量訪問內核。

如下插圖，下面的示例代碼添加兩個大小為 N 的向量 A 和 B ，並將結果存儲到向量 C 中：
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkC5iak7YxshhtvotLfcjepgVYoQ1VhDicGMicxahESB6IBAQZ2lzYddcbw/640?wx_fmt=png&wxfrom=5&wx_lazy=1)
在這裡，執行 `VecAdd（）` 的 N 個線程都執行一次一對一的加法(兩兩相加)

### 2.2 線程層次結構
為了方便， `threadIdx ` 是一個三維向量，所以可以用一維、二維、三維下標來指定唯一線程。形成一維、二維或三維的線程區塊，稱為線程塊。這提供了一種自然的方式來調用跨越元素的計算，例如向量，矩陣或體積。

一個線程的索引和它的線程ID以直接的方式相互關聯，對於一維塊，它們是相同的﹔對於尺寸為（Dx，Dy）的二維塊，索引（x，y）的線程的線程ID為（x + y Dx）﹔對於尺寸為（Dx，Dy，Dz）的三維塊，索引（x，y，z）的線程的線程ID為（x + y Dx + z Dx Dy）。

如下範例，下面的代碼相加了兩個大小為 NxN 的矩陣 A 和 B ，並將結果存儲到矩陣 C 中:
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkoogYhx6cfEticeQYxNSnlo7XDyaarSQZK5pEw9ISnJoR0nmIiaBNK2UA/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

每塊的線程數量是有限制的，因為一個塊的所有線程都應該駐留在同一個處理器內核上，並且必須共享該內核的有限內存資源。在當前的GPU上，一個線程塊最多可以包含1024個線程。

但是，一個內核可以由多個相同形狀的線程塊執行，因此線程的總數等於每塊的線程數乘以塊的數量。

如圖6所示，區塊被一維，二維或三維的線程塊組織成網格。網格中線程塊的數量，通常會由數據程序的大小或系統的程序數量來決定，因此它可以大大超過限制。

Figure 6. Grid of Thread Blocks
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkUXGYPwKnzD1coC2KD3r4puzUhqic0bhjGT4I3dKzdhxdesPE0ibcOPeg/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

每個塊的線程數和<<< ... >>>語法中指定的每個網格的塊數可以是int類型或dim3類型。可以像上面的例子那樣指定二維塊或網格。

網格中的每個塊都可以通過內核中通過內置blockIdx變量在內核中訪問的一維，二維或三維索引來標識。線程塊的維度可以通過內置的blockDim變量在內核中訪問。

擴展前面的MatAdd（）示例以處理多個塊，代碼變為如下所示。

![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkcplFIq59PAqYic5axfR1icz5ZaceenAkmZj6btoZ9xR3mdPfX9Baq8pw/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

儘管在這種情況下，我們可以任意的選擇線程塊大小，但16x16（256線程）是常見的選擇。如同以前每個矩陣元素都有一個線程，每個網格需要足夠的區塊來創造。為了簡單起見，本示例假定每個維度中每個網格的線程數可以被該維度中每個塊的線程數整除，但現實中並不一定如此。

線程塊需要獨立執行：它必須能夠以任意順序，並行或串行執行。這種獨立性要求允許按照圖5所示的任意數量的內核以任意順序調度線程塊，從而使編程人員能夠編寫與內核數量一致的代碼。

塊內的線程可以通過共享內存共享數據並通過同步執行來協調內存訪問來進行協作。更準確地說，可以通過調用 `__syncthreads（）` 內部函數來指定內核中的同步點;` __syncthreads（）`充當一個分界點，在允許繼續進行之前，塊中的所有線程必須等待。共享內存提供了一個使用共享內存的例子。除 `__syncthreads（）` 外，`Cooperative Groups API`還提供了豐富的線程同步原語。

為了有效協作，共享內存預計將是每個處理器內核附近的低延遲內存（類似於L1緩存），並且`__syncthreads（）`預計會很輕量。

### 2.3。內存層次結構
CUDA線程可能會允許在執行期間從多個內存空間訪問數據，如圖7所示。每個線程都有私有本地內存。每個線程塊都具有對該塊的所有線程都可見的共享存儲器，並且具有與該塊相同的生命週期。所有線程都可以訪問相同的全局內存。

所有線程還可以訪問另外兩個只讀內存空間：常量和紋理內存空間。全局，常量和紋理內存空間針對不同的內存使用進行了優化。對於某些特定的數據格式，紋理內存還提供了不同的尋址模式以及數據過濾。

全局，常量和紋理內存空間在同一應用程序的內核啟動之間是連續的。
圖7.內存層次結構
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkQgK0Dv16AVDibGwo3ejmzKibYAaCu1McDHk5PdhaNpDotnTvN8zwa1VA/640?wx_fmt=png&wxfrom=5&wx_lazy=1)


### 2.4 異構编程
如圖8所示，CUDA編程模型假定CUDA線程在物理上分離的設備上執行，該設備作為運行C程序的主機的協處理器運行。例如，當內核在GPU上執行時，C程序的其餘部分在CPU上執行。

CUDA編程模型還假定主機和設備都在DRAM中分別維護其自己的獨立存儲空間，分別稱為主機存儲器和設備存儲器。因此，程序通過調用CUDA運行庫來管理內核可見的全局，常量和紋理內存空間。這包括設備內存分配和重新分配以及主機和設備內存之間的數據傳輸。

統一內存提供託管內存以橋接主機和設備內存空間。託管內存可以從系統中的所有CPU和GPU訪問，作為具有公共地址空間的單連貫內存映像。這種功能可以實現對設備內存的超額訂購，並且可以通過消除在主機和設備上顯式鏡像數據的需求，大大簡化移植應用程序的任務。

圖8.異構編程
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTibaAWJD3ZDB7gr3wJn36vkCibPkqFL2lhibu15KEcpicRXWA5PKjNyzOygBCh3GfyMsQ1uevaYvoicuA/640?wx_fmt=png&wxfrom=5&wx_lazy=1)
附註：串行代碼在主機上執行，而並行代碼在設備上執行。

### 2.5 計算能力

設備的計算能力由版本號表示，有時也稱為“SM版本”。此版本號標識GPU硬件支持的功能，並由運行時的應用程序用於確定當前GPU上可用的硬件功能和/或指令。

計算能力包括主版本號X和次版本號Y，用X.Y表示。

具有相同主要版本號的設備具有相同的核心架構。基於Volta架構的設備的主要版本號為7，基於Pascal架構的設備為6，基於Maxwell架構的設備為5，基於Kepler架構的設備為3，基於Fermi架構的設備為2，和基於Teslaarchitecture的設備為1。

次要修訂號對應於核心架構的增量改進，可能包括新功能。計算能力給出了每種計算能力的技術規格。

注意：不應該將特定GPU的計算能力版本與CUDA軟件平台版本的CUDA版本（例如，CUDA 7.5，CUDA 8，CUDA 9）混淆。應用程序開發人員使用CUDA平台創建在多代GPU架構上運行的應用程序，包括尚未發明的未來GPU架構。雖然CUDA平台的新版本通常通過支持該體系結構的計算功能版本為新的GPU架構添加本地支持，但新版本的CUDA平台通常還包含獨立於硬件生成的軟件功能。

附註：從CUDA 7.0和CUDA 9.0開始，不再支持Tesla和Fermi架構。


>本文备注/经验分享：

 each of the N threads that execute VecAdd() performs one pair-wise addition
 
整体翻译的话，可以翻译为“每个线程进行一对数值的加法”，请注意pair-wise addition还有另外一个意思是log2(N)方式的相加。如果你有16个浮点数，一种并行化的方式是：分成前8个，和后8个。前8个里面分成4个+4个，4个+4个分成2+2+2+2...这种pair-wise的累加是为了保持精度。 我们常见的，常说的shared memory上的规约，实际上就是这种累加。 所以也叫log2规约加法。 这种累加能增加精度，减少误差。 回到VectorAdd这个例子，这里面就是普通的两个数相加的意思。


a kernel can be executed by multiple equally-shaped thread blocks, 这里equally-shape是相同形状，因为我们启动kernel的时候，标准的runtime api语法是：<<<A,B>>>，这代表启动A个blocks，每个blocks都是B个线程的形状。

 所以这里提到了：equally shaped。 CUDA也不支持一次启动中有多种不同形状的block，如果需要有多种不同形状的blocks，可以多次启动，或者自己用代码变形。


A thread block size of 16x16 (256 threads), although arbitrary in this case。这里arbitrary是任意的意思。我们启动kernel的时候，可以使用任意形状。但128， 256（本例), 512这些，是常见的形状选择。（16 * 16 = 256)。需要说明的是，某些kernel往往有个最佳的block形状，此形状下启动性能最好。但不能提前知道是什么样子，得反复试验，无直接的公式能告诉大家什么形状是最好的。注意很多时候我们选择形状的时候，需要加上if限制，if或者while (.....)。 这是很多情况下问题规模并不能直接被你刚才选择的“同样形状/大小”的block给整除。此时往往需要过多启动blocks，并同时用if限制掉越界的线程。 这同时也是因为我们刚才说的，“同样形状”导致的----边界上的blocks并不能选择一些较小的，不同形状的。 注意OpenCL有不同的选择，它允许边界处的groups（等于CUDA的blocks）具有不同的形状，但这额外的增加了kernel书写者面对的复杂性。 CUDA比较易用，直接不让你考虑这样的。所以我们需要if或者while或者for之类的设定条件，处理好边界。

# DAY3 
---
## 3.編程接口
CUDA C 利用 C 語言提供了使用者一個簡單的的路徑，用來輕鬆撰寫程序以提供設備執行。
它由一組最小的 C 語言擴展集和一個運行庫組成。
這個核心的延伸已經在 DAY2 中介紹，他們允許程序員用 C function 去定義一個核心，並在每一次方法被呼叫時，使用一些新的語法去定義格子與區塊大小。任何一個包含這些擴展集的原代碼已經被編譯為nvcc檔案。
這些執行期已經在Compilation Workflow介紹。它提供了可以在host上執行，用以分配和釋放設備內存、在主機內存和設備內存之間傳輸數據、管理具有多個設備的系統等的C函數。一個完整執行期的描述可以在CUDA reference manual 中查到。
這個執行期備建立在一個低階C API的頂部，CUDA 驅動程式 API，也可由應用程序訪問。這個驅動程序API通過利用底層的概念來提供額外的控制級別，CUDA contexts 用以設備主機進程的模擬；以及CUDA modules 用以設備動態加載庫的類比。大多數應用程序不使用驅動程序API，因為它們不需要此額外級別的控制，並且在使用運行時時， contexts 和 modules 管理是隱含的，從而產生更簡潔的代碼。驅動程序API在Driver API中描述，並在參考手冊中有詳細資料。

### 3.1 NVCC 的編撰
內核可以由 CUDA 指令集系統撰寫而成，其被命名為 PTX ，這在PTX參考手冊中有描述，這多麼通常而更有效的去使用一個例如C的高階程式語言。在兩個案例中，內核必須被利用 nvcc 編譯成一個二進制代碼使其執行於裝置上。

nvcc 是一個編譯器驅動，其簡化了編譯C或PTX代碼的過程，他提供了簡易且友善的命令行選單，並匯集實現不同的編譯階段的工具，藉由調用其並執行，本節概述了nvcc工作流程和命令選項。完整的描述可以在nvcc用戶手冊中找到。

#### 3.1.1 Compilation Workflow
##### 3.1.1.1 離線編譯
運用 nvcc 編譯原代碼可以混合包含主機的代碼(即，在主機上執行的代碼)以及設備的代碼（即，在設備上執行的代碼），nvcc的基本工作流程是將設備代碼與主機代碼分離，然後：
* 將設備代碼編譯成彙編形式（PTX）和/或 二進制形式（Cubin），

* 藉由必要的 CUDA C 運行時的 function 呼叫，從 PTX 或 cubin 中讀取與安裝每個編譯核心，更換<<<...>>>語法，以修改 host 代碼 (<<<...>>>在Kernels中介紹，並在 Execution Configuration 中更詳細地描述) 

修改後的主機代碼可以作為C代碼輸出，可以使用其他工具編譯，也可以直接通過讓nvcc在上一個編譯階段調用主編譯器來直接編譯為目標代碼。
此應用程序可以：
* 鏈接到已編譯的主機代碼（這是最常見的情況），

* 或者忽略修改的主機代碼（如果有）並使用CUDA驅動程序API（請參閱驅動程序API）加載和執行PTX代碼或Cubin對象。


##### 3.1.1.2 即時編譯
應用程序在運行時加載的任何PTX代碼都由設備驅動程序進一步編譯為二進制代碼，這就是所謂的即時編譯。即時編譯會增加應用程序加載時間，但允許應用程序受益於每個新設備驅動程序隨附的任何新編譯器改進。它也是應用程序在編譯應用程序時不存在的設備上運行的唯一方法，如應用程序兼容性中所述。
當設備驅動程序即時編譯某些應用程序的某些PTX代碼時，它會自動緩存生成的二進制代碼的副本，以避免在後續調用應用程序時重複編譯。緩存（稱為計算緩存）在設備驅動程序升級時會自動失效，以便應用程序可以從設備驅動程序中內置的新即時編譯器中的改進中受益。
環境變量可用於控制即時編譯，如 UDA Environment Variables 所述。

#### 3.1.2 二進制兼容性
二進制代碼是特定於體系結構的。使用指定目標體系結構的編譯器選項-code生成cubin對象：例如，使用-code = sm_35進行編譯會為計算能力3.5的設備生成二進制代碼。二進制兼容性可以保證從一個小版本到下一個版本，但不能從一個小版本到前一個版本或跨主要版本。換句話說，為計算能力X.y生成的Cubin對像只能在計算能力為X.z的設備上執行，其中z≥y。


#### 3.1.3 PTX兼容性

某些PTX指令僅在具有較高計算能力的設備上受支持。例如，Warp Shuffle函數僅在計算能力3.0及以上的設備上受支持。 -arch編譯器選項指定將C編譯為PTX代碼時的計算能力。因此，例如，包含warp shuffle的代碼必須使用-arch = compute_30（或更高版本）進行編譯。

針對某些特定計算能力生成的PTX代碼始終可以編譯為具有更高或相同計算能力的二進制代碼。請注意，從早期的PTX版本編譯的二進製文件可能無法使用某些硬件功能。例如，從為計算能力6.0（Pascal）生成的PTX編譯的計算能力7.0（Volta）的二進制目標設備將不使用Tensor Core指令，因為這些指令在Pascal上不可用。因此，如果二進製文件是使用最新版本的PTX生成的，則最終的二進製文件可能會執行得更差。

#### 3.1.4。應用兼容性

要在具有特定計算能力的設備上執行代碼，應用程序必須加載與此計算能力兼容的二進製或PTX代碼，如二進制兼容性和PTX兼容性中所述。特別是，為了能夠在具有更高計算能力的未來體系結構上執行代碼（尚未生成二進制代碼），應用程序必須加載PTX代碼，該代碼將被即時編譯用於這些設備（Just-in-Time Compilation）。

在CUDA C應用程序中嵌入哪些PTX和二進制代碼由-arch和-code編譯器選項或-gencode編譯器選項控制，詳見nvcc用戶手冊。例如，
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXSN0uSOqSISm1Q07A0fzut7CC82yX813icB6hoqahfPCZcDEVk09l6tvgN7ovuhaxt5BHENiceUxomg/640?wx_fmt=png&wxfrom=5&wx_lazy=1)
嵌入與計算能力3.5和5.0（第一和第二代碼選項）兼容的二進制代碼以及與計算能力6.0（第三代碼選項）兼容的PTX和二進制代碼。
生成主機代碼以在運行時自動選擇要加載和執行的最合適的代碼，在以上示例中，代碼將為：

* 具有計算能力3.5和3.7的設備的3.5二進制代碼，

* 具有計算能力5.0和5.2的設備的5.0二進制代碼，

* 具有計算能力6.0和6.1的設備的6.0二進制代碼，

* PTX代碼在運行時編譯為計算能力為7.0或更高的設備的二進制代碼。

例如，x.cu可以具有使用warp shuffle操作的優化代碼路徑，這些操作僅在計算能力3.0和更高版本的設備中受支持。 __CUDA_ARCH__宏可用於根據計算能力區分各種代碼路徑。它僅為設備代碼定義。例如，當使用-arch = compute_35進行編譯時，__​​CUDA_ARCH__等於350。

使用驅動程序API的應用程序必須編譯代碼以分離文件，並在運行時顯式加載和執行最合適的文件。

Volta體系結構引入了獨立線程調度，它改變了線程在GPU上的調度方式。對於依賴於以前的架構中SIMT調度的特定行為的代碼，獨立線程調度可能會改變參與的線程集合，從而導致不正確的結果。為了在執行獨立線程調度中詳述的糾正措施的同時幫助遷移，Volta開發人員可以使用編譯器選項組合-arch = compute_60 -code = sm_70來選擇加入Pascal的線程調度。

nvcc用戶手冊列出了-arch，-code和-gencode編譯器選項的各種簡寫。例如，-arch = sm_35是-arch = compute_35-code = compute_35，sm_35（這與-gencodearch = compute_35，code = \'compute_35，sm_35 \'相同）的簡寫。

#### 3.1.5 C / C++ 兼容性

編譯器的前端根據C ++語法規則處理CUDA源文件。所有 C++ 代碼皆被 host 支持。但是，如 C / C ++ 語言支持中所述，只有一個 C++ 子集完整被 device 支持。

#### 3.1.6 64位兼容性

64位版本的nvcc以64位模式編譯 device 代碼（即指針是64位）。只有在64位模式下編譯的 host 代碼才支持以64位模式編譯的 device 代碼。

類似地，32位版本的nvcc以32位模式編譯 device 代碼，而以32位模式編譯的 device 代碼僅支持以32位模式編譯的 host 代碼。

32位版本的nvcc也可以使用 `-m64` 編譯器選項在64位模式下編譯 device 代碼。

64位版本的nvcc也可以使用 `-m32` 編譯器選項以32位模式編譯 device 代碼。

>本文备注/经验分享：

 just-in-time compilation缩写为JIT，中文也叫“及时翻译”或者“及时编译”。具体的说法是在即将要被执行前的瞬间被编译。（反义词叫AOT。Ahead Of Time)。从你的角度看，普通编译发生在当下编译者的机器上。JIT编译发生了以后发布给用户，在用户的机器上进行有。或者有一个未来的时间，例如新一代的显卡发布了，因为编译者现在的机器上，在开发的时候，还没有新卡，编译器也不知道未来如何给新卡编译。采用JIT就不怕了，未来的编译器集成在未来的显卡驱动中，到时候在JIT编译即可。这样就解决了时间上的矛盾。而且如果将来有一天，编译器技术发生了进步，JIT编译可以在开发完成后很多年，甚至开发者都已经挂了的情况下（例如团队解散），依然能享受未来的更先进编译技术。因为它不是普通编译那样一次完成的，而是在将来在用户的机器上再即时的完成，所以这就是为何叫“即时编译”（Just in time）


Binary code is architecture-specific,这说的是SASS，SASS（Shader ASSembly的缩写）是每种架构的卡是固定的。为一种卡编译出来的SASS（例如cubin）只能在这种架构的卡上用。不像PTX那样通用。（二进制兼容性就像你的CPU。你的一个exe可能是10年前的。但CPU是今年出的，但这个CPU却依然可以运行当年的exe），GPU只能在PTX级别上保持兼容性，普通的SASS代码不能保持，除非是同一代架构的卡。等于你买了v5的CPU，只能运行v5上编译的exe，不能运行之前的，也不能运行之后的。


PTX Compatibility即PTX兼容性。PTX有几个不同的版本。越往后的驱动或者卡，
支持的PTX版本越高。低版本的PTX写的东西，能在高版本下运行。这样就保持了对老代码的兼容性。而不像是二进制的SASS，一代就只能在一代上运行。不能在老一代上，也不能上新一代上运行。这是SASS或者说二进制发布的最大坏处。PTX可以持续在未来的新卡上运行（JIT么），你可以直接将PTX理解成一种虚拟机和之上的虚拟指令。

  Full C++ is supported for the host code. However, only a subset of C++ is fully supported for the device code 在HOST代码中，具有完整的C++支持（也就是普通的CPU上）； 在DEVICE代码中，只有部分C++（的特性）被完全支持（也就是在GPU上）。


 Device code compiled in 64-bit mode is only supported with host code compiled in 64-bit mode.

 GPU端如果是64-bit，CPU端也必须是。这个看起来很正常，为何要特别说明？？ 因为CUDA 3.2和之前的版本，支持混合模式。允许一部分是64-bit，一部分是32-bit的。 后来发现这对很多人造成了困扰。于是直接要求都必须是统一的了。 这也是CUDA易用性的体验。 例如OpenCL就不要求这点。 所以CUDA可以很容易的将结构体（里面含有各种和字长相关的东西（32-bit或者64-bit）之类的在GPU和CPU上传递。 而OpenCL很难做到这种。

[原文網址](https://mp.weixin.qq.com/s/4YP8gVfV8dcgdm39OwRueQ)

# DAY4 中场休息，看这个印度小哥如何另类解释CUDA和GPU编程
---
[原文網址](https://mp.weixin.qq.com/s/N_AcK7s3JBHdVm2xeNDUaA)

# DAY5 阅读 CUDA C编程接口之CUDA C runtime 
---
### 3.2 CUDA C 運行時
CUDA C 的運行時是在 `cudar` 庫中實現的，它通過cudart.lib或libcudart.a靜態鏈接到應用程序，或者通過cudart.dll或libcudart.so動態鏈接到應用程序。需要cudart.dll和/或cudart.so進行動態鏈接的應用程序通常將它們作為應用程序安裝包的一部分包含在內。

在這兒，所有入口點都以cuda為前綴。
如 Heterogeneous Programming 中所述，CUDA編程模型假設一個由 host 和 device 組成的系統，每個都有自己獨立的記憶體。Device Memory 概述了運行時的方法，用於管理 device 記憶體。

Shared Memory 說明了在線程層次結構中引入的共享內存的使用，以最大限度地提高性能。

Page-Locked Host Memory【鎖頁主機內存】 介紹了將內核執行與 host 和 device 內存之間的數據傳輸重疊所需的頁鎖定主機內存。

Asynchronous Concurrent Execution【异步并发执行】描述了用於在系統中的各個級別啟用異步並發執行的概念和API。

Multi-Device System 顯示編程模型如何擴展到具有連接到同一主機的多個設備的系統。

Error Checking 描述瞭如何正確檢查運行時生成的錯誤。

Call Stack【调用栈】提及用於管理CUDA C調用堆棧的運行時函數

Texture and Surface Memory 呈現紋理和表面存儲空間，提供訪問設備存儲器的另一種方式;他們還暴露了GPU紋理硬件的一個子集。

Graphics Interoperability【图形互操作性】介紹了運行時提供的各種功能，以便與兩個主要的圖形API，OpenGL和Direct3D進行互操作。




### 3.2.1 Initialization【初始化】
運行時沒有明確的初始化函數;它在第一次調用運行時函數時初始化(更具體地說，參考手冊的設備和版本管理部分的功能以外的任何功能)在計時運行時函數調用和從第一次調用運行時解釋錯誤代碼時，需要記住這一點。

在初始化期間，運行時為系統中的每個設備創建 CUDA context （有關CUDA ontext 的更多詳細信息，請參閱 CUDA context ）。context 是此設備的主要 context，它在應用程序的所有主機線程之間共享。作為此 context 創建的一部分，設備代碼在必要時即時編譯（請參閱 Just-in-Time Compilation）並加載到設備內存中。這一切都發生在幕後，運行時不會將主要 context 暴露給應用程序。

當主機線程調用cudaDeviceReset（）時，這會破壞主機線程當前操作的設備的主要 context（即，設備選擇中定義的當前設備）。由此設備作為當前主機線程進行的下一個運行時函數調用將為此設備創建新的主要 context。


#### 3.2.2. Device Memory

正如異構編程中所提到的，CUDA編程模型假設一個由主機和設備組成的系統，每個系統都有自己獨立的內存。內核在設備內存之外運行，因此運行時提供分配，釋放和復制設備內存的功能，以及在主機內存和設備內存之間傳輸數據的功能。


設備存儲器可以分配為線性存儲器或CUDA陣列。

CUDA數組是不透明的內存佈局，針對紋理提取進行了優化。


線性存儲器存在於40位地址空間中的設備上，因此單獨分配的實體可以通過指針相互引用，例如，在二叉樹中。

線性存儲器通常使用cudaMalloc（）分配，並使用cudaFree（）釋放，主機存儲器和設備存儲器之間的數據傳輸通常使用cudaMemcpy（）完成。在內核的向量加法代碼示例中，向量需要從主機內存複製到設備內存：
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTfgWC2tP0BNvcqSNqNzX3nqbMFcMc0CKAdfS5AfIgGVlz7BkZd038EGictsiaECFIftjzU4eTz0QJQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1)
![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTfgWC2tP0BNvcqSNqNzX3nicsDBGNrY6zmzRUVmFW6MsmRDX9Y7BfjleI1B9Sf9FYq8zbxbEicYXow/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

線性存儲器也可以通過cudaMallocPitch（）和cudaMalloc3D（）分配。建議將這些函數用於2D或3D陣列的分配，因為它確保分配被適當填充以滿足設備存儲器訪問中描述的對齊要求，從而確保在訪問行地址或在2D陣列與其他區域之間執行複制時的最佳性能設備內存（使用cudaMemcpy2D（）和cudaMemcpy3D（）函數）。返回的音高（或步幅）必須用於訪問數組元素。以下代碼示例分配一個寬度x高度的浮點值2D數組，並顯示如何在設備代碼中循環數組元素：

![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTfgWC2tP0BNvcqSNqNzX3nwkEVLTNevosib6SfNFxJXbyBZmAiaZ3zyHTSU5wYkAMcHEiblXUFYTVCw/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

以下代碼示例分配寬度x高度x深度3D浮點值數組，並顯示如何在設備代碼中循環數組元素：

![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTfgWC2tP0BNvcqSNqNzX3nCXnoLt8rjff9kNtCibua45nicRGCvyxKkxojjTWibYPxuAib1EISnPdTrA/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

`cudaGetSymbolAddress() ` 是用來返回一個全域變數的記憶體位置，而其記憶體大小則通過 `cudaGetSymbolSize()` 索取。

#### 3.2.3 Share Memory
如 = Variable Memory Space Specifiers = 中所描述的，共享內存是使用 `__shared__`  說明符分配的。

共享內存預計比全局內存快得多，如線程層次結構中所述並在共享內存中詳細說明。因此，應該利用共享存儲器訪問替換全局存儲器訪問的任何機會，如以下矩陣乘法示例所示。

下面的代碼示例是矩陣乘法的簡單實現，它不利用共享內存。每個線程讀取A的一行和B的一列，併計算C的相應元素，如圖9所示。因此讀取B.從全局存儲器讀取B.寬度，讀取B的時間為A.高度時間。

![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTfgWC2tP0BNvcqSNqNzX3nntHqlFS7sKq3rcOgaOD1K7352W1WacUAhGicibSKvz6XFOVffvmicB1Lw/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTfgWC2tP0BNvcqSNqNzX3nCzKPqvHxxdlQK2dbqjft3Zj9JtUXibMLSyQfCaQuW93NFL8nxcpVAhA/640?wx_fmt=png&wxfrom=5&wx_lazy=1)

Figure 9. Matrix Multiplication without Shared Memory

![](https://mmbiz.qpic.cn/mmbiz_png/X0xSWHRkgXTfgWC2tP0BNvcqSNqNzX3nU7NAj8aupxwyLFlUSJrTlRWymKGNrRg6TjXqrMIjBfm5mStZqrZ8oQ/640?wx_fmt=png&wxfrom=5&wx_lazy=1)











[原文網址](https://mp.weixin.qq.com/s/b1TlC4wm52h29LcjtD_1iQ)