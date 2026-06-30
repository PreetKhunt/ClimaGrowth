import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://lwhvtrmcevzayljxxanx.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3aHZ0cm1jZXZ6YXlsanh4YW54Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0NzUzOTQsImV4cCI6MjA5ODA1MTM5NH0.UYimpceeIbK34ypHLRvfCj87oC2GwUekWNSRNoCISqA';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkFarms() {
  const { data, error } = await supabase.from('farms').select('*').limit(1);
  if (error) {
    console.error('Error fetching farms:', error.message, error.details, error.hint);
  } else {
    console.log('Farms data:', data);
    if (data && data.length > 0) {
      console.log('Columns:', Object.keys(data[0]));
    } else {
      console.log('No farms found, cannot deduce columns this way.');
      // Attempt an insert without area_acres to see what fails
      const testInsert = await supabase.from('farms').insert({ name: 'Test Farm' }).select();
      console.log('Insert test result without area_acres:', testInsert.error?.message || 'Success');
      if (testInsert.data) {
          console.log('Columns from insert return:', Object.keys(testInsert.data[0]));
      }
      console.log('Insert test result:', testInsert.error?.message || 'Success');
    }
  }
}

checkFarms();
