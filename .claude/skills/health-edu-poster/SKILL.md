---
name: health-edu-poster
description: 幫 Sabrina（精神科護理師）產出卡通風、清楚易懂的衛教單張。當她說「幫我做衛教單張/衛教圖/衛教海報」「XX衛教」「病患衛教資料」之類的話，或提到要給病人/家屬看的健康主題圖文說明時使用。輸入主題、受眾、尺寸，可選附上自己的資料，會套用固定視覺識別與插圖素材庫產出成品，發布成 Artifact。不是要做嚴肅的醫學文獻整理或臨床文件，是要做「病人/家屬一眼看懂」的衛教圖文。
---

# 衛教產圖

把「高血壓照護手冊」（2026-09-07 手工做的第一個範例，https://claude.ai/code/artifact/8b736e6b-6f0e-46e9-a9c9-f6713f85d733）驗證過的做法固化成可重複呼叫的流程：固定視覺識別 + 插圖素材庫優先 + 醫療內容安全規則，輸出一致品質的衛教單張。

## 先讀這些參考（依需要讀，不要一次全塞進 context）

- `references/style-guide.md`：色彩 token、字體、版面元件庫（split/ladder/riskgrid/actionstrip/compgrid/encourage）。
- `references/size-presets.md`：三種尺寸的用途與內容密度策略。
- `references/content-safety.md`：附資料/沒附資料兩種路徑的文案規則、免責聲明樣板、受眾對應用字難度。
- `references/library-index.md`：素材庫目錄，套版前先查這個。
- `references/prompt-template.md`：素材庫沒有合適插圖時，擴庫生圖的 prompt 模板與額度規則。

## 工作流程

### 1. 收集輸入

四個參數，缺哪個就用 `AskUserQuestion` 補問，不要自己亂猜：

- **主題**（必填）：例如「高血壓」「糖尿病用藥安全」「傷口照護」。
- **受眾**（必填）：長者 / 成人 / 兒童 / 家屬照顧者，決定用字難度、字級、插圖選用（見 `content-safety.md` 對照表）。
- **尺寸**（必填）：A4 列印 / 1:1 社群 / 16:9 螢幕簡報，對應 `templates/` 的三個檔案（見 `size-presets.md`）。
- **是否附資料**（選填）：使用者可提供檔案路徑／URL／貼上文字。有提供就以此為主要內容來源；沒提供就用一般臨床衛教常識，兩種路徑的文案規則見 `content-safety.md`。

### 2. 準備內容

依 `content-safety.md`：
- 有附資料 → 讀取、摘要成該尺寸容得下的重點，頁尾標註實際出處。
- 沒附資料 → 用廣泛採用的臨床分類方式整理重點（不要編造精確數字或引用「最新」但無法查證的版本），頁尾放標準免責聲明樣板。

段落結構彈性使用「認識→原因→怎麼做→警訊」這個骨架，依主題增減，不要每個主題都硬套四段。

### 3. 選插圖（素材庫優先，缺才補生成）

1. 讀 `references/library-index.md`，依主題關鍵字＋受眾比對 `assets/library/characters/` 裡有沒有合適的角色插圖，`assets/library/icons/icons.svg` 裡有沒有合適的圖示。
2. 找不到合適角色插圖時，才照 `references/prompt-template.md` 呼叫 `scripts/generate.py` 補生成，存進 `assets/library/characters/`、更新 `library-index.md`（新增一列＋在「擴庫紀錄」加一行）。
3. 額度規則：免費帳號一天約 8 張，quota 用盡不要短間隔重試，告知使用者預計等待時間（數小時級，非即時）。圖示類（`icons.svg`）不佔額度，缺圖示可以直接手繪 SVG 新增 `<symbol>`。

### 4. 套版輸出

1. 依尺寸選 `templates/a4-handout.html` / `templates/square-social.html` / `templates/widescreen-16-9.html` 之一當骨架。
2. CSS 變數的值從 `assets/palette.json` 填入（沒有機構 CI 覆寫時用預設值；有的話用使用者提供的覆寫版本，見 `assets/palette.json` 的 `logo` 欄位）。
3. 選定的角色插圖用 base64 內嵌（Artifact 是單一 HTML 檔，不能參照外部檔案路徑）：

   ```bash
   python3 -c "
   import base64
   with open('{圖片路徑}', 'rb') as f:
       print('data:image/png;base64,' + base64.b64encode(f.read()).decode('ascii'))
   "
   ```

4. `assets/library/icons/icons.svg` 的 `<symbol>` 內容整份貼進頁面最前面的 `<svg style="display:none">`，頁內用 `<use href="#icon-xxx"/>` 引用。
5. 產出前照 `artifact-design` skill 的規則跑一次（雙主題 token 完整、圖片有 alt、footer 免責聲明必留、標題名符其實）。

### 5. 交付

用 `Artifact` 工具發布，並回報：
- 用了素材庫裡哪些插圖／圖示，有沒有新生成插圖（已存入庫供下次重用）
- 內容來源：使用者提供的資料，還是一般衛教常識
- 發布連結

## 不要做的事

- 不要每次都重新 AI 生圖——素材庫是這個 skill 存在的意義，優先重用。
- 不要省略免責聲明或竄改成更「權威」的說法（例如寫成「最新2026年指引」）——寫不確定的數值時用「請洽醫師/藥師確認」代替。
- 不要用恐嚇性語氣做警示段落，也不要用警告語收尾（結尾一定是正向鼓勵句）。
- 不要把 1:1／16:9 做成 A4 版面的縮小版——三種尺寸各自的內容密度策略不同，見 `size-presets.md`。
