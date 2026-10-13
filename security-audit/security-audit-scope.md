# Security Audit Scope and Evidence Log

## 1) Repository Inventory (pre-analysis)

### Top-level entries
- `.env.backend.example`
- `.env.example.json`
- `.gitignore`
- `DESIGN.md`
- `LICENSE`
- `PRODUCT.md`
- `PRODUCTION_README.md`
- `README.md`
- `lib/`
- `pubspec.lock`
- `pubspec.yaml`
- `server/`
- `supabase/`
- `test/`
- `web/`

### Key source/manifests/config tested for security relevance
- Flutter frontend: `lib/**`, `web/index.html`, `web/manifest.json`, `pubspec.yaml`, `pubspec.lock`
- Node backend: `server/src/**`, `server/test/**`, `server/package.json`, `server/package-lock.json`, `server/tsconfig.json`
- Supabase: `supabase/schema.sql`, `supabase/migrations/*.sql`, `supabase/functions/**`
- Tests: `test/**`, `server/test/**`
- Env/docs: `.env.example.json`, `.env.backend.example`, `.gitignore`, `README.md`, `PRODUCTION_README.md`

## 2) Inspected directories/files

### Inspected directories
- `lib/core/config`, `lib/core/constants`, `lib/services`, `lib/providers`
- `server/src`, `server/test`
- `supabase/functions`, `supabase/migrations`
- `test/config`, `test/security`, `test/services`
- `web`

### Inspected files (security-relevant)
- `lib/core/config/app_config.dart`
- `lib/core/config/config_validator.dart`
- `lib/core/constants/app_constants.dart`
- `lib/services/integration_service.dart`
- `lib/services/auth/supabase_auth_service.dart`
- `lib/services/auth/demo_auth_service.dart`
- `lib/services/payment/stripe_payment_service.dart`
- `lib/services/supabase_service.dart`
- `lib/services/order/supabase_order_service.dart`
- `lib/providers/auth_provider.dart`
- `server/src/server.ts`
- `server/src/pricing.ts`
- `server/src/types.ts`
- `server/test/security.test.mjs`
- `server/test/pricing.test.mjs`
- `server/package.json`
- `server/tsconfig.json`
- `supabase/schema.sql`
- `supabase/migrations/001_initial_schema.sql`
- `supabase/migrations/002_harden_rls_and_integrity.sql`
- `supabase/functions/_shared/cors.ts`
- `supabase/functions/_shared/pricing.ts`
- `supabase/functions/create-checkout-session/index.ts`
- `supabase/functions/stripe-webhook/index.ts`
- `supabase/functions/health-check/index.ts`
- `test/config/app_config_test.dart`
- `test/config/config_validator_test.dart`
- `test/security/security_isolation_test.dart`
- `test/services/integration_service_test.dart`
- `web/index.html`
- `.env.example.json`
- `.env.backend.example`
- `.gitignore`
- `README.md`
- `PRODUCTION_README.md`

## 3) Excluded areas and justification
- `.git/**`: VCS internals; not application/runtime security logic.
- `server/dist/**`: generated/transpiled output mirror of `server/src/**`; excluded from primary evidence to avoid duplicate analysis.
- Pure UI/design-heavy files not security-relevant (`lib/views/**`, `lib/core/theme/app_theme.dart`, `DESIGN.md`, most of `PRODUCT.md`) were sampled only for claims/context, not treated as security control sources.

## 4) Search strategy and tools used
- Structural inventory: `find`, `ls`.
- Broad sensitive-pattern scanning: `rg` with auth/token/secret/cors/stripe/webhook/rls/policy/crypto terms.
- Manual implementation review: direct file reads with line numbers.
- CI/Workflow check: GitHub Actions MCP list runs + failed job logs query.
- Dependency audit: `npm --prefix server audit --omit=dev`.

## 5) Tests executed and results
- GitHub Actions run listing/log query: succeeded, no failed jobs in current run.
- `npm --prefix server run build`: failed (TypeScript `moduleResolution=node10` removal incompatibility).
- `npm --prefix server test`: not run due build dependency failure (tests import dist artifacts).
- `flutter test`: unable to execute (`flutter: command not found`).
- `npm --prefix server audit --omit=dev`: passed, 0 vulnerabilities.

## 6) Known limitations
1. No live Supabase/Stripe environment credentials or runtime deployment access.
2. Flutter SDK not available in this audit environment.
3. Backend tests blocked by TypeScript toolchain/config mismatch.
4. Audit is source/evidence-based and non-invasive (no production interaction, no real payments).

## 7) Artifact consistency checkpoints
- Implemented-features count includes only `Verified implemented` controls.
- CSV/JSON counts aligned with markdown report totals.
- PDF generation attempted only if local converter tooling is available.
- Sensitive values redacted; no live credentials included.

## 8) PDF artifact status
- Checked for `pandoc`, `wkhtmltopdf`, `weasyprint`, and `libreoffice`.
- None are installed in this environment.
- As required, `security-audit-report.pdf` was **not fabricated**.
