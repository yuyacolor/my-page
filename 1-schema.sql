-- 在 Supabase Dashboard → SQL Editor 貼上並執行這整份

-- 1. 建立訂單資料表
create table orders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz default now(),

  -- 訂購人資訊
  company_name text not null,
  contact_name text not null,
  mobile text not null,
  phone text,
  email text,

  -- 收件資訊
  receiver_name text,
  receiver_address text,

  -- 發票資訊
  tax_id text,
  invoice_title text,

  -- 品項（三種價格方案，選一種）
  product_tier text not null,       -- '60up' / '30up' / 'normal'
  unit_price integer not null,      -- 630 / 660 / 720
  quantity integer not null,

  subtotal integer not null,        -- 小計
  shipping_fee integer not null,    -- 運費
  total integer not null,           -- 總計

  order_date date,                  -- 訂貨日期
  expected_delivery_date date,      -- 預定到貨日

  status text default 'pending',    -- pending / confirmed / shipped / cancelled
  note text
);

-- 2. 開啟 Row Level Security
alter table orders enable row level security;

-- 3. 允許任何人（含未登入訪客）新增訂單，但不能讀取/修改/刪除
create policy "Anyone can submit an order"
  on orders for insert
  to anon
  with check (true);

-- 注意：沒有建立 select/update/delete 的 policy 給 anon，
-- 代表前台訪客完全看不到、也改不了任何訂單資料 —— 這是刻意的安全設計。

-- 4. 若之後要做「後台管理頁」查看所有訂單，
--    建議另外用 Supabase Auth 建立管理員帳號，
--    並針對該角色（例如透過 email 白名單或自訂 role）另外開一條 select policy，
--    不要對 anon 開放讀取權限。
