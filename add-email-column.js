const { Client } = require('pg');
async function run() {
  const client = new Client({
    connectionString: 'postgresql://postgres.lwhvtrmcevzayljxxanx:P1r2e3e4t5!@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres',
    ssl: { rejectUnauthorized: false }
  });
  await client.connect();
  
  // Add email column to profiles
  await client.query(`ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email text;`);
  
  // Update existing rows if any
  console.log("Added email column to profiles");
  
  await client.end();
}
run().catch(console.error);
