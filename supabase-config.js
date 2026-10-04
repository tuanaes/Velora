// Velora Supabase configuration
// Put ONLY your public project URL and PUBLISHABLE key here.
// Never put a Supabase secret/service_role key in this file.

const VELORA_SUPABASE_URL = "PASTE_YOUR_SUPABASE_URL_HERE";
const VELORA_SUPABASE_PUBLISHABLE_KEY = "PASTE_YOUR_SUPABASE_PUBLISHABLE_KEY_HERE";

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
