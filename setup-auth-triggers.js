const { Client } = require('pg');
async function run() {
  const client = new Client({
    connectionString: 'postgresql://postgres.lwhvtrmcevzayljxxanx:P1r2e3e4t5!@aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres',
    ssl: { rejectUnauthorized: false }
  });
  await client.connect();
  
  const sql = `
    -- 1. Auto-Confirm Users
    CREATE OR REPLACE FUNCTION public.auto_confirm_user()
    RETURNS trigger AS $$
    BEGIN
      NEW.email_confirmed_at = NOW();
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;

    DROP TRIGGER IF EXISTS auto_confirm_user_trigger ON auth.users;
    CREATE TRIGGER auto_confirm_user_trigger
    BEFORE INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user();

    -- 2. Auto-Create Profile
    CREATE OR REPLACE FUNCTION public.handle_new_user()
    RETURNS trigger AS $$
    BEGIN
      INSERT INTO public.profiles (user_id, id, full_name, email, role, created_at)
      VALUES (
        NEW.id,
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'New Farmer'),
        NEW.email,
        'Farmer',
        NOW()
      );
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;

    DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
    CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
  `;
  
  await client.query(sql);
  console.log("Database triggers for auto-confirm and profile creation applied successfully.");
  
  await client.end();
}
run().catch(console.error);
