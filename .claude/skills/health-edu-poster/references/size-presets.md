# 尺寸預設

三個 template 對應三種用途，**不是同一份內容縮放**——每種尺寸有自己的內容密度策略，套版前要先依尺寸決定要放多少內容。

## `a4-handout.html` — A4 直式衛教單張（列印）

- 用途：診間/家訪列印給病人帶回家，或貼在衛教看板。
- 版面：直式，內容寬度上限固定 **700px**（對齊真正 A4 可印刷寬度，見下方「寬度」教訓，不要改大），可以有多個段落（比照高血壓頁面：認識/成因/日常怎麼做/警訊四段）。
- 內容密度：最高。可以放完整的分期表、兩欄因子清單、5-6 項行動清單、3-4 張警示卡。
- 字級：直接就是模板內建的密度（body 級約 11.5px、footer 細字約 8.5px、標題視重要性到 23px），螢幕上看起來就是列印會長的樣子，不是另外縮小版（原因見下方）。**這組字級是下限，不是起點**——套版時只能等於或大於這組數字，不能為了塞版面再往下調（見下方「字級有下限」教訓）。

**一定要壓成單頁 A4（2026-09-08 起的硬性規則，不是「盡量」）：** 不管內容有幾段，印出來／存成 PDF 都必須剛好 1 頁，不能讓瀏覽器自動分頁或內容被切斷。

**關鍵教訓（2026-09-08 實測踩過的坑，不要重蹈覆轍）：** 一開始的做法是「螢幕版用寬鬆字級，另外寫一組 `@media print` 把字級/間距壓縮」，用 headless Chrome 直接印本機 HTML 檔測試也確實剛好 1 頁——但 Sabrina 實際在 Artifact（跑在 claude.ai 的 sandboxed iframe 裡）按瀏覽器列印時，印出來還是 3 頁，而且列印預覽裡連應該要被 `@media print{ .print-btn{display:none} }` 隱藏的列印提示按鈕都還在、插圖也是螢幕版原始大小——證實 `@media print` 這組規則在 Artifact 的 iframe 環境裡根本沒有生效。**結論：不能依賴 `@media print` 做任何「印刷時才生效」的關鍵調整，尤其是尺寸壓縮這種必須生效的規則。** 正確做法：把壓縮過的字級/間距直接寫成**預設值**（不包在 `@media print` 裡），螢幕版跟列印版共用同一套，這樣不管 print media query 生不生效都不影響版面。`templates/a4-handout.html` 現在就是照這個做法寫的，套版時直接沿用它的基準字級/間距，不要又把它們搬回 `@media print` 裡。

套版流程：
1. 把 `templates/a4-handout.html` 的字級/間距/圖片比例基準值整包當起點。
2. **字級有下限，塞不下 1 頁時的調整順序是固定的，不能先動字級（2026-09-08 五度踩坑教訓）**：早期做法是「內容多就整組字級/間距/圖片高度再縮小 10-15%」，結果縮到 body 只剩 8.5px、footer 只剩 6px，Sabrina 反映「字都太小」——對長者衛教單張來說完全不能用，這不是「盡量壓縮」可以犧牲的東西。**正確順序**：
   1. 先看內容量能不能減：清單項目數、卡片數、段落數是否真的都必要（例如高血糖版把兩個獨立的併發症小節合併成一個 2x2 網格，省下一整排的高度，而不是把兩排字都縮小）。
   2. 再收緊間距/padding：`section` 的 `margin-bottom`、`.split` 的 `gap`、各卡片的 `padding`，一次降 1-2px 重新測試，不要一次砍一大截。
   3. 圖片大小（`.split` 的欄寬比例、`.art.banner` 的 `max-width`）可以再收窄，但不要小到看不出插圖內容。
   4. 字級是最後手段，而且不能低於模板現在的基準值（body 11.5px / footer 8.5px 這個量級）——寧可調整內容量或間距，也不要印出來讓長者看不清楚。
   高血壓（4 段）跟高血糖（5 段＋低血糖警示框）都是照這個順序調到剛好 1 頁的，過程都沒有動字級。
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

   `/Count` 要是 `[b'1']`。不是 1 的話，回頭照上面「調整順序」重新調整、重新輸出 PDF 再驗證一次，反覆到剛好 1 頁為止；**不要為了趕快讓 `/Count` 變 1 就直接縮字級**，寧可多花幾輪調間距/內容量。**這個測試只驗證「直接印本機檔案」這條路徑**——因為沒辦法登入她的 claude.ai 帳號去測真正的 Artifact 頁面，沒辦法百分之百模擬 iframe 內的列印行為，讓壓縮值本身就是預設值（不靠任何「印刷限定」的條件生效）是唯一能補上這個測試盲區的辦法。
4. 產出後用 `qlmanage -t -s 1600 -o <輸出目錄> <pdf路徑>` 產生縮圖，用 Read 工具看一眼有沒有版面破圖（文字被切、卡片重疊、圖片留白過多跟文字比例不搭），這步不是選配，是唯一能在部署前肉眼確認排版沒壞掉的方式。**如果超過 1 頁**，用 PyMuPDF（`python3 -c "import fitz; ..."`）把溢出的第 2 頁另外存成圖片看一眼，能精確看到是哪個段落溢出、溢出多少，比單看縮圖猜測有效率。
5. **交付時明確告訴使用者**：這是用本機檔案測試驗證過的結果，實際在 Artifact 裡列印可能因為平台本身的限制而有落差，如果印出來還是超過 1 頁，需要她回報實際狀況（最好附截圖），不能單靠這邊的測試結果打包票。

**寬度一定要對齊「真正 A4 可印刷寬度」，不能自己隨便設一個看起來順眼的數字（2026-09-08 三度踩坑）：** A4 寬 210mm，扣掉 `@page` 兩邊 margin 12mm+12mm，可印刷寬度只有 186mm≈703px（96dpi 換算）。之前 `.wrap{max-width}` 設過 860-920px，比真正可印刷寬度寬了快 1/3——螢幕上（Artifact 預覽）看到的版面比例、換行位置跟真正印出來的完全是兩回事，Sabrina 反映「排版不符合A4」就是這個原因。跟前面 `@media print` 踩過的坑一樣，不能指望靠 `@media print{.wrap{max-width:100%}}` 在列印時修正回來，這條路已證實在 Artifact 的 iframe 裡不可靠。**結論：`.wrap{max-width:700px}` 要當螢幕版預設值**（不是列印限定），這樣螢幕上看到的比例本來就跟 A4 一致。`a4-handout.html` 已經是這個數字，套版時不要改大。

**素材庫圖片是 16:9（1280x720），插圖容器不要強制固定高度（2026-09-08 兩輪踩坑，先後試了 `cover` 跟「固定高度＋`contain`」都不對）：**
- 第一版用 `object-fit:cover` 撐滿容器，`.split` 裡的容器寬高比遠超過素材庫圖片實際的 16:9，`cover` 會把圖片上下裁掉大半，肉眼看縮圖不容易發現，是 Sabrina 實際看到「圖都會被裁切」才確認的。
- 改成「容器固定矮高度＋`object-fit:contain`」雖然不裁圖了，但圖片被縮成一小塊置中、四周留白，跟旁邊文字的比例明顯不搭，Sabrina 反映「圖的排版沒有配合文字」。
- **現在的做法**：`.art img{width:100%;height:auto;}`，不設固定高度、不用 `object-fit`，圖片用原生 16:9 比例自然撐開，大小完全跟著 `.split` 的欄寬走（`.split` 目前是 `0.72fr 1.28fr`，圖片欄比文字欄窄，圖片不會佔太大空間，也不會裁切或留白）。滿版單張（`.art.banner`）改用 `max-width`（約 300px）控制大小，同樣不設固定高度。`a4-handout.html` 已經是這個做法，套版時不要又改回固定高度或 `object-fit`。

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
