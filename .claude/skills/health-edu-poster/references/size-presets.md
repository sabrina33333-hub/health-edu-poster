# 尺寸預設

三個 template 對應三種用途，**不是同一份內容縮放**——每種尺寸有自己的內容密度策略，套版前要先依尺寸決定要放多少內容。

## `a4-handout.html` — A4 直式衛教單張（列印）

- 用途：診間/家訪列印給病人帶回家，或貼在衛教看板。
- 版面：直式，螢幕上內容寬度上限約 860-920px 方便閱讀，可以有多個段落（比照高血壓頁面：認識/成因/日常怎麼做/警訊四段）。
- 內容密度：最高。可以放完整的分期表、兩欄因子清單、5-6 項行動清單、3-4 張警示卡。
- 字級：**螢幕版**內文 14-17px（依受眾調整，長者用上限）；**印刷版**因為要壓成一頁，字級會明顯縮小（見下方「一定要壓成單頁 A4」）。
- 這是預設／最完整的版本，其他兩個尺寸都是從這版「精簡」而不是「放大」。

**一定要壓成單頁 A4（2026-09-08 起的硬性規則，不是「盡量」）：** 不管內容有幾段，印出來／存成 PDF 都必須剛好 1 頁，不能讓瀏覽器自動分頁或內容被切斷。做法：
1. 套版時把 `templates/a4-handout.html` 裡的 `@media print` 壓縮字級/間距那組規則整包帶過去，當作起點。
2. **內容量會影響要壓多緊，不能通用一組數字**：高血壓（4 段、無警示框）用模板內建的基準值剛好 1 頁；高血糖（5 段＋低血糖警示框，內容更多）就要在基準值上再往下調一截（字級/間距/圖片高度整組再縮小 10-20%）。套版時先看這次主題有幾段、有沒有額外的警示框，內容明顯比高血壓版多，就要預先調得更緊，不要照抄基準值就交差。
3. **一定要實測驗證，不能用肉眼看螢幕判斷**（screen 版跟 print 版的斷行、字重渲染差很多，肉眼在螢幕上估的頁數常常不準）：

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

   `/Count` 要是 `[b'1']`。不是 1 的話，回頭把 `@media print` 裡的字級/間距/圖片高度整組再縮小一截，重新輸出 PDF 再驗證一次，反覆到剛好 1 頁為止；不要只縮某一兩個元素就交差，會破壞版面比例一致性。
4. 驗證過 1 頁之後，可以順手用 `qlmanage -t -s 1600 -o <輸出目錄> <pdf路徑>` 產生縮圖，用 Read 工具看一眼有沒有版面破圖（文字被切、卡片重疊），這步是選配，但強烈建議做，尤其是壓得很緊的主題。

**背景色跟避免斷頁（原本就有的規則，跟壓成單頁不衝突）：** template 裡已經內建這段 print CSS，套版時不要刪掉：

```css
@page{ size:A4; margin:15mm 14mm; }
@media print{
  *{ -webkit-print-color-adjust:exact; print-color-adjust:exact; }
  body{ background:var(--paper); }
  .wrap{ max-width:100%; padding:0; }
  section{ break-inside:avoid-page; }
  .sev-row, .riskcard, .action-chip, .comp-card, .warn-box{ break-inside:avoid; }
  header{ break-after:avoid; }
}
```

原因：螢幕版 `.wrap` 的 `max-width:920px` 比 A4 版心（扣掉邊界後約 180mm≈680px）寬，如果印刷時沒有覆寫成 100%，瀏覽器只能整頁縮小塞進紙張，字級版面就跑掉了；另外瀏覽器預設列印會把背景色全部去掉，卡片底色、嚴重度色階（`--sev-1` ~ `--sev-5`）不加 `print-color-adjust:exact` 印出來就是純白，資訊圖表的顏色語意會不見。`break-inside:avoid` 是避免一張卡片或一列資料被硬切在兩頁中間。

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
