const { Client } = require('pg');

async function run() {
  const client = new Client({
    connectionString: "postgresql://postgres.lwhvtrmcevzayljxxanx:P1r2e3e4t5!@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres"
  });

  try {
    await client.connect();
    
    // Auto-confirm all unconfirmed users
    const res = await client.query("UPDATE auth.users SET email_confirmed_at = now() WHERE email_confirmed_at IS NULL RETURNING email;");
    console.log("Confirmed users:", res.rows);
    
  } catch (err) {
    console.error("Migration failed", err);
  } finally {
    await client.end();
  }
}

run();
