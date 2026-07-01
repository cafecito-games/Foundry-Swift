# How to run tests

`foundry` must be in `PATH`, or set `FOUNDRY_BIN=/path/to/foundry`, for tests that launch the engine.

## Run tests that require embedding in a Foundry instance

```bash
swift run FoundrySwiftTestRunner
```

## Run a specific test suite that requires embedding in a Foundry instance

```bash
FOUNDRYSWIFT_TEST_FILTER="SnappingTests" swift run FoundrySwiftTestRunner
```

## Run a specific test that requires embedding in a Foundry instance

```bash
FOUNDRYSWIFT_TEST_FILTER="SnappingTests.testSnapDouble" swift run FoundrySwiftTestRunner
```

## Run other tests

```bash
swift test
```
