---
title: UI App Block Rendering Pipeline
date: 2026-04-09
context: Explored how Boost AI Search & Filter app blocks are rendered in Shopify storefront
tags: [rendering, liquid, ssr, csr, app-blocks, tae, boost-fe-lib, shopify]
---

# UI App Block Rendering Pipeline

Use this note as context whenever working on requirements that touch **storefront UI app blocks** — 
filter widgets, recommendation widgets, search widgets, product listing, or any Shopify theme extension.

---

## Repo Responsibilities

| Repo | Role |
|------|------|
| `boost-sf-filter-admin-html-v2` | React admin UI — merchant configures widgets & templates |
| `boost-pfs-backend` | Compiles Liquid templates + CSS, syncs to Shopify metafields |
| `boost-fe-lib` | **Both sides**: Liquid blocks (SSR) + `bc-widget-integration.js` (CSR engine) |
| `boost-pfs-fe-api` | BFF — serves filter/search/product data to the CSR layer at runtime |
| `apphub-vision` | Separate "Clearer App" — parallel system with its own TAE and build pipeline |

---

## The Two Rendering Layers

### Layer 1 — SSR (Server-Side Rendering via Shopify Liquid)

**Handled by:** `boost-fe-lib/packages/widget-integration-tae/`

**Source files (Liquid blocks):**
- `src/embedded/app-embedded.liquid` → compiled to `boost-sd-ssr.liquid` (injected in `<head>`)
- `src/blocks/filter-product-list/filter-product-list.liquid` → `filter-product-list-ssr.liquid`
- `src/blocks/recommendation/recommendation.liquid` → `recommendation-ssr.liquid`
- `src/v3/blocks/` → v3 format blocks (newer)

**Build:** `apps/boost-tae-deployment/` runs `liquid-compiler` CLI → compiled blocks deployed via `shopify app deploy`

**What SSR produces:**
- `window.boostWidgetIntegration` — global config, settings, translations (from `app.metafields.boost-sd.*`)
- `window.boostSDFallback` — server-injected product/pagination data from Shopify Liquid objects
- `<script src="bc-widget-integration.js">` — loads the CSR engine
- Placeholder HTML divs (e.g., `<div class="boost-sd__filter-product-list">`) that CSR mounts into
- Inline `app.metafields` reads for recommendation widget config

**Key data injected by Liquid:**
```liquid
window.boostSDFallback = {
  products: {{ collection.products | json }},
  pagination: {{ paginate | json }},
  moneyFormat: {{ shop.money_with_currency_format }}
};
```

---

### Layer 2 — CSR (Client-Side Rendering via boost-fe-lib)

**Handled by:** `boost-fe-lib/packages/widget-integration/`

**Entry point:** `src/index.ts` → `main()` → `bootstrap(AppModule)`

**CSR boot sequence:**
1. `bc-widget-integration.js` (UMD bundle) loads from CDN
2. `getBoostTAE()` → `TAEApp.onReady()` → DI container starts
3. `AppSettings.init()` — reads Liquid vars via `window.liquidTransform()`
4. Module discovers blocks by CSS class: `querySelector('.boost-sd__filter-product-list')`
5. Fetches filter/product data from `boost-pfs-fe-api` (BFF)
6. `TAEApp.registerBlock(block)` → `AppModule` lazy-imports `FilterModule`
7. Module renders full widget UI into the placeholder div

**Module files (CSR side):**
- `src/modules/filter/` — filter tree rendering
- `src/modules/recommendation/` — recommendation widget
- `src/modules/instant-search/` — instant search
- `src/modules/cart/`, `pre-order/`, `volume-bundle/`, `predictive-bundle/`

**Build output:** `dist/<version>/bc-widget-integration.js` (UMD) + dynamic chunks per module

---

## Template Compilation Flow (boost-pfs-backend)

When a merchant saves a template config in the admin UI:

1. `boost-sf-filter-admin-html-v2` → `PUT /boost-pfs-widget-integration/admin/template-instance/{id}`
2. `boost-pfs-backend/packages/widget-integration` receives it
3. `raw-compile-template.service.ts` compiles Liquid from 42 widget template types
4. `compile-css.service.ts` compiles SCSS → CSS
5. `template-instance-metafield.service.ts` pushes to **Shopify App Metafields**

**Metafield keys:**
- `app.metafields.boost-sd-instance['template-{id}-{name}']` — compiled Liquid template HTML
- `app.metafields.boost-sd-instance['instance-{id}-settings']` — CSS
- `app.metafields.recommendation.{page}` — recommendation widget config per page type
- `app.metafields.boost-sd.general-settings` — global app settings
- `shop.metafields.boostpfs-settings.integration` — integration config

---

## Key Touch Points When Changing App Blocks

### Changing the Liquid block structure (SSR side)
- **Edit:** `boost-fe-lib/packages/widget-integration-tae/src/blocks/*.liquid`
- **Build:** `cd apps/boost-tae-deployment && npm run build`
- **Deploy:** `shopify app deploy`
- **Impact:** Changes how Shopify renders the placeholder HTML and what data is injected into `window`

### Changing widget rendering logic (CSR side)
- **Edit:** `boost-fe-lib/packages/widget-integration/src/modules/*/`
- **Build:** `npm run build` in `packages/widget-integration/`
- **Deploy:** Publish `bc-widget-integration.js` to CDN
- **Impact:** Changes how widgets mount and render client-side

### Changing template structure / widget types
- **Edit:** `boost-pfs-backend/packages/widget-integration/src/widget-templates/`
- **Impacts:** What gets compiled and stored in Shopify metafields
- **42 widget types** — each has its own folder with templates

### Adding a new app block type
Requires changes in **all three layers**:
1. `boost-fe-lib` (TAE): new `.liquid` source file + schema
2. `boost-pfs-backend`: new widget template type + compilation logic
3. `boost-fe-lib` (CSR): new module in `packages/widget-integration/src/modules/`

---

## The Role of boost-pfs-fe-api

Acts as **BFF (Backend-for-Frontend)** between CSR and backend services.

The CSR layer (`bc-widget-integration.js`) never calls `boost-pfs-backend` directly.
All runtime data requests go through `boost-pfs-fe-api`:
- Filter tree data
- Product listings (with Elasticsearch results)
- Search results
- Recommendation product lists

---

## apphub-vision (Clearer App) — Parallel System

The Clearer App (`apphub-vision`) has its own identical pattern but independent implementation:
- TAE source: `apps/widget-integration-tae/src/blocks/`
- Build: `apps/widget-integration-tae/compiler/build-tae.ts`
- Output: `apps/shopify/extensions/theme-app-extension/blocks/`
- Different app ID (`9b4a82b9922ade2c9db5b8887856c93b`), different metafield namespaces
- Same concepts: metafield-driven config, TAE blocks, JS widget modules

Changes to Boost app blocks **do not affect** Clearer App blocks and vice versa.
