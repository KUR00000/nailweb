# Security Audit Report — KUR00000/nailweb

**Version:** 1.0  
**Audit date:** 2026-10-13 (UTC)  
**Repository:** `KUR00000/nailweb`  
**Auditor:** GitHub Copilot Coding Agent  

---

## Cover Page

### Confidentiality Notice
This report contains a security-focused analysis of repository source code and configuration patterns. No live secrets, tokens, or PII are included.

### Report Objective
Perform a comprehensive, evidence-based security audit of the repository and classify controls by implementation status.

### Page Numbering
When rendered to PDF, this document is intended to use standard page numbering in the footer.

---

## Executive Summary

This repository implements strong baseline controls for authentication, authorization, payment integrity, webhook authenticity, and sensitive-data handling, primarily through:
- Supabase Auth + RLS policies (`supabase/schema.sql`, migration 002)
- Backend-authoritative Stripe checkout and pricing (`server/src/server.ts`, `server/src/pricing.ts`, `supabase/functions/create-checkout-session/index.ts`)
- Webhook verification and idempotent status transitions (`server/src/server.ts`, `supabase/functions/stripe-webhook/index.ts`)

However, several confirmed hardening gaps exist:
1. Permissive CORS defaults (`*`) in backend/edge paths.
2. Hardcoded VIP credentials in production auth service path.
3. Weak order ID entropy (`IVORY-1000..9999`) with collision risk.
4. CSP permits `'unsafe-inline'` and `'unsafe-eval'`.
5. In-memory rate limiter is not distributed.
6. `SECURITY DEFINER` functions do not explicitly set hardened `search_path`.

**Feature status counts (consolidated):**
- Verified implemented: **20**
- Partially implemented: **3**
- Conditionally enabled: **2**
- Test-only: **3**
- Documented only: **2**
- Unverified: **4**
- **Total consolidated features:** 34

**PDF generation status:** Markdown-to-PDF tooling (`pandoc`, `wkhtmltopdf`, `weasyprint`, `libreoffice`) is unavailable in this environment. Per requirement, no fabricated PDF was produced.

---

## Scope and Methodology

### Scope
Audited repository content at `/home/runner/work/nailweb/nailweb`, including:
- Flutter app (`lib/`, `web/`, `pubspec.*`)
- Node backend (`server/src`, `server/test`, `server/package*.json`, `server/tsconfig.json`)
- Supabase schema/migrations/functions (`supabase/schema.sql`, `supabase/migrations`, `supabase/functions`)
- Tests (`test/`, `server/test/`)
- Security-relevant docs/templates (`README.md`, `PRODUCTION_README.md`, `.env.example.json`, `.env.backend.example`, `.gitignore`)

### Method
1. Repository inventory and file classification.
2. Broad pattern search for security-sensitive code and config.
3. Manual evidence review with exact path/line references.
4. Runtime verification only for safe, existing commands available in environment.
5. Classification of each control candidate into one required status.

### Runtime verification performed
- CI visibility (GitHub Actions): listed workflows/runs and failed-job logs query.
- `npm --prefix server audit --omit=dev` (result: 0 vulnerabilities).

### Runtime verification blocked by environment/tooling
- `npm --prefix server run build` failed due TypeScript option incompatibility (`server/tsconfig.json`: `moduleResolution` removed in runtime TS toolchain).
- `flutter` command unavailable in this environment (`flutter: command not found`), so Flutter tests/analyze were not executed.

---

## Architecture Overview

1. **Flutter Web client** handles UI, invokes Supabase auth, and sends checkout requests to backend (`lib/services/payment/stripe_payment_service.dart:67-103`).
2. **Trusted payment backend** (Node or Supabase Edge) validates input, verifies auth tokens, calculates pricing from DB products, creates Stripe checkout sessions, and persists pending orders (`server/src/server.ts:248-370`, `supabase/functions/create-checkout-session/index.ts:75-220`).
3. **Supabase Postgres** enforces RLS and data integrity via policies and constraints (`supabase/schema.sql:39-197`).
4. **Stripe webhooks** are verified cryptographically before order status updates (`server/src/server.ts:74-135`, `supabase/functions/stripe-webhook/index.ts:15-127`).

---

## Implemented Features Master Inventory (Verified Implemented Only)

| ID | Feature | Category | Importance | Status |
|---|---|---|---|---|
| SECR-001 | Public/private credential separation and env hygiene | Secrets Management | Critical | Verified implemented |
| AUTH-001 | Supabase email/password authentication | Authentication | High | Verified implemented |
| AUTH-002 | Google OAuth via Supabase | Authentication | High | Verified implemented |
| AUTH-003 | Password reset flow via Supabase | Authentication | Medium | Verified implemented |
| AUTH-004 | Backend JWT identity verification for checkout ownership | Authentication | Critical | Verified implemented |
| AUTHZ-001 | Product catalog RLS: public read, admin write | Authorization | High | Verified implemented |
| AUTHZ-002 | Profile RLS + role-escalation prevention | Authorization | Critical | Verified implemented |
| AUTHZ-003 | Orders RLS + admin-only updates + blocked client insert path | Authorization | Critical | Verified implemented |
| AUTHZ-004 | Order-items RLS bound to authorized parent orders | Authorization | Critical | Verified implemented |
| AUTHZ-005 | Auto profile provisioning with default `customer` role | Authorization | High | Verified implemented |
| DB-001 | Foreign keys and check constraints for integrity | Data Integrity | High | Verified implemented |
| SECR-002 | Redacted diagnostics (no secret echo) | Secrets Management | High | Verified implemented |
| PAY-001 | Server-authoritative pricing, inventory, promo validation | Payments | Critical | Verified implemented |
| PAY-002 | Backend-only Stripe Checkout session creation | Payments | Critical | Verified implemented |
| PAY-003 | Stripe webhook signature verification gate | Payments | Critical | Verified implemented |
| PAY-004 | Webhook idempotent pending-state transitions | Payments | High | Verified implemented |
| API-001 | Open-redirect sanitization for return URLs | API Security | High | Verified implemented |
| API-002 | Checkout rate limiting (per-IP in-memory) | API Security | High | Verified implemented |
| OPS-001 | Security posture health checks (schema/RLS/config state) | Operations | Medium | Verified implemented |
| WEB-001 | Browser CSP present in web shell | Web Security | Medium | Verified implemented |

---

## Detailed Verified Feature Entries (Evidence-backed)

### SECR-001 — Public/private credential separation and env hygiene
- **Importance:** Critical
- **Locations:** `.env.example.json:1-8`, `.env.backend.example:7-16`, `.gitignore:37-49`, `server/src/server.ts:13-18`, `supabase/functions/create-checkout-session/index.ts:32-35`
- **Technical details:** Public config template contains publishable keys/URLs; backend templates and code read privileged secrets from runtime env.
- **Purpose:** Prevent exposure of service-role/Stripe secret keys to browser clients.
- **Threats mitigated:** Secret leakage, backend impersonation.
- **Enforcement point:** Backend/env boundary, git ignore guardrails.
- **Evidence/verification:** Static inspection confirms separate key paths and ignored secret files.
- **Related tests:** `server/test/security.test.mjs:26-43` (diagnostic leak assertions).
- **Limitations/scope:** Deployment secret handling remains environment-dependent (see unverified items).

### AUTH-001 — Supabase email/password authentication
- **Importance:** High
- **Locations:** `lib/services/auth/supabase_auth_service.dart:21-53`, `lib/providers/auth_provider.dart:44-83`
- **Technical details:** Client auth delegates sign-up/sign-in to Supabase SDK.
- **Purpose:** Authenticated user identity lifecycle.
- **Threats mitigated:** Anonymous order-history access when paired with RLS.
- **Enforcement point:** Supabase Auth + client auth service.
- **Evidence:** Direct SDK calls with email/password paths.
- **Related tests:** `test/services/integration_service_test.dart:118-138` (auth flow behavior in demo path only).
- **Limitations:** Runtime production auth was not executed in this environment.

### AUTH-002 — Google OAuth via Supabase
- **Importance:** High
- **Locations:** `lib/services/auth/supabase_auth_service.dart:57-70`, `lib/providers/auth_provider.dart:85-102`
- **Technical details:** OAuth sign-in delegated to Supabase with web-origin redirect.
- **Purpose:** External identity provider support.
- **Threats mitigated:** Custom OAuth implementation risk.
- **Enforcement point:** Supabase OAuth flow.
- **Evidence:** Explicit `signInWithOAuth(OAuthProvider.google, ...)`.
- **Related tests:** `test/services/integration_service_test.dart:118-138` (demo auth service path).
- **Limitations:** Production OAuth callback config is deployment-dependent.

### AUTH-003 — Password reset flow via Supabase
- **Importance:** Medium
- **Locations:** `lib/services/auth/supabase_auth_service.dart:105-107`, `lib/providers/auth_provider.dart:129-146`
- **Technical details:** Password reset email delegated to Supabase.
- **Purpose:** Account recovery.
- **Threats mitigated:** Unsafe custom reset-token handling.
- **Enforcement point:** Supabase Auth reset endpoint.
- **Evidence:** `resetPasswordForEmail(email.trim())`.
- **Related tests:** None specific.
- **Limitations:** Email template and token TTL not auditable from this repo.

### AUTH-004 — Backend JWT identity verification for checkout ownership
- **Importance:** Critical
- **Locations:** `server/src/server.ts:248-263`, `supabase/functions/create-checkout-session/index.ts:78-93`
- **Technical details:** Backend extracts bearer token and calls `supabase.auth.getUser(token)`; does not trust client `userId`.
- **Purpose:** Bind order ownership to verified auth identity.
- **Threats mitigated:** Account/order spoofing.
- **Enforcement point:** Checkout backend endpoints.
- **Evidence:** Verified-user assignment to `user_id` on order insert (`server/src/server.ts:347-350`).
- **Related tests:** `server/test/security.test.mjs:126-145`.
- **Limitations:** Server tests were not runnable due build/toolchain issue.

### AUTHZ-001 — Product catalog RLS: public read, admin write
- **Importance:** High
- **Locations:** `supabase/schema.sql:39-55`, `supabase/migrations/002_harden_rls_and_integrity.sql:21-40`
- **Technical details:** RLS enabled with `SELECT USING (true)` and admin-gated `FOR ALL` policy.
- **Purpose:** Catalog readability while restricting mutation.
- **Threats mitigated:** Unauthorized product tampering.
- **Enforcement point:** Postgres RLS policies.
- **Evidence:** Policy SQL definitions present and idempotent migration patterns.
- **Related tests:** No DB integration tests in repo.
- **Limitations:** Live policy deployment state unverified from this environment.

### AUTHZ-002 — Profile RLS + role-escalation prevention
- **Importance:** Critical
- **Locations:** `supabase/schema.sql:70-91`, `supabase/migrations/002_harden_rls_and_integrity.sql:45-70`
- **Technical details:** Self-or-admin profile visibility; update check blocks role change except admin.
- **Purpose:** Prevent privilege escalation from customer to admin/vip.
- **Threats mitigated:** Horizontal and vertical privilege abuse.
- **Enforcement point:** Postgres RLS policy `WITH CHECK`.
- **Evidence:** Role immutability check uses current stored role comparison.
- **Related tests:** None DB-runtime in repo.
- **Limitations:** No automated DB policy test execution observed.

### AUTHZ-003 — Orders RLS + admin-only updates + blocked client insert path
- **Importance:** Critical
- **Locations:** `supabase/schema.sql:137-161`, `supabase/migrations/002_harden_rls_and_integrity.sql:98-123`
- **Technical details:** Select restricted to own orders/admin; updates admin-only; no permissive insert policy for client.
- **Purpose:** Prevent unauthorized order access/modification.
- **Threats mitigated:** Order tampering, unauthorized reads/writes.
- **Enforcement point:** Postgres RLS policy set.
- **Evidence:** Explicit comments and absence of client insert allow policy.
- **Related tests:** `test/security/security_isolation_test.dart:7-46` (demo-only model behavior).
- **Limitations:** RLS bypass by service-role is expected for trusted backend paths.

### AUTHZ-004 — Order-items RLS bound to authorized parent orders
- **Importance:** Critical
- **Locations:** `supabase/schema.sql:178-196`, `supabase/migrations/002_harden_rls_and_integrity.sql:127-145`
- **Technical details:** Select allowed only when parent order belongs to caller/admin.
- **Purpose:** Prevent leakage of line-item details across users.
- **Threats mitigated:** Data exposure through related-table joins.
- **Enforcement point:** Postgres RLS subquery policy.
- **Evidence:** Policy checks `public.orders.user_id = auth.uid()` or admin.
- **Related tests:** None DB-runtime in repo.
- **Limitations:** Runtime DB test coverage not executed here.

### AUTHZ-005 — Auto profile provisioning with default `customer` role
- **Importance:** High
- **Locations:** `supabase/schema.sql:93-115`, `supabase/migrations/002_harden_rls_and_integrity.sql:72-94`
- **Technical details:** Trigger on `auth.users` insert creates profile with role `customer`.
- **Purpose:** Ensure safe default authorization baseline.
- **Threats mitigated:** Uninitialized profile/role ambiguities.
- **Enforcement point:** Postgres trigger + `SECURITY DEFINER` function.
- **Evidence:** Trigger `on_auth_user_created` and function body.
- **Related tests:** None.
- **Limitations:** `SECURITY DEFINER` hardening could be improved (see gaps).

### DB-001 — Foreign keys and check constraints for integrity
- **Importance:** High
- **Locations:** `supabase/schema.sql:22-34`, `60-68`, `119-132`, `166-174`
- **Technical details:** Referential constraints across auth/users/orders/items; check constraints for categories/status/quantities.
- **Purpose:** Protect commerce data integrity.
- **Threats mitigated:** Orphaned records, invalid state transitions/values.
- **Enforcement point:** DB schema constraints.
- **Evidence:** SQL definitions with FK and CHECK constraints.
- **Related tests:** Not directly executed.
- **Limitations:** Seed/sample data quality not security-critical.

### SECR-002 — Redacted diagnostics (no secret echo)
- **Importance:** High
- **Locations:** `server/src/server.ts:192-204`, `lib/core/config/app_config.dart:172-181`, `lib/core/config/config_validator.dart:14-23`
- **Technical details:** Health output emits booleans/mode only; frontend config redacts sensitive strings.
- **Purpose:** Reduce accidental secret leakage in logs/API responses.
- **Threats mitigated:** Credential disclosure via diagnostics.
- **Enforcement point:** API response composition and redaction utility.
- **Evidence:** String redaction and non-secret health payload fields.
- **Related tests:** `server/test/security.test.mjs:26-43`, `test/config/config_validator_test.dart:63-70`.
- **Limitations:** Does not protect secrets printed elsewhere by external infrastructure.

### PAY-001 — Server-authoritative pricing, inventory, promo validation
- **Importance:** Critical
- **Locations:** `server/src/pricing.ts:41-107`, `server/src/server.ts:265-283`, `supabase/functions/_shared/pricing.ts:41-107`, `supabase/functions/create-checkout-session/index.ts:95-116`
- **Technical details:** Backend loads DB products, validates quantity/in-stock, computes totals and accepted promo list.
- **Purpose:** Prevent client-side price/quantity tampering.
- **Threats mitigated:** Underpayment, fraudulent discounts.
- **Enforcement point:** Trusted backend pricing modules.
- **Evidence:** Input validation and server-side total recomputation.
- **Related tests:** `server/test/pricing.test.mjs:20-102`.
- **Limitations:** Promo list hardcoded; no expiry/usage-limit logic present.

### PAY-002 — Backend-only Stripe Checkout session creation
- **Importance:** Critical
- **Locations:** `server/src/server.ts:331-344`, `supabase/functions/create-checkout-session/index.ts:121-180`
- **Technical details:** Stripe session created server-side using env secret key.
- **Purpose:** Keep payment secret operations out of browser.
- **Threats mitigated:** Secret key exposure, tampered charge creation.
- **Enforcement point:** Node backend and Supabase edge function.
- **Evidence:** Direct server API call/SDK checkout session creation.
- **Related tests:** Indirect behavior assertions in `server/test/security.test.mjs`.
- **Limitations:** Payment path runtime not executed with live Stripe here.

### PAY-003 — Stripe webhook signature verification gate
- **Importance:** Critical
- **Locations:** `server/src/server.ts:74-97`, `supabase/functions/stripe-webhook/index.ts:16-57,80-95`
- **Technical details:** Node uses Stripe SDK constructEvent; Edge uses HMAC verification path.
- **Purpose:** Accept webhook updates only from Stripe-signed events.
- **Threats mitigated:** Forged payment notifications.
- **Enforcement point:** `/api/stripe-webhook` handlers.
- **Evidence:** Signature header required; invalid signatures rejected.
- **Related tests:** `server/test/security.test.mjs:45-53`.
- **Limitations:** Server tests not executable due build issue.

### PAY-004 — Webhook idempotent pending-state transitions
- **Importance:** High
- **Locations:** `server/src/server.ts:107-127`, `supabase/functions/stripe-webhook/index.ts:107-126`
- **Technical details:** Status updates constrained with `.eq('status','pending')`.
- **Purpose:** Prevent duplicate/late webhook transitions from overwriting finalized states.
- **Threats mitigated:** Order-state corruption and replay side effects.
- **Enforcement point:** DB update predicates in webhook handlers.
- **Evidence:** Transition guards implemented for completed/expired events.
- **Related tests:** Behavior intent documented in tests; direct DB idempotency test not executed.
- **Limitations:** No persisted event-id deduplication table.

### API-001 — Open-redirect sanitization for return URLs
- **Importance:** High
- **Locations:** `server/src/server.ts:39-56,324-330`, `supabase/functions/create-checkout-session/index.ts:8-24,164-171`
- **Technical details:** Allowlist origin/localhost/loopback/subdomain; fallback to trusted domain.
- **Purpose:** Prevent redirect-based phishing after checkout.
- **Threats mitigated:** Open redirect abuse.
- **Enforcement point:** URL sanitizer in checkout APIs.
- **Evidence:** URL parsing + allowlist checks.
- **Related tests:** `server/test/security.test.mjs:84-113`.
- **Limitations:** Domain policy currently hardcoded to `ivorynails.com` + configured store URL.

### API-002 — Checkout rate limiting (per-IP in-memory)
- **Importance:** High
- **Locations:** `server/src/server.ts:20-37,210-216`
- **Technical details:** 30 requests/15 minutes per IP using in-memory map.
- **Purpose:** Slow bot/carding/flood abuse.
- **Threats mitigated:** Basic brute-force checkout abuse.
- **Enforcement point:** Checkout endpoint precondition.
- **Evidence:** `isRateLimited` check returns HTTP 429.
- **Related tests:** `server/test/security.test.mjs:115-124`.
- **Limitations:** Single-instance memory only (see gaps).

### OPS-001 — Security posture health checks (schema/RLS/config state)
- **Importance:** Medium
- **Locations:** `server/src/server.ts:143-205`, `supabase/functions/health-check/index.ts:15-65`, `supabase/schema.sql:203-229`
- **Technical details:** Health endpoints report safe booleans for stripe/webhook/supabase/schema/RLS readiness.
- **Purpose:** Detect insecure/incomplete deployment states.
- **Threats mitigated:** Silent misconfiguration.
- **Enforcement point:** Operational diagnostics endpoints + DB helper RPC.
- **Evidence:** Calls `check_atelier_schema_status` and fallback checks.
- **Related tests:** `server/test/security.test.mjs:26-43`.
- **Limitations:** Publicly reachable health endpoint may expose operational metadata.

### WEB-001 — Browser CSP present in web shell
- **Importance:** Medium
- **Locations:** `web/index.html:22-24`
- **Technical details:** Defines `Content-Security-Policy` including script/style/frame/connect/img directives.
- **Purpose:** Baseline browser-side script origin restrictions.
- **Threats mitigated:** Some XSS/resource injection vectors.
- **Enforcement point:** Static web entry HTML.
- **Evidence:** CSP meta tag exists.
- **Related tests:** None.
- **Limitations:** Includes `'unsafe-inline'` and `'unsafe-eval'` (see partial/gaps).

---

## Partially Implemented Controls

| ID | Feature | Category | Importance | Status | Evidence |
|---|---|---|---|---|---|
| API-003 | CORS origin restrictions | API Security | High | Partially implemented | `server/src/server.ts:18,139`; `supabase/functions/_shared/cors.ts:1-5` (`*` allowed by default) |
| WEB-002 | Strict CSP hardening | Web Security | High | Partially implemented | `web/index.html:23` includes `'unsafe-inline'` + `'unsafe-eval'` |
| OPS-002 | Scalable abuse controls | Operations | Medium | Partially implemented | `server/src/server.ts:20-37` in-memory limiter only |

---

## Conditionally Enabled Controls

| ID | Feature | Category | Importance | Status | Condition |
|---|---|---|---|---|---|
| INT-001 | Real-payment path activation gate | Integration | High | Conditionally enabled | Enabled only when production mode + valid Stripe publishable key + valid backend URL (`lib/services/integration_service.dart:89-103`) |
| INT-002 | Supabase cloud path activation gate | Integration | Medium | Conditionally enabled | Enabled only when Supabase URL + publishable key pass validation (`lib/services/integration_service.dart:55-87`) |

---

## Test-only Controls

| ID | Feature | Category | Importance | Status | Evidence |
|---|---|---|---|---|---|
| TEST-001 | Node security regression tests for webhook/health/redirect/rate-limit | Testing | Medium | Test-only | `server/test/security.test.mjs:26-145` |
| TEST-002 | Pricing integrity test coverage | Testing | Medium | Test-only | `server/test/pricing.test.mjs:20-102` |
| TEST-003 | Flutter config and isolation assertions | Testing | Low | Test-only | `test/config/*.dart`, `test/security/security_isolation_test.dart` |

---

## Documented-only Items

| ID | Claim | Status | Evidence |
|---|---|---|---|
| DOC-001 | Claims of full production-ready verification in docs | Documented only | `README.md:219-253`, `PRODUCTION_README.md:196-210`; full runtime verification not reproducible in this environment |
| DOC-002 | Security statements requiring deployment context (e.g., “safe by default 24/7”) | Documented only | `PRODUCTION_README.md:196-209`; operational guarantees depend on deployment config |

---

## Unverified Items (Further Verification Needed)

| ID | Item | Status | Why unverified |
|---|---|---|---|
| INFRA-001 | Real deployment secret management quality | Unverified | Repo templates exist, but runtime host secret-store configuration is external |
| INFRA-002 | Supabase function deployment and secret injection state | Unverified | Requires project environment access and `supabase secrets` inspection |
| OPS-003 | End-to-end Stripe webhook operation in deployed env | Unverified | No live Stripe/Supabase runtime test executed |
| DB-002 | Live RLS enforcement against deployed Supabase instance | Unverified | SQL policies present but not exercised against a running database from this environment |

---

## Security Gaps and Limitations

### Confirmed gaps (code evidence)
1. **Permissive CORS** — wildcard origin remains allowed (`server/src/server.ts:18`; `supabase/functions/_shared/cors.ts:2`).  
   **Remediation:** Replace wildcard with explicit allowlist and environment-specific origin validation.
2. **Hardcoded VIP credentials in production auth service path** — `signInAsDemoVip` uses fixed credentials (`lib/services/auth/supabase_auth_service.dart:78-92`).  
   **Remediation:** Remove hardcoded credentials from production auth service; gate demo-only users to demo service exclusively.
3. **Low-entropy order IDs** — 4-digit random suffix (`server/src/server.ts:284-286`; `supabase/functions/create-checkout-session/index.ts:118-120`).  
   **Remediation:** Use collision-resistant IDs (UUID/ULID) with uniqueness enforcement handling.
4. **CSP relaxations** — `'unsafe-inline'` and `'unsafe-eval'` enabled (`web/index.html:23`).  
   **Remediation:** Move inline scripts/styles to hashed/nonced assets; remove unsafe directives where feasible.
5. **Rate limiting not distributed** — in-memory map only (`server/src/server.ts:20-37`).  
   **Remediation:** Move to Redis/API gateway/global rate limiting.
6. **`SECURITY DEFINER` hardening incomplete** — functions do not set explicit safe `search_path` (`supabase/schema.sql:94-109,203-229`).  
   **Remediation:** Set secure `search_path`, least-privilege grants, and explicit EXECUTE grants.

### Verification limitations (process/environment)
1. Node backend test execution blocked by TypeScript toolchain incompatibility (`tsconfig`/runtime mismatch).
2. Flutter test/analyze blocked because Flutter SDK is unavailable in this sandbox.
3. No live Supabase/Stripe environment access for end-to-end enforcement checks.

---

## Tests and Verification Results

| Command | Result | Notes |
|---|---|---|
| `github actions list_workflow_runs` + `get_job_logs(failed_only=true)` | Completed | No failed jobs found in current run (run id: 38433675051) |
| `npm --prefix server run build` | Failed | TS config/runtime incompatibility (`moduleResolution=node10 removed`) |
| `npm --prefix server test` | Not run | Skipped because build step failed and tests import dist artifacts |
| `flutter test` | Failed to start | `flutter: command not found` |
| `npm --prefix server audit --omit=dev` | Passed | 0 vulnerabilities reported |

Static inspection was therefore the primary verification method for most controls.

---

## Prioritized Remediation Roadmap

### Priority 0 (Critical / High)
1. Remove hardcoded VIP production credentials.
2. Restrict CORS origins for Node and Supabase functions.
3. Replace weak order ID scheme with collision-resistant IDs.

### Priority 1 (High)
4. Harden CSP by eliminating unsafe script/style execution where possible.
5. Add persistent/distributed rate limiting.

### Priority 2 (Medium)
6. Harden `SECURITY DEFINER` functions with explicit `search_path` and grant review.
7. Restore backend CI reliability by resolving TypeScript build config compatibility.
8. Add deploy-time RLS and webhook end-to-end integration tests.

---

## Appendices

### Appendix A — Full Feature Index
- Verified implemented: 20 IDs (`SECR-001`, `AUTH-001..004`, `AUTHZ-001..005`, `DB-001`, `SECR-002`, `PAY-001..004`, `API-001..002`, `OPS-001`, `WEB-001`)
- Partially implemented: 3 IDs (`API-003`, `WEB-002`, `OPS-002`)
- Conditionally enabled: 2 IDs (`INT-001`, `INT-002`)
- Test-only: 3 IDs (`TEST-001..003`)
- Documented only: 2 IDs (`DOC-001`, `DOC-002`)
- Unverified: 4 IDs (`INFRA-001`, `INFRA-002`, `OPS-003`, `DB-002`)

### Appendix B — Source Index (security-relevant files inspected)
- `server/src/server.ts`, `server/src/pricing.ts`, `server/src/types.ts`
- `server/test/security.test.mjs`, `server/test/pricing.test.mjs`
- `supabase/schema.sql`, `supabase/migrations/001_initial_schema.sql`, `supabase/migrations/002_harden_rls_and_integrity.sql`
- `supabase/functions/create-checkout-session/index.ts`, `supabase/functions/stripe-webhook/index.ts`, `supabase/functions/health-check/index.ts`, `supabase/functions/_shared/cors.ts`, `supabase/functions/_shared/pricing.ts`
- `lib/core/config/app_config.dart`, `lib/core/config/config_validator.dart`, `lib/services/integration_service.dart`, `lib/services/auth/supabase_auth_service.dart`, `lib/services/auth/demo_auth_service.dart`, `lib/services/payment/stripe_payment_service.dart`, `lib/providers/auth_provider.dart`, `lib/services/supabase_service.dart`, `lib/services/order/supabase_order_service.dart`
- `web/index.html`
- `.env.example.json`, `.env.backend.example`, `.gitignore`, `README.md`, `PRODUCTION_README.md`, `pubspec.yaml`, `server/package.json`, `server/package-lock.json`
- Flutter tests: `test/config/app_config_test.dart`, `test/config/config_validator_test.dart`, `test/security/security_isolation_test.dart`, `test/services/integration_service_test.dart`

### Appendix C — Test Index
- Node tests: `server/test/pricing.test.mjs`, `server/test/security.test.mjs`
- Flutter tests: `test/config/*`, `test/security/*`, `test/services/*`

### Appendix D — Definitions
- **Verified implemented:** Directly evidenced in executable/source logic in this repo.
- **Partially implemented:** Exists but materially weak/incomplete.
- **Conditionally enabled:** Active only in specific modes/configuration.
- **Test-only:** Present only in tests, not as production control.
- **Documented only:** Claimed in docs without sufficient executable evidence.
- **Unverified:** Plausible but not confirmable from available environment/runtime.

### Appendix E — Scope Limitations
- No production environment credentials or live service access.
- Flutter SDK unavailable; Node build failed due toolchain mismatch.
- No destructive or external attack testing performed.
