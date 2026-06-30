-- Irrigation Configs RLS
CREATE POLICY "Users can view own irrigation_configs" ON irrigation_configs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own irrigation_configs" ON irrigation_configs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own irrigation_configs" ON irrigation_configs FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own irrigation_configs" ON irrigation_configs FOR DELETE USING (auth.uid() = user_id);

-- Posts RLS (Public read, authenticated insert/update/delete)
CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (true);
CREATE POLICY "Users can insert own posts" ON posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = author_id);

-- Post Comments RLS
CREATE POLICY "Anyone can view post_comments" ON post_comments FOR SELECT USING (true);
CREATE POLICY "Users can insert own post_comments" ON post_comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own post_comments" ON post_comments FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own post_comments" ON post_comments FOR DELETE USING (auth.uid() = author_id);

-- Transport Bookings RLS
CREATE POLICY "Users can view own transport_bookings" ON transport_bookings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own transport_bookings" ON transport_bookings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own transport_bookings" ON transport_bookings FOR UPDATE USING (auth.uid() = user_id);

-- Products RLS (Public read, auth write)
CREATE POLICY "Anyone can view products" ON products FOR SELECT USING (true);
CREATE POLICY "Users can insert own products" ON products FOR INSERT WITH CHECK (auth.uid() = seller_id);
CREATE POLICY "Users can update own products" ON products FOR UPDATE USING (auth.uid() = seller_id);
CREATE POLICY "Users can delete own products" ON products FOR DELETE USING (auth.uid() = seller_id);

-- Orders RLS (Users can view their orders either as buyer or seller)
CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = buyer_id OR auth.uid() = seller_id);
CREATE POLICY "Users can insert own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY "Users can update own orders" ON orders FOR UPDATE USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

-- Learning Progress RLS
CREATE POLICY "Users can view own learning_progress" ON learning_progress FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own learning_progress" ON learning_progress FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own learning_progress" ON learning_progress FOR UPDATE USING (auth.uid() = user_id);

-- Notifications RLS
CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own notifications" ON notifications FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own notifications" ON notifications FOR DELETE USING (auth.uid() = user_id);

-- Yield Predictions RLS
CREATE POLICY "Users can view own yield_predictions" ON yield_predictions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own yield_predictions" ON yield_predictions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own yield_predictions" ON yield_predictions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own yield_predictions" ON yield_predictions FOR DELETE USING (auth.uid() = user_id);
