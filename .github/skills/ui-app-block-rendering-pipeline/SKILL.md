---
name: ui-app-block-rendering-pipeline
description: >
  Loads full context about how Boost AI Search & Filter UI app blocks are rendered in the Shopify
  storefront — covering server-side rendering (Liquid/TAE), client-side rendering (bc-widget-integration.js),
  template compilation (boost-pfs-backend), and the BFF API layer (boost-pfs-fe-api).
  Use this skill whenever working on requirements or changes related to: UI app blocks, filter widgets,
  recommendation widgets, search widgets, Liquid templates, Theme App Extension (TAE), boost-fe-lib,
  storefront rendering, Shopify metafields for widgets, or any cross-repo change touching the
  widget integration pipeline. Also use it when a task involves boost-pfs-backend widget-integration
  package, boost-pfs-fe-api, or widget template compilation.
---

# UI App Block Rendering Pipeline

This skill provides context about how Boost AI Search & Filter app blocks are rendered in the Shopify storefront. Load it whenever making changes that touch the widget rendering pipeline.

## Quick Reference

| Repo | Role |
|------|------|
| `boost-sf-filter-admin-html-v2` | React admin UI — merchant configures widgets & templates |
| `boost-pfs-backend` | Compiles Liquid templates + CSS, syncs to Shopify metafields |
| `boost-fe-lib` | **Both SSR** (Liquid blocks) **and CSR** (`bc-widget-integration.js`) |
| `boost-pfs-fe-api` | BFF — serves filter/search/product data to CSR at runtime |
| `apphub-vision` | Separate "Clearer App" — parallel system, do not conflate |

## Two Rendering Layers

**SSR (Shopify Liquid):** `boost-fe-lib/packages/widget-integration-tae/src/blocks/*.liquid`
- Built by `liquid-compiler` in `apps/boost-tae-deployment/`
- Deployed via `shopify app deploy`
- Injects `window.boostWidgetIntegration`, `window.boostSDFallback`, `<script>` tag

**CSR (JavaScript):** `boost-fe-lib/packages/widget-integration/src/`
- Entry: `src/index.ts` → `bootstrap(AppModule)`
- Discovers blocks via DOM class selectors
- Fetches data from `boost-pfs-fe-api`
- Lazily imports `FilterModule`, `RecommendationModule`, etc.

## When Making Changes

- **Liquid block structure** → edit `boost-fe-lib/packages/widget-integration-tae/src/blocks/`
- **Widget rendering logic** → edit `boost-fe-lib/packages/widget-integration/src/modules/`
- **Template types / widget config** → edit `boost-pfs-backend/packages/widget-integration/src/widget-templates/`
- **Adding a new block type** → requires changes in all three layers (TAE liquid + backend template + CSR module)

## Full Reference

For deep details — boot sequence, metafield keys, compilation flow, sequence diagrams, data flow:

→ Read `references/rendering-pipeline.md`
