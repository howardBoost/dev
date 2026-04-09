# External Integrations

**Analysis Date:** 2025-01-16

## APIs & External Services

**Shopify:**
- Shopify Admin API - Inventory, product, and order management
  - SDK/Client: `shopify-api-node` (v3.15.0)
  - Used in: `boost-pfs-backend/packages/sip-common`
- Shopify App Bridge - App UI and session management
  - SDK/Client: `@shopify/app-bridge` (v3.7.11), `@shopify/app-bridge-react` (v4.2.7)
  - Used in: `boost-sf-filter-admin-html-v2`
- Shopify Liquid Template Engine
  - SDK/Client: `@apphubdev/bc-template-engine-liquidjd-latest`
  - Used in: `boost-pfs-fe-api`, `boost-sf-filter-admin-html-v2`

**LangChain & AI:**
- OpenAI API - LLM and AI capabilities
  - SDK/Client: `@langchain/openai` (v0.3.17)
  - Auth: OpenAI API key (environment variable required)
  - Used in: `apphub-vision/packages/assistant`
- LangChain - AI agent and graph orchestration
  - SDK/Client: `@langchain/core`, `@langchain/langgraph`, `@langchain/community`
  - Used in: `apphub-vision/packages/assistant`
- LangGraph - Agent execution with checkpoint persistence
  - Checkpoint storage: PostgreSQL via `@langchain/langgraph-checkpoint-postgres`
  - Checkpoint storage: Redis via `@langchain/redis`
- MCP Protocol - Model Context Protocol for tool integration
  - SDK/Client: `@langchain/mcp-adapters` (v0.5.2)

**Payment Processing:**
- Stripe - Payment processing and billing
  - SDK/Client: `stripe` (v20.4.0)
  - UI Components: `@stripe/react-stripe-js`, `@stripe/stripe-js`
  - Auth: Stripe API key, multiple secret keys per region
  - Environment variables: `STRIPE_UK_TEST_SECRET_KEY`, `STRIPE_UK_SECRET_KEY`, `STRIPE_US_SECRET_KEY`, `STRIPE_DE_SECRET_KEY`, `STRIPE_AU_SECRET_KEY`
  - Used in: `apphub-vision/apps/billing`
  - Webhooks: `STRIPE_WEBHOOK_ENDPOINT`, `STRIPE_WEBHOOK_EVENTBRIDGE_ENDPOINT`
- Svix - Webhook management (implied from webhook management scripts)
  - Used in: `apphub-vision/apps/billing` for Stripe webhook configuration

**Authentication & Identity:**
- NextAuth.js - Session management and authentication
  - SDK/Client: `next-auth` (v5.0.0-beta.30 in billing, catalog version in core)
  - Auth provider: Frontegg integration
  - Environment variables: `AUTH_SECRET`, `AUTH_FRONTEGG_ID`, `AUTH_FRONTEGG_SECRET`, `AUTH_FRONTEGG_ISSUER`
  - Session sharing: Cross-app session persistence via AUTH_SECRET and cookies
  - Used in: `apphub-vision/apps/dashboard`, `apphub-vision/apps/billing`
- Frontegg - Identity & access management
  - Environment variables: `AUTH_FRONTEGG_ID`, `AUTH_FRONTEGG_SECRET`, `AUTH_FRONTEGG_ISSUER`
  - Auth scope: Merchant authentication and role management
  - Used in: `apphub-vision`

## Data Storage

**Databases:**
- PostgreSQL
  - Connection: `DATABASE_URL` environment variable
  - Client: Prisma ORM (`@prisma/client`)
  - Packages using PostgreSQL:
    - `apphub-vision/packages/app-database` - Main application data
    - `apphub-vision/packages/billing-database` - Billing and subscription data
    - `apphub-vision/packages/event-database` - Event stream data
  - Version: PostgreSQL 16 (in docker-compose.yml)
  - Used in: Dashboard, Billing, Core services

- MongoDB
  - Client: `mongodb` (v3.6.2)
  - Used in: `boost-pfs-backend/packages/sip-common`
  - Purpose: Document storage for commerce data

**File Storage:**
- AWS S3
  - SDK: `@aws-sdk/client-s3` (v3.554.0)
  - Used in: `boost-pfs-backend/packages/sip-common`
  - Purpose: File and asset storage
  - Auth: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

**Caching:**
- Redis
  - Client: `ioredis` (v4.19.1, v5.3.2)
  - Used in:
    - `boost-pfs-backend/packages/sip-common` - Caching and sessions
    - `apphub-vision/apps/billing` - Session and query caching
    - `apphub-vision/packages/assistant` - LangChain checkpoint persistence
  - Environment variable: `REDIS_CONNECTION_STRING`, `REDIS_CLUSTER_MODE`
  - Features: Distributed locks (via `redlock`)
  - Typo tolerance: `@apphubdev/typo-tolerance-redis` (v0.0.58)

## Authentication & Identity

**Auth Provider:**
- Frontegg - Primary identity provider
  - Environment variables:
    - `AUTH_FRONTEGG_ID` - Client ID
    - `AUTH_FRONTEGG_SECRET` - Client secret
    - `AUTH_FRONTEGG_ISSUER` - OIDC issuer URL
  - Scope: Merchant and user authentication
  - Integration: NextAuth.js with Frontegg provider

- NextAuth.js - Session management
  - `AUTH_SECRET` - Session signing key
  - `AUTH_COOKIE_DOMAIN` - Cross-app session sharing (.clearer.io)
  - `AUTH_COOKIE_PREFIX` - Environment-specific cookie prefixes
  - Session sharing: Shared between dashboard and billing apps

**Session Sharing:**
- Cross-app session synchronization via shared cookies
- `AUTH_SECRET` must match across apps (dashboard, billing, AI-API)
- Cookie domain: `.clearer.io` (production), `.clearer.local` (development)

## Monitoring & Observability

**Error Tracking & APM:**
- Datadog
  - SDK: `dd-trace` (v5.28.0)
  - Used in:
    - `boost-pfs-backend` - Root package
    - `boost-pfs-fe-api` - Frontend API
  - Purpose: Application Performance Monitoring, distributed tracing

**Logs:**
- Winston - Structured logging
  - Used in: `boost-pfs-backend/packages/sip-common`
  - Output: Configurable transports (console, files)
  - Version: v3.3.3

- Elasticsearch - Log aggregation and indexing
  - Clients: `@elastic/elasticsearch` (v5.6.9, v7.13.0, v8.8.0)
  - Used in: `boost-pfs-backend/packages/sip-common`, `boost-pfs-fe-api`
  - Purpose: Search and log storage

**Analytics & Observability:**
- PostHog - Product analytics
  - SDK: `posthog-node` (v5.21.1), `@posthog/react` (v1.5.0)
  - Environment variables: `NEXT_PUBLIC_POSTHOG_API_KEY`, `NEXT_PUBLIC_POSTHOG_HOST`
  - Used in: `boost-pfs-backend/packages/sip-common`, `boost-sf-filter-admin-html-v2`

- FullStory - User session recording and analytics
  - SDK: `@fullstory/browser` (v2.0.1)
  - Used in: `boost-sf-filter-admin-html-v2`

- LangFuse - LLM monitoring and evaluation
  - SDK: `langfuse-langchain` (v3.26.0)
  - Used in: `apphub-vision/packages/assistant`
  - Purpose: Track and analyze AI agent performance

**Upvoty - Customer feedback (integration):**
- SDK: `@upvoty/react` (v1.0.0)
- Used in: `boost-sf-filter-admin-html-v2`

## CI/CD & Deployment

**Hosting:**
- AWS - Cloud infrastructure
  - Services: S3, CloudFront, Kinesis, Lambda, SNS, EventBridge
  - Region: us-west-2, eu-west-1
  - Account ID: 222519192996 (implied in env examples)

- Kubernetes - Container orchestration (optional)
  - CDK definitions in: `apphub-vision/cdk`
  - Docker support available

**CI Pipeline:**
- GitHub Actions - Build and deployment automation
  - Configuration: `.github/workflows`
  - Used for: Testing, building, releases

**Build Tools:**
- Turbo - Monorepo build orchestrator
- Changesets - Version and changelog management
- Husky - Git hooks for commit quality

## Environment Configuration

**Required env vars (Critical):**
- `DATABASE_URL` - PostgreSQL connection string
- `NODE_ENV` - Environment (development, staging, production)
- `AUTH_SECRET` - Session encryption key
- `AUTH_FRONTEGG_ID`, `AUTH_FRONTEGG_SECRET`, `AUTH_FRONTEGG_ISSUER` - Identity provider
- `STRIPE_*_SECRET_KEY` - Stripe API keys (multiple regions)
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` - AWS credentials
- `REDIS_CONNECTION_STRING` - Redis connection

**Secrets location:**
- `.env` files (local development)
- `.env.local`, `.env.staging`, `.env.production` (environment-specific)
- AWS Secrets Manager (production)
- Environment variables in deployment platform

## Webhooks & Callbacks

**Incoming Webhooks:**
- Stripe Payment Webhooks
  - Endpoint: `/webhook` or `/webhook-eventbridge`
  - Events: payment_intent.succeeded, invoice.paid, charge.failed, etc.
  - Verification: Stripe webhook signature verification
  - Used in: `apphub-vision/apps/billing`

- Event notifications from AWS EventBridge
  - Incoming: Billing and payment events
  - Used in: `apphub-vision/apps/billing-lambda`

**Outgoing Webhooks:**
- AWS SNS - Event notifications
  - SDK: `@aws-sdk/client-sns` (v3.958.0)
  - Used in: `apphub-vision/apps/billing`
  - Purpose: Notify services of billing/subscription changes

- Slack - Alert notifications
  - SDK: `@slack/web-api` (v7.9.3), `@slack/webhook` (v5.0.3)
  - Used in: `boost-pfs-backend/packages/sip-common`
  - Purpose: System alerts and notifications
  - Environment variable: Slack webhook URL (if configured)

## Data & Analytics

**Data Warehouse:**
- Databricks - Analytics and data processing
  - SDK: `@databricks/sql` (v1.12.1)
  - Environment variables:
    - `DATABRICKS_SERVERLESS_HOSTNAME` - Endpoint
    - `DATABRICKS_SERVERLESS_HTTP_PATH` - Warehouse path
    - `DATABRICKS_WAREHOUSE_CLIENT_ID` - OAuth client
    - `DATABRICKS_WAREHOUSE_CLIENT_SECRET` - OAuth secret
    - `DATABRICKS_QUERY_GMV_TABLE` - GMV query table
  - Used in: `apphub-vision/apps/billing`
  - Purpose: Revenue analytics, GMV tracking

- AWS Kinesis - Event streaming
  - SDK: `@aws-sdk/client-kinesis` (v3.678.0)
  - Used in: `boost-pfs-backend/packages/sip-common`
  - Purpose: Real-time event ingestion

- Athena - SQL queries on S3
  - Client: `athena-client` (v2.5.1)
  - Used in: `boost-pfs-backend/packages/sip-common`
  - Purpose: Query archived data in S3

## Integration Points

**Internal Service Communication:**
- Direct HTTP via axios
- GraphQL via `graphql-request` (v7.2.0)
- NextAuth session tokens for inter-service auth
- Internal API tokens (JWT-based, described in BILLING_AUTH_SECRET)

**Commerce Integration:**
- Shopify Admin API for product/order sync
- Shopify Theme App for storefront customization
- Shopify Theme Editor for template management

**Email & Notifications:**
- Slack webhooks for alerts
- AWS SNS for event distribution
- Email via Stripe notifications (implicit)

---

*Integration audit: 2025-01-16*
