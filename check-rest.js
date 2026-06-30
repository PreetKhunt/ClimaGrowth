require('dotenv').config({ path: '.env.local' });
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
);

async function checkViaRest() {
  console.log("Checking columns in 'posts'...");
  const { data: posts, error: pErr } = await supabase.from('posts').select('*').limit(1);
  if (pErr) console.error("Posts Error:", pErr);
  else console.log("Posts Columns:", posts.length > 0 ? Object.keys(posts[0]) : "Table empty but accessible");

  console.log("\nChecking columns in 'farms'...");
  const { data: farms, error: fErr } = await supabase.from('farms').select('*').limit(1);
  if (fErr) console.error("Farms Error:", fErr);
  else console.log("Farms Columns:", farms.length > 0 ? Object.keys(farms[0]) : "Table empty but accessible");

  console.log("\nChecking buckets...");
  const { data: buckets, error: bErr } = await supabase.storage.listBuckets();
  if (bErr) console.error("Buckets Error:", bErr);
  else console.log("Buckets:", buckets.map(b => b.name));
}

checkViaRest();
