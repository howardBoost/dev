# Architecture

**Analysis Date:** 2025-04-09

## Pattern Overview

**Overall:** Monorepo Architecture with Multiple Polyglot Applications

This codebase is a **polyrepo-within-monorepo hybrid**, consisting of 5 independent repositories (boost projects and clearer/apphub-vision), each using monorepo patterns internally with their own workspaces, build systems, and deployment strategies.

**Key Characteristics:**
- Multiple independent git repositories cloned into `/workspaces/python/repos/`
- Each repository uses pnpm workspaces or npm workspaces for internal package management
- Turbo for build orchestration and task running
- Next.js, Fastify, and Express applications side-by-side
- Mix of TypeScript/JavaScript backend services and React frontends
- Shared infrastructure via Kubernetes and AWS CDK
- Database-first approach with Prisma schemas

## Layers

**Repository Layer** (Top Level):
- Purpose: Isolate independent projects with separate release cycles
- Location: `/workspaces/python/repos/`
- Contains: 5 major repositories (boost-pfs-backend, boost-fe-lib, boost-pfs-fe-api, boost-sf-filter-admin-html-v2, apphub-vision)
- Orchestrated by: Scripts in root directory

**Monorepo Layer** (within each repository):
- Purpose: Manage packages, applications, and libraries with shared dependencies
- Location: `packages/`, `apps/`, `libs/` within each repo
- Contains: TypeScript/JavaScript modules with specific domains
- Build tool: Turbo, npm/pnpm workspaces
- Dependency management: Centralized package.json catalogs (pnpm)

**Application Layer**:
- **API Applications:** Fastify (ai-api), Express (sip-api, boost-pfs-fe-api)
- **Frontend Applications:** Next.js (dashboard, boost-sf-filter-admin-html-v2)
- **Worker Applications:** Lambda functions, background services
- **Location:** `apps/` within each monorepo

**Package Layer** (Shared):
- **Database Packages:** Prisma schemas with migrations (`app-database`, `billing-database`, `event-database`)
- **Business Logic:** Core services, identity management (`core`, `assistant`)
- **Utilities:** Common functions, type definitions (`utils`, `ui-utils`, `server-utils`)
- **Framework/Config:** ESLint configs, shared setup (`eslint-config`, `framework`)
- **Features:** Domain-specific features (`feature-dashboard-chat`, `feature-profile-export`)
- **Location:** `packages/` in each monorepo

**Infrastructure Layer**:
- **Containerization:** Docker (Dockerfile in repos)
- **Orchestration:** Kubernetes manifests in `kubernetes/` (base, staging, prod)
- **IaC:** AWS CDK in `cdk/` folder (apphub-vision)
- **CI/CD:** GitHub Actions (`.github/workflows/`), Bitbucket Pipelines (`bitbucket-pipelines.yml`)

## Data Flow

**API Request Flow** (Backend Services):

1. **Entry:** HTTP request → Express/Fastify middleware
2. **Route Handling:** Route handler → Controller/Service layer
3. **Business Logic:** Service → Core package (business logic)
4. **Database Access:** Prisma client → PostgreSQL
5. **Response:** JSON response → Client

**Example: boost-pfs-fe-api (Product Filter Search)**
```
HTTP Request (Shopify query)
    ↓
Express middleware (auth, logging)
    ↓
Route handler (app.js, routes/)
    ↓
Service layer (filter logic, search ranking)
    ↓
Elasticsearch query (for product search)
    ↓
Redis cache check/update
    ↓
JSON Response (filtered products)
```

**Frontend Data Flow** (React Applications):

1. **User Interaction:** Browser event
2. **State Management:** Redux/Zustand action dispatch
3. **API Call:** Axios/fetch to backend API
4. **State Update:** Reducer updates store
5. **Re-render:** React component re-renders

**Example: boost-sf-filter-admin-html-v2 (Filter Admin Dashboard)**
```
User action in component
    ↓
Redux action (stores/actions/)
    ↓
Reducer processes action (stores/reducers/)
    ↓
State updates
    ↓
Component re-renders with new state
    ↓
API call for persistence (services/apis/)
```

**AI Workflow Flow** (apphub-vision/ai-api):

1. **WebSocket Connection:** Chat session initiated
2. **Message Processing:** LangGraph agent system
3. **Assistant Execution:** Multi-agent orchestration via LangChain
4. **Data Access:** Query app/ingest/model databases via Prisma
5. **Streaming Response:** WebSocket stream back to client

**State Management:**
- **Backend:** Database of record (PostgreSQL with Prisma ORM)
- **Cache Layer:** Redis (sessions, temporary state, checkpoints in ai-api)
- **Frontend:** In-memory Redux store, localStorage for client-side state
- **Event Bus:** AWS SQS (apphub-vision), Message queues for background jobs

## Key Abstractions

**Package Pattern**:
- Purpose: Encapsulate domain-specific functionality across multiple apps
- Examples: `@clearer/core`, `@clearer/assistant`, `@bc-sip/sip-api`
- Pattern: Each package has `src/`, `package.json`, may have `dist/` for builds

**Monorepo Workspace**:
- Purpose: Unify multiple packages under single dependency tree
- Examples: `packages/*/`, `apps/*/`, `libs/*/`
- Pattern: Root `package.json` with `"workspaces"` array, pnpm/npm hoisting

**Service Layer**:
- Purpose: Isolate business logic from HTTP handlers
- Examples: `src/services/`, API services in boost-sf-filter-admin-html-v2
- Pattern: Classes or functions that operate on data independent of request/response

**Database Schema Package**:
- Purpose: Single source of truth for database definitions
- Examples: `@clearer/app-database`, `@clearer/billing-database`
- Pattern: Prisma schema + migrations, shared across all apps needing that data

**Feature Package**:
- Purpose: Self-contained feature with all dependencies
- Examples: `@clearer/feature-dashboard-chat`, `@clearer/feature-profile-export`
- Pattern: Package includes UI components, services, database schema, types

**Configuration Pattern**:
- Purpose: Environment-specific settings without secrets
- Examples: `config/`, `configs/`, tsconfig paths
- Pattern: Config files in `config/` directory, secrets via env vars only

## Entry Points

**Monorepo-Level** (Root scripts):
- Location: `/workspaces/python/`
- Scripts: `clone-repos.sh` (clone all repos), `setup-env.sh` (environment setup), `start-copilot-yolo.sh` (Copilot CLI)

**Application Entry Points**:

**apphub-vision (Clearer - AI Analytics Platform):**
- `apps/ai-api/src/index.ts`: Main Fastify server, WebSocket server for chat
  - Triggers: npm run dev:server
  - Responsibilities: Chat API, artifact management, real-time AI responses
- `apps/dashboard/app/page.tsx`: Next.js app router entry
  - Triggers: npm run dev (development), npm run start (production)
  - Responsibilities: Admin dashboard, analytics UI
- `apps/billing/src/index.ts`: Billing service
- `apps/lambda/`: AWS Lambda functions for event processing
- `packages/core/src/identity`: Identity/user management core logic

**boost-pfs-backend (Product Filter Sync):**
- `packages/sip-api/src/app.ts`: Express API server
  - Triggers: npm run dev:api
  - Responsibilities: Sync index API, change detection
- `packages/sip-sync-process/src/`: Main sync engine
  - Triggers: npm run dev:sync-process
  - Responsibilities: Pull Shopify data, sync to search index

**boost-fe-lib (Frontend Library & Widget Integration):**
- `packages/widget-integration/src/index.ts`: Widget component library
  - Triggers: npm run dev:widget
  - Responsibilities: Storefront widget rendering, product filters
- `libs/ui-core/src/`: Core UI components
- `apps/widget-integration-tae/`: Theme app extension

**boost-pfs-fe-api (Shopify Filter API):**
- Root: `app.js`, `server.js`
  - Triggers: npm start (production), npm run dev (development)
  - Responsibilities: Filter/search REST API for Shopify storefronts
  - Uses Elasticsearch for search, Redis for caching

**boost-sf-filter-admin-html-v2 (Shopify Filter Admin Dashboard):**
- `src/index.tsx`: React app root (or similar SPA entry)
  - Triggers: Development server, Shopify app bridge integration
  - Responsibilities: Admin dashboard for filter configuration, Redux state management

## Error Handling

**Strategy:** Distributed error handling with centralized logging and monitoring

**Patterns:**

- **Backend Services:** Try-catch blocks with typed error responses
  - Example: Fastify error handler middleware in `apps/ai-api`
  - Pattern: `error-handler.js` (in boost-pfs-fe-api) for standardized error wrapping
  - Response: JSON with `{ error: string, code: string, statusCode: number }`

- **Database Errors:** Prisma error handling with migration guards
  - Pattern: Catch Prisma-specific errors (unique constraints, relation errors)
  - Recovery: Retry logic for transient errors, fail-fast for schema mismatches

- **API Boundary Errors:** Validation + error serialization
  - Pattern: Zod or similar validation at route entry
  - Response: 400 Bad Request with validation details

- **WebSocket Errors** (ai-api): Connection fallback, reconnection logic
  - Pattern: Client-side retry with exponential backoff
  - Server: Graceful degradation to polling if needed

- **Async/Background Job Errors:** Queue-based error retry
  - Pattern: Dead-letter queues (DLQ) in AWS SQS
  - Monitoring: CloudWatch logs, error tracking integration

## Cross-Cutting Concerns

**Logging:**
- **Frontend:** `console.log`, optional DataDog RUM (dd-trace in boost-pfs-fe-api)
- **Backend:** Winston (boost-pfs-fe-api), Fastify logger (ai-api)
- **Pattern:** Structured logs with request IDs, user context, severity levels
- **Location:** Integrated middleware in Express/Fastify apps

**Validation:**
- **Input:** Request body/query validation in route handlers
- **Framework:** Zod (TypeScript apps), basic schema validation
- **Pattern:** Middleware validation before service layer
- **Location:** Early in middleware chain or route handlers

**Authentication:**
- **Shopify Apps:** Custom JWT/session handling + Shopify App Bridge
- **Internal APIs:** Next-Auth (ai-api dashboard), JWT tokens
- **Pattern:** Middleware checks auth headers, sets user context
- **Location:** `middleware/`, `integrations/` directories

**Authorization:**
- **Role-based:** Check user roles/permissions in service layer
- **Pattern:** Middleware sets user, service checks permissions
- **Location:** Service layer functions

**Monitoring & Observability:**
- **APM:** DataDog (dd-trace in boost-pfs-fe-api shows version 5.28.0)
- **Error Tracking:** Integrated error handling, CloudWatch (AWS)
- **Pattern:** Errors logged with context, tracked centrally
- **Location:** Error handler middleware, service layer catch blocks

---

*Architecture analysis: 2025-04-09*
