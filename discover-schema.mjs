import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://lwhvtrmcevzayljxxanx.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3aHZ0cm1jZXZ6YXlsanh4YW54Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0NzUzOTQsImV4cCI6MjA5ODA1MTM5NH0.UYimpceeIbK34ypHLRvfCj87oC2GwUekWNSRNoCISqA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function probeColumn(colName) {
  const payload = { name: 'Test' };
  payload[colName] = 10;
  const res = await supabase.from('farms').insert(payload);
  if (res.error?.message.includes('Could not find the')) {
    console.log(`[NO] Column '${colName}' does NOT exist.`);
  } else if (res.error?.message.includes('row-level security')) {
    console.log(`[YES] Column '${colName}' EXISTS (hit RLS).`);
  } else {
    console.log(`[?] Column '${colName}' returned: ${res.error?.message || 'Success'}`);
  }
}

async function discover() {
  const colsToTry = ['area', 'area_acres', 'acreage', 'farm_area', 'size', 'size_acres', 'land_area'];
  for (const col of colsToTry) {
    await probeColumn(col);
  }
}

discover();
