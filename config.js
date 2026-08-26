// ⚠️ 請填入你自己 Supabase 專案的資訊
// 位置：Supabase Dashboard → Settings → API
// SUPABASE_URL      → Project URL
// SUPABASE_ANON_KEY → anon / public key（不是 service_role key！）

const SUPABASE_URL = "https://Supabase Project ID.supabase.co";
const SUPABASE_ANON_KEY = "Supabase anon API key";

const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
