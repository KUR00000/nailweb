-- ============================================================================
-- IVORY NAILS — SUPABASE POSTGRESQL SCHEMA & SEED DATA
-- Luxury Press-Ons & Polishes Digital Atelier
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ----------------------------------------------------------------------------
-- 1. PRODUCTS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
  category TEXT NOT NULL CHECK (category IN ('Polish', 'Press-On', 'Care')),
  rating NUMERIC(3, 2) NOT NULL DEFAULT 4.9,
  review_count INT NOT NULL DEFAULT 42,
  image_url TEXT NOT NULL,
  description TEXT NOT NULL,
  details TEXT,
  in_stock BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast category filtering and sorting
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);
CREATE INDEX IF NOT EXISTS idx_products_price ON public.products(price);

-- Enable RLS for products (Public read access)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to products"
  ON public.products FOR SELECT
  USING (true);

-- ----------------------------------------------------------------------------
-- 2. USER PROFILES TABLE (Mirrors Supabase Auth Users)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'vip', 'admin')),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Trigger to automatically create a profile row on auth.users sign-up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    'customer'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ----------------------------------------------------------------------------
-- 3. ORDERS TABLE (Stripe Checkout Records)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.orders (
  id TEXT PRIMARY KEY, -- e.g. 'IVORY-8492'
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  customer_email TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  subtotal NUMERIC(10, 2) NOT NULL,
  tax NUMERIC(10, 2) NOT NULL,
  shipping NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  total_amount NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'paid' CHECK (status IN ('pending', 'paid', 'preparing', 'shipped', 'delivered', 'cancelled')),
  stripe_payment_id TEXT,
  shipping_address JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own orders"
  ON public.orders FOR SELECT
  USING (auth.uid() = user_id OR auth.role() = 'anon');

CREATE POLICY "Allow inserting orders"
  ON public.orders FOR INSERT
  WITH CHECK (true);

-- ----------------------------------------------------------------------------
-- 4. ORDER ITEMS TABLE
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id TEXT NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL REFERENCES public.products(id),
  product_name TEXT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10, 2) NOT NULL,
  total_price NUMERIC(10, 2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view order items for their orders"
  ON public.order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE public.orders.id = public.order_items.order_id
      AND (public.orders.user_id = auth.uid() OR auth.role() = 'anon')
    )
  );

CREATE POLICY "Allow inserting order items"
  ON public.order_items FOR INSERT
  WITH CHECK (true);

-- ----------------------------------------------------------------------------
-- 5. SEED DATA: Exactly 13 Curated Luxury Products
-- ----------------------------------------------------------------------------
INSERT INTO public.products (id, name, price, category, rating, review_count, image_url, description, details, in_stock)
VALUES
  (
    'p1',
    'Baby Blossom Polish',
    14.50,
    'Polish',
    4.9,
    48,
    'https://images.unsplash.com/photo-1604654894610-df63bc536371?auto=format&fit=crop&w=800&q=80',
    'Soft pastel pink shade with ultra-shiny gloss finish.',
    '15ml bottle. 10-Free, vegan, and cruelty-free formula. Long-wearing gel-effect gloss without UV lamp required.',
    true
  ),
  (
    'p2',
    'Rose Quartz Press-Ons',
    24.00,
    'Press-On',
    5.0,
    64,
    'https://images.unsplash.com/photo-1632345031435-8727f6897d53?auto=format&fit=crop&w=800&q=80',
    'Elegant almond-shaped nails with genuine quartz shimmer.',
    'Set of 30 salon-grade acrylic press-ons with 15 custom sizes. Includes adhesive tabs, nail glue, cuticle stick, and prep pad.',
    true
  ),
  (
    'p3',
    'Milky Glaze Topcoat',
    12.00,
    'Care',
    4.8,
    39,
    'https://images.unsplash.com/photo-1519014816548-bf5fe059798b?auto=format&fit=crop&w=800&q=80',
    'Semi-translucent pearl shine coat for a glazed donut finish.',
    'Fast-drying mirror shine topcoat infused with nourishing keratin and vitamin E for cuticle barrier protection.',
    true
  ),
  (
    'p4',
    'Petal Pink Shimmer',
    16.00,
    'Polish',
    4.9,
    52,
    'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    'Fine gold specks infused inside sweet cherry blossom pink.',
    'Micro-refined mineral mica creates a dimensional light-catching glow suitable for day and evening wear.',
    true
  ),
  (
    'p5',
    'Pearl Radiance Nails',
    26.50,
    'Press-On',
    5.0,
    71,
    'https://images.unsplash.com/photo-1607779097040-26e80aa78e66?auto=format&fit=crop&w=800&q=80',
    'Coquette pearl studs with delicate soft pink tip artwork.',
    'Handcrafted 3D pearl embellishments secured with flexible acrylic resin. Reusable up to 5 wears with proper care.',
    true
  ),
  (
    'p6',
    'Cute Blush Gloss',
    15.00,
    'Polish',
    4.7,
    33,
    'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?auto=format&fit=crop&w=800&q=80',
    'Quick-drying jelly finish formula with a flush of rosy tint.',
    'Sheer buildable watercolor tint designed for Korean and Japanese-style syrup nail gradients.',
    true
  ),
  (
    'p7',
    'Soft Marshmallow Dip',
    18.00,
    'Care',
    4.9,
    41,
    'https://images.unsplash.com/photo-1508746829417-e6f548d8d6ed?auto=format&fit=crop&w=800&q=80',
    'Nourishing powder dip system for extra strong pastel nails.',
    'Fortified with calcium and organic jojoba extract. Reinforces brittle, damaged natural nails for up to 3 weeks.',
    true
  ),
  (
    'p8',
    'Velvet Ballet Polish',
    14.00,
    'Polish',
    4.8,
    45,
    'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?auto=format&fit=crop&w=800&q=80',
    'Creamy ballet slipper pink that pairs with every outfit.',
    'Full-coverage opaque crème in two effortless coats. Streak-free paddle brush designed for precise cuticle hugging.',
    true
  ),
  (
    'p9',
    'Sparkle Dust Gloss',
    13.50,
    'Polish',
    4.6,
    29,
    'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80',
    'Holographic glitter topper designed for accent nails.',
    'Ultra-fine prismatic suspension that layers smoothly over any base shade without grittiness or peeling.',
    true
  ),
  (
    'p10',
    'French Vanilla Press-Ons',
    22.00,
    'Press-On',
    4.9,
    58,
    'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80',
    'Classic micro-french tips with soft cream and pastel blush.',
    'Natural short oval silhouette featuring ultra-thin cuticle borders for an undetectable salon-fresh finish.',
    true
  ),
  (
    'p11',
    'Berry Sweet Gloss',
    15.50,
    'Polish',
    4.8,
    37,
    'https://images.unsplash.com/photo-1583241801142-113b9f5bbde5?auto=format&fit=crop&w=800&q=80',
    'Juicy strawberry-pink hue with high shine UV protection.',
    'Infused with raspberry seed oil for cuticle hydration. Non-yellowing UV inhibitors maintain fresh vibrant tone.',
    true
  ),
  (
    'p12',
    'Cotton Candy Polish',
    14.00,
    'Polish',
    4.7,
    34,
    'https://images.unsplash.com/photo-1610992015732-2449b76344bc?auto=format&fit=crop&w=800&q=80',
    'Playful light pastel pink with subtle violet undertones.',
    'Creamy pastel formulation engineered for chip resistance up to 9 days without topcoat re-application.',
    true
  ),
  (
    'p13',
    'Angel Wing Glaze',
    28.00,
    'Press-On',
    5.0,
    89,
    'https://images.unsplash.com/photo-1560869713-7d0a29430803?auto=format&fit=crop&w=800&q=80',
    'Luxury handcrafted 3D angel wing accents & aurora foil.',
    'Haute couture editorial nail set. Sculpted 3D wings, crystal accents, and iridescent aurora reflective foil.',
    true
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  price = EXCLUDED.price,
  category = EXCLUDED.category,
  rating = EXCLUDED.rating,
  review_count = EXCLUDED.review_count,
  image_url = EXCLUDED.image_url,
  description = EXCLUDED.description,
  details = EXCLUDED.details,
  in_stock = EXCLUDED.in_stock;
