-- 修正版：解決「admins 表自己的 RLS 擋住了管理員身分檢查」的問題
-- 請在 Supabase Dashboard → SQL Editor 執行整份

-- 1. 建立一個「security definer」函式
--    這種函式會用「建立者的權限」執行，能夠繞過呼叫者的 RLS 限制，
--    專門用來安全地檢查「目前登入的人是不是管理員」
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from admins where admins.user_id = auth.uid()
  );
$$;

-- 2. 刪除舊的、有問題的 policy
drop policy if exists "Admins can view all orders" on orders;
drop policy if exists "Admins can update orders" on orders;

-- 3. 重新建立 policy，改用 is_admin() 函式做檢查
create policy "Admins can view all orders"
  on orders for select
  to authenticated
  using ( is_admin() );

create policy "Admins can update orders"
  on orders for update
  to authenticated
  using ( is_admin() )
  with check ( is_admin() );

-- 完成後，admins 表本身仍然完全不開放前台讀寫（維持安全），
-- 但 orders 表的權限檢查改用這個函式繞過限制，就能正常運作了。
