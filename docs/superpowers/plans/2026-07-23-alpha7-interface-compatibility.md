# Foundry alpha.7 interface compatibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make FoundrySwift extensions initialize under Foundry v0.1.0-alpha.7 and publish synchronized source, addon, and SwiftPM binary artifacts.

**Architecture:** Keep the existing dynamic proc-address loader and public memory helper API. Replace the deprecated alpha.7 interface names and callback signatures in the hand-written runtime, synchronize the checked-in generated API artifacts with the official alpha.7 API package, and align the code-generation and headless-runner commands with alpha.7's CLI. Send post-initialize only after concrete wrapper construction completes; custom `InitContext` constructors use an explicit completion helper, while wrappers around existing engine objects do not notify. Validate at unit, package, and headless extension-load levels.

**Tech Stack:** Swift 6.3, SwiftPM/XCTest, Foundry extension C interface, Task, GitHub Actions release workflow, Foundry v0.1.0-alpha.7.

---

### Task 1: Add the alpha.7 proc-address regression test

**Files:**
- Create: `Tests/FoundrySwiftUniversalTests/EntryPointTests.swift`

- [x] **Step 1: Write the failing test**

Create an XCTest that calls the internal loader with a C-compatible fake proc-address provider. The provider returns `nil` for all six deprecated names and a non-null sentinel for every other requested symbol, including alpha.7's replacement names. The test must assert that the memory replacements were requested and the deprecated names were not:

```swift
import XCTest
import FoundryExtensionC
@testable import FoundrySwift

final class EntryPointTests: XCTestCase {
    func testLoadsAlpha7InterfaceWithoutDeprecatedFunctions() {
        requestedSymbols.removeAll()
        let procAddress: FoundryExtensionInterfaceGetProcAddress = alpha7ProcAddress
        loadFoundryInterface(procAddress)
        XCTAssertEqual(
            requestedSymbols.filter { $0.hasPrefix("mem_") },
            ["mem_alloc2", "mem_realloc2", "mem_free2"]
        )
        XCTAssertFalse(requestedSymbols.contains {
            [
                "callable_custom_create",
                "classdb_construct_object",
                "classdb_register_extension_class2",
            ].contains($0)
        })
    }
}

private nonisolated(unsafe) var requestedSymbols = [String]()

private func alpha7ProcAddress(_ name: UnsafePointer<CChar>?) -> FoundryExtensionInterfaceFunctionPtr? {
    guard let name else { return nil }
    let symbol = String(cString: name)
    requestedSymbols.append(symbol)
    if [
        "mem_alloc",
        "mem_realloc",
        "mem_free",
        "callable_custom_create",
        "classdb_construct_object",
        "classdb_register_extension_class2",
    ].contains(symbol) {
        return nil
    }
    return alpha7Sentinel
}

private func alpha7Sentinel() {}
```

- [x] **Step 2: Run the focused test to verify it fails**

Run:

```bash
swift test --filter EntryPointTests/testLoadsAlpha7InterfaceWithoutDeprecatedFunctions
```

Expected: the test process fails during `loadFoundryInterface` with the existing fatal error for `mem_alloc`, proving the test models the reported alpha.7 crash.

- [x] **Step 3: Commit the failing test**

```bash
git add Tests/FoundrySwiftUniversalTests/EntryPointTests.swift
git commit -m "test: reproduce alpha7 interface loader crash"
```

### Task 2: Update the runtime loader, callbacks, and memory helpers

**Files:**
- Modify: `Sources/FoundrySwift/Runtime/EntryPoint.swift:201-204,365-368`
- Modify: `Sources/FoundrySwift/Runtime/FoundryMemoryInterface.swift:8-18`
- Modify: `Sources/FoundrySwift/Runtime/Core/Wrapped.swift`

- [x] **Step 1: Store and load the alpha.7 memory functions**

Rename the deprecated `FoundryInterface` stored properties and loader entries to the imported alpha.7 types and symbols:

```swift
public let mem_alloc2: FoundryExtensionInterfaceMemAlloc2
public let mem_realloc2: FoundryExtensionInterfaceMemRealloc2
public let mem_free2: FoundryExtensionInterfaceMemFree2
```

```swift
mem_alloc2: load("mem_alloc2"),
mem_realloc2: load("mem_realloc2"),
mem_free2: load("mem_free2"),
```

Use `classdb_construct_object2`, `classdb_register_extension_class5`, and `callable_custom_create2`; pass alpha.7's callback hash, post-initialize flag, and callable argument-count fields through the imported callback types.

- [x] **Step 2: Preserve the existing allocator semantics with no pre-padding**

Call the new functions with `0` for `p_prepad_align`, matching the old functions' behavior:

```swift
func gmem_alloc (_ size: Int) -> UnsafeMutableRawPointer? {
    gi.mem_alloc2(size, 0)
}

func gmem_realloc (_ ptr: UnsafeMutableRawPointer?, size: Int) -> UnsafeMutableRawPointer? {
    gi.mem_realloc2(ptr, size, 0)
}

func gmem_free (_ ptr: UnsafeMutableRawPointer?) {
    return gi.mem_free2(ptr, 0)
}
```

- [x] **Step 3: Run the regression test to verify it passes**

Run:

```bash
swift test --filter EntryPointTests/testLoadsAlpha7InterfaceWithoutDeprecatedFunctions
```

Expected: PASS, with no fatal error for the omitted deprecated names.

- [x] **Step 4: Commit the runtime fix**

```bash
git add Sources/FoundrySwift/Runtime/EntryPoint.swift Sources/FoundrySwift/Runtime/FoundryMemoryInterface.swift
git commit -m "fix: load alpha7 memory interface"
```

### Task 3: Synchronize checked-in API artifacts with Foundry alpha.7

**Files:**
- Modify: `Sources/ExtensionApi/extension_api.json`
- Modify: `Sources/ExtensionApi/foundry_extension_interface.json`
- Modify: `Sources/FoundryExtension/include/foundry_extension_interface.h`

- [x] **Step 1: Download the official alpha.7 API package**

Run:

```bash
api_dir=$(mktemp -d)
gh release download v0.1.0-alpha.7 \
  --repo cafecito-games/Foundry \
  --pattern 'Foundry_v0.1.0-alpha.7_api.zip' \
  --dir "$api_dir"
unzip -o "$api_dir/Foundry_v0.1.0-alpha.7_api.zip" -d "$api_dir/unpacked"
```

- [x] **Step 2: Replace the generated artifacts from the release package**

Copy the package's `extension_api.json`, `foundry_extension_interface.json`, and `foundry_extension_interface.h` into the three checked-in paths. Confirm the copied API metadata identifies the alpha.7 engine build and that the header registers the `mem_alloc2` declarations.

- [x] **Step 3: Run code generation validation**

Run:

```bash
task codegen:check
git diff --check
```

Expected: code generation succeeds without source edits after generation, and the diff has no whitespace errors.

- [x] **Step 4: Commit the synchronized API artifacts**

```bash
git add Sources/ExtensionApi/extension_api.json \
  Sources/ExtensionApi/foundry_extension_interface.json \
  Sources/FoundryExtension/include/foundry_extension_interface.h
git commit -m "build: sync Foundry alpha7 extension API"
```

### Task 4: Run package and headless extension-load verification

**Files:**
- Modify: none unless a test or fixture exposes an intentional alpha.7 compatibility issue

- [x] **Step 1: Run all Swift unit tests**

```bash
swift test
```

Expected: exit 0 with all XCTest cases passing.

- [x] **Step 2: Run release helper checks**

```bash
task test:release
```

Expected: every release helper test prints its success line and exits 0.

- [x] **Step 3: Build the test extension and run it with the official alpha.7 editor**

Download and unpack the official macOS universal alpha.7 editor, then use the repository's existing Foundry test runner flow. Run the complete FoundrySwift test runner and confirm the extension reaches the runner instead of aborting during interface loading:

```bash
foundry_dir=$(mktemp -d)
gh release download v0.1.0-alpha.7 \
  --repo cafecito-games/Foundry \
  --pattern 'Foundry_v0.1.0-alpha.7_macos.universal.zip' \
  --dir "$foundry_dir"
unzip -o "$foundry_dir/Foundry_v0.1.0-alpha.7_macos.universal.zip" -d "$foundry_dir/unpacked"
foundry_bin=$(find "$foundry_dir/unpacked" -type f -name foundry -perm -111 -print -quit)
FOUNDRY_BIN="$foundry_bin" task test:foundry
```

Expected: the runner starts and reports its test result without a deprecated-interface fatal error or signal 5 abort. Verified with 49 suites and 450 passed tests.

- [x] **Step 4: Review the complete diff and commit any verification-only corrections**

```bash
git diff origin/main...HEAD --stat
git diff --check
git status --short
```

Expected: only the approved spec, plan, regression test, runtime fix, alpha.7 API artifacts, generator filters, Taskfile commands, and test-runner command are changed. The lifecycle correction is contained in `Wrapped.swift`.

### Task 5: Prepare the release and handoff

**Files:**
- Modify: none; use the existing `.github/workflows/release.yml` and `scripts/release`

- [ ] **Step 1: Run the full CI-style build before handoff**

Run the repository's complete Swift build and release helper suite, then repeat the focused regression test:

```bash
swift build --build-tests
swift test
task test:release
swift test --filter EntryPointTests/testLoadsAlpha7InterfaceWithoutDeprecatedFunctions
```

- [ ] **Step 2: Commit the final implementation state**

```bash
git status --short
git log --oneline --decorate -8
```

Ensure all implementation changes are committed on `issue-9` before pushing.

- [ ] **Step 3: Push and open the pull request**

```bash
git push -u origin issue-9
gh pr create --repo cafecito-games/Foundry-Swift \
  --base main \
  --head issue-9 \
  --title "Fix Foundry alpha.7 extension interface loading" \
  --body $'Updates the checked-in extension API and runtime loader for Foundry v0.1.0-alpha.7. Adds a regression test proving initialization works when the deprecated memory symbols are absent.\n\nCloses #9'
```

- [ ] **Step 4: Enable squash auto-merge after supervised review convergence**

Run the required supervised review against `origin/main`, resolve all in-scope findings, then enable squash auto-merge with:

```bash
gh pr merge --repo cafecito-games/Foundry-Swift --squash --auto
```

The subsequent release must use the existing workflow to publish the source release/addon archive and update `cafecito-games/Foundry-Swift-Binary` from the merged commit.
