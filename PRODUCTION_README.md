# 🌸 Ivory Nails Atelier — Store Owner's Production Setup Guide

Welcome! This guide is written for you, the store owner. You don't need to be a programmer or write code to launch your boutique with your own accounts.

---

## ⚡ The Big Picture (How This Works)

Your store connects to **two accounts** that you own:

```
  [ Your Customer ]
         │
         ▼
  [ Ivory Nails Storefront (Website) ]
         │
         ├───► 🗄️ Supabase  ── Saves your products, customer logins, and orders
         │
         └───► 💳 Stripe    ── Collects payments directly into your bank account
```

All you need to do is **grab 5 keys** from those two accounts, paste them into one small text file named `.env.json`, and your store is live.

---

## 📝 Step 1: Set Up Your Database (Supabase)
⏱️ *Time: ~3 minutes* • 💰 *Cost: Free*

Supabase holds your product catalog, customer accounts, and order history.

### 1.1 Create your account
1. Open [supabase.com](https://supabase.com) and click **Start your project**.
2. Sign in with GitHub or your email.
3. Click the green **New project** button.
4. Name your project (e.g. `Ivory Nails`), enter a database password, and click **Create new project**. Wait 1 minute for it to finish setting up.

### 1.2 Create your store tables (One click)
1. In the left menu of Supabase, click the **SQL Editor** tab (icon looks like `>_`).
2. Click **New query**.
3. Open the file [`supabase/schema.sql`](supabase/schema.sql) from this project, **copy everything**, and paste it into the big box.
4. Click the green **Run** button on the bottom right.
5. ✨ *Done! All 13 nail products, pricing, and order tables are now installed.*

### 1.3 Copy your Supabase keys
In the left menu, click the **Settings** gear at the bottom > **API**.
Copy and save these two things:

* **Project URL** (looks like `https://abcdefghijklm.supabase.co`)
* **`anon` `public` key** (a long string starting with `eyJhbGciOi...`)

*(Leave the `service_role` key alone for now — we'll use that in Step 4).*

---

## 💳 Step 2: Set Up Payments (Stripe)
⏱️ *Time: ~3 minutes* • 💰 *Cost: Free to setup*

Stripe processes credit cards and deposits money straight into your bank.

### 2.1 Get your Stripe keys
1. Open [dashboard.stripe.com](https://dashboard.stripe.com) and log in.
2. In the top-right corner, make sure **Test mode** is toggled **ON** (orange banner).
3. In the top search bar, type `API keys` and press Enter (or click **Developers** > **API keys**).
4. Copy these two keys:
   * **Publishable key** (starts with `pk_test_...`)
   * **Secret key** (click *Reveal test key* — starts with `sk_test_...`)

### 2.2 Set up the payment notification webhook
This tells your store the exact second a customer's payment succeeds.

1. In the Stripe dashboard, click **Developers** > **Webhooks** in the left menu.
2. Click **+ Add destination** (or **Add endpoint**).
3. In **Endpoint URL**, enter your backend URL:
   `https://<your-backend-host>/api/stripe-webhook`
   *(If testing on your computer, use `http://localhost:4242/api/stripe-webhook`)*
4. Under **Select events to listen to**, choose:
   * `checkout.session.completed`
   * `checkout.session.expired`
5. Click **Add endpoint**.
6. On the webhook page that opens, look for **Signing secret**, click **Reveal**, and copy it (starts with `whsec_...`).

---

## 📄 Step 3: Create Your Store Config File (`.env.json`)
⏱️ *Time: ~1 minute*

Now, put your public keys together in one file.

1. In the root folder of this project, duplicate the file `.env.example.json` and name the copy:
   ```
   .env.json
   ```
2. Open `.env.json` and replace the placeholder text with your real keys:

```json
{
  "APP_MODE": "production",
  "SUPABASE_URL": "https://YOUR-PROJECT-ID.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "GOOGLE_CLIENT_ID": "",
  "STRIPE_PUBLISHABLE_KEY": "pk_test_YOUR_STRIPE_KEY",
  "PAYMENTS_BACKEND_URL": "https://YOUR-BACKEND-URL"
}
```

> 🔒 **Security Promise**: This file only holds **public keys** (like your `pk_` Stripe key). Your private secret key (`sk_`) is never put here, never put on GitHub, and never visible to customers.

---

## ⚙️ Step 4: Turn On Your Payment Server
⏱️ *Time: ~2 minutes*

To keep your secret Stripe key 100% safe from browser users, a lightweight helper server creates checkout sessions for you.

### Option 4A: Running on your computer (for testing)
1. In the `server` folder, copy `.env.backend.example` to `server/.env`:
   ```bash
   cp .env.backend.example server/.env
   ```
2. Open `server/.env` and paste your private credentials:
   ```ini
   SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=eyJ...YOUR_SERVICE_ROLE_KEY_FROM_STEP_1
   STRIPE_SECRET_KEY=sk_test_YOUR_SECRET_KEY_FROM_STEP_2
   STRIPE_WEBHOOK_SECRET=whsec_YOUR_SIGNING_SECRET_FROM_STEP_2
   PORT=4242
   ```
3. Start the server:
   ```bash
   npm --prefix server start
   ```
   You will see: `✨ Ivory Nails Trusted Payments Backend running on port 4242`

### Option 4B: Deploying online (Render, Railway, or Fly.io)
When you deploy to a host like [render.com](https://render.com) or [railway.app](https://railway.app):
1. Connect your repo and set the root folder to `server`.
2. Add the 4 environment variables from Step 4A in the host's dashboard settings.
3. Copy the URL Render/Railway gives you (e.g. `https://ivory-api.onrender.com`) and paste it as `PAYMENTS_BACKEND_URL` in your `.env.json`.

---

## 🚀 Step 5: Launch Your Storefront!

Run this single command:

```bash
flutter run -d chrome --dart-define-from-file=.env.json
```

Your browser will pop up with the full Ivory Nails Atelier storefront:
* Connected to **your** Supabase project.
* Processing payments with **your** Stripe account.

---

## 🧪 How to Test a Purchase (Without Real Money)

1. Open your running store in Chrome.
2. Add any nail set or polish to your shopping bag.
3. Click **Proceed to Checkout**.
4. In the Stripe card fields, type:
   * **Card Number**: `4242 4242 4242 4242` *(Stripe's official test card)*
   * **Expires**: Any future date (e.g. `12/28`)
   * **CVC**: `123`
   * **Zip**: `90210`
5. Click **Pay Now**.
6. You'll see the gold receipt banner with your order number (`IVORY-XXXX`).
7. Open your Stripe Dashboard > **Payments** — you will see the test charge recorded!
8. Open your Supabase Dashboard > **Table Editor** > **orders** — you will see the order marked as `"paid"`!

---

## 🟢 Ready to Accept Real Money? (Going Live)

When you're ready to start selling to customers:

1. In your **Stripe Dashboard**, turn **Test mode** switch **OFF** (to Live mode).
2. Grab your live keys:
   * `pk_live_...` -> Update in `.env.json`
   * `sk_live_...` -> Update in `server/.env`
   * `whsec_...` -> Create a live webhook endpoint in Stripe and update in `server/.env`
3. Compile your production website:
   ```bash
   flutter build web --release --no-tree-shake-icons --dart-define-from-file=.env.json
   ```
4. Upload the files inside `build/web/` to Vercel, Netlify, or Cloudflare Pages.

---

## ❓ Frequently Asked Questions

#### Q: What if I don't enter any keys at all?
Your store automatically runs in **Atelier Demo Mode**. Everything works offline with simulated cards, so you can preview the website without signing up for anything.

#### Q: Can customers or hackers steal my Stripe secret key?
**No.** Your secret key (`sk_...`) stays on your private server. The web app only knows your public key (`pk_...`), which Stripe explicitly designs to be public.

#### Q: Can someone tamper with the prices in the browser?
**No.** The payment server queries the database directly to confirm the exact price of every item before charging the card. Any fake prices sent from a browser are rejected.
