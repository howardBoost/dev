# Testing Patterns

**Analysis Date:** 2024-12-19

## Test Framework

**Runner:**
- Jest (ts-jest preset)
- Configuration: `/repos/apphub-vision/packages/assistant/jest.config.js`
- Version: Inferred from `@jest/globals` usage

**Assertion Library:**
- Native Jest assertions: `expect()`

**Run Commands:**
```bash
npm test                    # Run all tests
npm test -- --watch        # Watch mode
npm test -- --coverage     # Coverage report
```

## Test File Organization

**Location:**
- Co-located with source: `src/lib/connection-pool.test.ts` next to `src/lib/connection-pool.ts`
- Alternative structure: `__tests__/` directory: `packages/server-utils/__tests__/locker.test.ts`
- Fixture files: `src/ai/agents/runnables/__fixtures__/detect-event-types.ts`

**Naming:**
- `.test.ts` suffix for test files: `connection-pool.test.ts`, `detect-event-type.test.ts`
- `.spec.ts` also supported: mentioned in tsconfig excludes
- Fixture files in `__fixtures__/` subdirectories

**Structure:**
```
src/
├── lib/
│   ├── connection-pool.ts
│   ├── connection-pool.test.ts    # Co-located test
│   └── safe-eval.ts
└── ai/agents/runnables/
    ├── detect-event-type.ts
    ├── detect-event-type.test.ts
    └── __fixtures__/
        └── detect-event-types.ts  # Test data
```

## Test Structure

**Suite Organization:**
```typescript
import {
  describe,
  it,
  expect,
  beforeEach,
  afterEach,
  jest,
} from '@jest/globals';

describe('AccountConnectionPool', () => {
  let pool: AccountConnectionPool;
  let mockClient: jest.Mocked<Client>;

  beforeEach(() => {
    jest.clearAllMocks();
    // Setup test fixtures
    mockClient = { ... } as any;
    pool = new AccountConnectionPool(1000, 2000);
  });

  afterEach(async () => {
    await pool.closeAll();
  });

  it('should create a new connection for a new account', async () => {
    const client = await pool.getConnection('account1');
    expect(client).toBe(mockClient);
  });

  it('should reuse existing connection for the same account', async () => {
    const client1 = await pool.getConnection('account1');
    const client2 = await pool.getConnection('account1');
    expect(client1).toBe(client2);
  });

  describe('nested describe block', () => {
    it('handles edge cases', () => { ... });
  });
});
```

**Patterns:**
- Setup: `beforeEach()` clears mocks and initializes fixtures
- Teardown: `afterEach()` cleans up resources (closes pools, flushes timers)
- Test isolation: Each test gets fresh mocks and state via beforeEach

## Mocking

**Framework:** Jest mocks (`jest.fn()`, `jest.mock()`)

**Patterns:**

### Function Mocking:
```typescript
const mockTask = jest.fn(() => Promise.resolve());
const tasks = Array.from({ length: 10 }, () => mockTask);
await runTasksConcurrent(3, tasks);
expect(mockTask).toHaveBeenCalledTimes(10);
```

### Module Mocking:
```typescript
jest.mock('./db', () => ({
  createPgClientByType: jest.fn(),
  CredentialsType: {
    READONLY: 'readonly',
    WRITER: 'writer',
    ROOT: 'root',
  },
}));
```

### Object Mocking with Typed Interface:
```typescript
const mockClient: jest.Mocked<Client> = {
  query: jest.fn().mockResolvedValue({ rows: [] }),
  end: jest.fn().mockResolvedValue(undefined),
  connect: jest.fn().mockResolvedValue(undefined),
} as any;
```

### Mock Return Value Configuration:
```typescript
const { createPgClientByType } = require('./db');
createPgClientByType
  .mockResolvedValueOnce(mockClient)
  .mockResolvedValueOnce(mockClient2);
```

### Spy on Native Methods:
```typescript
const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
// ... test code ...
expect(consoleErrorSpy).toHaveBeenCalledWith('Worker failed', expect.any(Error));
consoleErrorSpy.mockRestore();
```

**What to Mock:**
- External dependencies: database connections, Redis clients, HTTP clients
- System calls: timers, process environment
- Third-party libraries: LLM clients, authentication services
- Module boundaries: Import and mock at module level before tests import the implementation

**What NOT to Mock:**
- Core business logic being tested
- Utility functions in same module
- Error handling paths (test them directly)
- Async/await patterns (execute the actual async code)

## Fixtures and Factories

**Test Data Pattern:**
```typescript
// From detect-event-type.test.ts
import { examples } from './__fixtures__/detect-event-types';

describe('detectEventType', () => {
  examples.forEach(({ name, input, expected }) => {
    it(`should generate correct jsonPath for "${name}"`, () =>
      Test(detectEventType, expected).invoke(input));
  });
});
```

**Location:**
- `__fixtures__/` directory alongside test file
- Example: `/repos/apphub-vision/packages/assistant/src/ai/agents/runnables/__fixtures__/detect-event-types.ts`

**Data Structure:**
```typescript
// __fixtures__/detect-event-types.ts (inferred from usage)
export const examples = [
  { name: 'test case name', input: { ... }, expected: { ... } },
  { name: 'another case', input: { ... }, expected: { ... } },
];
```

## Jest Configuration

**Setup Files:**
- `jest.setup.ts`: Runs after test environment setup
- `setupFiles: ['dotenv/config']`: Load environment variables before tests
- `setupFilesAfterEnv: ['./jest.setup.ts']`: Custom setup after Jest environment

**Jest Setup Content (jest.setup.ts):**
```typescript
jest.setTimeout(5 * 60_000);  // 5 minute timeout for tests

process.removeAllListeners("warning");
process.on("warning", (warning) => {
  if (warning.name !== "DeprecationWarning") {
    console.warn(warning);
  }
});
```

**Transform Configuration:**
```javascript
transform: {
  '^.+\\.ts$': [
    'ts-jest',
    {
      tsconfig: './tsconfig.test.json',
      useESM: true,
    },
  ],
},
moduleNameMapper: {
  '^(\\.{1,2}/.*)\\.js$': '$1',  // Handle .js extensions in imports
}
```

## Test Types

**Unit Tests:**
- Scope: Individual function or class behavior
- Approach: Isolate component with mocks, test specific functionality
- Files: `connection-pool.test.ts` (300+ lines testing single class)
- Example: Test AccountConnectionPool reuses connections correctly across multiple scenarios

**Integration Tests:**
- Scope: Multiple components interacting
- Approach: Mock external systems (DB, Redis) but test actual interaction logic
- Files: Tests with multiple mocked external services
- Example: Connection pool interacting with mocked database clients

**E2E Tests:**
- Framework: Not detected in this codebase
- Status: Not implemented

## Common Patterns

**Async Testing:**
```typescript
it('should create a new connection for a new account', async () => {
  const client = await pool.getConnection('account1');
  expect(client).toBe(mockClient);
  expect(mockClient.query).toHaveBeenCalledWith(
    "select set_config('vision.session_account_id', $1, false)",
    ['account1'],
  );
});
```

**Waiting in Tests:**
```typescript
it('should close connection after timeout when link count reaches zero', async () => {
  const client = await pool.getConnection('account1');
  await client.end();

  // Wait for timeout to trigger
  await new Promise((resolve) => setTimeout(resolve, 1100));

  const stats = pool.getStats();
  expect(stats.totalConnections).toBe(0);
});
```

**Error Testing:**
```typescript
it('should propagate errors from tasks', async () => {
  const errorTask = jest.fn(() => Promise.reject(new Error('Task failed')));
  const tasks = [errorTask];

  await expect(runTasksConcurrent(1, tasks)).rejects.toThrow('Task failed');
  expect(errorTask).toHaveBeenCalledTimes(1);
});
```

**Error Logging Testing:**
```typescript
it('should handle errors thrown by the function', async () => {
  const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
  const mockFn = jest.fn(() => Promise.reject(new Error('Test error')));

  await runInBackground(mockFn);
  await new Promise((resolve) => setTimeout(resolve, 10));

  expect(consoleErrorSpy).toHaveBeenCalledWith('Worker failed', expect.any(Error));
  consoleErrorSpy.mockRestore();
});
```

**Concurrent Behavior Testing:**
```typescript
it('should not exceed the number of concurrent workers', async () => {
  const taskExecutionOrder: number[] = [];
  const tasks = Array.from({ length: 5 }, (_, i) => async () => {
    taskExecutionOrder.push(i);
    await new Promise((resolve) => setTimeout(resolve, 100));
  });

  await runTasksConcurrent(2, tasks);
  
  // Verify task chunks executed concurrently
  expect(taskExecutionOrder.slice(0, 2).sort()).toEqual([0, 1]);
  expect(taskExecutionOrder.slice(2, 4).sort()).toEqual([2, 3]);
});
```

## Coverage

**Requirements:** Not explicitly enforced in jest.config.js

**View Coverage:**
```bash
npm test -- --coverage
```

**Coverage Reports:**
- Generated to `coverage/` directory (inferred from Jest defaults)
- Threshold enforcement: Not detected in configuration

## Test Execution Environment

**Environment:** `node` (testEnvironment in jest.config.js)

**Timeout:** 5 minutes (300,000ms) globally via `jest.setTimeout(5 * 60_000)`

**Environment Variables:**
- Loaded via `dotenv/config` in setupFiles
- Tests can access `process.env` variables
- `.env` file in project root provides test configuration

---

*Testing analysis: 2024-12-19*
