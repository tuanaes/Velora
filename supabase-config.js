// Velora Supabase configuration
// Put ONLY your public project URL and PUBLISHABLE key here.
// Never put a Supabase secret/service_role key in this file.

const VELORA_SUPABASE_URL = "https://rsneuogdincsqflqaqqv.supabase.co";
const VELORA_SUPABASE_PUBLISHABLE_KEY = "sb_publishable_6EnyT_urYcFA-rYVgS8g9w_XZrkAv3c";

let supabaseClient = null;
if (
  typeof window.supabase !== "undefined" &&
  !VELORA_SUPABASE_URL.includes("PASTE_") &&
  !VELORA_SUPABASE_PUBLISHABLE_KEY.includes("PASTE_")
) {
  supabaseClient = window.supabase.createClient(
    VELORA_SUPABASE_URL,
    VELORA_SUPABASE_PUBLISHABLE_KEY,
    { auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true } }
  );
}
