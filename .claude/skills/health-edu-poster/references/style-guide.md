# 視覺識別指南

來源：本 skill 第一個實作範例「高血壓照護手冊」（發布為 Artifact，https://claude.ai/code/artifact/8b736e6b-6f0e-46e9-a9c9-f6713f85d733）。所有 template 都要延續這套語彙，除非使用者提供機構 logo/CI 要求換色。

## 色彩 token

色碼定義在 `assets/palette.json`（light/dark 各一份）。模板永遠讀 token 名稱，不要在 CSS 裡硬寫色碼：

- `--paper` / `--paper-raised`：頁面底色／卡片底色（暖白，不是純白也不是常見 AI 米色+赭石那套）
- `--ink` / `--ink-soft` / `--ink-faint`：文字三階（主文字／說明文字／頁尾極淡文字）
- `--primary` / `--primary-dark` / `--primary-soft`：薄荷綠，標題重點、資訊類卡片
- `--accent-warm` / `--accent-warm-soft`：蜜桃橘，只用在「需要提高注意力」的區塊（併發症警訊卡），不要當成主色濫用
- `--line`：卡片邊框、分隔線
- `--sev-1` ~ `--sev-5`：五階嚴重度色階（綠→黃→橘→深橘→深紅），只用在分期/分級表格，不要用在其他裝飾

雙主題規則照 `artifact-design` skill 的規矩跑：`:root` 定義亮色版、`@media (prefers-color-scheme: dark)` + `:root[data-theme="dark"]` 各定義一次暗色版 token，不要只寫一份。

## 字體

- 標題與內文都用 **Noto Sans TC**（Google Fonts），權重 400/500/700/900。標題用 900（black）營造親切海報感，不要用細字重當標題。
- 不用襯線字（serif）——衛教單張要親切好讀，不是正式文件。
- fallback stack：`'Noto Sans TC','PingFang TC','Microsoft JhengHei',sans-serif`
- 內文字級不小於 13.5px；若受眾是長者，內文提高到 15-17px、行高 1.7 以上（見 `content-safety.md` 的受眾對應規則）。

## 版面語彙（可重複使用的元件）

這些是高血壓頁面驗證過、值得沿用的版面 pattern，寫新主題時優先重用而不是發明新版型：

- **`eyebrow` 標籤**：藥丸狀小標籤，`--primary-soft` 底、`--primary-dark` 字，放在 H1 上方標明「病患衛教資訊」類的定位語。
- **`sec-head` 段落標題**：兩位數編號（01/02/03…）+ 標題，只在內容真的是有順序的步驟／流程時使用編號（例如「認識→原因→怎麼做→警訊」這種教育流程），不要為了好看硬加編號。
- **`split` / `split.reverse`**：左右兩欄（插圖 + 內容），桌面版左右切換增加節奏感，手機版自動疊成單欄。
- **`ladder`（嚴重度階梯）**：分期/分級類數據用色階列表呈現，每列：色條 + 標籤 + 說明 + 數值（`font-variant-numeric: tabular-nums` 對齊數字）。適用於任何有分級概念的主題（血壓分期、血糖分級、傷口分級⋯）。
- **`riskgrid`（兩欄清單卡）**：「不可改變因子 / 可改變因子」這種二分類清單，用小圓點 bullet，不要每個項目都配專屬 icon（視覺會太雜）。
- **`actionstrip`（行動清單條）**：日常可執行的行動項目，配合插圖庫的 6 格式插圖使用，文字只需簡短標籤（2-4字），細節寫在插圖說明或內文。
- **`compgrid` + `comp-card`**：警示類資訊（併發症、副作用、禁忌）用 `--accent-warm-soft` 底色，溫和但明確，不要用刺眼的純紅或黑底製造恐懼感。
- **`encourage` 收尾**：每份衛教單張結尾放一句正向鼓勵語（不是警告語收尾），呼應「衛教是為了讓病人有行動力，不是嚇他們」。
- **`footer` 免責聲明**：見 `content-safety.md`，每份輸出必備，不可省略。

## 插圖風格（Visual DNA，供擴庫生圖用）

見 `prompt-template.md`。核心關鍵字：flat cartoon、thick clean outlines、warm pastel colors (soft teal + peach)、simple rounded shapes、minimal background、healthcare education poster style、no text（畫面本身不嵌文字，文字一律用頁面上的 HTML 排版處理，避免 AI 生圖中文字錯字問題）。
