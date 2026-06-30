const fs = require('fs');
const { Client } = require('pg');

async function runMigration() {
  const connectionString = 'postgresql://postgres:P1r2e3e4t5!@db.lwhvtrmcevzayljxxanx.supabase.co:5432/postgres';
  
  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('Connected to Supabase PostgreSQL');
    
    const sql = fs.readFileSync('supabase/migrations/20260630_rls_policies.sql', 'utf8');
    
    console.log('Executing migration...');
    await client.query(sql);
    
    console.log('Migration executed successfully!');
  } catch (err) {
    console.error('Error executing migration:', err);
  } finally {
    await client.end();
  }
}

runMigration();
