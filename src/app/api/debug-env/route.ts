import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    supabaseUrl: process.env.NEXT_PUBLIC_SUPABASE_URL || 'missing',
    anonKeyPrefix: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ? process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY.substring(0, 10) : 'missing'
  });
}
