# 尺寸預設

三個 template 對應三種用途，**不是同一份內容縮放**——每種尺寸有自己的內容密度策略，套版前要先依尺寸決定要放多少內容。

## `a4-handout.html` — A4 直式衛教單張（列印）

- 用途：診間/家訪列印給病人帶回家，或貼在衛教看板。
- 版面：直式，內容寬度上限約 860-920px，可以有多個段落（比照高血壓頁面：認識/成因/日常怎麼做/警訊四段）。
- 內容密度：最高。可以放完整的分期表、兩欄因子清單、5-6 項行動清單、3-4 張警示卡。
- 字級：直接就是壓縮過的密度（約 6.5-18px，依元素重要性分級），螢幕上看起來就是列印會長的樣子，不是另外縮小版（原因見下方）。

**一定要壓成單頁 A4（2026-09-08 起的硬性規則，不是「盡量」）：** 不管內容有幾段，印出來／存成 PDF 都必須剛好 1 頁，不能讓瀏覽器自動分頁或內容被切斷。

**關鍵教訓（2026-09-08 實測踩過的坑，不要重蹈覆轍）：** 一開始的做法是「螢幕版用寬鬆字級，另外寫一組 `@media print` 把字級/間距壓縮」，用 headless Chrome 直接印本機 HTML 檔測試也確實剛好 1 頁——但 Sabrina 實際在 Artifact（跑在 claude.ai 的 sandboxed iframe 裡）按瀏覽器列印時，印出來還是 3 頁，而且列印預覽裡連應該要被 `@media print{ .print-btn{display:none} }` 隱藏的列印提示按鈕都還在、插圖也是螢幕版原始大小——證實 `@media print` 這組規則在 Artifact 的 iframe 環境裡根本沒有生效。**結論：不能依賴 `@media print` 做任何「印刷時才生效」的關鍵調整，尤其是尺寸壓縮這種必須生效的規則。** 正確做法：把壓縮過的字級/間距直接寫成**預設值**（不包在 `@media print` 裡），螢幕版跟列印版共用同一套，這樣不管 print media query 生不生效都不影響版面。`templates/a4-handout.html` 現在就是照這個做法寫的，套版時直接沿用它的基準字級/間距，不要又把它們搬回 `@media print` 裡。

套版流程：
1. 把 `templates/a4-handout.html` 的字級/間距/圖片高度基準值整包當起點（這些數字已經是壓縮後的版本，不是螢幕寬鬆版）。
2. **內容量會影響要壓多緊，不能通用一組數字**：高血壓（4 段、無警示框）用模板內建的基準值剛好 1 頁；高血糖（5 段＋低血糖警示框，內容更多）實測要在基準值上再往下壓一截（字級/間距/圖片高度整組再縮小 10-15%）。套版時先看這次主題有幾段、有沒有額外的警示框，內容明顯比高血壓版多，就要預先調得更緊。
3. **一定要實測驗證，不能用肉眼判斷**：

   ```bash
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu \
     --print-to-pdf="/path/to/test.pdf" --no-margins --print-to-pdf-no-header \
     "file:///path/to/output.html"

   python3 -c "
   import re
   data = open('/path/to/test.pdf', 'rb').read()
   print(re.findall(rb'/Type\s*/Pages.{0,200}?/Count\s+(\d+)', data, re.S))
   "
   ```

   `/Count` 要是 `[b'1']`。不是 1 的話，回頭把預設字級/間距/圖片高度整組再縮小一截，重新輸出 PDF 再驗證一次，反覆到剛好 1 頁為止；不要只縮某一兩個元素就交差，會破壞版面比例一致性。**這個測試只驗證「直接印本機檔案」這條路徑**——因為沒辦法登入她的 claude.ai 帳號去測真正的 Artifact 頁面，沒辦法百分之百模擬 iframe 內的列印行為，所以第 4 步用不是可省略的裝飾，是唯一能補上這個測試盲區的辦法：讓壓縮值本身就是預設值，不靠任何「印刷限定」的條件生效，這樣不管 headless 測試環境跟她實際的 iframe 環境有什麼差異，只要頁面本身夠短，理論上都不會被迫分頁。
4. 產出後用 `qlmanage -t -s 1600 -o <輸出目錄> <pdf路徑>` 產生縮圖，用 Read 工具看一眼有沒有版面破圖（文字被切、卡片重疊），這步不是選配，是唯一能在部署前肉眼確認排版沒壞掉的方式。
5. **交付時明確告訴使用者**：這是用本機檔案測試驗證過的結果，實際在 Artifact 裡列印可能因為平台本身的限制而有落差，如果印出來還是超過 1 頁，需要她回報實際狀況（最好附截圖），不能單靠這邊的測試結果打包票。

**素材庫圖片是 16:9（1280x720），全寬單張情境不能用 `cover`（2026-09-08 踩過的坑）：** `.art img` 預設用 `object-fit:cover` 撐滿容器，這在 `.split` 裡的正常尺寸容器（寬高比接近圖片本身）沒問題；但套版流程裡有一種「單張滿版插圖＋下面接 actionstrip」的段落（模板裡標記為「日常行動類段落」），這張圖的容器是**整個內容寬度**、高度卻只有 70-90px 上下，寬高比被拉到 10:1 以上，遠超過素材庫圖片實際的 16:9——用 `cover` 會把圖片左右兩側裁掉大半，六宮格插圖只剩中間一兩格看得到，其餘被切掉，肉眼看縮圖很容易忽略（因為看起來「有圖」，不會像斷頁那樣明顯），是 Sabrina 實際列印後才發現的。**套版時這一段的 `<div class="art">` 一定要加上 `banner` class**（`<div class="art banner">`），對應的 CSS 用 `object-fit:contain` + 固定高度（不撐滿寬度、置中），寬度會自動內縮但圖片完整不裁切，模板 `a4-handout.html` 裡已經內建這組 `.art.banner` 規則，套版時直接沿用即可，不要手動改回單純 `.art`。

**列印提示按鈕（`.print-btn`）不能只靠 `@media print{display:none}` 隱藏（2026-09-08 二度踩坑）：** 上面那次改成「壓縮值變預設」修好了頁數，但 Sabrina 再印一次，列印提示按鈕還是出現在列印預覽裡——再次證實 `@media print` 這個機制在 Artifact 的 iframe 裡不可靠，不只影響字級間距，連簡單的 `display:none` 都可能失效。**修正兩件事**：(1) 按鈕原本用 `position:fixed`，這是相對「視窗」定位、脫離文件流，改成放進 `<header>` 裡、用 `position:absolute` 相對 header 定位（header 設 `position:relative`），跟著文件走。(2) 在 `</div>`（`.wrap` 結束）後面加一段 `<script>`，監聽 `beforeprint`/`afterprint` 事件與 `matchMedia('print')` 變化，直接用 JS 把 `.print-btn` 的 `style.display` 設成 `none`/還原——inline style 的優先權比任何 CSS 規則都高，不依賴 `@media print` 是否生效。`a4-handout.html` 現在已經內建這段 markup 位置（`.print-btn` 在 `<header>` 內）跟這段 script（放在檔案最後），**套版時原封不動保留，不要把 `.print-btn` 搬回 header 外面、也不要刪掉結尾的 script**。這個 JS 做法本機測試（headless Chrome print-to-pdf）驗證有效，但跟前面一樣，本機測試無法百分之百還原 Artifact 的 iframe 情境，交付時要照樣提醒使用者用實際列印確認。

**背景色跟避免斷頁（附加規則，跟壓成單頁不衝突，但不能指望它一定生效）：** template 裡還留著這段 print CSS，套版時不要刪掉——在「直接用瀏覽器開本機檔案列印」這種沒有 iframe 包一層的情境下這組規則會生效，只是不能假設在 Artifact 裡也一定生效：

```css
@page{ size:A4; margin:12mm 12mm; }
@media print{
  *{ -webkit-print-color-adjust:exact; print-color-adjust:exact; }
  body{ background:var(--paper); }
  .wrap{ max-width:100%; padding:0; }
  section, .sev-row, .riskcard, .action-chip, .comp-card, .warn-box{ break-inside:avoid; }
  header{ break-after:avoid; }
}
```

## `square-social.html` — 1:1 社群方圖（LINE / IG / 群組分享）

- 用途：單張快速分享，不是拿來讀長文的。
- 版面：正方形（例如 1080×1080 概念尺寸，CSS 用 `aspect-ratio:1/1` + `max-width:640px` 呈現），**強制單一畫面不捲動**。
- 內容密度：最低。只能保留：一張主插圖 + 一句核心訊息（標題級大字）+ 最多 3-4 條精簡重點（每條不超過 12 字）。分期表、雙欄清單這類細節內容一律捨棄，不要硬塞縮小字。
- 決策規則：套版前先問「如果病人只看這一眼，最重要的一句話是什麼」，其餘全部砍掉。

## `widescreen-16-9.html` — 16:9 螢幕/簡報用

- 用途：衛教說明時投影、或插入既有簡報。
- 版面：橫式，`aspect-ratio:16/9`，同樣強制單一畫面不捲動。
- 內容密度：中等。可以放一張主插圖 + 標題 + 3-5 條重點（比 1:1 多一些空間，但仍不放完整分期表這種密集表格；如果主題真的需要分期表，改用 A4 版本）。

## 選擇邏輯

輸入的「尺寸」若不明確（例如只說「一張圖」），用 `AskUserQuestion` 問清楚用途（列印 / 社群分享 / 簡報投影），對應到上面三選一，不要自行假設。
