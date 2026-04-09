# Coding Conventions

**Analysis Date:** 2024-12-19

## Naming Patterns

**Files:**
- kebab-case for all TypeScript source files: `connection-pool.ts`, `safe-eval.ts`, `billing-internal-auth.ts`
- Test files use `.test.ts` or `.spec.ts` suffix (co-located with source): `connection-pool.test.ts`, `detect-event-type.test.ts`
- Configuration files: `jest.config.js`, `.eslintrc.json`, `.prettierrc.json`, `tsconfig.json`

**Functions:**
- camelCase for function declarations and exports: `assertNonNullable()`, `createHealthCheckServer()`, `parseStructuredResponse()`, `memoizeAsync()`
- Arrow functions commonly used for single-expression utilities: `const cast = <T>(x: unknown): T => x as T;`
- Async functions explicitly marked: `const parseYamlResponse = async (content: string, retry = 1) => {...}`

**Variables:**
- camelCase for all variable names: `mockClient`, `cachedClient`, `isConnecting`, `connectionOptions`
- Constants use camelCase (not SCREAMING_SNAKE_CASE): `CredentialsType.ROOT`, `credentials`, `defaultTimeout`
- Private/internal variables may be prefixed with underscore: `_model`, `_Sandbox`

**Types:**
- PascalCase for interfaces and types: `RedisClient`, `CreateBillingInternalTokenOptions`, `BaseAIAgentOptions`
- Enum values use SCREAMING_SNAKE_CASE within enum definitions: `CredentialsType.READONLY`, `CredentialsType.WRITER`
- Generic type parameters use PascalCase: `<T>`, `<Args extends any[], Result>`

## Code Style

**Formatting:**
- Prettier enforces single quotes in all files: `singleQuote: true`
- Files processed by Prettier throughout project
- Configuration: `/.prettierrc.json` with `{ "singleQuote": true }`

**Linting:**
- ESLint with TypeScript support enforced
- Configuration: `/repos/apphub-vision/packages/assistant/.eslintrc.json`
- Parser: `@typescript-eslint/parser` with ES2022 target
- Extends: `eslint:recommended` and `plugin:@typescript-eslint/recommended`

**ESLint Rules:**
- Semicolons always required: `"semi": ["error", "always"]`
- Unix line endings enforced: `"linebreak-style": ["error", "unix"]`
- `@typescript-eslint/no-explicit-any`: off (explicit use of `any` is allowed)
- `@typescript-eslint/no-unused-vars`: warn level (not enforced as error)
- `no-case-declarations`: off (switch case declarations allowed)
- `no-fallthrough`: off (switch fallthrough permitted)
- `no-empty`: off (empty blocks allowed)
- `no-useless-escape`: off
- `no-constant-condition`: warn level

## Import Organization

**Order:**
1. Node.js built-in modules: `import http from 'http';`, `import crypto from 'crypto';`
2. Third-party packages: `import pg from 'pg';`, `import { ChatOpenAI } from '@langchain/openai';`
3. Local modules from sibling or parent packages: `import { assertNonNullable, cast } from './misc';`
4. Relative imports from project: `import { CredentialsType } from './db';`

**Path Aliases:**
- tsconfig includes path aliases (see `/repos/apphub-vision/packages/assistant/tsconfig.json`)
- moduleResolution: `bundler` for ES module compatibility
- Import paths use relative imports with `.js` extensions for ESM: `const moduleNameMapper = { '^(\\.{1,2}/.*)\\.js$': '$1' }`

**Import Destructuring:**
- Explicit destructuring preferred: `const { Pool, Client, types } = pg;`
- Named imports grouped: `import { BaseMessage, HumanMessage, AIMessage } from '@langchain/core/messages';`
- Type imports use regular syntax (not `import type`): `import { StringPromptValueInterface } from '@langchain/core/prompt_values';`

## Error Handling

**Patterns:**
- Custom error-throwing utilities: `assertNonNullable<T>()` throws with optional message
- `assertUnreachable()` function used for exhaustiveness checks: `assertUnreachable(_x?: never)` throws "This error is unreachable"
- Try-catch blocks with error logging: `catch (e) { console.error(e); ... }`
- Error message construction includes context: `'DATABASE_URL_ROOT is missing'`

**Example from `misc.ts`:**
```typescript
export function assertNonNullable<T>(
  x: T | null | undefined,
  message?: string,
) {
  if (x !== null && x !== undefined) {
    return x as NonNullable<T>;
  } else {
    throw new Error(message);
  }
}
```

**Try-Catch in llm.ts:**
```typescript
try {
  return yaml.parse(clean, { strict: false, uniqueKeys: false });
} catch (e) {
  if (retry && e instanceof Error) {
    console.error(e);
    if (retry > 0) {
      // Retry logic with LLM correction
      return parseYamlResponse(
        await invokeUntilFinished(default_chat_llm_model, prompt),
        --retry,
      );
    }
  } else {
    throw e;
  }
}
```

## Logging

**Framework:** console (native browser/Node.js logging)

**Patterns:**
- `console.log()` for informational messages with structured prefixes
- `console.error()` for error conditions
- `console.debug()` for debug-level output
- Timing logs include brackets prefix: `console.log('[Agent Timing] graphql_tool_builder: Starting...');`
- Error context logged before throwing: `console.error(JSON.stringify({ code, args }, null, 2), e);`

**Example from agents.ts:**
```typescript
const startTime = Date.now();
console.log('[Agent Timing] graphql_tool_builder: Starting...');
// ... work ...
const endTime = Date.now();
console.log(
  `[Agent Timing] graphql_tool_builder: Total creation time ${endTime - startTime}ms`,
);
```

## Comments

**When to Comment:**
- TODO comments mark future work: `// TODO Refactor that to be a properly typed langgraph app`
- Brief inline comments explain non-obvious logic
- TODO comments used sparingly, not for every code section

**JSDoc/TSDoc:**
- Function documentation headers in test files: `/** Unit Tests for Billing Internal Authentication */`
- Parameter descriptions included in tests for clarity
- Not extensively used in implementation files

**Example from test file:**
```typescript
/**
 * Unit Tests for Billing Internal Authentication
 *
 * Tests token creation and verification functions for service-to-service
 * communication with Billing API.
 *
 * @ticket BP-25 - Task U7
 */
```

## Function Design

**Size:** 
- Functions range from single-line utilities to ~50 line implementations
- Agent builder functions (40-80 lines) handle complex initialization
- Preference for small, focused functions like `substring()`, `createISODate()`

**Parameters:**
- Options objects used for functions with multiple related parameters
- Type safety with TypeScript generics for utility functions: `assertNonNullable<T>()`, `cast<T>()`
- Optional parameters marked with `?`: `message?: string`

**Return Values:**
- Explicit return types in function signatures
- Generic return types for utilities: `Promise<T>`, `<T>`
- Async functions always return Promises: `async () => Promise<boolean>`

**Example from safe-eval.ts:**
```typescript
export const safeEvalFn = (code: string, ...args: unknown[]) => {
  try {
    const fn = compileFn(code);
    const scope = { args };
    const result = fn(scope).run();
    return result;
  } catch (e) {
    console.error(JSON.stringify({ code, args }, null, 2), e);
    throw e;
  }
};
```

## Module Design

**Exports:**
- Named exports for public functions and types: `export const`, `export function`, `export enum`
- Multiple exports per file common (10-50 exports in utility modules)
- Default exports not used

**Barrel Files:**
- Index files aggregate exports: `export { ... } from './module';`
- Location: `src/lib/alchemy/index.ts`, `src/lib/observability/index.ts`

**Example export patterns from misc.ts:**
```typescript
export function assertNonNullable<T>(...) { ... }
export function assertUnreachable(...) { ... }
export const cast = <T>(x: unknown): T => x as T;
export const replaceAll = (...) => ...;
export const createISODate = () => ...;
```

## TypeScript Configuration

**Compiler Options (tsconfig.json):**
- Target: `ESNext`
- Module: `ESNext` with `moduleResolution: bundler`
- Strict mode enabled: `"strict": true`
- Declaration files generated: `declaration: true`
- Incremental compilation enabled: `"incremental": true`
- Type checking: `useUnknownInCatchVariables: true` for strict error handling

---

*Convention analysis: 2024-12-19*
