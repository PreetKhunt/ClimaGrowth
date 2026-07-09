const { createClient } = require('@supabase/supabase-js');
const { Client: PgClient } = require('pg');
require('dotenv').config({ path: '.env.local' });

async function testAuthFlow() {
  console.log("Starting Auth Flow Test...");

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  const dbUrl = 'postgresql://postgres.lwhvtrmcevzayljxxanx:P1r2e3e4t5!@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres';

  if (!supabaseUrl || !supabaseKey) {
    console.error("Missing Supabase Env Vars!");
    return;
  }
  
  console.log("Supabase URL in use:", supabaseUrl);

  const supabase = createClient(supabaseUrl, supabaseKey);
  const pgClient = new PgClient({ connectionString: dbUrl, ssl: { rejectUnauthorized: false } });
  
  await pgClient.connect();

  const testEmail = `testuser_${Date.now()}@example.com`;
  const testPassword = `SecurePass123!`;

  console.log(`\n--- 1. Registering user: ${testEmail} ---`);
  const { data: signUpData, error: signUpError } = await supabase.auth.signUp({
    email: testEmail,
    password: testPassword,
    options: {
      data: { full_name: 'Test Auto User' }
    }
  });

  if (signUpError) {
    console.error("SignUp Failed:", signUpError.message);
    await pgClient.end();
    return;
  }

  const userId = signUpData.user.id;
  console.log("User registered with ID:", userId);

  console.log(`\n--- 2. Verifying auth.users and email_confirmed_at ---`);
  const userResult = await pgClient.query(`SELECT email, email_confirmed_at FROM auth.users WHERE id = $1`, [userId]);
  if (userResult.rows.length === 0) {
    console.error("User not found in auth.users!");
  } else {
    console.log("User Row:", userResult.rows[0]);
  }

  console.log(`\n--- 3. Verifying profiles table creation ---`);
  const profileResult = await pgClient.query(`SELECT * FROM public.profiles WHERE user_id = $1`, [userId]);
  if (profileResult.rows.length === 0) {
    console.error("Profile NOT CREATED for user!");
  } else {
    console.log("Profile Row:", profileResult.rows[0]);
  }

  console.log(`\n--- 4. Attempting immediate login ---`);
  const { data: signInData, error: signInError } = await supabase.auth.signInWithPassword({
    email: testEmail,
    password: testPassword
  });

  if (signInError) {
    console.error("Login Failed:", signInError.message);
  } else {
    console.log("Login Successful! Session generated.");
  }

  await pgClient.end();
}

testAuthFlow().catch(console.error);
