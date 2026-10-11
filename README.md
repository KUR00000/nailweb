# Ivory Nails — Luxury Press-Ons & Polishes (Flutter Web + Supabase + Stripe)

An editorial luxury e-commerce web application for **Ivory Nails**, engineered with **Flutter**, **Supabase Authentication & PostgreSQL Database**, and **Stripe Payment Integration**.

---

## ✨ Features & Architecture

- **Minimalist Editorial Luxury Aesthetic**: Warm porcelain ivory ground (`#FBF9F7`), muted petal blush tones, deep charcoal typography, and refined editorial serif headings.
- **13 Curated Nail Products**: Exact reproduction of all 13 handcrafted nail products from the original atelier prototype with high-resolution imagery, detailed specifications, ratings, and instant category filters (`Press-On`, `Polish`, `Care`).
- **Supabase Authentication**:
  - Email & Password Sign-up, Login, and Password recovery.
  - Profile sync and VIP status tracking.
  - Zero-config **1-Click Demo Mode (Princess VIP)** for immediate testing without requiring API keys.
- **Supabase PostgreSQL Schema (`supabase/schema.sql`)**:
  - `products`: Publicly readable catalog with ratings, inventory flags, and prices.
  - `profiles`: User profiles linked to `auth.users` with automated signup triggers.
  - `orders`: Stripe payment records with customer contact, shipping addresses, and status.
  - `order_items`: Line-item breakdown per completed transaction.
  - Row Level Security (RLS) policies and performance indexes.
- **Stripe Web Payment Integration**:
  - In-app Stripe Web Elements simulation with Luhn check, CVV validation, and 256-bit AES encryption indicators.
  - Hosted Stripe Checkout session launcher via `url_launcher`.
  - Realistic PaymentIntent processing latency and verified transaction receipts (`#IVORY-XXXX`).
- **Interactive Shopping Bag**:
  - Realtime badge counter.
  - Free express packaging progress bar (unlocked at \$50 threshold).
  - Promo code discounts (e.g. `IVORY10` for 10% off, `ATELIER20` for 20% off).
  - Dynamic 8% sales tax calculation.
- **Responsive Architecture**:
  - Fluid adaptivity from mobile smartphones (single column) to tablets (2-3 columns) and widescreen desktop displays (4 columns).

---

## 🚀 Getting Started

### 1. Prerequisites
Ensure you have Flutter 3.x+ installed:
```bash
flutter --version
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App in Demo Mode (Zero Setup Required)
To run immediately in demo mode with pre-seeded data:
```bash
flutter run -d chrome
```

---

## ⚡ Connecting Live Supabase & Stripe

### Step 1: Set up Supabase
1. Create a free project at [supabase.com](https://supabase.com).
2. Go to the **SQL Editor** in your Supabase dashboard.
3. Open [`supabase/schema.sql`](supabase/schema.sql), paste the script into the SQL editor, and click **Run**. This creates the `products`, `profiles`, `orders`, and `order_items` tables, Row-Level Security policies, and inserts all 13 products.
4. Copy your **Project URL** and **Anon Key** from **Project Settings > API**.

### Step 2: Set up Stripe
1. Retrieve your **Publishable Key** from your [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys).

### Step 3: Run with Environment Variables
Launch Flutter with your live credentials:
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
```

### Step 4: Build for Production Web Deployment
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
```
Deploy the generated `build/web/` folder to Vercel, Netlify, Cloudflare Pages, or Supabase Storage!

---

## 📂 Project Directory Structure

```
├── lib/
│   ├── main.dart                          # App entry point & provider bootstrap
│   ├── core/
│   │   ├── constants/app_constants.dart   # API keys & store constants
│   │   └── theme/app_theme.dart           # Editorial luxury styling & typography
│   ├── models/
│   │   ├── product.dart                   # 13 verified items & JSON schema
│   │   ├── cart_item.dart                 # Shopping bag item model
│   │   └── order.dart                     # Stripe order & order items model
│   ├── services/
│   │   ├── supabase_service.dart          # Supabase Auth, DB & demo mock fallback
│   │   └── stripe_service.dart            # Stripe payment session & validation
│   ├── providers/
│   │   ├── auth_provider.dart             # Auth session & VIP status state
│   │   ├── cart_provider.dart             # Bag items, tax & shipping calculations
│   │   └── catalog_provider.dart          # Product search, categories & sorting
│   └── views/
│       ├── home/home_screen.dart          # Sticky header, hero & responsive grid
│       ├── catalog/widgets/product_card.dart # Hoverable luxury product card
│       ├── product_detail/product_detail_dialog.dart # Craftsmanship specs & quick-add
│       ├── cart/cart_sheet.dart           # Slide-over shopping bag & promo codes
│       ├── checkout/checkout_modal.dart   # Stripe card form & order receipt
│       ├── auth/auth_modal.dart           # Supabase email login & VIP demo toggle
│       └── orders/order_history_modal.dart # Customer order history & receipts
├── supabase/
│   └── schema.sql                         # PostgreSQL schema, RLS & seed data
├── web/
│   ├── index.html                         # Tailored HTML, Stripe.js & loader
│   └── manifest.json                      # PWA web manifest
├── pubspec.yaml                           # Flutter dependencies
└── PRODUCT.md                             # Product specifications & design system architecture
```
