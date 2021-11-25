---
title: Tensorflow-GPU 環境配置
date: 2019-01-13 22:05:43
tags:
- 機器學習
- TensorFlow
- GPU
categories: 機器學習
thumbnail: https://i.imgur.com/dRnyRMm.png
---


# Tensorflow-GPU 環境配置

`Author`：[William Mou](https://t.me/WilliamMou)
[點我進入個人 Blog](https://william-mou.github.io/)

## 前言
:::info
AI 發展日新月異，各軟硬體更是推陳出新，而其中 Tensorflow 與其依賴的 CUDA 更是當今潮流，但兩者版本卻多不互相兼容，常常有各種 Bug 。

故，今天實作一篇安裝成功的例子，盡可能完整的陳述相關知識，以及所需注意的地方；供大家參考與共同學習。若有任何不恰當或錯誤的地方，都煩請您聯絡作者修改，共同進步。
:::

## 需求
:::success
安裝前，須先明瞭自己對於開發（~~潔癖~~）需求，以個人為例，我希望能夠在 `VScode` 中用 `shift + enter` run `conda env` 裡的 `tensorflow-gpu` with `Cuda9` and `Cudnn7` 

---
以清單表示：
| |細項|
|---|--------------|
|硬體|GeForce GTX 1080Ti|
|系統|Windows10 專業版|
|框架|Tensorlfow-GPU 1.9|
|版本|`CUDA 9` & `cuDNN 7.5`|
|環境|`python3.5` conda(`Anaconda`) env|
|編輯器|Visual Stusio code|
:::

## 正文
### 安裝 CUDA
:::info
定義：

`CUDA` 是由 NVIDIA 所推出的一種整合技術，在其製造的圖形處理單元（GPUs）之上，實現平行計算平臺與程式設計模型。透過這個技術，開發人員可了直接存取 `CUDA GPUs` 中的虛擬指令集和平行計算元件的記憶體，運用 NVIDIA GeForce 8 以後的 GPU 和較新的 Quadro GPU 進行並行計算。 
> [name=[取自wiki](https://zh.wikipedia.org/wiki/CUDA)]


> 作者案：
>
> 你可以將它看作是 NVIDIA 顯示卡專用的平台，讓開發者更輕鬆的以 CUDA C 或 OpenCL 撰寫代碼，並透過 `CUDA` 最終被驅動程式轉換成PTX代碼，交由顯示核心計算。
> 
> 這種方法與 `CPUs` 不同的是， `GPUs` 有著側重以較慢速度執行大量併發執行緒的並行流架構，而非快速執行單一執行緒。擅長運算「小」而「多」的數據資料，尤其是圖像運算更是在行。
> 
> 但這並不表示在相同的花費下，使用 GPU 訓練 AI 一定會比使用 CPU 來的有效益，端看數據的資料大小及其特性，有時候數台 Xeon 系列的 CPU 多核運算，會比 GPU 來的快或節省經費。
:::

:::success
綜合上述，要在 Windows 平台安裝 CUDA ，我們需要準備一些其所需要的軟體，包括以下：

* [Visual Studio 2017](https://visualstudio.microsoft.com/zh-hant/?rr=https%3A%2F%2Fwww.google.com%2F)
    * 用以編寫 CUDA 代碼，若無需求可不安裝。

        ![](https://i.imgur.com/tZTiujI.png)
        
    * 安裝時，至少勾選 使用 C++ 的桌面開發
        ![](https://i.imgur.com/XnI4BLd.png)

        
    * 並且安裝位置建議放在 C:\ （系統磁碟機）

        > 作者案：
        >
        > Visual Studio IDE 有時候會有版本未識別錯誤的訊息，例如 [CUDA 9 failed to support the latest Visual Studio 2017 version 15.5](https://devtalk.nvidia.com/default/topic/1027299/cuda-setup-and-installation/cuda-9-failed-to-support-the-latest-visual-studio-2017-version-15-5/) 可透過修改版本代號的方式解決

* [顯示卡驅動程式](http://www.nvidia.com.tw/Download/index.aspx?lang=tw)
    * 依照自己的顯示卡型號下載
        ![](https://i.imgur.com/XP5YraM.png)
        > 作者案：
        >
        > 務必注意自己得硬體型號，若不確定可以使用 NVIDIA 開發的工具 [NVIDIA GPU Reader](http://www.nvidia.com.tw/object/gpureader-faq-tw.html) 辨識
        
    * 以下提供安裝示意圖
    
        ![](https://i.imgur.com/83ajtNT.png)
        
        ![](https://i.imgur.com/dRnyRMm.png)

        ![](https://i.imgur.com/gExA7WB.png)
        
        ![](https://i.imgur.com/NMqqrft.png)

        ![](https://i.imgur.com/U5kyKT9.png)

:::

接著，要來安裝本節主角： `CUDA` 與 `cuDNN`
:::danger
CUDA 的版本較多，而每個版本有自己所對應的 cuDNN （將在下節介紹），為此，我們必須選定好適當的版本號，並謹記在心，以對應恰當的 Tensorflow 與 cuDNN。

建議各位在安裝前，可以去搜尋看看他人 Tendsorflow 與 CUDA 配對成功的版本，而這裡提供[ 其他作者 ](https://developer.nvidia.com/cuda-90-download-archive?target_os=Windows&target_arch=x86_64&target_version=10&target_type=exenetwork)已經測試成功的案例：

* tensorflow 1.4 及以下的不支持高於 CUDA 9.0 。
* tensorflow 1.0 及以上的不支持低於 CUDA 8.0 。
* tensorflow-gpu 1.5 以上不支持使用 CUDA 8.0。

而本節，以 Tensorflow 1.9 與 CUDA 9.0 做為安裝範例。

:::

:::success
首先，前往 NVIDIA 開發者的官網，下載 CUDA [ 連結點我 ](https://developer.nvidia.com/cuda-90-download-archive?target_os=Windows&target_arch=x86_64&target_version=10&target_type=exenetwork)

![](https://i.imgur.com/xkYZm4J.png)

點選相對應的版本後，下載 Base Installer。

雙擊執行檔案 `cuda_9.0.176_win10_network.exe` 開始安裝
![](https://i.imgur.com/r6R9Mml.png)

![](https://i.imgur.com/ibn7qDE.png)

在檢查系統系統相容性與合約後
![](https://i.imgur.com/2rKFFGp.png)

![](https://i.imgur.com/rABqW3n.png)

會進入安裝選項，建議可以直接快速安裝。
![](https://i.imgur.com/kIauEYD.png)

> 作者案
> 
> 若沒有要使用Visual Studio 2017 編譯 CUDA 的朋友，可以進入自訂安裝中修改設定，將 Visual Studio Integration 關閉，避免報錯。
![](https://i.imgur.com/kBdt4uo.png)
:::warning
若仍然遇到 安裝失敗的情形
![](https://i.imgur.com/1ArZxqd.png)
建議可至 [這篇博客](https://blog.csdn.net/zzpong/article/details/80282814) 依照步驟解決，本文便不多贅述。
:::


### 安裝 cuDNN 

:::info
定義：

`cuDNN` 全名為：`NVIDIACUDA®深度神經網絡庫` 是用於 [`深度神經網絡` ](https://developer.nvidia.com/deep-learning)的GPU加速庫。 cuDNN為標準例程提供高度調整的實現，例如卷積，池化，規範化和激活層。而 cuDNN 同時也是 NVIDIA [`深度學習SDK`](https://developer.nvidia.com/deep-learning-sdk) 的一部分。

全球深度學習研究人員和框架開發人員依靠 `cuDNN` 實現高性能 GPU 加速。它允許他們專注於訓練神經網絡和開發軟件應用程序，而不是花時間在低級 GPU 性能調適上。 `cuDNN` 加速了廣泛使用的深度學習框架，包括 `Caffe2`，`MATLAB`，`Microsoft Cognitive Toolkit` ， `TensorFlow` ， `Theano` 和 `PyTorch` 。

> 作者案
> 
> 作為 CUDA 的一個深度學習加速庫， cuDNN 的版本必須配合 CUDA 才能正常運行。下面我們將演示如何正確的安裝 cuDNN 。
:::

:::success
首先，前往 NVIDIA DEVELOPER 官網，點擊下載 cuDNN。
![](https://i.imgur.com/ax7yK8d.png)
註冊或登入
![](https://i.imgur.com/71PUOCC.png)
![](https://i.imgur.com/tFAZcmn.png)
跳轉至下載頁面
![](https://i.imgur.com/J1kMlp3.png)
勾選同意後，會跳出版本選擇
![](https://i.imgur.com/qDuWVWk.png)
此處，我們可以選擇適合的 CUDA 版本、與作業系統進行下載
![](https://i.imgur.com/XW0Nim8.png)
> 作者案
> 
> 此處選擇 CUDA 9.0 ，以應對上方我們所安裝的版本。

下載後開啟
![](https://i.imgur.com/0lPKvVp.png)

解壓縮檔案
![](https://i.imgur.com/O1NN2Bx.png)

之後會得到一個 CUDA 資料夾，分別含有 `bin` 、 `include` 、 `lib` 三個資料夾
![](https://i.imgur.com/jWvCji7.png)

將其內部的檔案，分別移至 `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v9.0` 路徑下的對應資料夾中
![](https://i.imgur.com/skQndsU.png)

例如： `bin` 裡面，需包含 `cudnn64_7.dll`
![](https://i.imgur.com/sZQryQw.png)

再分別將三個資料夾的檔案拖移至對應的位置後，
我們要將下列路徑加入環境變數中，以利將來調用

* C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\bin
    ![](https://i.imgur.com/njhoU1h.png)
* C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\lib\x64
    ![](https://i.imgur.com/YgUysjH.png)


打開控制台→系統及安全性→進階系統設定→進階→環境變數（或是直接在控制台中搜尋 PATH）
尋找「系統變數」中「Path」的部份並用左鍵雙擊，新增下述變數：
* C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\bin
* C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\lib\x64
![](https://i.imgur.com/56azOht.png)

到此為止， cuDNN 的安裝就到一段落了
:::

### 安裝 Anaconda 
:::info
Anaconda 是一種 Python 語言的免費增值開源發行版，用於進行大規模數據處理, 預測分析, 和科學計算, 致力於簡化包的管理和部署。Anaconda 使用 軟體包管理系統 Conda 進行包管理。
> [name=[取自wiki](https://zh.wikipedia.org/wiki/Anaconda_(Python%E5%8F%91%E8%A1%8C%E7%89%88))]

> 編者案
> 
> 使用 Anaconda 的好處是他擁有豐富的套件包與良好的套件管理，在資源（硬碟）足夠的情況下，安裝它可以為我們省去很多套件相關的麻煩。
> 
> 而其安裝過程較為簡單，唯一需要的注意的是，關於 Python 的 PATH 是否與電腦內存在的（例如：Visual Studio 自帶的 Python、 或是原生的 Python）產生衝突，若為第一次安裝則沒有這個問題。

而關於使用方式， wiki 寫得相當清楚，下方引用列出。
* 使用時，可以點擊啟動相應的編程環境：
```
    Python(shell) ： 標準CPython
    IPython(shell)： 相當於在命令窗口的命令提示符後輸入ipython回車。pip install ipython安裝的ipython用法一樣。
    Ipython QTConsole
    IPython Notebook：直接點擊打開，或者在命令提示符中輸入ipython.exe notebook
    Jupyter QTConsole
    Jupyter Notebook：直接點擊打開，或在終端中輸入： jupyter notebook 以啟動伺服器；在瀏覽器中打開notebook頁面地址：http://localhost:8888 。Jupyter Notebook是一種 Web 應用，能讓用戶將說明文本、數學方程、代碼和可視化內容全部組合到一個易於共享的文檔中。
    Spyder：直接點擊打開IDE。最大優點就是模仿MATLAB的「工作空間」
    Anaconda Prompt ： 命令行終端
    支持其他IDE，如Pycharm
```

* 安裝包管理：
```
    列出已經安裝的包：在命令提示符中輸入pip list或者用conda list
    安裝新包：在命令提示符中輸入「pip install 包名」，或者「conda install 包名」
    更新包： conda update package_name
    升級所有包： conda upgrade --all
    卸載包：conda remove package_names
    搜索包：conda search search_term
```
* 管理環境：
```
    安裝nb_conda，用於notebook自動關聯nb_conda的環境
    創建環境：在Anaconda終端中 conda create -n env_name package_names[=ver]
    使用環境：在Anaconda終端中 activate env_name
    離開環境：在Anaconda終端中 deactivate
    導出環境設置：conda env export > environmentName.yaml 或 pip freeze > environmentName.txt
    導入環境設置：conda env update -f=/path/environmentName.yaml 或 pip install -r /path/environmentName.txt
    列出環境清單：conda env list
    刪除環境： conda env remove -n env_name
```
:::

:::success
首先，我們進入 [Anaconda 官方網站](https://anaconda.org/)，並點擊右上方的 [Download Anaconda](https://www.anaconda.com/downloads)。
![](https://i.imgur.com/zrtBsB7.png)

選擇 Python3.6 64-bit版本
![](https://i.imgur.com/0ZlZeVf.png)

下載完成後雙擊安裝，以下為安裝過程截圖
![](https://i.imgur.com/MohCChL.png)

![](https://i.imgur.com/9i8xbDT.png)

![](https://i.imgur.com/VybIu3w.png)

![](https://i.imgur.com/zqy3Zxq.png)

![](https://i.imgur.com/iGTNwAt.png)
可將兩者一併勾選，省去設定的麻煩
![](https://i.imgur.com/L7bxcrW.png)


安裝完成後，我們可以打開 Anaconda prompt 創建環境
![](https://i.imgur.com/X04H5Zp.png)

前面`()`表示我們當前的環境，我們需要創造一個專屬於 tensorflow 的環境，以免套件彼此間相互干擾，連跟新個版本都要綁手綁腳的。
![](https://i.imgur.com/tBq18aX.png)

依照 wiki 所說，我們可以使用
`conda create -n env_name package_names[=ver]`
來創建一個環境。


> 編者案
> 
> 由於電腦已創建過 tensorflow 環境，所以截圖中的命名會多一個 -t 避免衝突

輸入
```shell=
$ conda create -n tensorflow python=3.5
```
![](https://i.imgur.com/8eoOPt7.png)

他會提示你你的環境將放在何處。
![](https://i.imgur.com/qKDX0jp.png)

輸入 Y　進行環境創建，他會預先幫你安裝一些套件
![](https://i.imgur.com/4DOCufs.png)

環境創建完成，依照命令行提示，你的環境被套件被放在 `C:\Users\willi\Anaconda3\pkgs\wheel-0.31.1-py35_0` ，可以輸入 `conda activate` 指令來進入環境，輸入 `conda deactivate` 來離開環境
![](https://i.imgur.com/b1YWVuT.png)


接著我們進入環境
```shell=
$ conda activate tensorflow
```
![](https://i.imgur.com/s126Kvn.png)

使用以下指令來安裝 tensorflow
```shell=
$ pip install tensorflow
# 或者
$ conda install tensorflow
```

> 編者案
>  
> 若有開發需求，可以如以下方式指定 tensoeflow 版本
>```shell=
># 移除舊有版本
>$ pip uninstall tensorflow-gpu==1.3.0
># 安裝指定版本
>$ pip install tensorflow-gpu==1.5.0
>```

安裝完成
![](https://i.imgur.com/LFL5aag.png)

使用 import 來檢驗是否安裝正確
```shell=
$ python
# 進入 python 互動介面後
>>> import tensorflow as tf
```
![](https://i.imgur.com/vxx6bb3.png)

隨後逐行複製以下代碼，檢測是否正常運行 GPU 
```python
import tensorflow as tf
# Creates a graph.
a = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[2, 3], name='a')
b = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[3, 2], name='b')
c = tf.matmul(a, b)
# Creates a session with log_device_placement set to True.
sess = tf.Session(config=tf.ConfigProto(log_device_placement=True))
# Runs the op.
print(sess.run(c))
```
運行成功應該如圖，輸出運行之顯示卡序號 
```
GPU 0
``` 

與運算結果
```
[[22. 28.]
 [49. 64.]]
 ```
 
![](https://i.imgur.com/UUCdhsb.png)

:::

### 安裝 Visual Stduio Code
:::info
Visual Studio Code（簡稱VS Code）是一個由微軟開發的，同時支援Windows、Linux和macOS作業系統且開放原始碼的文字編輯器。它支援偵錯，並內建了Git 版本控制功能，同時也具有開發環境功能，例如代碼補全（類似於 IntelliSense）、代碼片段、代碼重構等。該編輯器支援用戶自訂配置，例如改變主題顏色、鍵盤捷徑、編輯器屬性和其他參數，還支援擴充功能程式並在編輯器中內建了擴充功能程式管理的功能。 
> [name=[取自wiki](https://zh.wikipedia.org/wiki/Visual_Studio_Code)]

> 作者案
> 
> 作為一門編輯器， VS Code 具有跨平台、輕量、擴展性高等優點，使用容易上手，功能雖多卻不會像 Visual Studio 般繁亂，是個老少咸宜的好軟體。
:::


:::success
首先，前往 [VS Code官網](https://code.visualstudio.com/) 下載之
![](https://i.imgur.com/FNMsK22.png)

之後全勾安裝後打開，可以得到如下畫面
![](https://i.imgur.com/dK5QRKC.png)

我們可以先至你想要編輯的資料夾，此處以這個 `ai` 資料夾為例
![](https://i.imgur.com/c8baJoW.png)

右鍵點擊 Open with Code
![](https://i.imgur.com/J88XiPS.png)

之後 VS Code 就會將此資料夾作為一個工作區，在 VS Code 中開啟

![](https://i.imgur.com/qkFRkWC.png)

之後點擊紅框處的新增檔案，創建一個測試用的 .py 檔。
![](https://i.imgur.com/TpontF8.png)

接著，將以下 tensorflow 官方測試代碼複製到檔案內。
```python=
import tensorflow as tf

class SquareTest(tf.test.TestCase):
    def testSquare(self):
        with self.test_session():
            x = tf.square([2, 3])
            self.assertAllEqual(x.eval(), [4, 9])

if __name__ == '__main__':
    tf.test.main()
    
```

此時，因為你所處的環境是 Anaconda 預設的環境中，並不包含 tensorflow 套件，所以會報錯。
![](https://i.imgur.com/B7Yhl5I.png)

我們可以點選左下角的選項，以察看與切換環境
![](https://i.imgur.com/khsatxX.png)

點擊後，我們可以切換到到方才設定的環境 `tensorflow`
![](https://i.imgur.com/txN496l.png)

此時，我們可以注意到右下角的 `pylint` 以及諸如此類的提示，可以選擇安裝他們，讓開發更加順利。
![](https://i.imgur.com/DJPVpvE.png)

下方命令行會自動打開，並顯示已成功安裝。
![](https://i.imgur.com/ncoTa19.png)

接著，點選左邊的紅框處，然後按下綠色三角形箭頭偵錯
![](https://i.imgur.com/xnUzPAV.png)

選擇 Python
![](https://i.imgur.com/j9tAa0i.png)

若得到以下畫面則代表設定與安裝順利
![](https://i.imgur.com/6JsdFE1.png)

之後也可以使用 F5 來偵錯。
但若有其他慣用偵錯快捷鍵，可以透過 `Ctrl` + `Shift` + `P` ，搜尋開啟鍵盤快速鍵
![](https://i.imgur.com/DU6BhQV.png)
或是使用 `Ctrl` + `K` 緊接著按 `Ctrl` + `s` 來開啟
![](https://i.imgur.com/q8PEtym.png)

接著上方欄位中搜尋 F5
![](https://i.imgur.com/TVSrbti.png)

點選左邊的小鉛筆，再輸入你想要的鍵盤快捷鍵後按 `Enter` 就大功告成囉。
![](https://i.imgur.com/IjnukA4.png)

:::

## 結語
希望讀者都能夠在本筆記中學到想學習的東西，也恭喜您成功設定完成 Tensorflow 的基礎設定，但 AI 的學習如同汪洋大海般，遠不只如此，僅此希望能夠帶給您一個好的開始與學習體驗，持之以恆，努力前進。共勉之。

:::warning
若對於此筆記有任何錯誤、或是沒有詳盡提到的地方，都非常期待您與我聯絡，能與您的共筆是我的榮幸。歡迎將更多的建議寫在其他 HackMD 中，我將以連結的方式將其引入；或是將建議寄送到我的信箱： william.mou960174@gmail.com 。
:::

## 其他參考資料
https://blog.csdn.net/LOVE1055259415/article/details/80343932
https://zhuanlan.zhihu.com/p/30324113
https://rreadmorebooks.blogspot.com/2017/04/win10cudacudnn.html
https://zhuanlan.zhihu.com/p/37086409