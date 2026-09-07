# 擴庫生圖 Prompt 模板

只有在 `library-index.md` 比對後、素材庫真的沒有合適場景時才用這個模板呼叫 `scripts/generate.py` 補新插圖。每次生成後要更新 `library-index.md`。

## Visual DNA（固定不變，維持風格一致）

```text
cute flat cartoon illustration, {場景描述}, warm pastel colors (soft teal and peach), simple rounded shapes, thick clean outlines, minimal background, healthcare education poster style, no text
```

- `{場景描述}`：換成具體場景，例如「a friendly nurse showing a blood pressure monitor cuff to a smiling elderly patient sitting in a chair」。
- 固定關鍵字不要拿掉：`flat cartoon`、`thick clean outlines`、`warm pastel colors (soft teal and peach)`、`minimal background`、`healthcare education poster style`、`no text`。這些是跟既有素材庫（護理師量測長者、危險因子情境、六格日常自我照護、器官警示徽章、兒童家庭情境、成人自我照護、照顧者情境）維持同一視覺語言的關鍵。
- 一律加 `no text`：中文字用 AI 生圖不可靠（超過 2-3 個簡單詞就容易錯字），畫面留白，文字都交給 HTML 排版處理。若真的需要圖上短標籤，才用 `scripts/annotate.py` 疊字（見下方）。

## 呼叫方式

```bash
SKILL_DIR="/Users/new/Library/Mobile Documents/com~apple~CloudDocs/claudeAgen/工作用/衛教產圖/.claude/skills/health-edu-poster"
"$SKILL_DIR/scripts/.venv/bin/python" "$SKILL_DIR/scripts/generate.py" \
  --prompt "cute flat cartoon illustration, ...(場景描述)..., warm pastel colors (soft teal and peach), simple rounded shapes, thick clean outlines, minimal background, healthcare education poster style, no text" \
  --output "$SKILL_DIR/assets/library/characters/{描述性檔名}.png"
```

## 額度規則（沿用 ian-xiaohei-illustrations skill 的驗證結果）

- `HF_TOKEN` 已在 `~/.claude/settings.json` 設定，免費帳號一天約可生 8 張。
- 額度用盡時回充很慢（數小時級，非即時），**不要短間隔重試**；告知使用者預計要等到隔天，或改用 `annotate.py` 疊字在既有底圖上先湊合。
- 每次擴庫前，先確認素材庫既有圖片是不是可以稍微調整用途（例如「量血壓」場景很多主題都能借用，不用真的每個新主題都重新生成人物場景）。

## annotate.py（插圖需要短標籤時）

```bash
"$SKILL_DIR/scripts/.venv/bin/python" "$SKILL_DIR/scripts/annotate.py" \
  --image 底圖.png --output 成品.png --size 40 \
  --label "文字:x,y:顏色[:角度]"
```

顏色支援 black/red/orange/blue。只在插圖本身需要精準標註（例如指出身體部位）時使用，一般文字說明優先寫在 HTML 版面裡，不要疊在圖上。

## 檔名與分類慣例

存進 `assets/library/characters/`，檔名用「情境-受眾/角色」描述（英文 kebab-case），例如：

- `nurse-measuring-vitals-elderly.png`
- `nurse-explaining-to-child-family.png`
- `adult-selfcare-confident.png`

不要用主題名稱命名（例如不要叫 `hypertension-01.png`）——素材庫的插圖要能跨主題重用，檔名應該描述「畫面內容」而不是「用在哪個主題」。
