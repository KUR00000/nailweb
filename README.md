# Ivory Nails Atelier — Luxury Press-Ons & Polishes

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-BYOK%20Auth%20%26%20Postgres-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Stripe](https://img.shields.io/badge/Stripe-BYOK%20Checkout-635BFF?logo=stripe&logoColor=white)](https://stripe.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Visibility](https://img.shields.io/badge/Visibility-Public-green.svg)](https://github.com/KUR00000/nailweb)

An editorial haute-couture e-commerce web application for **Ivory Nails Atelier**, crafted with **Flutter Web**, backed by **Supabase Authentication & PostgreSQL Database**, and secured with **Stripe Payments**.

Now equipped with a production-ready **Bring Your Own Keys (BYOK)** zero-UI integration system. Store owners can connect their own Supabase, Google OAuth, and Stripe accounts simply by providing their public keys in a local `.env.json` file.

---

## Highlights & Features

- **Editorial Luxury Aesthetic**: Warm porcelain ground (`#FBF9F7`), charcoal noir typography (`#1C1917`), muted petal blush tones (`#B57770`), and atelier gold accents (`#B8966E`).
- **100% Vector Geometry**: Zero emoji or unicode glyph fallbacks — authored mathematical vector stars, clean geometric badges, and optically aligned 40px navbar controls.
- **13 Curated Creations**: Complete catalog of handcrafted press-on nails and 10-Free micro-milled lacquers with authentic salon manicure photography, individual finish descriptions, and color swatch indicators.
- **Interactive Shade Palette Bar**: Filter creations dynamically by live color dots (Rose Quartz, Glazed Pearl, Ballet Crème, Cherry Fleck, Strawberry Glass, Baby Blossom, Angel Aurora).
- **Zero-UI BYOK Architecture**: No clumsy integration dashboards, settings forms, or wizard screens in the storefront. Configure credentials purely via file, launch the app, and integrations initialize automatically.
- **Dual-Mode Backend Architecture**:
  - **Zero-Config Atelier Demo Mode**: Fully functional offline/local fallback with a 1-click VIP test account, in-memory mock catalog, isolated demo orders, and simulated Stripe checkout that generates verified receipts.
  - **Live Cloud Production Sync**: Connects customer-owned Supabase projects (Auth, Realtime, hardened RLS), Google OAuth, and Stripe accounts.
- **Hardened Row-Level Security (`supabase/schema.sql`)**:
  - Restricts customer access to their own profiles and orders.
  - Eliminates anonymous query access to orders and prevents client-side tampering with order totals, prices, or payment statuses.
  - Restricts product and inventory catalog modification to authorized administrators.
  - Migration tracking (`_migrations` table) and idempotency guards safe to retry.
- **Trusted Payments Backend**: Server-side Stripe Checkout Session creation, cryptographic webhook signature verification (`STRIPE_WEBHOOK_SECRET`), duplicate delivery idempotency, and price-tampering protection. Available as Supabase Edge Functions (`supabase/functions/`) or lightweight standalone service (`server/`).
- **Responsive Web-First Layout**: Adaptive layout spanning mobile smartphones (1 column), tablets (2–3 columns), and widescreen desktop monitors (4 columns).

> [!TIP]
> **Looking for the dedicated deployment runbook?** See [**PRODUCTION_README.md**](PRODUCTION_README.md) for step-by-step setup instructions for non-technical store owners and DevOps engineers.

---

## 🔐 BYOK Architecture & Security Model

The application strictly separates **Public Frontend Configuration** from **Privileged Backend Secrets**:

```
┌────────────────────────────────────────────────────────┐
│               FLUTTER WEB FRONTEND                     │
│               (.env.json / Public)                     │
│  - APP_MODE: "production"                              │
│  - SUPABASE_URL: Customer's project URL                │
│  - SUPABASE_PUBLISHABLE_KEY: Customer's anon key       │
│  - GOOGLE_CLIENT_ID: Web OAuth Client ID               │
│  - STRIPE_PUBLISHABLE_KEY: Customer's pk_test_... key  │
│  - PAYMENTS_BACKEND_URL: Trusted API endpoint          │
└──────────────────────────┬─────────────────────────────┘
                           │ (Never transmits secret keys)
                           ▼
┌────────────────────────────────────────────────────────┐
│               TRUSTED BACKEND LAYER                    │
│      (Supabase Edge Functions OR server/ Node.js)      │
│  - STRIPE_SECRET_KEY (sk_...)                          │
│  - STRIPE_WEBHOOK_SECRET (whsec_...)                   │
│  - SUPABASE_SERVICE_ROLE_KEY                           │
│                                                        │
│  • Authoritative product pricing & tax calculations    │
│  • Stripe Checkout Session generation                  │
│  • Cryptographic Webhook signature verification        │
│  • Idempotent order status updates                     │
└────────────────────────────────────────────────────────┘
```

### ⚠️ Critical Flutter Web Security Note
A local `.env.json` in a web browser is **not private**. Any credential bundled into Flutter Web or served publicly can be inspected by browser dev tools.
- **Allowed in `.env.json`**: Only publishable, client-safe keys (`pk_test_...`, Supabase anon key, Google client ID, URLs).
- **Forbidden in `.env.json`**: Service role keys, Stripe secret keys (`sk_...`), database passwords, Google client secrets, and webhook signing secrets. Privileged secrets belong exclusively in your backend environment!

---

## 📄 File-Based Configuration Schema

To connect your own services, copy `.env.example.json` to `.env.json`:

```bash
cp .env.example.json .env.json
```

Edit `.env.json` with your credentials:

```json
{
  "APP_MODE": "production",
  "SUPABASE_URL": "https://YOUR_PROJECT.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "YOUR_SUPABASE_PUBLISHABLE_KEY",
  "GOOGLE_CLIENT_ID": "YOUR_GOOGLE_OAUTH_CLIENT_ID",
  "STRIPE_PUBLISHABLE_KEY": "pk_test_YOUR_KEY",
  "PAYMENTS_BACKEND_URL": "YOUR_BACKEND_ENDPOINT"
}
```

### Field Reference

| Field | Required in Production | Description | Example |
|---|---|---|---|
| `APP_MODE` | Yes | Application execution mode (`production` or `demo`). When set to `demo`, the app runs completely locally with simulated data. | `"production"` |
| `SUPABASE_URL` | Yes | Your personal Supabase Project URL from **Project Settings > API**. | `"https://abcdefghijklm.supabase.co"` |
| `SUPABASE_PUBLISHABLE_KEY` | Yes | Your Supabase Project public anon key (`eyJ...`) from **Project Settings > API**. *(Also supports legacy key name `SUPABASE_ANON_KEY`).* | `"eyJhbGciOiJIUzI1NiIsInR5cCI6..."` |
| `GOOGLE_CLIENT_ID` | Optional | Web Client ID created in Google Cloud Console for Google Sign-In. | `"1234567890-abc.apps.googleusercontent.com"` |
| `STRIPE_PUBLISHABLE_KEY` | Yes | Your Stripe Publishable Key from **Stripe Dashboard > Developers > API keys**. Must begin with `pk_test_` or `pk_live_`. | `"pk_test_51IvoryNails..."` |
| `PAYMENTS_BACKEND_URL` | Yes | The URL of your deployed trusted payments backend (Supabase Edge Functions endpoint or Node backend). | `"https://abcdefghijklm.supabase.co/functions/v1"` or `"http://localhost:4242"` |

> [!NOTE]
> `.env.json` is ignored by Git in `.gitignore` to prevent accidental credential commits.

---

## 🚀 Quick Start Guide for the Store Owner

### Option A: Run in Zero-Config Demo Mode (Default)
To preview the boutique immediately with zero keys:

```bash
flutter run -d chrome
```
The application detects missing keys and launches in **Atelier Demo Mode**:
- Browse all 13 handcrafted nail creations.
- Test 1-click Princess VIP login.
- Add items to the shopping bag and apply promo codes (`IVORY10`, `ATELIER20`).
- Complete simulated Stripe checkouts with realistic latency and receipts.

---

### Option B: Connect Your Own Services (BYOK Production)

#### Step 1: Set Up Your Supabase Project
1. Create a free account at [supabase.com](https://supabase.com) and create a new project.
2. Go to the **SQL Editor** in your Supabase dashboard.
3. Open [`supabase/schema.sql`](supabase/schema.sql) in this repository, paste the entire SQL script, and click **Run**.
   - Creates `products`, `profiles`, `orders`, `order_items`, and `_migrations` tables.
   - Applies hardened Row-Level Security (RLS) policies.
   - Pre-seeds all 13 luxury creations with prices and details.
4. Go to **Project Settings > API** and copy:
   - **Project URL** -> `SUPABASE_URL` in `.env.json`
   - **anon / public key** -> `SUPABASE_PUBLISHABLE_KEY` in `.env.json`
   - **service_role key** -> Keep this secret for your backend!

#### Step 2: (Optional) Enable Google Sign-In
1. In your Supabase Dashboard, go to **Authentication > Providers > Google**.
2. Follow Supabase's guided instructions to create OAuth Credentials in the [Google Cloud Console](https://console.cloud.google.com):
   - Set Authorized Redirect URI to: `https://<YOUR-PROJECT-REF>.supabase.co/auth/v1/callback`
   - Paste the Google Client ID & Client Secret into Supabase Auth.
3. Add the Web Client ID to your `.env.json` as `GOOGLE_CLIENT_ID`.

#### Step 3: Set Up Your Stripe Account
1. Create an account at [stripe.com](https://stripe.com) and open the [Stripe Dashboard](https://dashboard.stripe.com).
2. Go to **Developers > API keys**:
   - Copy **Publishable key** (`pk_test_...`) -> `STRIPE_PUBLISHABLE_KEY` in `.env.json`.
   - Copy **Secret key** (`sk_test_...`) -> Store in backend `.env` as `STRIPE_SECRET_KEY`.
3. In **Developers > Webhooks**, create a webhook endpoint pointing to your backend:
   - Endpoint URL: `https://<your-backend-host>/api/stripe-webhook` (or Supabase Edge Function URL)
   - Select events to listen to: `checkout.session.completed`, `checkout.session.expired`
   - Copy the **Signing secret** (`whsec_...`) -> Store in backend `.env` as `STRIPE_WEBHOOK_SECRET`.

#### Step 4: Configure & Start Your Trusted Backend

You have two supported backend options:

##### Option 4A: Standalone Node.js Backend (Easiest for local / Docker / container deployment)
1. In the `server/` folder, copy `.env.backend.example` to `server/.env`:
   ```bash
   cp .env.backend.example server/.env
   ```
2. Enter your private secrets in `server/.env`:
   ```ini
   SUPABASE_URL=https://YOUR_PROJECT.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=eyJh...YOUR_SERVICE_ROLE_KEY
   STRIPE_SECRET_KEY=sk_test_YOUR_STRIPE_SECRET_KEY
   STRIPE_WEBHOOK_SECRET=whsec_YOUR_SIGNING_SECRET
   PORT=4242
   ```
3. Start the backend:
   ```bash
   npm --prefix server start
   ```

##### Option 4B: Supabase Edge Functions (Serverless inside your Supabase project)
Deploy the functions in `supabase/functions/` directly using the Supabase CLI:
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_... STRIPE_WEBHOOK_SECRET=whsec_...
supabase functions deploy create-checkout-session
supabase functions deploy stripe-webhook
supabase functions deploy health-check
```

#### Step 5: Launch the Application
Run Flutter Web with your `.env.json` configuration file:

```bash
flutter run -d chrome --dart-define-from-file=.env.json
```

The application automatically validates your configuration, initializes Supabase and Stripe services, and starts up with production-ready real checkout!

---

## 🏗️ Production Build & Static Deployment

To compile the production-ready static web bundle:

```bash
flutter build web --release --no-tree-shake-icons --dart-define-from-file=.env.json
```

The compiled static assets will be located in `build/web/`.

### Hosting on Cloud Platforms
- **Vercel / Netlify / Cloudflare Pages**: Connect your Git repository, set the build command to `flutter build web --release --no-tree-shake-icons --dart-define-from-file=.env.json`, and set the output directory to `build/web`.
- In CI/CD pipelines (e.g. GitHub Actions), create `.env.json` from repository secrets prior to running `flutter build`.

---

## 🧪 Automated Testing & Security Verification

Ivory Nails Atelier includes comprehensive test suites across both the Flutter client and the trusted backend:

### 1. Run Flutter Test Suite (18 tests)
```bash
flutter test
```
Tests verify:
- Startup without credentials defaults cleanly to Demo Mode
- Format validation for URLs, Supabase keys, Stripe keys, and Google OAuth IDs
- Placeholder detection and sanitization
- Credential redaction in diagnostic outputs
- Incomplete payment configuration rejection in production mode
- Google OAuth flow via `AuthService`
- In-memory tenant isolation and order immutability
- Cart tax (8%), free shipping threshold ($50), and promo discount calculations

### 2. Run Backend Security Test Suite (12 tests)
```bash
npm --prefix server test
```
Tests verify:
- Authoritative server-side pricing & 8% tax calculation
- Rejection of client price and quantity tampering
- Rejection of out-of-stock items
- Webhook HMAC-SHA256 signature verification and missing header rejection
- Idempotent order status updates on duplicate webhook deliveries
- Zero credential leakage in diagnostic health check endpoints

### 3. Static Analysis
```bash
flutter analyze
```

---

## 📂 Project Directory Structure

```
nailweb/
├── .env.example.json                      # Public BYOK configuration template
├── .env.backend.example                   # Privileged backend secrets template
├── lib/
│   ├── main.dart                          # Entry point & provider root
│   ├── core/
│   │   ├── config/
│   │   │   ├── app_config.dart            # BYOK configuration loader & diagnostics
│   │   │   ├── config_validator.dart      # URL, key format, & redaction validators
│   │   │   └── integration_status.dart    # IntegrationState enum & status models
│   │   ├── constants/app_constants.dart   # Store commerce rules & defaults
│   │   └── theme/app_theme.dart           # Editorial luxury styling tokens
│   ├── models/
│   │   ├── product.dart                   # Catalog product model & 13 default items
│   │   ├── cart_item.dart                 # Shopping bag item model
│   │   └── order.dart                     # Order & order line item models
│   ├── services/
│   │   ├── integration_service.dart       # Central BYOK orchestration & initialization
│   │   ├── auth/
│   │   │   ├── auth_service.dart          # AuthService interface
│   │   │   ├── demo_auth_service.dart     # In-memory mock auth
│   │   │   └── supabase_auth_service.dart # Production Supabase & Google OAuth auth
│   │   ├── catalog/
│   │   │   ├── catalog_service.dart       # CatalogService interface
│   │   │   ├── demo_catalog_service.dart  # In-memory catalog service
│   │   │   └── supabase_catalog_service.dart # PostgreSQL catalog service
│   │   ├── order/
│   │   │   ├── order_service.dart         # OrderService interface
│   │   │   ├── demo_order_service.dart    # Isolated in-memory orders
│   │   │   └── supabase_order_service.dart # RLS-enforced PostgreSQL orders
│   │   ├── payment/
│   │   │   ├── payment_service.dart       # PaymentService interface
│   │   │   ├── demo_payment_service.dart  # Simulated test card processor
│   │   │   └── stripe_payment_service.dart # Authoritative server Stripe checkout
│   │   ├── supabase_service.dart          # Supabase facade (backward-compatible)
│   │   └── stripe_service.dart            # Stripe facade (backward-compatible)
│   ├── providers/
│   │   ├── auth_provider.dart             # Auth session state & Google sign-in
│   │   ├── cart_provider.dart             # Shopping bag, taxes, discounts, shipping
│   │   └── catalog_provider.dart          # Category filtering & search state
│   └── views/
│       ├── home/home_screen.dart          # Sticky nav, marquee, hero, grid
│       ├── catalog/widgets/product_card.dart # Hoverable luxury card
│       ├── product_detail/product_detail_dialog.dart # Specs & quick-add
│       ├── cart/cart_sheet.dart           # Slide-over shopping bag
│       ├── checkout/checkout_modal.dart   # Stripe card & receipt modal
│       ├── auth/auth_modal.dart           # Email & Google Sign-In modal
│       ├── common/atelier_star_icon.dart  # Pure vector mathematical star
│       └── orders/order_history_modal.dart # Customer order history
├── server/                                # Standalone trusted payment backend
│   ├── src/
│   │   ├── server.ts                      # Express API & webhook handlers
│   │   ├── pricing.ts                     # Authoritative server pricing logic
│   │   └── types.ts                       # Database typing
│   ├── test/                              # Automated security & pricing tests
│   └── package.json
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql         # Idempotent baseline schema
│   │   └── 002_harden_rls_and_integrity.sql # Hardened RLS & tamper protection
│   ├── functions/                         # Supabase Edge Functions
│   │   ├── create-checkout-session/       # Server-side checkout session
│   │   ├── stripe-webhook/                # Webhook verification & order updater
│   │   └── health-check/                  # Redacted integration health check
│   └── schema.sql                         # Complete, idempotent production schema
├── test/                                  # Flutter automated test suite
│   ├── config/                            # Configuration & validation tests
│   ├── services/                          # Integration service & demo tests
│   └── security/                          # Isolation & immutability tests
├── web/
│   ├── index.html                         # Tailored HTML shell & Stripe.js
│   └── manifest.json
└── pubspec.yaml
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
