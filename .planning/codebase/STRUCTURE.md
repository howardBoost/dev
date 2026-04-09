# Codebase Structure

**Analysis Date:** 2025-04-09

## Directory Layout

```
/workspaces/python/
├── repos/                        # 5 independent repositories
│   ├── apphub-vision/            # AI analytics platform (Clearer)
│   ├── boost-pfs-backend/        # Product sync & indexing
│   ├── boost-fe-lib/             # Frontend library & components
│   ├── boost-pfs-fe-api/         # Shopify product filter API
│   ├── boost-sf-filter-admin-html-v2/  # Admin dashboard
│   └── mempalace.yaml            # Project workspace config
├── data/                         # Local data and artifacts
│   ├── copilot/                  # Copilot integration data
│   └── mempalace/                # Mempalace configuration
├── .planning/                    # Planning documents
│   └── codebase/                 # This directory
├── clone-repos.sh                # Script to clone all repos
├── setup-env.sh                  # Environment setup script
├── start-copilot-yolo.sh         # Launch Copilot CLI
├── Dockerfile                    # Container definition for workspace
├── entities.json                 # Project metadata (people, projects)
└── python_typescript.code-workspace  # VS Code workspace config
```

## Directory Purposes

**repos/**:
- Purpose: Contains 5 independent git repositories with separate CI/CD pipelines
- Contains: Backend APIs, frontend libraries, admin dashboards, shared packages
- Key files: Each repo has `.git/`, `package.json`, `pnpm-workspace.yaml` or npm workspaces config

**data/**:
- Purpose: Local development data and copilot integration artifacts
- Contains: Copilot context memory, mempalace configuration
- Generated: Yes
- Committed: No (local-only)

**.planning/**:
- Purpose: GSD (Get Stuff Done) planning documents and codebase analysis
- Contains: ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md, INTEGRATIONS.md, STACK.md
- Generated: Yes (by GSD tools)
- Committed: Yes

## Repository Structure (Within Each Repo)

### apphub-vision (Clearer AI Analytics Platform)

```
repos/apphub-vision/
├── apps/                    # Deployable applications
│   ├── ai-api/             # Fastify WebSocket API (main backend)
│   ├── dashboard/          # Next.js admin dashboard
│   ├── billing/            # Billing service
│   ├── billing-lambda/     # AWS Lambda for billing events
│   ├── lambda/             # Lambda functions for event processing
│   ├── shopify/            # Shopify app (theme extensions)
│   ├── widget-integration-tae/  # Theme app extension
│   └── boost-store-front-lib/   # Storefront library
├── packages/               # Shared packages (@clearer/*)
│   ├── core/              # Business logic, identity management
│   ├── assistant/         # AI/ML workflows (LangChain, LangGraph)
│   ├── utils/             # Shared utilities
│   ├── ui-utils/          # React UI utilities & components
│   ├── server-utils/      # Server-side utilities
│   ├── app-database/      # Prisma schema (main app)
│   ├── billing-database/  # Prisma schema (billing)
│   ├── event-database/    # Prisma schema (events/ingest)
│   ├── aiml/              # AI/ML utilities
│   ├── feature-dashboard-chat/   # Chat feature module
│   ├── feature-profile-export/   # Export feature module
│   ├── types/             # Shared TypeScript types
│   ├── eslint-config/     # Shared ESLint rules
│   └── ui-core/           # Core UI components
├── cdk/                    # AWS CDK infrastructure as code
├── kubernetes/             # K8s manifests (base, staging, prod)
├── docs/                   # Documentation
├── package.json            # Monorepo root with workspaces & scripts
├── pnpm-workspace.yaml     # pnpm workspace configuration
└── ARCHITECTURE.md         # Application-specific architecture docs
```

### boost-pfs-backend (Product Filter Sync - bc-sip)

```
repos/boost-pfs-backend/
├── packages/               # Main packages for sync pipeline
│   ├── sip-api/           # Express API server for sync endpoints
│   ├── sip-sync-process/  # Main sync/index engine
│   ├── sip-map-process/   # Data mapping service
│   ├── sip-flow-manager/  # Workflow orchestration
│   ├── sip-change-detector/  # Change detection service
│   ├── sip-worker-history/   # Worker state tracking
│   ├── sip-worker-email-report/  # Email reporting
│   ├── admin-api/         # Admin dashboard API
│   ├── workflow-api/      # Workflow management API
│   ├── migration/         # Data migration tools
│   ├── data-preparer/     # Data transformation utilities
│   ├── widget-integration/ # Widget integration
│   ├── pricing/           # Pricing calculation module
│   └── sip-common/        # Shared utilities & types
├── libs/                   # Libraries
│   ├── liquid-linter/     # Shopify Liquid template linting
│   └── [other-libs]/
├── es-mapping/            # Elasticsearch mapping definitions
├── config/                # Configuration files
├── dev-ops/              # DevOps & CI/CD config
├── kubernetes/            # K8s manifests
├── package.json           # Monorepo with workspaces
└── bitbucket-pipelines.yml  # Bitbucket CI/CD pipeline
```

### boost-fe-lib (Frontend Library & Widget Integration)

```
repos/boost-fe-lib/
├── apps/                   # Deployable apps
│   └── widget-integration-tae/  # Theme app extension
├── packages/               # Feature packages
│   ├── widget-integration/ # Main widget component library
│   └── analytic/          # Analytics tracking package
├── libs/                   # Framework & infrastructure libraries
│   ├── ui-core/           # Core React components
│   ├── framework/         # Framework base classes
│   ├── liquid-compiler/   # Shopify Liquid template compiler
│   ├── cli/              # CLI tools
│   ├── webpack-build-hooks-plugin/  # Webpack plugin
│   ├── doc-gen/          # Documentation generator
│   ├── eslint-config/    # ESLint configuration
│   └── internal-3rd-libs/ # Third-party integrations
├── kubernetes/            # K8s manifests
├── docs-site/            # Documentation website (Docusaurus)
├── scripts/              # Build and deployment scripts
└── package.json          # Monorepo workspaces
```

### boost-pfs-fe-api (Shopify Product Filter REST API)

```
repos/boost-pfs-fe-api/
├── app.js                 # Express app setup
├── error-handler.js       # Central error handling
├── alias-loader.mjs       # Module alias loader for imports
├── server.js              # Server entry (if separate from app.js)
├── libs/                  # Shared libraries
├── config/               # Configuration directory
├── scripts/              # Build & utility scripts
├── package.json          # Dependencies (no workspaces)
└── bitbucket-pipelines.yml  # CI/CD pipeline
```

### boost-sf-filter-admin-html-v2 (Admin Dashboard)

```
repos/boost-sf-filter-admin-html-v2/
├── src/
│   ├── components/       # React components
│   │   ├── containers/  # Container/smart components
│   │   └── views/       # View/page components
│   ├── stores/          # Redux store setup
│   │   ├── actions/     # Redux action creators (by feature)
│   │   ├── reducers/    # Redux reducers (by feature)
│   │   ├── flow-type/   # Flow filter state
│   │   ├── dashboard/   # Dashboard state
│   │   └── shopify-integration/  # Shopify integration state
│   ├── services/        # Business logic & API calls
│   │   └── apis/        # API client functions
│   ├── integrations/    # Third-party integrations
│   │   └── shopify-app-bridge/  # Shopify App Bridge setup
│   ├── routes/          # Route definitions
│   ├── libs/            # Utility libraries
│   ├── styles/          # CSS/SCSS styles
│   ├── locales/         # i18n translations
│   │   ├── scripts/     # i18n processing scripts
│   │   ├── constants/   # i18n constants
│   │   └── data/        # Translation data
│   ├── constants/       # App constants
│   └── expose/          # React provider setup
│       └── provider/    # Context providers
├── public/              # Static assets
├── config/             # Build configuration (Jest, etc.)
└── package.json        # Dependencies
```

## Key File Locations

**Entry Points:**
- `repos/apphub-vision/apps/ai-api/src/index.ts`: WebSocket + REST API server
- `repos/apphub-vision/apps/dashboard/app/page.tsx`: Next.js dashboard
- `repos/boost-pfs-backend/packages/sip-api/src/app.ts`: Express API
- `repos/boost-pfs-fe-api/app.js`: Express server for filter API
- `repos/boost-sf-filter-admin-html-v2/src/index.tsx`: React SPA entry

**Configuration:**
- `/workspaces/python/repos/apphub-vision/pnpm-workspace.yaml`: Workspace package groups, dependency catalogs
- `/workspaces/python/repos/apphub-vision/package.json`: Build scripts, root dependencies
- `/workspaces/python/repos/apphub-vision/tsconfig.json`: TypeScript configuration with path aliases
- `/workspaces/python/repos/boost-pfs-backend/package.json`: bc-sip workspaces & scripts
- `/workspaces/python/repos/boost-fe-lib/tsconfig.json`: Frontend library TypeScript config

**Database Schemas:**
- `repos/apphub-vision/packages/app-database/prisma/schema.prisma`: Main app schema
- `repos/apphub-vision/packages/billing-database/prisma/schema.prisma`: Billing schema
- `repos/apphub-vision/packages/event-database/prisma/schema.prisma`: Event/ingest schema

**Core Business Logic:**
- `repos/apphub-vision/packages/core/src/identity/`: Identity management
- `repos/apphub-vision/packages/assistant/src/`: AI agent workflows
- `repos/boost-pfs-backend/packages/sip-common/src/`: Shared SIP utilities
- `repos/boost-sf-filter-admin-html-v2/src/services/`: Filter admin API clients

**Infrastructure:**
- `repos/apphub-vision/kubernetes/`: K8s manifests (base, staging, prod overlays)
- `repos/apphub-vision/cdk/`: AWS CDK infrastructure definitions
- `repos/boost-pfs-backend/dev-ops/`: Docker, deploy templates

## Naming Conventions

**Files:**
- TypeScript/JavaScript: `camelCase.ts`, `camelCase.js` (functions/exports)
- Components: `PascalCase.tsx` (React components)
- Tests: `*.test.ts`, `*.spec.ts` (Jest/Vitest pattern)
- Configuration: `config.json`, `tsconfig.json`, `.eslintrc.json` (kebab-case for config files)

**Directories:**
- Feature-based: `features/`, `services/`, `components/`, `utils/`
- Monorepo packages: lowercase with hyphens (`app-database`, `ui-utils`, `sip-api`)
- Feature domains: lowercase (`dashboard`, `billing`, `ai-api`)

**Package Names:**
- Scoped to org: `@clearer/*` (apphub-vision), `@bc-sip/*` (boost-pfs-backend), `@boost-sd/*` (boost-fe-lib)
- Pattern: `@scope/descriptive-name`

**Exports/Barrel Files:**
- Many packages use barrel files: `src/index.ts` re-exports public API
- Example: `repos/apphub-vision/packages/utils/src/index.ts`

## Where to Add New Code

**New Backend Feature/API Endpoint:**
- Primary code: `apps/{app-name}/src/` (for app-specific) or `packages/{new-package}/src/`
- Type definitions: `packages/types/src/` (if shared) or co-locate in package
- Tests: `{location}/__tests__/` or `{location}.test.ts` (co-located)
- Example: New AI agent → `packages/assistant/src/agents/{agent-name}.ts`

**New React Component:**
- Reusable components: `libs/ui-core/src/components/` (boost-fe-lib) or `packages/ui-utils/src/` (apphub-vision)
- App-specific components: `apps/{app-name}/src/components/`
- Tests: `src/components/{name}.test.tsx`

**New Database Entity:**
- Add to Prisma schema: `packages/{*-database}/prisma/schema.prisma`
- Create migration: Run `pnpm db:migrate` (apphub-vision) or equivalent
- Update types: TypeScript types auto-generated from Prisma

**New Shared Package:**
- Create in `packages/` directory with `package.json` containing:
  - `"name": "@scope/package-name"`
  - `"main": "./src/index.ts"` (or dist for built packages)
  - `"exports"` field for modern import paths
- Add to `pnpm-workspace.yaml` packages list
- Create `tsconfig.json` extending root tsconfig

**New CLI Tool:**
- Location: `libs/cli/` (boost-fe-lib) or create `apps/cli-app/`
- Entry: Executable script in package `bin` field
- Pattern: TypeScript with ts-node or compiled JavaScript

**Configuration Changes:**
- ESLint rules: `packages/eslint-config/`
- TypeScript paths: Root `tsconfig.json` `compilerOptions.paths`
- Build settings: Turbo tasks in `turbo.json` (root) or workspace package.json

## Special Directories

**kubernetes/**:
- Purpose: Kubernetes manifests for cloud deployment
- Structure: `base/` (common), `staging/`, `prod/` (overlays)
- Generated: No (manually maintained)
- Committed: Yes

**cdk/**:
- Purpose: AWS CDK infrastructure as code (apphub-vision only)
- Generated: No (manually maintained)
- Committed: Yes

**docs/** / **docs-site/**:
- Purpose: Project documentation and auto-generated docs
- Generated: docs-site is built from source
- Committed: Source committed, builds generated

**scripts/**:
- Purpose: Utility scripts for builds, deployment, local setup
- Examples: `create-branch.sh`, `build-tae-cli.js`, `generate-release-notes.mjs`
- Committed: Yes

**.changeset/**:
- Purpose: Versioning and changelog management (Changesets CLI)
- Generated: Yes (on release process)
- Committed: Partially (PR mode writes new files)

**es-mapping/** (boost-pfs-backend):
- Purpose: Elasticsearch index mapping definitions
- Generated: No (manually configured)
- Committed: Yes

**node_modules/**:
- Purpose: Installed dependencies
- Generated: Yes (from package-lock.json or pnpm-lock.yaml)
- Committed: No (.gitignore)

**dist/** / **build/**:
- Purpose: Compiled output from TypeScript
- Generated: Yes (npm run build)
- Committed: No (in .gitignore)

## Import Path Conventions

**TypeScript Path Aliases** (from root tsconfig.json):
- `@scope/package-name`: Points to package workspace
- `~`: Root directory alias (if configured)
- Relative imports: `../../../` avoided in favor of path aliases

**Module Resolution:**
- pnpm workspaces: Hoisting enabled, direct imports: `import { x } from '@package/name'`
- Barrel exports: `import { Component } from './components'` (imports index.ts)

## Build & Development Commands

**Root Level** (monorepo):
- `turbo run build`: Build all packages using Turbo cache
- `turbo watch dev`: Watch and dev build all packages
- `turbo run test`: Run tests across all packages
- `turbo run lint`: Lint all packages

**Package Level** (individual):
- `npm run build -w=@scope/package-name`: Build single package
- `npm run dev -w=@scope/package-name`: Dev mode for single package
- `pnpm --filter @scope/package-name build`: Build with pnpm filtering

**Database**:
- `pnpm db:generate`: Generate Prisma client
- `pnpm db:migrate`: Run migrations
- `pnpm db:studio`: Open Prisma Studio UI

---

*Structure analysis: 2025-04-09*
