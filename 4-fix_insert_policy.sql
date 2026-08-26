-- 修正：讓 order.html 不管使用者有沒有登入都能正常送出訂單
-- 請在 Supabase Dashboard → SQL Editor 執行

drop policy if exists "Anyone can submit an order" on orders;

create policy "Anyone can submit an order"
  on orders for insert
  to public          -- public 涵蓋所有角色：anon（訪客）+ authenticated（已登入）
  with check (true);

-- 說明：這張訂購單本來就設計成任何人都能填、不需要登入，
-- 所以不管填單的人有沒有登入過其他帳號，都應該能成功送出。
-- 這不影響安全性 —— 送出訂單本來就是要開放給所有人的動作，
-- 真正需要保護的是「讀取/修改」訂單，那部分維持只有管理員能做，沒有變動。
