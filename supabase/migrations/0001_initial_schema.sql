-- Run this SQL in the Supabase SQL Editor (https://supabase.com/dashboard/project/_/sql)

-- 1. Create a Profiles table to store extended user data
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS) for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update their own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Trigger to automatically create a profile when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', 'https://api.dicebear.com/7.x/avataaars/svg?seed=' || new.id);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 2. Create Farms Table
CREATE TABLE farms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  area TEXT NOT NULL,
  crop TEXT NOT NULL,
  health INTEGER DEFAULT 100,
  water TEXT DEFAULT 'Optimal',
  status TEXT DEFAULT 'Growing',
  lat TEXT,
  lng TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own farms" ON farms FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own farms" ON farms FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own farms" ON farms FOR UPDATE USING (auth.uid() = user_id);

-- 3. Create Posts Table for Community
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  image_url TEXT,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  is_expert BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can insert posts" ON posts FOR INSERT WITH CHECK (auth.uid() = author_id);

-- 4. Insert Mock Data (Optional)
-- (We will leave this empty and let the app populate it naturally, but you can insert manual rows here if desired)
