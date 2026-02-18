---
title: ISC23 歐洲行 - 賽前準備及旅遊安排
date: 2026-02-18 16:34:23
tags:
categories:
thumbnail: /img/ISC23-Europe-pre-competition_files/image_b.png
---
   
沒想到人生第一次踏上歐洲，竟是跟著清大超算團隊出國參加競賽！舉辦這次競賽的是 ISC High Performance 德國超高速運算電腦展會底下的 HPC-AI ADVISORY COUNCIL，由於 ISC 及該主辦單位並不提供參賽隊伍住宿與機票補助，清大超算團隊過往不會主動報名歐洲的 ISC 比賽，通常只有在 HPC-AI 線上賽或 SCC 奪得冠軍的隊伍，才會因為獲得主辦方正式邀請前往參賽。   
   
這次有幸能參加 ISC23 主要是因為我們在 SC22 獲得冠軍獲得保障名額，如同前段所說，我們並不預期自己的超算生涯中會前往歐洲參賽，因此這次參賽對我們來說有點畢業旅行的感覺。總之，願我們都能享受比賽、享受旅行。
   
## 比賽前   
行程分為兩部分   
- 2023/05/20-2023/05/25 ISC23 現場比賽 - 德國漢堡   
- 2023/05/25-2023/06/03 賽後旅行 - 超算畢業旅行   
   
   
### 比賽規則   
學生叢集競賽是一場結合高效能運算 (HPC) 硬體建置與軟體效能調校的綜合性挑戰。參賽團隊必須在嚴格的 4500W 電力功耗限制下，平衡硬體耗電與運算效率，從零開始構建一套足以支撐大規模科學模擬的運算系統。   
競賽題目設計兼顧了「研究開發」與「臨場應變」。除了一項秘密題目 (Mystery Application) 外，其餘三項題目皆於賽前數個月公布，讓團隊有充足時間進行硬體選型、軟體安裝與初步優化。   
|                  **題目類別** |             **應用程式名稱** |                                                                                                                                                   **技術特徵與挑戰** |                             **評分關鍵** |
|:--------------------------|:-----------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------|
|             **A. 電子結構計算** |   **Quantum ESPRESSO** |                                                                                                                基於密度泛函理論 (DFT) 的開源平行程式，考驗選手在叢集上對材料建模模擬的效能優化能力。 |                            執行時間、面試表現 |
|              **B. 流體動力學** |             **FluTAS** |                                                                                                                         針對多相流體模擬的框架，支持跨 CPU 與多 GPU 的高效能模組化運作。 |                   指定 Timestamp 之執行速度 |
|             **C. 太陽磁場模擬** |              **POT3d** |                                                                                            使用 MPI 與 HDF5，並結合 **OpenACC** **cuSparse** 進行 GPU 加速，處理光球磁場邊界條件計算。 |                         完成磁場模擬，越快越高分 |
|               **D. 秘密題目** |     **MILC (Mystery)** |                                                                                                       比賽現場方才揭曉題目。參賽隊伍必須在有限時間內，針對現場機器環境進行**即時編譯與優化**，挑戰臨場活用能力。 |                         完成現場模擬，越快越高分 |

![我們會在這樣的 Booth 內比賽，伺服器機櫃及所有參賽隊員都需要在這裡面，一起在這裡拼搏兩天](/img/ISC23-Europe-pre-competition_files/image.png)   
### 初賽分工   
就和每一次超算比賽一樣，我們進行題目的分工，共有三題：   
- System： [Yi Kuo](yi-kuo.md) 、 [William Mou](william-mou.md)    
- POT3D： [William Mou](william-mou.md) 、 [黃恩明](huang-en-ming.md)    
- FluTAS： [丁緒慈](ding-xu-ci.md) 、 [Yi Kuo](yi-kuo.md)    
- QE： [張富強](zhang-fu-qiang.md) 、 [翁君牧](weng-jun-mu.md)    
   
> 以下為技術內容，非作戰人員建議跳到「出國前準備」
   
### System   
這次我們使用的是 A100 \* 4 的機器，共計 4 台，透過 Infniband 高速網路連接，大致上與 SC22 相同，裝機後要執行 HPL、HPCG 等常見的 Benchmark 軟體，需要使用一些 binding 相關的知識來加速，由於已經是我參與過的第三場國際比賽了，大致上沒什麼特別的，這次許多任務也轉交給比我更擅長系統管理的 [Yi Kuo](yi-kuo.md) ，更是讓他體驗了一把 HPL 驚心動魄的功耗挑戰。   
![系統安裝滿需要經驗及練習，但由於設備十分昂貴，我們常常都在比賽當場才碰到真機，因此更考驗臨場學習及應變的能力。安裝之後便是執行系統跑分，要注意功耗不能超過主辦單位的限制](/img/ISC23-Europe-pre-competition_files/image_g.png)   
### POD3D   
【科學角度】POT3D（Potential Field Solver in 3D）用於計算以觀測到的光球磁場作為邊界條件，近似太陽冠磁場的電位場解。它可用於生成電位場源面（PFSS）、電位場電流片（PFCS）和開放磁場（OF）模型。    
![](/img/ISC23-Europe-pre-competition_files/image_4.png)    
[https://iopscience.iop.org/article/10.3847/1538-4357/abfd2f/pdf](https://iopscience.iop.org/article/10.3847/1538-4357/abfd2f/pdf)    
【資工角度】使用老朋友 Fortran 撰寫，CUDA-aware MPI 和 OpenACC 進行多節點多 GPU 加速，同時也提供使用 NVIDIA cuSparse 庫的選項。輸入/輸出使用 HDF5 文件格式。   
【評分方式】：比賽單位提供了一組測資，用以模擬及計算磁場，時間越短的隊伍分數越高。   
    
我主要花時間在做 System 以及 Library 的安裝、測試和性能分析，主要發現了 UCX 和 NVHPC 分別對 P2P 和 All Reduce 有更好的性能。既然是成熟的大人了，那就是「我全都要」，追根究底後發現，NVHPC 的 P2P 性能較差是因為 NVHPC 選到了比較爛的 cu API，而 UCX 在 All reduced 性能較差是因為 UCX 在用 gcc 編譯時會有一個 Bug 導致 UCT Layer 沒有正常識別，在更換成 Intel Compiler recompile UCX 後 All reduced function 從 2.6ms 縮減至 1ms。這個問題在隔年被我衍伸、出題成了清大平行程式課程的作業。   
   
 [黃恩明](huang-en-ming.md) 專注在使用 Nsight Compute 觀察 GPU 計算及溝通 pattern，在得知這是一個 memory bounded 且 L1/L2 Cache miss rate 較高的程式後進行一波瘋狂優化，包含手動為目標 GPU A100 指定適合的 Threads Block Size、改善 dimension 及 rank 的排列組合以符合 Communication Pattern，大幅降低 Communication Overhead，使在 3 nodes scalability 變得很好，性能提升 19%   
   
最後不得不提到，如果改使用 NVIDIA 提供的 Library `cuSparse`  上述的性能問題大部分都會被 `cuSparse` 優化好，所以說有 NVIDIA 內部的 CUDA 大師做好的 Library 用還是用原廠的省時省力。這次會需要這麼多手動優化是因為在比賽前大會禁止我們使用 POT3D `cuSparse` 版本的 code。   
![](/img/ISC23-Europe-pre-competition_files/image_f.png)    
   
### 出國前準備   
由於幾乎是美國比賽的原班人馬，再加上這次我也沒斷腳，出國準備變得十分有經驗且輕鬆，逐條檢查要帶出國的物資，節儉持家的用 SC22 就用過的郵局紙箱和 Uber Eats 袋子（後來在歐洲破掉了，Uber Eats 這品質扛不住兩次出國，反觀郵局紙箱至今還在使用），再次將哩哩扣扣準備帶到歐洲。   
   
![比賽雜物整理好，之後要分裝到大家的行李箱](/img/ISC23-Europe-pre-competition_files/image_l.png)   
![經過這麼多場比賽，郵局箱子永遠值得信任](/img/ISC23-Europe-pre-competition_files/image_d.png)   
![伺服器都用 CR2032 電池，20表示直徑，32表示厚度](/img/ISC23-Europe-pre-competition_files/image_y.png)   
![參賽經驗豐富的人，在比賽前心態都很穩](/img/ISC23-Europe-pre-competition_files/image_s.png)   
   
### 行前旅行規劃   
為了在賽後也能玩得盡興，我自認精心地規劃了一場歐洲自由行。現在回想起來，第一次去歐洲自助、在沒什麼經驗的情況下，憑著一股熱血，行李收一收、火車票看好（甚至沒有訂）就出發了，真的覺得我們當時挺大膽的！以下是我們做的所有規劃，礙於我們都是窮學生，全程盡可能節省開銷：   
   
**機票**   
|                           **航空公司** |         **航班號碼** |                    **航段 (起點 → 終點)** |         **執飛機型** |
|:-----------------------------------|:-----------------|:------------------------------------|:-----------------|
|          **中華航空 (China Airlines)** |            CI921 |                 台北 (TPE) → 香港 (HKG) |  Airbus A330-300 |
|             **德國漢莎航空 (Lufthansa)** |            LH797 |               香港 (HKG) → 法蘭克福 (FRA) |  Airbus A340-300 |
|             **德國漢莎航空 (Lufthansa)** |              LH6 |               法蘭克福 (FRA) → 漢堡 (HAM) |   Airbus A319neo |
|             **德國漢莎航空 (Lufthansa)** |            LH772 |                慕尼黑 (MUC) → 曼谷 (BKK) |  Airbus A380-800 |
|                 **長榮航空 (EVA Air)** |             BR68 |                 曼谷 (BKK) → 台北 (TPE) | Boeing 777-300ER |

**行程**   
- 漢堡 → 柏林 → 布拉格 → CK → 薩爾斯堡 → 國王湖 → 新天鵝堡 → 慕尼黑   
- Hamburg → Berlin → Prague → Český Krumlov → Salzburg → Königssee → Neuschwanstein → Munich   
![住宿方式整理](/img/ISC23-Europe-pre-competition_files/image_b.png)   
| 地點 | 日期 | 住宿點 |
|:---|:---|:---|
| 漢堡 | 5/25 | [4+4, 138€ per room](https://www.agoda.com/zh-tw/a-o-hamburg-hauptbahnhof_9/hotel/hamburg-de.html?locale=zh-tw&ckuid=0d559a0f-8d11-4c12-8394-daef0ac75214&prid=0&currency=EUR&correlationId=9da4a767-0bc0-4932-91be-cdbc4e8e838b&analyticsSessionId=8445145596491847804&pageTypeId=7&realLanguageId=20&languageId=20&origin=TW&cid=1844104&userId=0d559a0f-8d11-4c12-8394-daef0ac75214&whitelabelid=1&loginLvl=0&storefrontId=3&currencyId=1&currencyCode=EUR&htmlLanguage=zh-tw&cultureInfoName=zh-tw&machineName=hk-pc-2g-acm-web-user-66b6767645-6frc6&trafficGroupId=1&sessionId=brqk21jnvgmpnju5oqjxl5hx&trafficSubGroupId=84&aid=130589&useFullPageLogin=true&cttp=4&isRealUser=true&mode=production&browserFamily=Chrome&checkIn=2023-05-25&checkOut=2023-05-27&rooms=2&adults=8&childs=0&priceCur=EUR&los=2&textToSearch=A&O漢堡中央火車站飯店&productType=-1&travellerType=3&familyMode=off)  [2+2+2+2, 135€ per room](https://www.agoda.com/zh-tw/ibis-budget-hamburg-st-pauli-messe_2/hotel/hamburg-de.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=8&children=0&rooms=4&maxRooms=0&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&isCityHaveAsq=false&los=2&searchrequestid=7afb9a26-6727-4d2c-9a58-3f75022d9331&checkin=2023-05-25)  [2+2+2+2, 145€ per room](https://www.agoda.com/zh-tw/holiday-inn-hamburg/hotel/hamburg-de.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=8&children=0&rooms=4&maxRooms=0&checkIn=2023-05-25&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&isCityHaveAsq=false&los=1&searchrequestid=7afb9a26-6727-4d2c-9a58-3f75022d9331)  [2+2+2+2, 147€ per cab](https://www.agoda.com/zh-tw/cab20/hotel/all/hamburg-de.html?locale=zh-tw&ckuid=0d559a0f-8d11-4c12-8394-daef0ac75214&prid=0&currency=EUR&correlationId=2f4aea39-d932-428c-afb6-576937921bd9&analyticsSessionId=8445145596491847804&pageTypeId=7&realLanguageId=20&languageId=20&origin=TW&cid=1844104&userId=0d559a0f-8d11-4c12-8394-daef0ac75214&whitelabelid=1&loginLvl=0&storefrontId=3&currencyId=1&currencyCode=EUR&htmlLanguage=zh-tw&cultureInfoName=zh-tw&machineName=hk-pc-2f-acm-web-user-64fdf96858-m8blp&trafficGroupId=1&sessionId=brqk21jnvgmpnju5oqjxl5hx&trafficSubGroupId=84&aid=130589&useFullPageLogin=true&cttp=4&isRealUser=true&mode=production&browserFamily=Chrome&checkIn=2023-05-25&checkOut=2023-05-26&rooms=4&adults=4&childs=0&priceCur=EUR&los=1&textToSearch=CAB20&productType=-1&travellerType=3&familyMode=off)  [✅ 2+2+2+2, 188€ per room](https://www.agoda.com/zh-tw/courtyard-hamburg-city/hotel/hamburg-de.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=8&children=0&rooms=4&maxRooms=0&checkIn=2023-05-25&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&isCityHaveAsq=false&tspTypes=2&los=2&searchrequestid=ce4ffa39-2cc4-4b5a-915f-75a1856c3be2) |
| 漢堡 | 5/26 | 同上 |
| 漢堡 | 5/27 | [✅ Urban, 1 room, 522€](https://www.agoda.com/schulterblatt-apartments-hamburg-unit-3-for-5/hotel/hamburg-de.html?finalPriceView=1&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-27&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=-1&showReviewSubmissionEntry=false&currencyCode=TWD&isFreeOccSearch=false&isCityHaveAsq=false&tspTypes=17,6,4&los=1&searchrequestid=60773ead-d1e6-42b4-98c9-83ee6fad028d)  [Urban, 3+3, 346€ per room](https://www.agoda.com/zh-tw/leonardo-hotel-hamburg-elbbruecken/hotel/hamburg-de.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=2&maxRooms=0&checkIn=2023-05-27&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&isCityHaveAsq=false&tspTypes=1,8&los=1&searchrequestid=9722ee53-460b-40b0-af9f-70fd471d6695) |
| 布拉格 | 5/28, 5/29 | [Urban, 117€](https://www.agoda.com/janackovo-nabrezi-19-riverside-apartments/hotel/all/prague-cz.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1897699&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-28&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&tag=643d75919d78f710ee0d319d&isCityHaveAsq=false&los=2&searchrequestid=639831a9-c9c9-46ef-91b3-78206d168a41), [✅ Urban Entire Building 170€](https://www.agoda.com/vn48-suites-by-prague-residences/hotel/all/prague-cz.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1897699&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-28&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&tag=643d75919d78f710ee0d319d&isCityHaveAsq=false&los=2&searchrequestid=639831a9-c9c9-46ef-91b3-78206d168a41) |
| 薩爾斯堡 | 5/30 | [Urban, 123€](https://www.agoda.com/zh-tw/meininger-hotel-salzburg-city-center/hotel/salzburg-at.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1897699&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-30&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&tag=643d75919d78f710ee0d319d&isCityHaveAsq=false&tspTypes=3&los=1&searchrequestid=729fa920-bdf1-4592-be42-f47ae6447f10) [Urban, More public spaces, 3 sofa beds](https://www.agoda.com/zh-tw/boutique-guesthouse-arte-vida/hotel/salzburg-at.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1897699&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-30&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&tag=643d75919d78f710ee0d319d&isCityHaveAsq=false&los=1&searchrequestid=24656ff4-dbd4-43fd-825b-69a09bbf760d) [✅ a&o](https://www.agoda.com/zh-tw/a-o-salzburg-hauptbahnhof/hotel/salzburg-at.html?finalPriceView=1&isShowMobileAppPrice=false&cid=1897699&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-30&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&tag=643d75919d78f710ee0d319d&isCityHaveAsq=false&tspTypes=6,8,8&los=1&searchrequestid=e1778bac-62f3-4720-930e-9154c61c108d) |
| 慕尼黑 | 5/31, 6/1, 6/2 | [Urban 青旅 147€](https://www.agoda.com/zh-tw/the-4you-hostel-hotel-munich/hotel/munich-de.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-31&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&isCityHaveAsq=false&tspTypes=2&los=2&searchrequestid=b01eab44-0138-4fb5-865c-f996202b3f4e) [Surburb 小公寓含廚房 221€](https://www.agoda.com/zh-tw/the-stay-residence/hotel/munich-de.html?finalPriceView=2&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-31&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&isCityHaveAsq=false&los=2&searchrequestid=b01eab44-0138-4fb5-865c-f996202b3f4e) [✅ 睡地上](https://www.agoda.com/zh-tw/bayer-s-boardinghouse-und-hotel/hotel/munich-de.html?finalPriceView=1&isShowMobileAppPrice=false&cid=1844104&numberOfBedrooms=&familyMode=false&adults=5&children=0&rooms=1&maxRooms=0&checkIn=2023-05-31&isCalendarCallout=false&childAges=&numberOfGuest=0&missingChildAges=false&travellerType=3&showReviewSubmissionEntry=false&currencyCode=EUR&isFreeOccSearch=false&isCityHaveAsq=false&los=2&searchrequestid=bb85dc0c-6242-48aa-880d-1455ecd4320f) |

**歐陸交通整理**   
|                                地點 |                時間 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             車票 |
|:----------------------------------|:------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|                 Hamburg -> Berlin |         5/27 上午的票 | |
|                   Berlin -> Praha |         5/27 下午的票 | |
|                       Praha -> CK |              5/30 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       [CK Shuttle](https://www.ckshuttle.cz/) |
|                    CK -> Salzburg |              5/30 | [CK Shuttle](https://www.ckshuttle.cz/) |
|           Salzburg → 國王湖 → Munich |              5/31 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      公車，行李放在 Berchtesgaden Hbf |
|                   新天鵝堡 1 day tour |               6/1 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |

**個人支出** 22600     
- 旅館 15800   
- 交通 6800   
- (機票 42600)
   
   
沒錯就這樣！去歐洲旅行應該很少有人能像我們一樣製作如此之少的規劃就出發了吧？火車都到當場才訂，連旅館都只比較了兩三間就訂下去了。總之，我們就要前往比賽了！   
