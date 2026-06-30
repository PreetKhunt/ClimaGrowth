const fs = require('fs');
const { Client } = require('pg');

async function run() {
  const connectionString = 'postgresql://postgres.lwhvtrmcevzayljxxanx:P1r2e3e4t5!@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres';
  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });
  
  await client.connect();
  const sql = fs.readFileSync('supabase/migrations/20260630_final_schema_fixes.sql', 'utf8');
  await client.query(sql);
  console.log('Migration completed successfully!');
  await client.end();
}

run().catch(console.error);
