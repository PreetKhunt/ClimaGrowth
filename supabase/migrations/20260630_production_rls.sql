-- ==============================================================================
-- PRODUCTION ENFORCEMENT & RLS RECONCILIATION
-- ==============================================================================

-- 1. Create 'harvest_inventory' table for Task 3
CREATE TABLE IF NOT EXISTS harvest_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    farm_id UUID REFERENCES farms(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity NUMERIC NOT NULL DEFAULT 0,
    unit TEXT NOT NULL,
    warehouse TEXT,
    expiry_date DATE,
    low_stock_threshold NUMERIC,
    images TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. ENABLE RLS ON ALL TABLES
ALTER TABLE farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE transport_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE irrigation_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE harvest_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE yield_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE disease_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- 3. DROP EXISTING POLICIES TO PREVENT CONFLICTS
DO $$ 
DECLARE
    row record;
BEGIN
    FOR row IN SELECT tablename, policyname 
               FROM pg_policies 
               WHERE schemaname = 'public' 
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I', row.policyname, row.tablename);
    END LOOP;
END $$;

-- 4. APPLY STANDARDIZED RLS POLICIES

-- FARMS
CREATE POLICY "Users can view own farms" ON farms FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own farms" ON farms FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own farms" ON farms FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own farms" ON farms FOR DELETE USING (auth.uid() = user_id);

-- TRANSPORT BOOKINGS
CREATE POLICY "Users can view own transport bookings" ON transport_bookings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own transport bookings" ON transport_bookings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own transport bookings" ON transport_bookings FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own transport bookings" ON transport_bookings FOR DELETE USING (auth.uid() = user_id);

-- IRRIGATION CONFIGS
CREATE POLICY "Users can view own irrigation configs" ON irrigation_configs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own irrigation configs" ON irrigation_configs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own irrigation configs" ON irrigation_configs FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own irrigation configs" ON irrigation_configs FOR DELETE USING (auth.uid() = user_id);

-- HARVEST INVENTORY
CREATE POLICY "Users can view own inventory" ON harvest_inventory FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own inventory" ON harvest_inventory FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own inventory" ON harvest_inventory FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own inventory" ON harvest_inventory FOR DELETE USING (auth.uid() = user_id);

-- POSTS (Community)
CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (true);
CREATE POLICY "Users can insert own posts" ON posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = author_id);

-- LEARNING PROGRESS
CREATE POLICY "Users can view own learning progress" ON learning_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own learning progress" ON learning_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own learning progress" ON learning_progress FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own learning progress" ON learning_progress FOR DELETE USING (auth.uid() = user_id);

-- NOTIFICATIONS
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own notifications" ON notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);

-- PRODUCTS (Marketplace)
CREATE POLICY "Anyone can view active products" ON products FOR SELECT USING (true);
CREATE POLICY "Users can insert own products" ON products FOR INSERT WITH CHECK (auth.uid() = seller_id);
CREATE POLICY "Users can update own products" ON products FOR UPDATE USING (auth.uid() = seller_id);
CREATE POLICY "Users can delete own products" ON products FOR DELETE USING (auth.uid() = seller_id);

-- ORDERS
CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = buyer_id);
CREATE POLICY "Users can insert own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY "Users can update own orders" ON orders FOR UPDATE USING (auth.uid() = buyer_id);
CREATE POLICY "Users can delete own orders" ON orders FOR DELETE USING (auth.uid() = buyer_id);

-- POST COMMENTS
CREATE POLICY "Anyone can view comments" ON post_comments FOR SELECT USING (true);
CREATE POLICY "Users can insert own comments" ON post_comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own comments" ON post_comments FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own comments" ON post_comments FOR DELETE USING (auth.uid() = author_id);

-- POST LIKES
CREATE POLICY "Anyone can view likes" ON post_likes FOR SELECT USING (true);
CREATE POLICY "Users can insert own likes" ON post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON post_likes FOR DELETE USING (auth.uid() = user_id);

-- PROFILES
CREATE POLICY "Anyone can view profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = user_id);
-- No delete for profiles typically, or allow owner:
CREATE POLICY "Users can delete own profile" ON profiles FOR DELETE USING (auth.uid() = user_id);

-- REVIEWS
CREATE POLICY "Anyone can view reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can insert own reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reviews" ON reviews FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reviews" ON reviews FOR DELETE USING (auth.uid() = user_id);

-- YIELD PREDICTIONS
CREATE POLICY "Users can view own yield predictions" ON yield_predictions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own yield predictions" ON yield_predictions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own yield predictions" ON yield_predictions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own yield predictions" ON yield_predictions FOR DELETE USING (auth.uid() = user_id);

-- DISEASE SCANS
CREATE POLICY "Users can view own disease scans" ON disease_scans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own disease scans" ON disease_scans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own disease scans" ON disease_scans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own disease scans" ON disease_scans FOR DELETE USING (auth.uid() = user_id);

-- AUDIT LOGS
CREATE POLICY "Users can view own audit logs" ON audit_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own audit logs" ON audit_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

NOTIFY pgrst, 'reload schema';
