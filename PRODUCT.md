# Product

## Platform

web

## Stack

Flutter (Web-first responsive, cross-platform architecture), Supabase (`supabase_flutter` for Email Auth, PostgreSQL tables, Realtime sync, and Row-Level Security), and Stripe Checkout (`url_launcher` / Stripe Web Checkout & client session integration) with built-in instant mock/demo fallback mode.

## Users

Beauty connoisseurs, salon-goers, and press-on nail enthusiasts looking for salon-grade handcrafted press-on sets, luxury polishes, and nail care with an elevated, effortless boutique shopping experience.

## Product Purpose

Elevate the Ivory Nails digital storefront into a refined, editorial e-commerce Flutter web application. Provide seamless email authentication via Supabase, a persistent shopping bag, reactive product catalog filtering, order history tracking, and Stripe checkout processing.

## Positioning

Minimalist Editorial Luxury: Unlike playful candy-pink novelty nail shops, Ivory Nails delivers subdued blush, warm ivory, tailored serif typography, and calm high-fashion editorial composition reminiscent of Chanel Le Vernis and luxury beauty ateliers.

## Operating Context

Responsive web app optimized for mobile smartphones, tablets, and wide desktop displays. Fast load times, tactile micro-interactions, robust offline/demo capabilities when API keys are pending, and reliable payment checkout flows.

## Capabilities and Constraints

- **Flutter Web Responsive Architecture**: Clean adaptable layouts across mobile (<600px), tablet (600-1024px), and desktop (>1024px).
- **Supabase Authentication**: Email and password sign-up, login, session persistence, profile sync, and password recovery.
- **Dual-Mode Backend**: Pluggable Supabase Client configuration (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) with automatic seamless fallback to local mock repository for instant zero-config testing.
- **Curated 13-Product Catalog**: Rich product cards with categories (Press-On, Polish, Care), high-resolution imagery, ratings, specifications, and instant filter/search.
- **Shopping Bag & State**: Cart addition, quantity adjustments, tax & shipping calculations, persistent bag storage.
- **Stripe Checkout Integration**: Stripe payment session generation, checkout redirect/modal flow, order record creation in Supabase `orders` table, and receipt generation.
- **Order Management & Receipts**: Confirmation modal with order ID, itemized receipt, and tracking details.

## Brand Commitments

- **Name**: Ivory Nails — Luxury Press-Ons & Polishes
- **Aesthetic**: Minimalist Editorial Luxury. Warm ivory background, muted blush accents, charcoal slate text, whisper-thin borders, and soft natural elevations.
- **Typography**: Editorial serif headings paired with clean, highly legible geometric sans body text.

## Evidence on Hand

- 13 confirmed catalog items from HTML prototype with descriptions, categories, and prices:
  1. Baby Blossom Polish ($14.50, Polish)
  2. Rose Quartz Press-Ons ($24.00, Press-On)
  3. Milky Glaze Topcoat ($12.00, Care)
  4. Petal Pink Shimmer ($16.00, Polish)
  5. Pearl Radiance Nails ($26.50, Press-On)
  6. Cute Blush Gloss ($15.00, Polish)
  7. Soft Marshmallow Dip ($18.00, Care)
  8. Velvet Ballet Polish ($14.00, Polish)
  9. Sparkle Dust Gloss ($13.50, Polish)
  10. French Vanilla Press-Ons ($22.00, Press-On)
  11. Berry Sweet Gloss ($15.50, Polish)
  12. Cotton Candy Polish ($14.00, Polish)
  13. Angel Wing Glaze ($28.00, Press-On)

## Product Principles

1. **Editorial Restraint**: Quiet confidence through generous negative space, refined typography, and subtle tonal depth rather than aggressive saturation.
2. **Zero-Friction Reliability**: Runs out-of-the-box in demo mode and seamlessly hooks into live Supabase & Stripe backends via environment variables or settings.
3. **Tactile Feedback**: Immediate, fluid visual feedback on bag additions, tab transitions, quantity shifts, and auth states.
4. **Transparent Commerce**: Clear pricing, explicit shipping terms, and reassuring security cues throughout checkout.
