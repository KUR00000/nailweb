# Ivory Nails Atelier — Luxury Press-Ons & Polishes

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Auth%20%26%20Postgres-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Stripe](https://img.shields.io/badge/Stripe-Checkout-635BFF?logo=stripe&logoColor=white)](https://stripe.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Visibility](https://img.shields.io/badge/Visibility-Public-green.svg)](https://github.com/KUR00000/nailweb)

An editorial haute-couture e-commerce web application for **Ivory Nails Atelier**, crafted with **Flutter Web**, backed by **Supabase Authentication & PostgreSQL Database**, and secured with **Stripe Payments**.

---

## Highlights & Features

- **Editorial Luxury Aesthetic**: Warm porcelain ground (`#FBF9F7`), charcoal noir typography (`#1C1917`), muted petal blush tones (`#B57770`), and atelier gold accents (`#B8966E`).
- **100% Vector Geometry**: Zero emoji or unicode glyph fallbacks — authored mathematical vector stars, clean geometric badges, and optically aligned 40px navbar controls.
- **13 Curated Creations**: Complete catalog of handcrafted press-on nails and 10-Free micro-milled lacquers with authentic salon manicure photography, individual finish descriptions, and color swatch indicators.
- **Interactive Shade Palette Bar**: Filter creations dynamically by live color dots (Rose Quartz, Glazed Pearl, Ballet Crème, Cherry Fleck, Strawberry Glass, Baby Blossom, Angel Aurora).
- **Dual-Mode Backend Architecture**:
  - **Zero-Config Atelier Demo Mode**: Fully functional offline/local fallback with a 1-click VIP test account and mock Stripe card checkout that outputs verified receipts.
  - **Live Cloud Sync**: Seamlessly connects to your Supabase project (Auth, Realtime, RLS) and Stripe account when passed via `--dart-define`.
- **Complete Supabase Database (`supabase/schema.sql`)**:
  - `products`: Publicly queryable catalog with prices, ratings, and inventory.
  - `profiles`: Customer profiles linked to Supabase Auth with automated signup triggers.
  - `orders` & `order_items`: Full transactional records with addresses and line-item details.
  - Robust Row-Level Security (RLS) policies.
- **Responsive Web-First Layout**: Adaptive layout spanning mobile smartphones (1 column), tablets (2–3 columns), and widescreen desktop monitors (4 columns).

---

## 🚀 Quick Start (Clone & Run in 60 Seconds)

### 1. Clone the Repository

Choose your preferred method:

**HTTPS:**
```bash
git clone https://github.com/KUR00000/nailweb.git
cd nailweb
```

**SSH:**
```bash
git clone git@github.com:KUR00000/nailweb.git
cd nailweb
```

**GitHub CLI:**
```bash
gh repo clone KUR00000/nailweb
cd nailweb
```

---

## 💻 Prerequisites & Setup per Operating System

This project requires the **Flutter SDK (version 3.19 or higher)** and a modern web browser (Google Chrome, Chromium, Microsoft Edge, or Safari).

### macOS
1. Install Flutter via Homebrew:
   ```bash
   brew install --cask flutter
   ```
   *(Or download the official zip from [flutter.dev](https://docs.flutter.dev/get-started/install/macos) and add it to your `$PATH`).*
2. Verify your installation:
   ```bash
   flutter doctor
   ```

### Windows
1. Install Flutter via `winget` in PowerShell / Command Prompt:
   ```powershell
   winget install -e --id Google.Flutter
   ```
   *(Or download from [flutter.dev](https://docs.flutter.dev/get-started/install/windows) and add `flutter\bin` to your system Environment Variables).*
2. Ensure Google Chrome or Microsoft Edge is installed.
3. Verify your installation:
   ```powershell
   flutter doctor
   ```

### Linux (Ubuntu, Debian, Fedora, Arch)
1. Install Flutter via Snap or tarball:
   ```bash
   sudo snap install flutter --classic
   ```
   *(For Arch Linux: `sudo pacman -S flutter` or manual download from [flutter.dev](https://docs.flutter.dev/get-started/install/linux)).*
2. Ensure build tools and Chrome/Chromium are installed:
   ```bash
   # Debian/Ubuntu
   sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev chromium-browser
   ```
3. Verify your installation:
   ```bash
   flutter doctor
   ```

---

## 📦 Install Dependencies

Inside the `nailweb` directory, fetch the required packages:

```bash
flutter pub get
```

---

## 🖥️ Running the Application

### Option A: Run in Demo Mode (Zero Setup Required)

The application launches out of the box in **Atelier Demo Mode** without needing any API keys. You can test email login, 1-click Princess VIP login, shopping bag interactions, promo codes (`IVORY10`, `ATELIER20`), and complete a mock Stripe checkout.

**On Google Chrome (Default):**
```bash
flutter run -d chrome
```

**On Microsoft Edge (Windows):**
```bash
flutter run -d edge
```

**As a Local Network Web Server (Access from other devices/phones on same Wi-Fi):**
```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```
Then open `http://localhost:8080` or `http://<your-ip-address>:8080` in any browser.

---

### Option B: Connecting Live Supabase & Stripe

To run the application connected to your live Supabase cloud database and Stripe account:

#### Step 1: Set up Supabase
1. Create a free project at [supabase.com](https://supabase.com).
2. Go to the **SQL Editor** in your Supabase dashboard.
3. Open [`supabase/schema.sql`](supabase/schema.sql), paste the entire script into the SQL editor, and click **Run**.
   - This creates `products`, `profiles`, `orders`, and `order_items` tables.
   - Sets up Row-Level Security (RLS) policies.
   - Pre-seeds all 13 handcrafted atelier items.
4. Go to **Project Settings > API** and copy:
   - **Project URL**
   - **Anon / Public Key**

#### Step 2: Set up Stripe
1. Log into your [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys).
2. Retrieve your test **Publishable Key** (`pk_test_...`).

#### Step 3: Run with Environment Variables
Launch Flutter with your live environment variables:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
```

---

## 🏗️ Production Build & Deployment

To compile the production-ready web bundle:

```bash
flutter build web --release --no-tree-shake-icons
```

Or with live Supabase & Stripe credentials:

```bash
flutter build web --release --no-tree-shake-icons \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
```

The compiled static assets will be located in `build/web/`.

### Previewing the Production Build Locally
You can test the compiled production build with Python or Node:

```bash
# Using Python
python3 -m http.server 8080 --directory build/web

# Or using Node.js serve
npx serve build/web -l 8080
```
Open [http://localhost:8080](http://localhost:8080) to inspect.

### Deploying to Cloud Hosting Providers

- **Vercel**: Run `npx vercel build/web` or set the root directory to `build/web`.
- **Netlify**: Drag and drop the `build/web` folder into the Netlify dashboard, or configure publish directory as `build/web`.
- **Cloudflare Pages**: Connect your repository, set the build command to `flutter build web --release --no-tree-shake-icons`, and set output directory to `build/web`.
- **GitHub Pages**: Push the contents of `build/web/` to a `gh-pages` branch.

---

## 📂 Project Directory Structure

```
nailweb/
├── lib/
│   ├── main.dart                          # App entry point, provider root & theme bindings
│   ├── core/
│   │   ├── constants/app_constants.dart   # API keys, store policies & VIP presets
│   │   └── theme/app_theme.dart           # Editorial luxury styling, typography & depth tokens
│   ├── models/
│   │   ├── product.dart                   # 13 verified items, shades, silhouettes & schema
│   │   ├── cart_item.dart                 # Shopping bag line item model
│   │   └── order.dart                     # Stripe order & order items model
│   ├── services/
│   │   ├── supabase_service.dart          # Supabase Auth, DB persistence & demo mock fallback
│   │   └── stripe_service.dart            # Stripe payment session & validation
│   ├── providers/
│   │   ├── auth_provider.dart             # Auth session & VIP status state
│   │   ├── cart_provider.dart             # Bag items, tax & shipping calculations
│   │   └── catalog_provider.dart          # Product search, categories & sorting
│   └── views/
│       ├── home/home_screen.dart          # Sticky header, marquee, hero, shade bar & grid
│       ├── catalog/widgets/product_card.dart # Hoverable luxury card with vector badges
│       ├── product_detail/product_detail_dialog.dart # Specs, application tips & quick-add
│       ├── cart/cart_sheet.dart           # Slide-over shopping bag & promo code support
│       ├── checkout/checkout_modal.dart   # Stripe card form & order receipt confirmation
│       ├── auth/auth_modal.dart           # Supabase email login & VIP demo toggle
│       ├── common/atelier_star_icon.dart  # Pure vector mathematical faceted star
│       └── orders/order_history_modal.dart # Customer order history & receipts
├── supabase/
│   └── schema.sql                         # PostgreSQL schema, RLS policies & seed data
├── web/
│   ├── index.html                         # Tailored HTML shell, Stripe.js & vector preloader
│   └── manifest.json                      # PWA web manifest
├── pubspec.yaml                           # Flutter dependencies & font definitions
├── DESIGN.md                              # Atelier design tokens, colors & typography specs
├── PRODUCT.md                             # Product specifications & design system architecture
└── README.md                              # Documentation & setup guide
```

---

## 🧪 Testing & Code Quality

Verify that your local environment passes analyzer and formatting checks:

```bash
# Analyze code health (0 warnings, 0 errors expected)
flutter analyze

# Format code
dart format .
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
