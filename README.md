# GitHub Pages + Supabase Sample（帳號系統 + 線上訂購單）

純前端（HTML + JS），沒有任何後端程式碼。帳號驗證交給 Supabase Auth，
訂單資料直接寫入 Supabase 資料庫（PostgreSQL）。

## 檔案說明

- `index.html`　登入頁
- `signup.html`　註冊頁
- `dashboard.html`　登入後頁面，可修改密碼、登出
- `order.html`　**線上訂購單**（鳳凰酥禮盒範例，對應紙本表單，自動計算金額，送出後存進 Supabase）
- `admin.html`　**後台管理頁**（需登入且為管理員身分，可查看所有訂單、標記核銷/出貨狀態）
- `schema.sql`　建立訂單資料表用的 SQL，在 Supabase 執行一次即可
- `schema_admin.sql`　建立管理員權限用的 SQL，**要在 schema.sql 之後才執行**
- `config.js`　放你的 Supabase 連線資訊（**這是唯一需要修改的檔案**）

`order.html` 不需要登入即可填寫送出，跟帳號系統是各自獨立的功能。

## 步驟一：建立 Supabase 專案

1. 到 https://supabase.com → Sign in（建議用 GitHub 帳號）
2. New organization（若還沒有）→ New project
3. 填專案名稱、設一組資料庫密碼、Region 選 Singapore
4. 建立完成後，左側選單 **Settings → API**，複製兩個值：
   - `Project URL`
   - `anon public` key（不是 `service_role`，那組不能外流）

## 步驟二：確認 Email Auth 是開著的

1. 左側選單 **Authentication → Providers**
2. 確認 **Email** 是 Enabled（預設就是開的，不用另外設定）

> 預設情況下，Supabase 註冊後會寄一封驗證信，使用者要點信裡的連結才能登入。
> 如果你只是要快速測試、不想處理收信驗證這件事，可以到
> **Authentication → Settings → 找到「Confirm email」選項關閉**，
> 這樣註冊後可以直接登入，跳過信箱驗證（正式上線建議還是開著）。

## 步驟三：建立訂單資料表（若要使用 order.html）

1. Supabase Dashboard → 左側選單 **SQL Editor**
2. 開新的 query，把 `schema.sql` 整份內容貼進去
3. 按 **Run** 執行

執行後會建立一張 `orders` 資料表，並設定好安全規則（RLS）：
- 任何人都能**送出**訂單（insert）
- 但沒有人能透過前台**讀取**別人的訂單資料（select），保護客戶資料不外洩

之後要查看所有訂單，直接在 Supabase Dashboard → **Table Editor → orders** 用管理員身分查看即可，
不需要另外做後台頁面。

## 步驟 3.5：設定管理員權限（若要使用 admin.html 後台）

1. SQL Editor 貼上 `schema_admin.sql` 的內容並執行（要在上一步 `schema.sql` 之後執行）
2. 到 `signup.html` 用你自己要當管理員的 email 正常註冊一個帳號
3. Supabase Dashboard → **Authentication → Users**，找到剛剛註冊的帳號，複製它的 **User UID**
4. Supabase Dashboard → **Table Editor → admins → Insert row**，把 User UID 貼到 `user_id` 欄位，儲存

設定完成後，用這個帳號登入即可看到 `admin.html` 的訂單列表。
其他一般帳號即使登入，也完全看不到任何訂單資料 —— 這是資料庫層級擋下的，不是前端隱藏而已。

## 步驟四：填入 config.js

打開 `config.js`，把裡面的兩行換成你自己的：

```js
const SUPABASE_URL = "https://xxxxxxxxxxxx.supabase.co";
const SUPABASE_ANON_KEY = "your-anon-public-key-here";
```

## 步驟五：發布到 GitHub Pages

1. GitHub 建一個新 repo（Public）
2. 把這 6 個檔案（`index.html`, `signup.html`, `dashboard.html`, `order.html`, `admin.html`, `config.js`）上傳進去
   （`schema.sql`、`schema_admin.sql` 不用上傳到 GitHub，那兩份只是給你在 Supabase 執行一次用的）
3. repo 的 **Settings → Pages**
4. Source 選 **Deploy from a branch**，Branch 選 `main` / `(root)`，Save
5. 等 1-2 分鐘，網址會是 `https://<你的帳號>.github.io/<repo名稱>/`

## 測試流程 — 帳號系統

1. 開啟網址 → 進到登入頁
2. 點「註冊新帳號」→ 輸入 email/密碼 → 註冊
3. （若沒關閉 email 驗證）去信箱點驗證連結
4. 回登入頁登入 → 進入會員中心
5. 在會員中心輸入新密碼 → 更新密碼
6. 登出 → 用新密碼再登入一次，確認有生效

## 測試流程 — 線上訂購單

1. 開啟 `order.html`（例如 `https://<你的帳號>.github.io/<repo名稱>/order.html`）
2. 填公司名稱、聯絡人、手機等欄位
3. 選擇價格方案（60 盒以上／30 盒以上／一般價），輸入數量
4. 確認畫面上自動計算的小計/運費/總計是否正確
5. 送出後，回 Supabase Dashboard → **Table Editor → orders**，確認這筆訂單有進來

## 測試流程 — 後台管理

1. 用已設定為管理員的帳號到 `index.html` 登入
2. 手動把網址列改成 `admin.html`（例如 `https://<你的帳號>.github.io/<repo名稱>/admin.html`）
3. 應該能看到所有客戶送出的訂單列表，以及各狀態的統計卡片
4. 挑一筆訂單，把狀態下拉選單改成「已核銷」，按更新，確認狀態有變更成功
5. 換一個**沒有**加進 admins 表的帳號登入 admin.html，應該會看到「無法讀取訂單」的錯誤，
   確認一般帳號真的看不到別人的訂單資料

## 之後可以擴充的方向

- **登入自動導向**：目前登入後固定跳去 `dashboard.html`，管理員要手動改網址到 `admin.html`；
  之後可以判斷登入帳號是否在 `admins` 表裡，自動導向不同頁面
- **Email 通知**：客戶送出訂單後自動寄確認信、核銷後自動通知客戶
  （需要搭配 Supabase Edge Functions 或第三方寄信服務）
- **多品項商品**：目前是單一商品（鳳凰酥禮盒）三種價格方案，若之後要賣多種禮盒，
  資料表結構要改成 `products` + `order_items` 兩張表
- **匯出報表**：admin.html 加一個「匯出 Excel/CSV」按鈕，方便對帳

## 安全提醒

- `config.js` 裡的 `anon key` 是設計成可以公開的（它本來就會被瀏覽器看到），
  但真正的資料保護要靠 Supabase 的 **RLS 規則**，不是靠藏 key。
- 千萬不要把 `service_role key` 放進任何前端檔案，那組 key 擁有完整資料庫權限。
