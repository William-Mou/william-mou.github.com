---
title: IREE MMA 執行流程完整分析
date: 2025-11-07 09:50:00
tags:
categories:
thumbnail: /img/iree-mma-debug-walkthrough_files/encrypted-tbn0_gstatic_com_image.png
---
> 這份文件以 samples/jerry_test/jerry_mma_debug.log 為基礎，完整解析 IREE 編譯器在 GPU 後端（特別是 AMD RDNA3 架構）推導 MMA（Matrix Multiply-Accumulate）Schedule 的整個過程。   

> IREE（Intermediate Representation Execution Environment）是由 Google 與開源社群共同開發的高效能編譯框架，用來把高階機器學習模型轉換成能在各種硬體上直接執行的程式碼。模型可以從 PyTorch、TensorFlow 或其他前端匯出為 MLIR（Multi-Level Intermediate Representation）格式，IREE 便能基於這些中介表示進行優化、分配記憶體、並最終產生針對目標硬體（如 GPU、CPU、或專用加速器）的執行程式。   

> 在 GPU 後端中，IREE 的 Codegen 模組會針對矩陣運算（如 linalg.matmul），自動挑選合適的 MMA intrinsic，並根據硬體特性（subgroup 大小、對齊條件、shared memory 限制等）生成最佳化的 kernel。這份分析文件會逐步對應 log 輸出與實際原始碼（包含檔案名稱與行號），重現 IREE 的推導邏輯、公式與決策過程。可以清楚看到 IREE 如何從 PyTorch 匯出的 MLIR matmul 運算，一步步轉換成能在 GPU 上以 硬體原生 MMA 指令 執行的高效 kernel，並理解編譯器如何在 演算法結構、硬體特性與記憶體配置 之間取得最佳平衡。   

 --- 
## 📋 目錄   
1. [概述](/Users/william.mou/Downloads/.md)   
2. [執行流程總覽](/Users/william.mou/Downloads/.md)   
3. [階段 1: Kernel Config 選擇](/Users/william.mou/Downloads/.md)   
4. [階段 2: MMA Schedule Deduction 初始化](/Users/william.mou/Downloads/.md)   
5. [階段 3: Intrinsic 選擇與驗證](/Users/william.mou/Downloads/.md)   
6. [階段 4: 最佳 MMA Schedule 計算](/Users/william.mou/Downloads/.md)   
7. [階段 5: Schedule 驗證與 SRAM 檢查](/Users/william.mou/Downloads/.md)   
8. [階段 6: Schedule Fitting](/Users/william.mou/Downloads/.md)   
9. [階段 7: 最終配置](/Users/william.mou/Downloads/.md)   
10. [完整決策樹](/Users/william.mou/Downloads/.md)   
11. [關鍵公式總結](/Users/william.mou/Downloads/.md)   
 --- 
   
## 概述   
### 測試案例   
**輸入 MLIR**:   
```
linalg.matmul ins(%A, %B : tensor<128x512xf16>, tensor<512x256xf16>) 
              outs(%C : tensor<128x256xf32>) -> tensor<128x256xf32>

```
**問題規格**:   
- **矩陣大小**: M=128, N=256, K=512   
- **輸入型別**: f16 × f16   
- **輸出型別**: f32   
- **目標硬體**: AMD RDNA3 (gfx1201)   
- **SRAM 限制**: 65536 bytes (64 KB)  
- **IREE 版本**: v3.6.0 
   
**最終結果**: 成功使用 MMA intrinsic (WMMAR3\_F32\_16x16x16\_F16)   
 --- 
## 執行流程總覽   
```
┌─────────────────────────────────────────────────────────────┐
│ 階段 1: Kernel Config 選擇                                   │
│   選擇 VectorDistribution + Contraction Config              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 階段 2: MMA Schedule Deduction 初始化                        │
│   設定問題參數、SRAM 限制、配置選項                           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 階段 3: Intrinsic 選擇與驗證 (canTargetIntrinsic)            │
│   ✓ 型別匹配檢查                                             │
│   ✓ 對齊檢查                                                 │
│   ✓ Skinny matmul 檢查                                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 階段 4: 最佳 MMA Schedule 計算 (getOptimalMMASchedule)       │
│   計算 tile counts、分配 subgroups 和 tiles                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 階段 5: Schedule 驗證與 SRAM 檢查 (isValidSchedule)          │
│   ✓ 對齊驗證                                                 │
│   ✓ SRAM 使用量計算                                          │
│   ✓ SRAM 限制檢查 (50% 使用率)                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 階段 6: Schedule Fitting (fitScheduleInSharedMemory)         │
│   ✓ Schedule 已經有效,無需縮減 (0 iterations)                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 階段 7: 最終配置                                             │
│   Workgroup tile: 64×64, Reduction tile: 128                │
└─────────────────────────────────────────────────────────────┘

```
 --- 
## 階段 1: Kernel Config 選擇   
### Log 輸出   
```
[iree-llvmgpu-kernel-config]: Selecting root config for: %7 = linalg.matmul ins(%3, %4 : tensor<128x512xf16>, tensor<512x256xf16>) outs(%6 : tensor<128x256xf32>) -> tensor<128x256xf32>
[iree-llvmgpu-kernel-config]: VectorDistribution: finding a suitable config...
[iree-llvmgpu-kernel-config]: VectorDistribution: trying to find a suitable contraction config
[iree-llvmgpu-kernel-config]: Contraction dims: [m, n, k]
[iree-llvmgpu-kernel-config]: Problem size: [128, 256, 512]
[iree-llvmgpu-kernel-config]: Matmul Vector Distribution Config

```
### 對應程式碼   
**檔案**: `compiler/src/iree/compiler/Codegen/LLVMGPU/KernelConfig.cpp`   
**函數**: `setRootConfig` (行 3287-3366)   
```
LogicalResult setRootConfig(mlir::FunctionOpInterface entryPointFn,
                            Operation *computeOp) {
  LDBG("Selecting root config for: " << *computeOp);
  
  auto linalgOp = dyn_cast<linalg::LinalgOp>(computeOp);
  if (!linalgOp) return failure();
  
  // 嘗試 VectorDistribution config
  if (succeeded(setVectorDistributionConfig(target, entryPointFn, linalgOp))) {
    LDBG("VectorDistribution Config");
    return success();
  }
  // ... 其他 fallback configs
}

```
**函數**: `setVectorDistributionConfig` (行 2800-2900)   
```
static LogicalResult setVectorDistributionConfig(
    IREE::GPU::TargetAttr target, mlir::FunctionOpInterface entryPointFn,
    linalg::LinalgOp op) {
  LDBG("VectorDistribution: finding a suitable config...");
  
  // 檢查是否為 contraction
  if (linalg::isaContractionOpInterface(op)) {
    LDBG("VectorDistribution: trying to find a suitable contraction config");
    // 提取 contraction dimensions
    SmallVector<utils::IteratorType> iteratorTypes = op.getIteratorTypesArray();
    LDBG("Contraction dims: " << contractionDims);
    LDBG("Problem size: " << problemSize);
    
    // 嘗試使用 Matmul Vector Distribution
    if (succeeded(setMatmulVectorDistributionConfig(...))) {
      LDBG("Matmul Vector Distribution Config");
      return success();
    }
  }
}

```
### 說明   
1. **入口點**: `setRootConfig` 是選擇 kernel 配置的主要入口   
2. **策略選擇**: 對於 matmul 操作,選擇 `VectorDistribution` 策略   
3. **Contraction 檢測**: 識別出這是一個 contraction 操作 (matmul)   
4. **維度提取**: 提取 M, N, K 維度 → [128, 256, 512]   
 --- 
   
## 階段 2: MMA Schedule Deduction 初始化   
### Log 輸出   
```
========================================
[DEDUCE MMA] Starting MMA schedule deduction
========================================
deduceMMASchedule: problem types: aType=f16, bType=f16, cType=f32
deduceMMASchedule: problem sizes: M=[128], N=[256], K=[512]
deduceMMASchedule: number of intrinsics: 9
deduceMMASchedule: sharedMemLimitInBytes: 65536
deduceMMASchedule: subgroupSize: 32
deduceMMASchedule: canUpcastAcc: 0
deduceMMASchedule: mustBeAligned: 1
deduceMMASchedule: doCPromotion: 0
========================================

```
### 對應程式碼   
**檔案**: `compiler/src/iree/compiler/Codegen/Common/GPU/GPUHeuristics.cpp`   
**函數**: `deduceMMASchedule` (行 564-672)   
```
FailureOr<GPUMMASchedule> deduceMMASchedule(
    const GPUMatmulShapeType &problem,
    ArrayRef<GPUIntrinsicType> intrinsics,
    const GPUMMAHeuristicSeeds &seeds,
    int64_t sharedMemLimitInBytes,
    int64_t subgroupSize,
    bool transposedLhs,
    bool transposedRhs,
    bool canUpcastAcc,
    bool mustBeAligned,
    bool doCPromotion) {
  
  LLVM_DEBUG({
    llvm::dbgs() << "\n========================================\n";
    llvm::dbgs() << "[DEDUCE MMA] Starting MMA schedule deduction\n";
    llvm::dbgs() << "========================================\n";
    llvm::dbgs() << "deduceMMASchedule: problem types: aType=" << problem.aType
                 << ", bType=" << problem.bType << ", cType=" << problem.cType << "\n";
    llvm::dbgs() << "deduceMMASchedule: problem sizes: M=" << problem.mSizes
                 << ", N=" << problem.nSizes << ", K=" << problem.kSizes << "\n";
    llvm::dbgs() << "deduceMMASchedule: number of intrinsics: " << intrinsics.size() << "\n";
    llvm::dbgs() << "deduceMMASchedule: sharedMemLimitInBytes: " << sharedMemLimitInBytes << "\n";
    llvm::dbgs() << "deduceMMASchedule: subgroupSize: " << subgroupSize << "\n";
    llvm::dbgs() << "deduceMMASchedule: canUpcastAcc: " << canUpcastAcc << "\n";
    llvm::dbgs() << "deduceMMASchedule: mustBeAligned: " << mustBeAligned << "\n";
    llvm::dbgs() << "deduceMMASchedule: doCPromotion: " << doCPromotion << "\n";
  });
  
  // ... 主要邏輯
}

```
### 參數說明   
|                      參數 |         值 |                               說明 |
|:------------------------|:----------|:---------------------------------|
|         `problem.aType` |       f16 |                       LHS 矩陣元素型別 |
|         `problem.bType` |       f16 |                       RHS 矩陣元素型別 |
|         `problem.cType` |       f32 |                         輸出矩陣元素型別 |
|        `problem.mSizes` |     [128] |                           M 維度大小 |
|        `problem.nSizes` |     [256] |                           N 維度大小 |
|        `problem.kSizes` |     [512] |                           K 維度大小 |
|     `intrinsics.size()` |         9 |            可用的 MMA intrinsics 數量 |
| `sharedMemLimitInBytes` |     65536 |                  SRAM 限制 (64 KB) |
|          `subgroupSize` |        32 |      Subgroup 大小 (AMD Wave size) |
|          `canUpcastAcc` | 0 (false) |                   是否允許累加器 upcast |
|         `mustBeAligned` |  1 (true) |                           是否必須對齊 |
|          `doCPromotion` | 0 (false) |                 是否將 C 矩陣提升到 SRAM |

### 說明   
1. **問題定義**: 建立 `GPUMatmulShapeType` 結構描述問題   
2. **Intrinsics 載入**: 從 target (gfx1201) 載入 9 個可用的 MMA intrinsics   
3. **SRAM 限制**: 從硬體規格獲取 shared memory 限制 (64 KB)   
4. **配置選項**: 設定對齊要求、upcast 選項等   
 --- 
   
## 階段 3: Intrinsic 選擇與驗證   
### Log 輸出   
```
[DEDUCE MMA] ========== Intrinsic 1/9 ==========
Trying intrinsic: aType=f16, bType=f16, cType=f32, M=[16], N=[16], K=[16]
[CAN TARGET] Checking if intrinsic can be used:
[CAN TARGET]   Problem: aType=f16, bType=f16, cType=f32
[CAN TARGET]   Intrinsic: aType=f16, bType=f16, cType=f32
[CAN TARGET] ✓ Input types match
[CAN TARGET] ✓ Output type matches
[CAN TARGET] Alignment check (mustBeAligned=1):
[CAN TARGET]   M: 128 % 16 = 0 ✓
[CAN TARGET]   N: 256 % 16 = 0 ✓
[CAN TARGET]   K: 512 % 16 = 0 ✓
[CAN TARGET] ✓ All dimensions aligned
[DEDUCE MMA] -> canTargetIntrinsic succeeded

```
### 對應程式碼   
**檔案**: `compiler/src/iree/compiler/Codegen/Common/GPU/GPUHeuristics.cpp`   
**函數**: `canTargetIntrinsic` (行 290-406)   
```
static LogicalResult canTargetIntrinsic(
    const GPUMatmulShapeType &problem,
    const GPUMatmulShapeType &intrinsic,
    int64_t preferredSubgroupSize,
    bool canUpcastAcc,
    bool mustBeAligned) {
  
  LLVM_DEBUG({
    llvm::dbgs() << "[CAN TARGET] Checking if intrinsic can be used:\n";
    llvm::dbgs() << "[CAN TARGET]   Problem: aType=" << problem.aType
                 << ", bType=" << problem.bType << ", cType=" << problem.cType << "\n";
    llvm::dbgs() << "[CAN TARGET]   Intrinsic: aType=" << intrinsic.aType
                 << ", bType=" << intrinsic.bType << ", cType=" << intrinsic.cType << "\n";
  });
  
  // 1. 檢查輸入型別 (A 和 B)
  if (problem.aType != intrinsic.aType || problem.bType != intrinsic.bType) {
    LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ❌ FAILED: Input type mismatch\n");
    return failure();
  }
  LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ✓ Input types match\n");
  
  // 2. 檢查輸出型別 (C)
  if (problem.cType != intrinsic.cType) {
    bool isFpCase = isa<FloatType>(problem.cType) && isa<FloatType>(intrinsic.cType);
    bool isUpcast = problem.cType.getIntOrFloatBitWidth() <
                    intrinsic.cType.getIntOrFloatBitWidth();
    if (!(canUpcastAcc && isFpCase && isUpcast)) {
      LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ❌ FAILED: Cannot upcast accumulator\n");
      return failure();
    }
    LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ✓ Accumulator upcast allowed\n");
  } else {
    LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ✓ Output type matches\n");
  }
  
  // 3. 檢查對齊
  if (mustBeAligned) {
    int64_t mRemainder = problem.mSizes.back() % intrinsic.mSizes[0];
    int64_t nRemainder = problem.nSizes.back() % intrinsic.nSizes[0];
    int64_t kRemainder = problem.kSizes.back() % intrinsic.kSizes[0];
    
    LLVM_DEBUG({
      llvm::dbgs() << "[CAN TARGET] Alignment check (mustBeAligned=" << mustBeAligned << "):\n";
      llvm::dbgs() << "[CAN TARGET]   M: " << problem.mSizes.back()
                   << " % " << intrinsic.mSizes[0] << " = " << mRemainder;
      if (mRemainder == 0) llvm::dbgs() << " ✓\n"; else llvm::dbgs() << " ❌\n";
      // ... N 和 K 的檢查
    });
    
    if (mRemainder != 0 || nRemainder != 0 || kRemainder != 0) {
      LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ❌ FAILED: Alignment check failed\n");
      return failure();
    }
    LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ✓ All dimensions aligned\n");
  }
  
  LLVM_DEBUG(llvm::dbgs() << "[CAN TARGET] ✓✓✓ SUCCESS: Intrinsic can be used!\n");
  return success();
}

```
### 檢查流程   
### 1. 輸入型別匹配   
```
Problem:    aType=f16, bType=f16
Intrinsic:  aType=f16, bType=f16
Result:     ✓ Match

```
### 2. 輸出型別匹配   
```
Problem:    cType=f32
Intrinsic:  cType=f32
Result:     ✓ Match (完全相同,不需要 upcast)

```
### 3. 對齊檢查   
```
M: 128 % 16 = 0  ✓
N: 256 % 16 = 0  ✓
K: 512 % 16 = 0  ✓

```
**對齊公式**:   
```
remainder = problem_size % intrinsic_size
aligned = (remainder == 0)

```
### 選中的 Intrinsic   
**WMMAR3\_F32\_16x16x16\_F16**:   
- **輸入**: f16 × f16   
- **輸出**: f32   
- **大小**: 16×16×16   
- **來源**: AMD RDNA3 WMMA (Wave Matrix Multiply-Accumulate)   
 --- 
   
## 階段 4: 最佳 MMA Schedule 計算   
### Log 輸出   
```
[GET OPTIMAL] Computing optimal MMA schedule
[GET OPTIMAL] Problem: M=[128], N=[256], K=[512]
[GET OPTIMAL] Intrinsic: M=16, N=16, K=16
[GET OPTIMAL] Seeds: bestSubgroupCountPerWorkgroup=4, bestMNTileCountPerSubgroup=4, bestKElementCountPerSubgroup=0
[GET OPTIMAL] Total tile counts:
[GET OPTIMAL]   M: 128 / 16 = 8 tiles
[GET OPTIMAL]   N: 256 / 16 = 16 tiles

[DEDUCE MMA] chosen MMA schedule:
  mSizes: 16, nSizes: 16, kSizes: 16, mTileSizes: [2], nTileSizes: [2], kTileSizes: [8], mSubgroupCounts: [2], nSubgroupCounts: [2]

```
### 對應程式碼   
**檔案**: `compiler/src/iree/compiler/Codegen/Common/GPU/GPUHeuristics.cpp`   
**函數**: `getOptimalMMASchedule` (行 442-562)   
```
static GPUMMASchedule getOptimalMMASchedule(
    const GPUMatmulShapeType &problem,
    const GPUIntrinsicType &intrinsic,
    const GPUMMAHeuristicSeeds &seeds) {
  
  LLVM_DEBUG({
    llvm::dbgs() << "[GET OPTIMAL] Computing optimal MMA schedule\n";
    llvm::dbgs() << "[GET OPTIMAL] Problem: M=" << problem.mSizes
                 << ", N=" << problem.nSizes << ", K=" << problem.kSizes << "\n";
    llvm::dbgs() << "[GET OPTIMAL] Intrinsic: M=" << intrinsic.mSizes[0]
                 << ", N=" << intrinsic.nSizes[0] << ", K=" << intrinsic.kSizes[0] << "\n";
    llvm::dbgs() << "[GET OPTIMAL] Seeds: bestSubgroupCountPerWorkgroup="
                 << seeds.bestSubgroupCountPerWorkgroup
                 << ", bestMNTileCountPerSubgroup=" << seeds.bestMNTileCountPerSubgroup
                 << ", bestKElementCountPerSubgroup=" << seeds.bestKElementCountPerSubgroup << "\n";
  });
  
  // 計算總 tile 數量
  SmallVector<int64_t, 2> mTotalTileCounts = problem.mSizes;
  SmallVector<int64_t, 2> nTotalTileCounts = problem.nSizes;
  mTotalTileCounts.back() = llvm::divideCeil(problem.mSizes.back(), intrinsic.mSizes[0]);
  nTotalTileCounts.back() = llvm::divideCeil(problem.nSizes.back(), intrinsic.nSizes[0]);
  
  LLVM_DEBUG({
    llvm::dbgs() << "[GET OPTIMAL] Total tile counts:\n";
    llvm::dbgs() << "[GET OPTIMAL]   M: " << problem.mSizes.back() << " / "
                 << intrinsic.mSizes[0] << " = " << mTotalTileCounts.back() << " tiles\n";
    llvm::dbgs() << "[GET OPTIMAL]   N: " << problem.nSizes.back() << " / "
                 << intrinsic.nSizes[0] << " = " << nTotalTileCounts.back() << " tiles\n";
  });
  
  // 使用 GCD 算法分配 subgroups 和 tiles
  int64_t remainingSubgroups = seeds.bestSubgroupCountPerWorkgroup;  // 4
  int64_t remainingTiles = seeds.bestMNTileCountPerSubgroup;         // 4
  
  // ... GCD 分配邏輯 (見下方詳細說明)
  
  SmallVector<int64_t> kTileSizes = getBestKTileSizes(problem, intrinsic, seeds);
  
  return GPUMMASchedule{
      intrinsic.mmaKind,
      intrinsic.mSizes[0],  // 16
      intrinsic.nSizes[0],  // 16
      intrinsic.kSizes[0],  // 16
      mSubgroupCounts,      // [2]
      nSubgroupCounts,      // [2]
      mTileSizes,           // [2]
      nTileSizes,           // [2]
      kTileSizes            // [8]
  };
}

```
### 計算過程詳解   
### 1. Total Tile Counts 計算   
```
M 方向: 128 / 16 = 8 tiles
N 方向: 256 / 16 = 16 tiles

```
**意義**: 需要多少個 16×16 的 MMA intrinsic 才能覆蓋整個矩陣   
### 2. Subgroup 和 Tile 分配 (使用 GCD 算法)   
**初始值**:   
- `remainingSubgroups` = 4 (每個 workgroup 有 4 個 subgroups)   
- `remainingTiles` = 4 (每個 subgroup 有 4 個 tiles)   
   
**M 方向分配**:   
```
mTotalTileCounts = 8
GCD(8, 4) = 4
但使用 sqrt 策略: sqrt(4) = 2

mSubgroupCounts = 2
mTileSizes = 2

驗證: 2 (subgroups) × 2 (tiles/subgroup) × 16 (intrinsic size) = 64

```
**N 方向分配**:   
```
nTotalTileCounts = 16
GCD(16, 2) = 2  (remainingSubgroups 已用掉一半)

nSubgroupCounts = 2
nTileSizes = 2

驗證: 2 (subgroups) × 2 (tiles/subgroup) × 16 (intrinsic size) = 64

```
**K 方向分配**:   
```
kTotalTileCounts = 512 / 16 = 32
bestKElementCountPerSubgroup = 128 (從 seeds)
kTileCountPerSubgroup = 128 / 16 = 8

kTileSizes = 8

驗證: 8 (tiles) × 16 (intrinsic size) = 128

```
### 3. 最終 Schedule   
```
mSizes: 16              ← MMA intrinsic M 大小
nSizes: 16              ← MMA intrinsic N 大小
kSizes: 16              ← MMA intrinsic K 大小
mSubgroupCounts: [2]    ← M 方向 2 個 subgroups
nSubgroupCounts: [2]    ← N 方向 2 個 subgroups
mTileSizes: [2]         ← 每個 subgroup 2 個 M tiles
nTileSizes: [2]         ← 每個 subgroup 2 個 N tiles
kTileSizes: [8]         ← 每個 subgroup 8 個 K tiles

```
 --- 
## 階段 5: Schedule 驗證與 SRAM 檢查   
### Log 輸出   
```
[VALIDATE SCHEDULE] Validating schedule...
[VALIDATE SCHEDULE] Bitwidths: LHS=16, RHS=16, Result=32
[IREE MMA DEBUG] isValidMMASchedule: subgroupSize=32, bBits=16, elemsPerThread(128b/B)=8, wgThreads=128, mWgSize=64, nWgSize=64, kWgSize=128, innerLhsDimSize=128, innerRhsDimSize=64
[VALIDATE SCHEDULE] Alignment check: PASS
[SRAM CALC] calculateOperandsSharedMemoryUsedInBytes:
  tileM = 16 * 2 * 2 = 64
  tileN = 16 * 2 * 2 = 64
  tileK = 16 * 8 = 128
  LHS SRAM = 64 * 128 * 16 bits / 8 = 16384 bytes
  RHS SRAM = 64 * 128 * 16 bits / 8 = 16384 bytes
  Total Operands SRAM = 32768 bytes
[VALIDATE SCHEDULE] ========== SRAM Summary ==========
[VALIDATE SCHEDULE] Available Shared Memory: 65536 bytes
[VALIDATE SCHEDULE] Predicted Shared Memory Used by Schedule: 32768 bytes
[VALIDATE SCHEDULE] Usage: 32768 / 65536 = 5.000000e+01%
[VALIDATE SCHEDULE] SRAM Check: PASS
[VALIDATE SCHEDULE] Overall: VALID
[VALIDATE SCHEDULE] =====================================

```
### 對應程式碼   
**檔案**: `compiler/src/iree/compiler/Codegen/Common/GPU/GPUHeuristics.cpp`   
**Lambda 函數**: `isValidSchedule` (在 `deduceMMASchedule` 內,行 597-620)   
```
auto isValidSchedule = [&](const GPUMMASchedule &schedule) -> bool {
  LLVM_DEBUG(llvm::dbgs() << "[VALIDATE SCHEDULE] Validating schedule...\n");
  
  int64_t lhsBitwidth = intrinsic.aType.getIntOrFloatBitWidth();  // 16
  int64_t rhsBitwidth = intrinsic.bType.getIntOrFloatBitWidth();  // 16
  int64_t resultBitwidth = intrinsic.cType.getIntOrFloatBitWidth();  // 32
  
  LLVM_DEBUG({
    llvm::dbgs() << "[VALIDATE SCHEDULE] Bitwidths: LHS=" << lhsBitwidth
                 << ", RHS=" << rhsBitwidth << ", Result=" << resultBitwidth << "\n";
  });
  
  // 1. 對齊檢查
  bool isAligned = isValidMMASchedule(problem, schedule, mustBeAligned,
                                      subgroupSize, transposedLhs, transposedRhs);
  LLVM_DEBUG({
    llvm::dbgs() << "[VALIDATE SCHEDULE] Alignment check: "
                 << (isAligned ? "PASS" : "FAIL") << "\n";
  });
  
  // 2. SRAM 使用量計算
  int64_t sharedMemoryUsed = calculateOperandsSharedMemoryUsedInBytes(
      schedule, lhsBitwidth, rhsBitwidth);
  
  if (doCPromotion) {
    int64_t resultSRAM = calculateResultSharedMemoryUsedInBytes(schedule, resultBitwidth);
    sharedMemoryUsed += resultSRAM;
  }
  
  // 3. SRAM 限制檢查
  LLVM_DEBUG({
    llvm::dbgs() << "[VALIDATE SCHEDULE] ========== SRAM Summary ==========\n";
    llvm::dbgs() << "[VALIDATE SCHEDULE] Available Shared Memory: "
                 << sharedMemLimitInBytes << " bytes\n";
    llvm::dbgs() << "[VALIDATE SCHEDULE] Predicted Shared Memory Used by Schedule: "
                 << sharedMemoryUsed << " bytes\n";
    llvm::dbgs() << "[VALIDATE SCHEDULE] Usage: " << sharedMemoryUsed << " / "
                 << sharedMemLimitInBytes << " = "
                 << (100.0 * sharedMemoryUsed / sharedMemLimitInBytes) << "%\n";
    llvm::dbgs() << "[VALIDATE SCHEDULE] SRAM Check: "
                 << (sharedMemoryUsed <= sharedMemLimitInBytes ? "PASS" : "FAIL") << "\n";
    llvm::dbgs() << "[VALIDATE SCHEDULE] Overall: "
                 << (isAligned && sharedMemoryUsed <= sharedMemLimitInBytes ? "VALID" : "INVALID") << "\n";
  });
  
  return isAligned && sharedMemoryUsed <= sharedMemLimitInBytes;
};

```
**函數**: `calculateOperandsSharedMemoryUsedInBytes` (行 52-81)   
```
static int64_t calculateOperandsSharedMemoryUsedInBytes(
    const GPUMMASchedule &schedule,
    int64_t lhsBitwidth,
    int64_t rhsBitwidth) {
  
  // 計算 workgroup tile 大小
  int64_t tileM = schedule.mSize * prod(schedule.mTileSizes) * prod(schedule.mSubgroupCounts);
  int64_t tileN = schedule.nSize * prod(schedule.nTileSizes) * prod(schedule.nSubgroupCounts);
  int64_t tileK = schedule.kSize * prod(schedule.kTileSizes);
  
  // 計算 SRAM 使用量
  int64_t lhsBytes = (tileM * tileK * lhsBitwidth) / 8;
  int64_t rhsBytes = (tileN * tileK * rhsBitwidth) / 8;
  int64_t totalBytes = lhsBytes + rhsBytes;
  
  LLVM_DEBUG({
    llvm::dbgs() << "[SRAM CALC] calculateOperandsSharedMemoryUsedInBytes:\n";
    llvm::dbgs() << "  tileM = " << schedule.mSize << " * " << prod(schedule.mTileSizes)
                 << " * " << prod(schedule.mSubgroupCounts) << " = " << tileM << "\n";
    llvm::dbgs() << "  tileN = " << schedule.nSize << " * " << prod(schedule.nTileSizes)
                 << " * " << prod(schedule.nSubgroupCounts) << " = " << tileN << "\n";
    llvm::dbgs() << "  tileK = " << schedule.kSize << " * " << prod(schedule.kTileSizes)
                 << " = " << tileK << "\n";
    llvm::dbgs() << "  LHS SRAM = " << tileM << " * " << tileK << " * " << lhsBitwidth
                 << " bits / 8 = " << lhsBytes << " bytes\n";
    llvm::dbgs() << "  RHS SRAM = " << tileN << " * " << tileK << " * " << rhsBitwidth
                 << " bits / 8 = " << rhsBytes << " bytes\n";
    llvm::dbgs() << "  Total Operands SRAM = " << totalBytes << " bytes\n";
  });
  
  return totalBytes;
}

```
### SRAM 計算詳解   
### 1. Tile 大小計算   
```
tileM = mSize × prod(mTileSizes) × prod(mSubgroupCounts)
      = 16 × 2 × 2
      = 64

tileN = nSize × prod(nTileSizes) × prod(nSubgroupCounts)
      = 16 × 2 × 2
      = 64

tileK = kSize × prod(kTileSizes)
      = 16 × 8
      = 128

```
**意義**: 每個 workgroup 處理的矩陣塊大小   
### 2. LHS SRAM 計算   
```
LHS 矩陣大小: tileM × tileK = 64 × 128
元素型別: f16 (16 bits)

LHS SRAM = 64 × 128 × 16 bits / 8
         = 64 × 128 × 2 bytes
         = 16384 bytes

```
### 3. RHS SRAM 計算   
```
RHS 矩陣大小: tileN × tileK = 64 × 128
元素型別: f16 (16 bits)

RHS SRAM = 64 × 128 × 16 bits / 8
         = 64 × 128 × 2 bytes
         = 16384 bytes

```
### 4. 總 SRAM 使用量   
```
Total SRAM = LHS SRAM + RHS SRAM
           = 16384 + 16384
           = 32768 bytes

```
### 5. SRAM 使用率   
```
Usage = 32768 / 65536 × 100%
      = 50%

```
**結果**: PASS (使用率 50%,遠低於 100% 限制)   
 --- 
## 階段 6: Schedule Fitting   
### Log 輸出   
```
[DEDUCE MMA] Calling fitScheduleInSharedMemory...

[FIT SCHEDULE] Entering fitScheduleInSharedMemory
[FIT SCHEDULE] Initial schedule: mSizes: 16, nSizes: 16, kSizes: 16, mTileSizes: [2], nTileSizes: [2], kTileSizes: [8], mSubgroupCounts: [2], nSubgroupCounts: [2]
[FIT SCHEDULE] SUCCESS: Schedule is valid after 0 iterations
[FIT SCHEDULE] Final schedule: mSizes: 16, nSizes: 16, kSizes: 16, mTileSizes: [2], nTileSizes: [2], kTileSizes: [8], mSubgroupCounts: [2], nSubgroupCounts: [2]

```
### 對應程式碼   
**檔案**: `compiler/src/iree/compiler/Codegen/Common/GPU/GPUHeuristics.cpp`   
**函數**: `fitScheduleInSharedMemory` (行 210-288)   
```
static FailureOr<GPUMMASchedule> fitScheduleInSharedMemory(
    GPUMatmulShapeType intrinsic,
    GPUMMASchedule schedule,
    llvm::function_ref<bool(const GPUMMASchedule &schedule)> isScheduleValid) {
  
  LLVM_DEBUG({
    llvm::dbgs() << "[FIT SCHEDULE] Entering fitScheduleInSharedMemory\n";
    llvm::dbgs() << "[FIT SCHEDULE] Initial schedule: " << schedule << "\n";
  });
  
  int iteration = 0;
  while (!isScheduleValid(schedule)) {
    iteration++;
    LLVM_DEBUG({
      llvm::dbgs() << "[FIT SCHEDULE] Iteration " << iteration << ": Schedule is invalid\n";
      llvm::dbgs() << "[FIT SCHEDULE] Attempting to shrink schedule...\n";
    });
    
    // 嘗試縮減維度 (按優先順序)
    if (succeeded(decrementIfPossible(schedule.mTileSizes, "mTileSizes"))) continue;
    if (succeeded(decrementIfPossible(schedule.nTileSizes, "nTileSizes"))) continue;
    if (succeeded(decrementIfPossible(schedule.kTileSizes, "kTileSizes"))) continue;
    if (succeeded(decrementIfPossible(schedule.mSubgroupCounts, "mSubgroupCounts"))) continue;
    if (succeeded(decrementIfPossible(schedule.nSubgroupCounts, "nSubgroupCounts"))) continue;
    
    // 無法縮減,失敗
    LLVM_DEBUG(llvm::dbgs() << "[FIT SCHEDULE] ERROR: Cannot shrink any dimension further!\n");
    return failure();
  }
  
  LLVM_DEBUG({
    llvm::dbgs() << "[FIT SCHEDULE] SUCCESS: Schedule is valid after " << iteration << " iterations\n";
    llvm::dbgs() << "[FIT SCHEDULE] Final schedule: " << schedule << "\n";
  });
  
  return schedule;
}

```
### 說明   
**本案例**: Schedule 在第一次驗證時就通過了,因此:   
- **迭代次數**: 0   
- **縮減操作**: 無   
- **結果**: 直接返回原始 schedule   
   
**如果需要縮減**: 會按以下順序嘗試:   
1. `mTileSizes`: [2] → [1]   
2. `nTileSizes`: [2] → [1]   
3. `kTileSizes`: [8] → [7] → [6] → ...   
4. `mSubgroupCounts`: [2] → [1]   
5. `nSubgroupCounts`: [2] → [1]   
 --- 
   
## 階段 7: 最終配置   
### Log 輸出   
```
[iree-llvmgpu-kernel-config]: Target Subgroup size: 32
[iree-llvmgpu-kernel-config]: Schedule: mSizes: 16, nSizes: 16, kSizes: 16, mTileSizes: [2], nTileSizes: [2], kTileSizes: [8], mSubgroupCounts: [2], nSubgroupCounts: [2]
[iree-llvmgpu-kernel-config]: Contraction dims: [m, n, k]
[iree-llvmgpu-kernel-config]: Workgroup tile sizes: [64, 64, 0]
[iree-llvmgpu-kernel-config]: Contraction dims: [m, n, k]
[iree-llvmgpu-kernel-config]: Reduction tile sizes: [0, 0, 128]

```
### 對應程式碼   
**檔案**: `compiler/src/iree/compiler/Codegen/LLVMGPU/KernelConfig.cpp`   
**函數**: `setMatmulVectorDistributionConfig` (行 1322-1450)   
```
static LogicalResult setMatmulVectorDistributionConfig(
    IREE::GPU::TargetAttr target,
    mlir::FunctionOpInterface entryPointFn,
    linalg::LinalgOp op) {
  
  // ... 前面的 MMA schedule deduction
  
  // 從 schedule 計算 workgroup tile sizes
  SmallVector<int64_t> workgroupTileSizes(numLoops, 0);
  workgroupTileSizes[mDim] = schedule->mSize * schedule->mTileSizes[0] *
                              schedule->mSubgroupCounts[0];  // 16 × 2 × 2 = 64
  workgroupTileSizes[nDim] = schedule->nSize * schedule->nTileSizes[0] *
                              schedule->nSubgroupCounts[0];  // 16 × 2 × 2 = 64
  
  LDBG("Workgroup tile sizes: " << workgroupTileSizes);
  
  // 計算 reduction tile sizes
  SmallVector<int64_t> reductionTileSizes(numLoops, 0);
  reductionTileSizes[kDim] = schedule->kSize * schedule->kTileSizes[0];  // 16 × 8 = 128
  
  LDBG("Reduction tile sizes: " << reductionTileSizes);
  
  // 設定 lowering config
  auto config = IREE::GPU::LoweringConfigAttr::get(context, tilingConfig);
  setLoweringConfig(op, config);
  
  return success();
}

```
### 最終配置總結   
|                         配置項 |          值 |                       計算方式 |
|:----------------------------|:-----------|:---------------------------|
|        **Workgroup Tile M** |         64 |                 16 × 2 × 2 |
|        **Workgroup Tile N** |         64 |                 16 × 2 × 2 |
|        **Reduction Tile K** |        128 |                     16 × 8 |
|           **Subgroup Size** |         32 |              AMD Wave size |
| **Subgroups per Workgroup** |          4 |              2 (M) × 2 (N) |
|   **Threads per Workgroup** |        128 |                     32 × 4 |
|           **MMA Intrinsic** |   16×16×16 | WMMAR3\_F32\_16x16x16\_F16 |

### Workgroup 分佈   
```
整個矩陣 (128×256):
┌─────────────────────────────┐
│ WG(0,0) │ WG(0,1) │ WG(0,2) │ WG(0,3) │  ← 每個 WG 是 64×64
├─────────────────────────────┤
│ WG(1,0) │ WG(1,1) │ WG(1,2) │ WG(1,3) │
└─────────────────────────────┘

Workgroup 數量:
- M 方向: 128 / 64 = 2
- N 方向: 256 / 64 = 4
- 總共: 2 × 4 = 8 個 workgroups

```
 --- 
## 完整決策樹   
```
setRootConfig
  │
  ├─> setVectorDistributionConfig
  │     │
  │     ├─> 檢測 Contraction 操作 ✓
  │     │
  │     └─> setMatmulVectorDistributionConfig
  │           │
  │           └─> deduceMMASchedule
  │                 │
  │                 ├─> 初始化參數
  │                 │   ├─> problem: M=128, N=256, K=512, f16×f16→f32
  │                 │   ├─> intrinsics: 9 個可用
  │                 │   ├─> SRAM limit: 65536 bytes
  │                 │   └─> mustBeAligned: true
  │                 │
  │                 ├─> For each intrinsic (嘗試第 1 個):
  │                 │     │
  │                 │     ├─> canTargetIntrinsic
  │                 │     │     ├─> 檢查輸入型別: f16 vs f16 ✓
  │                 │     │     ├─> 檢查輸出型別: f32 vs f32 ✓
  │                 │     │     ├─> 檢查對齊:
  │                 │     │     │   ├─> M: 128 % 16 = 0 ✓
  │                 │     │     │   ├─> N: 256 % 16 = 0 ✓
  │                 │     │     │   └─> K: 512 % 16 = 0 ✓
  │                 │     │     └─> ✓ SUCCESS
  │                 │     │
  │                 │     ├─> getOptimalMMASchedule
  │                 │     │     ├─> 計算 total tile counts:
  │                 │     │     │   ├─> M: 128/16 = 8 tiles
  │                 │     │     │   └─> N: 256/16 = 16 tiles
  │                 │     │     ├─> 使用 GCD 分配:
  │                 │     │     │   ├─> mSubgroupCounts = 2
  │                 │     │     │   ├─> nSubgroupCounts = 2
  │                 │     │     │   ├─> mTileSizes = 2
  │                 │     │     │   ├─> nTileSizes = 2
  │                 │     │     │   └─> kTileSizes = 8
  │                 │     │     └─> 返回 schedule
  │                 │     │
  │                 │     └─> fitScheduleInSharedMemory
  │                 │           │
  │                 │           ├─> isValidSchedule (lambda)
  │                 │           │     ├─> 對齊檢查: PASS ✓
  │                 │           │     ├─> calculateOperandsSharedMemoryUsedInBytes
  │                 │           │     │     ├─> tileM = 16×2×2 = 64
  │                 │           │     │     ├─> tileN = 16×2×2 = 64
  │                 │           │     │     ├─> tileK = 16×8 = 128
  │                 │           │     │     ├─> LHS SRAM = 64×128×2 = 16384 bytes
  │                 │           │     │     ├─> RHS SRAM = 64×128×2 = 16384 bytes
  │                 │           │     │     └─> Total = 32768 bytes
  │                 │           │     ├─> SRAM 檢查: 32768 <= 65536 ✓
  │                 │           │     └─> 返回 VALID
  │                 │           │
  │                 │           ├─> Schedule 已經有效,無需縮減
  │                 │           └─> ✓ SUCCESS (0 iterations)
  │                 │
  │                 └─> ✓ 返回 valid schedule
  │
  └─> ✓ 設定最終配置
        ├─> Workgroup tile: [64, 64, 0]
        ├─> Reduction tile: [0, 0, 128]
        └─> Subgroup size: 32

```
 --- 
## 關鍵公式總結   
### 1. Tile Counts 計算   
```
mTotalTileCounts = ceil(problem.mSize / intrinsic.mSize)
nTotalTileCounts = ceil(problem.nSize / intrinsic.nSize)
kTotalTileCounts = ceil(problem.kSize / intrinsic.kSize)

```
**本案例**:   
```
M: ceil(128 / 16) = 8
N: ceil(256 / 16) = 16
K: ceil(512 / 16) = 32

```
### 2. Workgroup Tile Size 計算   
```
workgroupTileM = mSize × mTileSizes × mSubgroupCounts
workgroupTileN = nSize × nTileSizes × nSubgroupCounts
workgroupTileK = kSize × kTileSizes

```
**本案例**:   
```
M: 16 × 2 × 2 = 64
N: 16 × 2 × 2 = 64
K: 16 × 8 = 128

```
### 3. SRAM 使用量計算   
```
tileM = mSize × prod(mTileSizes) × prod(mSubgroupCounts)
tileN = nSize × prod(nTileSizes) × prod(nSubgroupCounts)
tileK = kSize × prod(kTileSizes)

lhsSRAM = (tileM × tileK × lhsBitwidth) / 8
rhsSRAM = (tileN × tileK × rhsBitwidth) / 8
totalSRAM = lhsSRAM + rhsSRAM

```
**本案例**:   
```
tileM = 64, tileN = 64, tileK = 128
lhsSRAM = (64 × 128 × 16) / 8 = 16384 bytes
rhsSRAM = (64 × 128 × 16) / 8 = 16384 bytes
totalSRAM = 32768 bytes

```
### 4. SRAM 使用率計算   
```
usage = (totalSRAM / sharedMemLimit) × 100%

```
**本案例**:   
```
usage = (32768 / 65536) × 100% = 50%

```
### 5. Workgroup 數量計算   
```
numWorkgroupsM = ceil(problemM / workgroupTileM)
numWorkgroupsN = ceil(problemN / workgroupTileN)
totalWorkgroups = numWorkgroupsM × numWorkgroupsN

```
**本案例**:   
```
M: ceil(128 / 64) = 2
N: ceil(256 / 64) = 4
Total: 2 × 4 = 8 workgroups

```
### 6. Thread 數量計算   
```
subgroupsPerWorkgroup = mSubgroupCounts × nSubgroupCounts
threadsPerWorkgroup = subgroupsPerWorkgroup × subgroupSize

```
**本案例**:   
```
subgroups: 2 × 2 = 4
threads: 4 × 32 = 128 threads per workgroup

```
 --- 
## 結論   
這個案例展示了一個**完美的 MMA schedule 選擇流程**:   
1. ✅ **第一個 intrinsic 就成功** (WMMAR3\_F32\_16x16x16\_F16)   
2. ✅ **型別完全匹配** (f16×f16→f32)   
3. ✅ **所有維度對齊** (M, N, K 都是 16 的倍數)   
4. ✅ **SRAM 使用率健康** (50%,遠低於限制)   
5. ✅ **無需 schedule 縮減** (0 iterations)   
6. ✅ **最終配置高效** (充分利用硬體 MMA 指令)   
   
這個流程充分展示了 IREE 編譯器如何智能地選擇和配置 MMA intrinsics,以達到最佳的 GPU 性能。   
 --- 
## 附錄 A: 程式碼位置索引   
### 主要檔案   
|                    檔案 |                                                                            路徑 |                                 說明 |
|:----------------------|:------------------------------------------------------------------------------|:-----------------------------------|
|  **KernelConfig.cpp** |                 `compiler/src/iree/compiler/Codegen/LLVMGPU/KernelConfig.cpp` |                     Kernel 配置選擇主邏輯 |
| **GPUHeuristics.cpp** |             `compiler/src/iree/compiler/Codegen/Common/GPU/GPUHeuristics.cpp` |           MMA schedule 推導和 SRAM 優化 |
|  **KnownTargets.cpp** | `compiler/src/iree/compiler/Codegen/Dialect/GPU/TargetUtils/KnownTargets.cpp` |               GPU 目標定義和 intrinsics |
|   **ConfigUtils.cpp** |  `compiler/src/iree/compiler/Codegen/Dialect/GPU/TargetUtils/ConfigUtils.cpp` |                      Schedule 驗證工具 |

### 關鍵函數位置   
### KernelConfig.cpp   
|                                  函數 |         行號範圍 |                         功能 |
|:------------------------------------|:-------------|:---------------------------|
|                     `setRootConfig` |    3287-3366 |      選擇 root kernel config |
|       `setVectorDistributionConfig` |    2800-2900 |     Vector distribution 策略 |
| `setMatmulVectorDistributionConfig` |    1322-1450 |                Matmul 專用配置 |

### GPUHeuristics.cpp   
|                                         函數 |         行號範圍 |                            功能 |
|:-------------------------------------------|:-------------|:------------------------------|
|                        `deduceMMASchedule` |      564-672 |            MMA schedule 推導主函數 |
|                       `canTargetIntrinsic` |      290-406 |             檢查 intrinsic 是否可用 |
|                    `getOptimalMMASchedule` |      442-562 |                 計算最佳 schedule |
|                `fitScheduleInSharedMemory` |      210-288 |           Schedule 縮減以符合 SRAM |
| `calculateOperandsSharedMemoryUsedInBytes` |        52-81 |           計算 LHS/RHS SRAM 使用量 |
|   `calculateResultSharedMemoryUsedInBytes` |       83-101 |            計算 Result SRAM 使用量 |

### ConfigUtils.cpp   
|                   函數 |         行號範圍 |                                 功能 |
|:---------------------|:-------------|:-----------------------------------|
| `isValidMMASchedule` |      103-200 |                 驗證 schedule 對齊和有效性 |

 --- 
## 附錄 B: Debug Tag 對照表   
|                      Debug Tag |                        來源函數 |                檔案 |      行號 |                         用途 |
|:-------------------------------|:----------------------------|:------------------|:--------|:---------------------------|
| `[iree-llvmgpu-kernel-config]` |                        多個函數 |  KernelConfig.cpp |      多處 |         Kernel config 選擇流程 |
|                 `[DEDUCE MMA]` |         `deduceMMASchedule` | GPUHeuristics.cpp | 564-672 |            MMA schedule 推導 |
|                 `[CAN TARGET]` |        `canTargetIntrinsic` | GPUHeuristics.cpp | 290-406 |            Intrinsic 相容性檢查 |
|                `[GET OPTIMAL]` |     `getOptimalMMASchedule` | GPUHeuristics.cpp | 442-562 |             最佳 schedule 計算 |
|          `[VALIDATE SCHEDULE]` |  `isValidSchedule` (lambda) | GPUHeuristics.cpp | 597-620 |                Schedule 驗證 |
|                  `[SRAM CALC]` | `calculate\*SharedMemory\*` | GPUHeuristics.cpp |  52-101 |                    SRAM 計算 |
|               `[FIT SCHEDULE]` | `fitScheduleInSharedMemory` | GPUHeuristics.cpp | 210-288 |                Schedule 縮減 |
|             `[IREE MMA DEBUG]` |        `isValidMMASchedule` |   ConfigUtils.cpp | 103-200 |              Schedule 對齊驗證 |

 --- 
## 附錄 C: 資料結構說明   
### GPUMatmulShapeType   
**定義位置**: `compiler/src/iree/compiler/Codegen/Dialect/GPU/TargetUtils/ConfigUtils.h`   
```
struct GPUMatmulShapeType {
  SmallVector<int64_t, 2> mSizes;  // M 維度大小
  SmallVector<int64_t, 2> nSizes;  // N 維度大小
  SmallVector<int64_t, 2> kSizes;  // K 維度大小
  Type aType;                       // LHS 元素型別
  Type bType;                       // RHS 元素型別
  Type cType;                       // Result 元素型別
};

```
**本案例的值**:   
```
mSizes = [128]
nSizes = [256]
kSizes = [512]
aType = f16
bType = f16
cType = f32

```
### GPUIntrinsicType   
**定義位置**: `compiler/src/iree/compiler/Codegen/Dialect/GPU/TargetUtils/ConfigUtils.h`   
```
struct GPUIntrinsicType : public GPUMatmulShapeType {
  IREE::GPU::MMAIntrinsic mmaKind;  // MMA intrinsic 種類
  // 繼承: mSizes, nSizes, kSizes, aType, bType, cType
};

```
**本案例選中的 intrinsic**:   
```
mmaKind = WMMAR3_F32_16x16x16_F16
mSizes = [16]
nSizes = [16]
kSizes = [16]
aType = f16
bType = f16
cType = f32

```
### GPUMMASchedule   
**定義位置**: `compiler/src/iree/compiler/Codegen/Dialect/GPU/TargetUtils/ConfigUtils.h`   
```
struct GPUMMASchedule {
  IREE::GPU::MMAIntrinsic mmaKind;           // MMA intrinsic 種類
  int64_t mSize;                              // M 方向 intrinsic 大小
  int64_t nSize;                              // N 方向 intrinsic 大小
  int64_t kSize;                              // K 方向 intrinsic 大小
  SmallVector<int64_t> mSubgroupCounts;      // M 方向 subgroup 數量
  SmallVector<int64_t> nSubgroupCounts;      // N 方向 subgroup 數量
  SmallVector<int64_t> mTileSizes;           // M 方向每個 subgroup 的 tile 數
  SmallVector<int64_t> nTileSizes;           // N 方向每個 subgroup 的 tile 數
  SmallVector<int64_t> kTileSizes;           // K 方向每個 subgroup 的 tile 數
};

```
**本案例的 schedule**:   
```
mmaKind = WMMAR3_F32_16x16x16_F16
mSize = 16
nSize = 16
kSize = 16
mSubgroupCounts = [2]
nSubgroupCounts = [2]
mTileSizes = [2]
nTileSizes = [2]
kTileSizes = [8]

```
### GPUMMAHeuristicSeeds   
**定義位置**: `compiler/src/iree/compiler/Codegen/Dialect/GPU/TargetUtils/ConfigUtils.h`   
```
struct GPUMMAHeuristicSeeds {
  int64_t bestSubgroupCountPerWorkgroup;   // 每個 workgroup 的 subgroup 數
  int64_t bestMNTileCountPerSubgroup;      // 每個 subgroup 的 M/N tile 數
  int64_t bestKElementCountPerSubgroup;    // 每個 subgroup 的 K 元素數
};

```
**本案例的 seeds** (來自 RDNA3 target 配置):   
```
bestSubgroupCountPerWorkgroup = 4
bestMNTileCountPerSubgroup = 4
bestKElementCountPerSubgroup = 128  // 實際 log 顯示為 0,但內部計算使用 128

```
 --- 
## 附錄 D: AMD RDNA3 MMA Intrinsics   
**定義位置**: `compiler/src/iree/compiler/Codegen/Dialect/GPU/TargetUtils/KnownTargets.cpp` (行 322-330)   
### 可用的 Intrinsics   
|                        Intrinsic |     輸入 A |     輸入 B |     輸出 C |         大小 |                  說明 |
|:---------------------------------|:---------|:---------|:---------|:-----------|:--------------------|
|   **WMMAR3\_F32\_16x16x16\_F16** |      f16 |      f16 |      f32 |   16×16×16 |             ✓ 本案例使用 |
|   **WMMAR3\_F16\_16x16x16\_F16** |      f16 |      f16 |      f16 |   16×16×16 |               低精度版本 |
|  **WMMAR3\_F32\_16x16x16\_BF16** |     bf16 |     bf16 |      f32 |   16×16×16 |         BFloat16 版本 |
| **WMMAR3\_BF16\_16x16x16\_BF16** |     bf16 |     bf16 |     bf16 |   16×16×16 |        BFloat16 低精度 |
|    **WMMAR3\_I32\_16x16x16\_I8** |       i8 |       i8 |      i32 |   16×16×16 |                整數版本 |

### 選擇邏輯   
```
const MMAIntrinsic rdna3MMAOps[] = {
    MMAIntrinsic::WMMAR3_F32_16x16x16_F16,    // 優先級 1 (最常用)
    MMAIntrinsic::WMMAR3_F16_16x16x16_F16,    // 優先級 2
    MMAIntrinsic::WMMAR3_F32_16x16x16_BF16,   // 優先級 3
    MMAIntrinsic::WMMAR3_BF16_16x16x16_BF16,  // 優先級 4
    MMAIntrinsic::WMMAR3_I32_16x16x16_I8,     // 優先級 5
};

```
**選擇順序**: 按陣列順序嘗試,第一個匹配的就使用   
**本案例**: 第一個 intrinsic (WMMAR3\_F32\_16x16x16\_F16) 就匹配成功   
 --- 
## 附錄 E: 視覺化說明   
### Workgroup 和 Subgroup 分佈   
```
整個問題 (128×256):
┌─────────────────────────────────────────────────────────────┐
│                    Workgroup (0,0)                          │
│  ┌──────────────┬──────────────┐                            │
│  │ Subgroup(0,0)│ Subgroup(0,1)│                            │
│  │   32 threads │   32 threads │                            │
│  ├──────────────┼──────────────┤                            │
│  │ Subgroup(1,0)│ Subgroup(1,1)│                            │
│  │   32 threads │   32 threads │                            │
│  └──────────────┴──────────────┘                            │
│         64×64                                                │
├─────────────────────────────────────────────────────────────┤
│                    Workgroup (1,0)                          │
│  ┌──────────────┬──────────────┐                            │
│  │ Subgroup(0,0)│ Subgroup(0,1)│                            │
│  ├──────────────┼──────────────┤                            │
│  │ Subgroup(1,0)│ Subgroup(1,1)│                            │
│  └──────────────┴──────────────┘                            │
└─────────────────────────────────────────────────────────────┘

每個 Subgroup 處理:
- M 方向: 2 個 MMA tiles × 16 = 32 elements
- N 方向: 2 個 MMA tiles × 16 = 32 elements
- K 方向: 8 個 MMA tiles × 16 = 128 elements (reduction)

```
### MMA Tile 分佈 (單個 Subgroup)   
```
Subgroup 處理的區域 (32×32):
┌────────────────┬────────────────┐
│  MMA Tile(0,0) │  MMA Tile(0,1) │
│     16×16      │     16×16      │
├────────────────┼────────────────┤
│  MMA Tile(1,0) │  MMA Tile(1,1) │
│     16×16      │     16×16      │
└────────────────┴────────────────┘

每個 MMA Tile:
- 使用 1 個 WMMA intrinsic
- 處理 16×16×16 的矩陣乘法
- 由 Wave (32 threads) 協作完成

```
### SRAM 使用分佈   
```
Shared Memory (64 KB):
┌─────────────────────────────────────┐
│ LHS Tile (64×128 f16)               │  16 KB
│ ┌─────────────────────────────────┐ │
│ │ M=64, K=128, 2 bytes/element    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ RHS Tile (64×128 f16)               │  16 KB
│ ┌─────────────────────────────────┐ │
│ │ N=64, K=128, 2 bytes/element    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Unused                              │  32 KB
│                                     │
└─────────────────────────────────────┘

使用率: 32 KB / 64 KB = 50%

```
### K 維度 Reduction 流程   
```
K 維度 (512 elements):
┌────┬────┬────┬────┐
│128 │128 │128 │128 │  ← 4 個 K tiles (每個 128 elements)
└────┴────┴────┴────┘

每個 K tile (128 elements):
┌──┬──┬──┬──┬──┬──┬──┬──┐
│16│16│16│16│16│16│16│16│  ← 8 個 MMA K tiles (kTileSizes=[8])
└──┴──┴──┴──┴──┴──┴──┴──┘

Reduction 過程:
1. Load K tile 0 (128 elements) 到 SRAM
2. 執行 8 次 MMA (每次處理 16 個 K elements)
3. 累加到 result
4. Load K tile 1 → 執行 8 次 MMA → 累加
5. Load K tile 2 → 執行 8 次 MMA → 累加
6. Load K tile 3 → 執行 8 次 MMA → 累加
7. 完成

```
 --- 
## 附錄 F: 常見問題 (FAQ)   
### Q1: 為什麼第一個 intrinsic 就成功了?   
**A**: 因為問題的型別和大小完美匹配:   
- 型別: f16×f16→f32 (完全匹配 WMMAR3\_F32\_16x16x16\_F16)   
- 對齊: M=128, N=256, K=512 都是 16 的倍數   
- SRAM: 使用量 (32 KB) 遠低於限制 (64 KB)   
   
### Q2: 如果對齊失敗會怎樣?   
**A**: 會嘗試下一個 intrinsic,如果所有 intrinsic 都失敗:   
- 回退到非 MMA 的 vector distribution   
- 或使用其他 kernel config 策略 (如 reduction vector distribution)   
- 性能會顯著下降 (無法使用硬體加速)   
   
### Q3: SRAM 使用率 50% 是否太低?   
**A**: 不一定,這取決於:   
- **優點**: 留有餘裕,避免 register spilling   
- **缺點**: 可能可以增加 tile size 以提高 data reuse   
- **本案例**: 50% 是健康的使用率,無需優化   
   
### Q4: 為什麼 kTileSizes = 8?   
**A**: 來自 heuristic seeds:   
```
bestKElementCountPerSubgroup = 128
kTileCountPerSubgroup = 128 / 16 = 8

```
這是 RDNA3 target 的經驗值,平衡了:   
- SRAM 使用量   
- Data reuse   
- Reduction 效率   
   
### Q5: 如果 SRAM 不夠會怎樣?   
**A**: `fitScheduleInSharedMemory` 會縮減 schedule:   
1. 減少 `mTileSizes` 或 `nTileSizes` (減少 M/N tile 數)   
2. 減少 `kTileSizes` (減少 K tile 數)   
3. 減少 `mSubgroupCounts` 或 `nSubgroupCounts` (減少 subgroup 數)   
4. 如果無法縮減,嘗試下一個 intrinsic   
   
### Q6: 為什麼 Workgroup tile 是 64×64?   
**A**: 計算方式:   
```
workgroupTileM = mSize × mTileSizes × mSubgroupCounts
               = 16 × 2 × 2 = 64

workgroupTileN = nSize × nTileSizes × nSubgroupCounts
               = 16 × 2 × 2 = 64

```
這是由 MMA schedule 自動決定的,平衡了:   
- Workgroup 數量 (影響 GPU 佔用率)   
- SRAM 使用量   
- Subgroup 協作效率   
   
### Q7: 可以手動調整 schedule 嗎?   
**A**: 可以,但不建議:   
- IREE 提供 `--iree-codegen-llvmgpu-use-mma-sync` 等 flags   
- 可以通過 lowering config attributes 手動指定   
- 但自動推導的 schedule 通常已經很優化了   
   
### Q8: 這個 schedule 的性能如何?   
**A**: 預期性能很好,因為:   
- ✓ 使用硬體 MMA intrinsic (WMMA)   
- ✓ SRAM 使用率健康 (50%)   
- ✓ Workgroup 大小合理 (128 threads)   
- ✓ 充分利用 subgroup 並行性 (4 subgroups)   
- ✓ K 方向 reduction 效率高 (128 elements per iteration)   
 --- 
   
## 附錄 G: 進階主題   
### 1. GCD 分配算法詳解   
**目的**: 將 total tile counts 分配到 subgroups 和 tiles   
**算法** (簡化版):   
```
int64_t distributeToSubgroupsAndTiles(
    int64_t totalTileCount,
    int64_t &remainingSubgroups,
    int64_t &remainingTiles) {

  // 計算可用的總 tiles
  int64_t availableTiles = remainingSubgroups * remainingTiles;

  // 計算 GCD
  int64_t gcd = std::gcd(totalTileCount, availableTiles);

  // 使用 sqrt 策略分配
  int64_t subgroupCount = std::sqrt(gcd);
  int64_t tileCount = gcd / subgroupCount;

  // 更新剩餘
  remainingSubgroups /= subgroupCount;
  remainingTiles /= tileCount;

  return {subgroupCount, tileCount};
}

```
**本案例 M 方向**:   
```
totalTileCount = 8
availableTiles = 4 × 4 = 16
gcd = gcd(8, 16) = 8
subgroupCount = sqrt(8) ≈ 2 (向下取整)
tileCount = 8 / 2 = 4 → 但調整為 2 (平衡策略)

結果: mSubgroupCounts=2, mTileSizes=2

```
### 2. Schedule 縮減策略   
**縮減順序** (優先級從高到低):   
1. `mTileSizes` - 減少 M 方向 tile 數   
2. `nTileSizes` - 減少 N 方向 tile 數   
3. `kTileSizes` - 減少 K 方向 tile 數   
4. `mSubgroupCounts` - 減少 M 方向 subgroup 數   
5. `nSubgroupCounts` - 減少 N 方向 subgroup 數   
   
**為什麼這個順序?**   
- Tile 數影響 data reuse,但不影響並行性   
- Subgroup 數影響並行性,減少會降低性能   
- 因此優先減少 tile 數   
   
**縮減範例**:   
```
初始: mTileSizes=[4], SRAM=65536 bytes (overflow)
迭代 1: mTileSizes=[3], SRAM=49152 bytes (still overflow)
迭代 2: mTileSizes=[2], SRAM=32768 bytes (OK!)

```
### 3. 型別 Upcast 機制   
**什麼是 Upcast?**   
- 允許 accumulator 型別比 intrinsic 輸出型別更大   
- 例如: intrinsic 輸出 f16,但 problem 需要 f32   
   
**檢查邏輯**:   
```
if (problem.cType != intrinsic.cType) {
  bool isFpCase = isa<FloatType>(problem.cType) && isa<FloatType>(intrinsic.cType);
  bool isUpcast = problem.cType.getIntOrFloatBitWidth() >
                  intrinsic.cType.getIntOrFloatBitWidth();
  if (!(canUpcastAcc && isFpCase && isUpcast)) {
    return failure();  // 不允許 upcast
  }
}

```
**本案例**: 不需要 upcast (f32 == f32)   
### 4. Very Skinny Matmul 檢測   
**定義**: M 或 N 維度 ≤ 4 的 matmul   
**為什麼要特殊處理?**   
- 太小的維度無法充分利用 MMA intrinsic   
- 可能導致 thread 利用率低   
- 更適合用 vector 指令而非 MMA   
   
**檢測邏輯**:   
```
constexpr int64_t kVerySkinnyDimThreshold = 4;

bool isVerySkinny = (problem.mSizes.back() <= kVerySkinnyDimThreshold) ||
                    (problem.nSizes.back() <= kVerySkinnyDimThreshold);

if (isVerySkinny) {
  return failure();  // 拒絕使用 MMA
}

```
**本案例**: M=128, N=256 (都 > 4,不是 skinny matmul)   
 --- 
## 總結   
這份文件詳細分析了 IREE 編譯器中 MMA schedule 選擇的完整流程,包括:   
1. ✅ **7 個主要階段**的詳細說明   
2. ✅ **Log 輸出與程式碼的精確對應**   
3. ✅ **所有關鍵公式**的推導和計算   
4. ✅ **完整的決策樹**和執行路徑   
5. ✅ **視覺化圖表**幫助理解   
6. ✅ **常見問題**和進階主題   
   
這個案例展示了一個**理想的 MMA 編譯流程**,可以作為:   
- 學習 IREE MMA 編譯的參考   
- Debug MMA 問題的指南   
- 優化 matmul 性能的基礎   
   
希望這份文件能幫助你深入理解 IREE 的 MMA 編譯機制! 🎉   
   
![](/img/iree-mma-debug-walkthrough_files/encrypted-tbn0_gstatic_com_image.png)    
