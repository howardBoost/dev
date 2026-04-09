# Technology Stack

**Analysis Date:** 2025-01-16

## Languages

**Primary:**
- TypeScript - All backend services, frontend applications, and libraries
- JavaScript/Node.js - Runtime for all server-side code

**Secondary:**
- SQL - Database queries and schema definitions (PostgreSQL)

## Runtime

**Environment:**
- Node.js - Primary runtime
  - `boost-pfs-backend`: >=12.17.0
  - `apphub-vision`: >=20.0.0
  - `boost-fe-lib`: >=24.0.0

**Package Manager:**
- npm (boost-fe-lib): ^11.0.0
- pnpm (apphub-vision): 10.12.3, (boost-pfs-fe-api): 9.0.5
- Lockfiles present in all repositories

## Frameworks

**Core Backend:**
- Express - HTTP API framework (`boost-pfs-backend`, `boost-pfs-fe-api`)
  - Used in `packages/sip-api`, `packages/admin-api`, `packages/sip-worker-history`
- Next.js - Full-stack React framework (apphub-vision apps: billing, dashboard)
  - Version: 16.0.10+ (apphub-vision)

**Frontend:**
- React - UI library
  - Version: 18.3.1 (boost-sf-filter-admin-html-v2)
  - Version: 19.2.0 (apphub-vision)
- React Router - Client-side routing (v5.3.3 in boost-sf-filter-admin-html-v2)
- React-specific libraries: React Redux, React Select, React DnD

**ORM & Database:**
- Prisma - Database ORM and migration tool
  - Used in `apphub-vision/packages/app-database`
  - Used in `apphub-vision/packages/billing-database`
  - Used in `apphub-vision/packages/event-database`
  - Provider: PostgreSQL

**Testing:**
- Jest - Test runner (multiple packages)
- Mocha - Test runner (boost-pfs-backend packages)
- Chai - Assertion library (boost-pfs-backend)
- ts-jest - Jest transformer for TypeScript
- Testing Library - React testing utilities (@testing-library/react, @testing-library/dom)

**Build/Dev Tools:**
- TypeScript Compiler - Type checking and compilation
- tspc (ts-patch compiler) - TypeScript compiler with path transformations
- ESLint - Linting (v8.57.0+ in boost-pfs-backend)
- Prettier - Code formatting (v3.5.3 in boost-pfs-backend, v3.3.2 in boost-fe-lib)
- Turbo - Monorepo build orchestrator (v2.5.4 in boost-fe-lib)
- ts-node - TypeScript execution without compilation
- Webpack - Module bundler (boost-sf-filter-admin-html-v2)
- esbuild - JavaScript bundler (0.25.0 in boost-fe-lib)
- tsup - TypeScript bundler (v8.1.0 in boost-fe-lib)
- Vite/Dev servers - Development servers configured per project
- Nodemon - Development watch tool (v3.1.4 in boost-pfs-fe-api)
- Concurrently - Run multiple npm scripts in parallel

## Key Dependencies

**Critical Backend:**
- `express` - REST API framework
- `@aws-sdk/client-s3` (v3.554.0) - AWS S3 file operations
- `@aws-sdk/client-cloudfront` (v3.583.0) - CloudFront CDN
- `@aws-sdk/client-kinesis` (v3.678.0) - AWS Kinesis streaming
- `aws-sdk` (v2.781.0) - AWS SDK v2 (legacy support)
- `ioredis` - Redis client library (v4.19.1, v5.3.2)
- `@elastic/elasticsearch` - Elasticsearch client (v5.6.9, v7.13.0, v8.8.0)
- `mongodb` (v3.6.2) - MongoDB driver
- `shopify-api-node` (v3.15.0) - Shopify API client

**Authentication & Authorization:**
- `jsonwebtoken` - JWT signing and verification (v8.5.1, v9.0.2)
- `next-auth` - Authentication framework (catalog version in apphub-vision, v5.0.0-beta.30)

**API & HTTP:**
- `axios` - HTTP client library
- `graphql-request` (v7.2.0) - GraphQL client
- `body-parser` - Express middleware for JSON parsing
- `compression` - Response compression middleware
- `express-validator` - Input validation middleware
- `validator` - String validation library

**AI & LLM:**
- `@langchain/core` (v0.3.49) - LangChain core
- `@langchain/langgraph` (v0.2.57) - Agent framework
- `@langchain/langgraph-checkpoint-postgres` (v0.0.4) - Graph persistence
- `@langchain/openai` (v0.3.17) - OpenAI integration
- `@langchain/community` (v0.3.36) - Community integrations
- `@langchain/redis` (v0.1.1) - Redis persistence
- `@langchain/mcp-adapters` (v0.5.2) - MCP protocol support
- `langfuse-langchain` (v3.26.0) - LLM observability

**Data & Utilities:**
- `lodash` - Utility functions
- `moment` / `moment-timezone` - Date/time handling
- `pluralize` - Pluralization utility
- `uuid` - UUID generation
- `ajv` - JSON schema validation

**Observability & Logging:**
- `dd-trace` (v5.28.0) - Datadog APM tracing (in boost-pfs-backend, boost-pfs-fe-api)
- `winston` - Logging library (v3.3.3 in boost-pfs-backend)
- `posthog-node` - PostHog analytics
- `@posthog/react` - PostHog React integration
- `langfuse-langchain` - LLM monitoring

**Payments & Commerce:**
- `stripe` (v20.4.0) - Stripe payment processing
- `@stripe/react-stripe-js` - Stripe React components
- `@stripe/stripe-js` - Stripe JavaScript SDK

**Development:**
- `@changesets/cli` - Changesets for versioning
- `husky` - Git hooks (v9.0.11+)
- `lint-staged` - Run linters on staged files
- `rimraf` - Cross-platform file deletion
- `concurrently` - Run multiple commands in parallel
- `dotenv` - Environment variable loading (v16.4.5)

**Template & Component Libraries:**
- `@shopify/polaris` - Shopify UI component library (v9.24.0)
- `@shopify/app-bridge` - Shopify app framework (v3.7.11)
- `@apphubdev/bc-template-engine` - Shopify Liquid template engine
- `@monaco-editor/react` - Code editor component

**Additional Libraries:**
- `redlock` - Redis-based distributed lock
- `bluebird` - Promise library
- `fp-ts` - Functional programming utilities
- `io-ts` - Runtime type checking
- `zod` - Schema validation

## Configuration

**Environment:**
- Configuration via `.env` files (.env.local, .env.staging, .env.production)
- Environment variables loaded with `dotenv` (v16.4.5)
- Environment files per project:
  - `apphub-vision/apps/dashboard/.env.example`
  - `apphub-vision/apps/billing/.env.example`
  - `boost-fe-lib/scripts/local-tae-setup/setup/.env.example`

**Build:**
- TypeScript configuration: `tsconfig.json` in root and workspace packages
- ESLint configuration: `.eslintrc`, `.eslintrc.json` files
- Prettier configuration: `.prettierrc` files
- Jest configuration: `jest.config.js` / `jest.config.cjs` in packages
- Webpack configuration: `config/webpack.config.js` (boost-sf-filter-admin-html-v2)
- Turbo configuration: `turbo.json` (boost-fe-lib)

**Database:**
- Prisma schema: `prisma/schema.prisma` in database packages
- Provider: PostgreSQL
- Migration scripts in database packages

## Platform Requirements

**Development:**
- Node.js 12.17.0+ minimum (boost-pfs-backend)
- Node.js 20.0.0+ recommended (apphub-vision)
- Node.js 24.0.0+ for boost-fe-lib
- Package managers: npm, pnpm
- Git for version control
- Docker support (optional, for containerization)

**Production:**
- Node.js runtime environment
- PostgreSQL database (for Prisma ORM)
- Redis (optional, for caching and session management)
- AWS services (S3, CloudFront, Kinesis, SNS)
- Elasticsearch (for search/logging)
- MongoDB (for document storage in specific services)
- Stripe account (for payment processing)
- Shopify account (for commerce integration)
- Datadog account (for APM/monitoring)
- PostHog account (for analytics)
- ngrok (for webhook testing in development)

---

*Stack analysis: 2025-01-16*
