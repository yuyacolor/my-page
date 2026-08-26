-- 在 Supabase Dashboard → SQL Editor 執行
-- 請先確認已經執行過 schema.sql（orders 資料表要先存在）

-- 1. 建立管理員名單表
--    這張表記錄「哪些登入帳號有權限管理訂單」
create table admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  note text,
  created_at timestamptz default now()
);

alter table admins enable row level security;

-- 管理員只能看到自己在名單裡這件事，不開放任何人讀寫這張表（後續都用 Dashboard 手動管理）
-- 不建立任何 policy，等於預設全部拒絕（含管理員自己也不能透過前台讀取這張表）


-- 2. 幫 orders 資料表加上「管理員可以讀取」的規則
create policy "Admins can view all orders"
  on orders for select
  to authenticated
  using ( exists (select 1 from admins where admins.user_id = auth.uid()) );

-- 3. 幫 orders 資料表加上「管理員可以更新訂單狀態」的規則
create policy "Admins can update orders"
  on orders for update
  to authenticated
  using ( exists (select 1 from admins where admins.user_id = auth.uid()) )
  with check ( exists (select 1 from admins where admins.user_id = auth.uid()) );


-- === 設定完成後，怎麼把某個帳號設成管理員 ===
--
-- 1. 先讓該帳號到 signup.html 正常註冊一次（跟一般客戶帳號註冊方式相同）
-- 2. 到 Supabase Dashboard → Authentication → Users，找到該帳號，複製它的 User UID
-- 3. 到 Table Editor → admins → Insert row，把剛剛複製的 UID 貼到 user_id 欄位，儲存
--
-- 之後這個帳號登入 admin.html 後，就能看到並管理所有訂單。
-- 一般客戶帳號（不在 admins 表裡的）即使登入，也完全看不到 orders 資料，
-- 因為前面 schema.sql 裡只開放 insert，這裡新增的 policy 只信任 admins 表裡的人。
