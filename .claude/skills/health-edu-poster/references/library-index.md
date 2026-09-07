# 素材庫目錄

套版前先查這份清單，比對主題關鍵字選現有素材；真的沒有合適的才照 `prompt-template.md` 補生成，生成後要回來更新這份清單。

## 角色插圖（`assets/library/characters/`）

| 檔名 | 畫面內容 | 適合受眾 | 適合主題關鍵字 | 原始 prompt 摘要 |
|---|---|---|---|---|
| `nurse-measuring-vitals-elderly.png` | 護理師用壓脈帶幫長者量測（血壓計情境） | 長者 | 血壓、生命徵象量測、居家監測類主題 | friendly nurse showing a blood pressure monitor cuff to a smiling elderly patient sitting in a chair |
| `risk-factors-elderly-worried.png` | 長者被薯條、香菸、久坐沙發、壓力雲圍繞，表情擔憂 | 長者 | 慢性病危險因子（高血壓/糖尿病/高血脂共用） | worried but friendly elderly person surrounded by risk factor icons: fries, cigarette, stress cloud, couch potato |
| `daily-selfcare-six-panel.png` | 六格漫畫：飲食、快走、吃藥、量血壓、戒菸限酒 | 長者/成人 | 慢性病日常自我管理類主題（高度可重用） | five/six small friendly scenes: light meal, brisk walking, pill+water, home BP measuring, crossed-out cigarette+wine |
| `organ-complication-badges.png` | 腦、心、腎三個徽章插圖，溫和警示風 | 通用 | 併發症/器官相關警訊類主題 | brain/heart/kidney in soft rounded badges, reassuring not scary |
| `nurse-explaining-to-child-family.png` | 醫師蹲低跟小朋友衛教說明，家長在旁陪伴 | 兒童 | 兒童衛教、疫苗、感染控制、成長發育類主題 | friendly doctor explaining health checkup to a smiling child, parent standing supportively behind |
| `adult-selfcare-confident.png` | 成人自信地做伸展運動，旁邊桌上有居家健康監測儀器 | 成人 | 一般成人自我照護、運動類主題 | confident middle-aged adult stretching with water bottle, home health monitor on table |
| `caregiver-helping-elderly.png` | 醫護人員／照顧者陪伴長者喝水/服藥，沙發居家情境 | 家屬照顧者 | 用藥安全、居家照護、長期照顧類主題 | warm caregiver gently helping an elderly person hold water and a pill at home（注意：AI 生成結果偏向專業醫護形象而非居家家屬，構圖仍可用於「陪伴服藥」情境，若需要更明確的「非專業家屬」形象需重新生成） |

## 圖示庫（`assets/library/icons/icons.svg`）

單一 sprite 檔，用 `<use href="icons.svg#icon-{id}"/>` 引用。24x24 viewBox，`stroke=currentColor`，外層 CSS 控制大小與顏色。

| id | 圖示 | 適合情境 |
|---|---|---|
| `icon-heart` | 心臟＋脈波 | 心臟病、心血管相關警示 |
| `icon-brain` | 腦＋閃電裂痕 | 中風、腦血管、神經類警示 |
| `icon-kidney` | 腎臟 | 腎臟病、泌尿相關警示 |
| `icon-lung` | 肺 | 呼吸道、肺部相關主題 |
| `icon-stomach` | 胃 | 腸胃、消化道相關主題 |
| `icon-pill` | 藥丸膠囊 | 服藥、用藥安全 |
| `icon-scale` | 體重計 | 體重管理、肥胖相關因子 |
| `icon-walking` | 走路人形 | 運動、規律活動 |
| `icon-salt` | 鹽罐 | 飲食控鹽 |
| `icon-no-smoke-drink` | 菸/酒禁止 | 戒菸限酒 |
| `icon-cuff` | 壓脈帶 | 血壓測量（沒有插圖可用時的簡化版） |
| `icon-gauge` | 儀表指針 | 量測/監測類通用圖示 |
| `icon-clock` | 時鐘 | 服藥時間、定期監測提醒 |
| `icon-calendar` | 日曆 | 回診、定期檢查提醒 |
| `icon-warning` | 警示三角 | 需要注意/就醫的警訊 |
| `icon-check` | 勾選圓圈 | 正向確認、已完成項目 |
| `icon-question` | 問號圓圈 | 常見問題、不確定情境 |
| `icon-face-worried` | 擔憂表情 | 情緒/心理狀態類內容 |
| `icon-face-happy` | 開心表情 | 正向鼓勵、狀態良好 |
| `icon-sliders` | 可調整滑桿 | 「可改變的因子」分類標頭 |
| `icon-family` | 兩人剪影 | 「不可改變因子/家族史」分類標頭 |
| `icon-water` | 水滴 | 飲水、體液相關主題 |

## 擴庫紀錄

新增素材時在這裡加一行，並更新上面對應表格。目前尚未有擴庫紀錄（初始庫於 2026-09-07 建立，共 7 張角色插圖＋22 個圖示）。
