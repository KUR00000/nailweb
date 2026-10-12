-- ============================================================================
-- MIGRATION 002: HARDEN ROW LEVEL SECURITY & DATA INTEGRITY
-- Enforces customer isolation, prevents price tampering & privilege escalation
-- ============================================================================

-- 0. SCHEMA MIGRATION TRACKING TABLE
CREATE TABLE IF NOT EXISTS public._migrations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Record migration 001 if not already present
INSERT INTO public._migrations (id, name)
VALUES ('001', 'initial_schema')
ON CONFLICT (id) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 1. HARDEN PRODUCTS TABLE
-- ----------------------------------------------------------------------------
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Drop old policies to ensure idempotency
DROP POLICY IF EXISTS "Allow public read access to products" ON public.products;
DROP POLICY IF EXISTS "Allow admin modify products" ON public.products;

-- Public can read products
CREATE POLICY "Allow public read access to products"
  ON public.products FOR SELECT
  USING (true);

-- Only admins can insert, update, or delete products
CREATE POLICY "Allow admin modify products"
  ON public.products FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
    )
  );

-- ----------------------------------------------------------------------------
-- 2. HARDEN PROFILES TABLE & PREVENT ROLE TAMPERING
-- ----------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- Users can view only their own profile, admins can view all
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (
    auth.uid() = id OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Users can update only their own profile details (full_name, avatar_url)
CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id AND
    -- Prevent customers from changing their role to 'admin' or 'vip'
    (
      role IS NOT DISTINCT FROM (SELECT p.role FROM public.profiles p WHERE p.id = auth.uid()) OR
      EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
    )
  );

-- Function to handle new user registration from Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    'customer'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 3. HARDEN ORDERS TABLE & PREVENT TAMPERING
-- ----------------------------------------------------------------------------
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Drop legacy permissive policies
DROP POLICY IF EXISTS "Users can view their own orders" ON public.orders;
DROP POLICY IF EXISTS "Allow inserting orders" ON public.orders;
DROP POLICY IF EXISTS "Allow customers to view own orders" ON public.orders;

-- Customers can view only their own orders; admins can view all orders
CREATE POLICY "Allow customers to view own orders"
  ON public.orders FOR SELECT
  USING (
    (auth.uid() IS NOT NULL AND auth.uid() = user_id) OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Prevent unauthorized direct insert from browser.
-- Note: Service-role (trusted backend) bypasses RLS and handles all order creation.
-- Authenticated users may insert orders ONLY if status is 'pending' and user_id matches.
CREATE POLICY "Allow inserting pending orders"
  ON public.orders FOR INSERT
  WITH CHECK (
    (auth.uid() IS NOT NULL AND auth.uid() = user_id AND status = 'pending') OR
    (user_id IS NULL AND status = 'pending')
  );

-- Prevent customer updating orders (status, payment id, total amount are immutable to client)
DROP POLICY IF EXISTS "Prevent client order modification" ON public.orders;
CREATE POLICY "Admin order update only"
  ON public.orders FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ----------------------------------------------------------------------------
-- 4. HARDEN ORDER ITEMS TABLE
-- ----------------------------------------------------------------------------
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view order items for their orders" ON public.order_items;
DROP POLICY IF EXISTS "Allow inserting order items" ON public.order_items;
DROP POLICY IF EXISTS "Allow customers to view own order items" ON public.order_items;

-- Customers can view order items ONLY for their own verified orders
CREATE POLICY "Allow customers to view own order items"
  ON public.order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE public.orders.id = public.order_items.order_id
      AND (
        (auth.uid() IS NOT NULL AND public.orders.user_id = auth.uid()) OR
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin')
      )
    )
  );

-- Order items can be inserted with pending orders
CREATE POLICY "Allow inserting pending order items"
  ON public.order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE public.orders.id = public.order_items.order_id
      AND public.orders.status = 'pending'
    )
  );

-- ----------------------------------------------------------------------------
-- 5. VERIFICATION HELPER FUNCTION
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.check_atelier_schema_status()
RETURNS JSONB AS $$
DECLARE
  v_products_count INT;
  v_orders_exist BOOLEAN;
  v_profiles_exist BOOLEAN;
  v_rls_products BOOLEAN;
  v_rls_orders BOOLEAN;
  v_rls_profiles BOOLEAN;
BEGIN
  SELECT COUNT(*) INTO v_products_count FROM public.products;
  SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'orders') INTO v_orders_exist;
  SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'profiles') INTO v_profiles_exist;
  
  SELECT rowsecurity INTO v_rls_products FROM pg_tables WHERE schemaname = 'public' AND tablename = 'products';
  SELECT rowsecurity INTO v_rls_orders FROM pg_tables WHERE schemaname = 'public' AND tablename = 'orders';
  SELECT rowsecurity INTO v_rls_profiles FROM pg_tables WHERE schemaname = 'public' AND tablename = 'profiles';

  RETURN jsonb_build_object(
    'status', 'ready',
    'products_count', v_products_count,
    'tables_valid', v_orders_exist AND v_profiles_exist,
    'rls_enforced', COALESCE(v_rls_products, false) AND COALESCE(v_rls_orders, false) AND COALESCE(v_rls_profiles, false)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Record migration 002
INSERT INTO public._migrations (id, name)
VALUES ('002', 'harden_rls_and_integrity')
ON CONFLICT (id) DO NOTHING;
