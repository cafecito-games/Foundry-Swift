# Foundry-Swift Product Fork Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build `Foundry-Swift` as a full Foundry-native product fork of the local Cafecito `FoundrySwift` package.

**Architecture:** Import FoundrySwift as the implementation base, replace the extension ABI and API dump with local Foundry artifacts, then layer package-specific public renames and verification gates. The finished package exposes `FoundrySwift`, `FoundryExtensionC`, `@Foundry`, `#initFoundryExtension`, `.foundryextension`, and Foundry release/addon names without FoundrySwift/FoundryExtension compatibility aliases.

**Tech Stack:** SwiftPM 6.3 package, Swift macros, SwiftSyntax, C bridge target, Foundry extension API dumps, shell-based package scripts, Foundry editor binary at `/Users/christian/CafecitoGames/godot/bin/foundry.macos.editor.dev.arm64`.

---

## File Structure

- Create/modify: repository root files copied from `/Users/christian/CafecitoGames/FoundrySwift`.
- Create: `Sources/FoundryExtension/include/foundry_extension_interface.h` from Foundry dump.
- Create: `Sources/ExtensionApi/foundry_extension_interface.json` from Foundry dump.
- Modify: `Sources/ExtensionApi/extension_api.json` with Foundry dump.
- Rename: `Sources/FoundryExtension` to `Sources/FoundryExtension`.
- Rename: `Sources/FoundrySwift` to `Sources/FoundrySwift`.
- Rename: `Sources/FoundrySwiftMacroLibrary` to `Sources/FoundrySwiftMacroLibrary`.
- Rename: `Sources/FoundrySwiftTestMacrosLibrary` to `Sources/FoundrySwiftTestMacrosLibrary`.
- Rename: `Sources/FoundrySwiftTestMacros` to `Sources/FoundrySwiftTestMacros`.
- Rename: `Sources/FoundrySwiftTestRunner` to `Sources/FoundrySwiftTestRunner`.
- Rename: `Sources/FoundrySwiftEmbed` to `Sources/FoundrySwiftEmbed`.
- Rename: `Tests/FoundrySwiftUniversalTests` to `Tests/FoundrySwiftUniversalTests`.
- Rename: `Tests/FoundrySwiftMacrosTests` to `Tests/FoundrySwiftMacrosTests`.
- Rename: `Tests/FoundrySwiftTestExtension` to `Tests/FoundrySwiftTestExtension`.
- Modify: `Package.swift` and `Package.distribution.swift` for FoundrySwift products/targets.
- Modify: `Plugins/CodeGeneratorPlugin/plugin.swift` and `Plugins/EntryPointGeneratorPlugin/EntryPointGeneratorPlugin.swift`.
- Modify: `Generator/Generator/*.swift` for Foundry C symbols, module names, generated file names, and `@Foundry`.
- Modify: sample/test extension resource files to `.foundryextension` and `compatibility_minimum = 0.1.0`.
- Modify/rename: scripts under `scripts/`, `Makefile`, `Taskfile.yml`, docs, README, TESTING, and addon packaging resources.
- Create: `scripts/audit-foundry-product` for naming/resource gates.

### Task 1: Import FoundrySwift Base

**Files:**
- Create/modify: repository contents from `/Users/christian/CafecitoGames/FoundrySwift`
- Preserve: `docs/superpowers/specs/2026-07-01-foundry-swift-product-fork-design.md`
- Preserve: `docs/superpowers/plans/2026-07-01-foundry-swift-product-fork.md`

- [ ] **Step 1: Copy the source tree**

Run:

```bash
rsync -a \
  --exclude '.git' \
  --exclude '.build' \
  --exclude '.swiftpm' \
  --exclude 'DerivedData' \
  /Users/christian/CafecitoGames/FoundrySwift/ \
  /Users/christian/CafecitoGames/Foundry-Swift/
```

Expected: FoundrySwift files appear in the Foundry-Swift repository without replacing the already committed design spec.

- [ ] **Step 2: Remove copied generated build artifacts if any slipped in**

Run:

```bash
find . -path './.git' -prune -o \( -name '.build' -o -name '.swiftpm' -o -name 'DerivedData' \) -print
```

Expected: no output.

- [ ] **Step 3: Verify source package imported**

Run:

```bash
test -f Package.swift
test -d Sources/FoundrySwift
test -d Sources/FoundryExtension
test -f Sources/ExtensionApi/extension_api.json
```

Expected: exit code `0`.

### Task 2: Add Failing Foundry Product Audit

**Files:**
- Create: `scripts/audit-foundry-product`

- [ ] **Step 1: Write the failing audit script**

Create `scripts/audit-foundry-product`:

```bash
#!/usr/bin/env bash
set -euo pipefail

failures=0

require_path() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "missing required path: $path" >&2
    failures=$((failures + 1))
  fi
}

forbid_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "forbidden path exists: $path" >&2
    failures=$((failures + 1))
  fi
}

forbid_rg() {
  local pattern="$1"
  local description="$2"
  if rg -n --glob '!.git/**' --glob '!docs/superpowers/**' "$pattern" . >/tmp/foundry_audit_matches.txt; then
    echo "forbidden $description:" >&2
    cat /tmp/foundry_audit_matches.txt >&2
    failures=$((failures + 1))
  fi
}

require_path Package.swift
require_path Sources/FoundrySwift
require_path Sources/FoundryExtension/include/foundry_extension_interface.h
require_path Sources/ExtensionApi/extension_api.json
require_path Sources/ExtensionApi/foundry_extension_interface.json
require_path Sources/FoundrySwiftEmbed
require_path Tests/FoundrySwiftMacrosTests

forbid_path Sources/FoundrySwift
forbid_path Sources/FoundryExtension
forbid_path Sources/FoundryExtension/include/foundry_extension_interface.h

forbid_rg 'FoundrySwift' 'FoundrySwift references'
forbid_rg 'FoundryExtension' 'FoundryExtension references'
forbid_rg '\.foundryextension' '.foundryextension references'
forbid_rg '@Foundry\b' '@Foundry macro references'
forbid_rg '#initFoundryExtension\b' '#initFoundryExtension references'

if find . -path './.git' -prune -o -name '*.foundryextension' -print | grep -q .; then
  echo "forbidden .foundryextension files remain" >&2
  find . -path './.git' -prune -o -name '*.foundryextension' -print >&2
  failures=$((failures + 1))
fi

if find . -path './.git' -prune -o -name 'project.godot' -print | grep -q .; then
  echo "forbidden project.godot files remain" >&2
  find . -path './.git' -prune -o -name 'project.godot' -print >&2
  failures=$((failures + 1))
fi

if rg -n --glob '*.foundryextension' 'compatibility_minimum *= *4\.' .; then
  echo "found .foundryextension file with Godot compatibility floor" >&2
  failures=$((failures + 1))
fi

exit "$failures"
```

- [ ] **Step 2: Make it executable**

Run:

```bash
chmod +x scripts/audit-foundry-product
```

- [ ] **Step 3: Run audit and verify it fails before renaming**

Run:

```bash
scripts/audit-foundry-product
```

Expected: non-zero exit with missing `Sources/FoundrySwift` and forbidden FoundrySwift/FoundryExtension references.

### Task 3: Import Foundry API Dump Artifacts

**Files:**
- Modify: `Sources/ExtensionApi/extension_api.json`
- Create: `Sources/ExtensionApi/foundry_extension_interface.json`
- Create: `Sources/FoundryExtension/include/foundry_extension_interface.h`
- Delete: `Sources/FoundryExtension/include/foundry_extension_interface.h`

- [ ] **Step 1: Generate fresh Foundry dumps**

Run:

```bash
rm -rf /tmp/foundry-swift-dump
mkdir -p /tmp/foundry-swift-dump
cd /tmp/foundry-swift-dump
/Users/christian/CafecitoGames/godot/bin/foundry.macos.editor.dev.arm64 \
  --headless \
  --dump-extension-api \
  --dump-foundryextension-interface \
  --dump-foundryextension-interface-json
```

Expected output includes:

```text
Dumping Extension API
Dumping FoundryExtension interface header file
Dumping FoundryExtension interface json file
```

- [ ] **Step 2: Stage Foundry dump files into the package**

Run:

```bash
mkdir -p Sources/FoundryExtension/include
cp /tmp/foundry-swift-dump/extension_api.json Sources/ExtensionApi/extension_api.json
cp /tmp/foundry-swift-dump/foundry_extension_interface.json Sources/ExtensionApi/foundry_extension_interface.json
cp /tmp/foundry-swift-dump/foundry_extension_interface.h Sources/FoundryExtension/include/foundry_extension_interface.h
```

Expected: all three files exist in the target paths.

- [ ] **Step 3: Verify Foundry API contents**

Run:

```bash
swift -e 'import Foundation; let data = try Data(contentsOf: URL(fileURLWithPath: "Sources/ExtensionApi/extension_api.json")); let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]; let classes = obj["classes"] as! [[String: Any]]; precondition(classes.contains { ($0["name"] as? String) == "FoundryScript" }); precondition(classes.contains { ($0["name"] as? String) == "FSReflection" }); precondition(classes.contains { ($0["name"] as? String) == "FoundryExtension" }); print("found Foundry classes")'
```

Expected:

```text
found Foundry classes
```

### Task 4: Apply Directory and File Renames

**Files:**
- Rename package source and test directories listed in File Structure
- Rename `.foundryextension` to `.foundryextension`
- Rename `project.godot` to `project.foundry`
- Rename scripts and files containing FoundrySwift in their basename

- [ ] **Step 1: Rename package directories**

Run:

```bash
mv Sources/FoundryExtension Sources/FoundryExtension
mv Sources/FoundrySwift Sources/FoundrySwift
mv Sources/FoundrySwiftMacroLibrary Sources/FoundrySwiftMacroLibrary
mv Sources/FoundrySwiftTestMacrosLibrary Sources/FoundrySwiftTestMacrosLibrary
mv Sources/FoundrySwiftTestMacros Sources/FoundrySwiftTestMacros
mv Sources/FoundrySwiftTestRunner Sources/FoundrySwiftTestRunner
mv Sources/FoundrySwiftEmbed Sources/FoundrySwiftEmbed
mv Tests/FoundrySwiftUniversalTests Tests/FoundrySwiftUniversalTests
mv Tests/FoundrySwiftMacrosTests Tests/FoundrySwiftMacrosTests
mv Tests/FoundrySwiftTestExtension Tests/FoundrySwiftTestExtension
```

Expected: old directories no longer exist; new directories exist.

- [ ] **Step 2: Rename extension and project resource files**

Run:

```bash
find . -path './.git' -prune -o -name '*.foundryextension' -print | while read -r file; do mv "$file" "${file%.foundryextension}.foundryextension"; done
find . -path './.git' -prune -o -name 'project.godot' -print | while read -r file; do mv "$file" "$(dirname "$file")/project.foundry"; done
find . -path './.git' -prune -o -name '*.gd' -print | while read -r file; do mv "$file" "${file%.gd}.fs"; done
```

Expected: no `.foundryextension`, `project.godot`, or `.gd` files remain outside `.git`.

- [ ] **Step 3: Rename FoundrySwift basenames**

Run:

```bash
find . -path './.git' -prune -o -name '*FoundrySwift*' -print | sort -r | while read -r file; do mv "$file" "$(dirname "$file")/$(basename "$file" | sed 's/FoundrySwift/FoundrySwift/g')"; done
find . -path './.git' -prune -o -name '*foundryswift*' -print | sort -r | while read -r file; do mv "$file" "$(dirname "$file")/$(basename "$file" | sed 's/foundryswift/foundryswift/g')"; done
```

Expected: no file or directory basename contains `FoundrySwift` or `foundryswift`.

### Task 5: Apply Content Renames

**Files:**
- Modify: `Package.swift`, `Package.distribution.swift`, `Sources/**`, `Tests/**`, `Plugins/**`, `Generator/**`, scripts, docs, samples
- Preserve ABI names in: `Sources/FoundryExtension/include/foundry_extension_interface.h`, `Sources/ExtensionApi/extension_api.json`, `Sources/ExtensionApi/foundry_extension_interface.json`

- [ ] **Step 1: Apply safe package-wide text renames**

Run:

```bash
git ls-files -co --exclude-standard \
  ':!:Sources/FoundryExtension/include/foundry_extension_interface.h' \
  ':!:Sources/ExtensionApi/extension_api.json' \
  ':!:Sources/ExtensionApi/foundry_extension_interface.json' \
  | while read -r file; do
      [[ -f "$file" ]] || continue
      perl -0pi -e 's/FoundrySwift/FoundrySwift/g; s/Foundry Swift/Foundry Swift/g; s/foundryswift/foundryswift/g; s/Foundry-Swift/Foundry-Swift/g; s/Foundry Swift Kit/Foundry Swift Kit/g' "$file"
    done
```

Expected: package names and prose are FoundrySwift-branded.

- [ ] **Step 2: Apply Foundry extension C API renames**

Run:

```bash
git ls-files -co --exclude-standard \
  ':!:Sources/FoundryExtension/include/foundry_extension_interface.h' \
  ':!:Sources/ExtensionApi/extension_api.json' \
  ':!:Sources/ExtensionApi/foundry_extension_interface.json' \
  | while read -r file; do
      [[ -f "$file" ]] || continue
      perl -0pi -e 's/FoundryExtension/FoundryExtension/g; s/foundry_extension_interface/foundry_extension_interface/g; s/foundry_extension/foundryextension/g; s/FOUNDRY_EXTENSION/FOUNDRY_EXTENSION/g' "$file"
    done
```

Expected: Swift and package code refer to FoundryExtension types and Foundry extension resources.

- [ ] **Step 3: Apply public macro and runtime symbol renames**

Run:

```bash
git ls-files -co --exclude-standard \
  ':!:Sources/FoundryExtension/include/foundry_extension_interface.h' \
  ':!:Sources/ExtensionApi/extension_api.json' \
  ':!:Sources/ExtensionApi/foundry_extension_interface.json' \
  | while read -r file; do
      [[ -f "$file" ]] || continue
      perl -0pi -e 's/@Foundry\b/@Foundry/g; s/#initFoundryExtension\b/#initFoundryExtension/g; s/initFoundryExtension/initFoundryExtension/g; s/FoundryMacro/FoundryMacro/g; s/MacroFoundry/MacroFoundry/g; s/FoundryMemoryInterface/FoundryMemoryInterface/g; s/FoundryInterface/FoundryInterface/g; s/FoundryNativeObjectPointer/FoundryNativeObjectPointer/g; s/FoundryVirtualDispatchCallback/FoundryVirtualDispatchCallback/g; s/FoundryError/FoundryError/g; s/VariantFoundryInterface/VariantFoundryInterface/g' "$file"
    done
```

Expected: public macro/runtime names use Foundry terminology while C ABI `FoundryExtensionGodotVersion` symbols remain untouched.

- [ ] **Step 4: Fix resource compatibility floors**

Run:

```bash
find . -path './.git' -prune -o -name '*.foundryextension' -print | while read -r file; do
  perl -0pi -e 's/compatibility_minimum\s*=\s*"?4\.[0-9.]*"?/compatibility_minimum = 0.1.0/g' "$file"
done
```

Expected: every `.foundryextension` file uses `compatibility_minimum = 0.1.0`.

### Task 6: Repair Package Manifest and C Bridge

**Files:**
- Modify: `Package.swift`
- Modify: `Package.distribution.swift`
- Modify: `Sources/FoundryExtension/FoundryExtension.h`
- Modify: `Sources/FoundryExtension/FoundryExtensionSupport.c`
- Modify: `Sources/FoundryExtension/include/FoundryExtensionSupport.h`

- [ ] **Step 1: Update FoundryExtension umbrella headers**

Ensure `Sources/FoundryExtension/FoundryExtension.h` contains:

```c
#ifndef FoundryExtensionBridge_c_h
#define FoundryExtensionBridge_c_h

#include <stdio.h>
#include <foundry_extension_interface.h>
#include <FoundryExtensionSupport.h>

#endif /* FoundryExtensionBridge_c_h */
```

Ensure `Sources/FoundryExtension/FoundryExtensionSupport.c` includes:

```c
#include <stdio.h>
#include "FoundryExtension.h"
```

Ensure `Sources/FoundryExtension/include/FoundryExtensionSupport.h` contains:

```c
#ifndef FoundryExtensionSupport_c_h
#define FoundryExtensionSupport_c_h

#include <stdio.h>
#include <foundry_extension_interface.h>

#endif /* FoundryExtensionSupport_c_h */
```

- [ ] **Step 2: Update manifest target/product names**

In `Package.swift` and `Package.distribution.swift`, ensure:

```swift
let package = Package(
    name: "FoundrySwift",
```

and product/target names use:

```swift
FoundrySwift
FoundrySwiftStatic
FoundryExtensionC
FoundrySwiftMacroLibrary
FoundrySwiftTestMacrosLibrary
FoundrySwiftTestMacros
FoundrySwiftTestRunner
FoundrySwiftTestExtension
FoundrySwiftEmbed
```

- [ ] **Step 3: Verify manifest parses**

Run:

```bash
swift package dump-package >/tmp/foundry-swift-package.json
```

Expected: exit code `0`.

### Task 7: Repair Generator and Plugins

**Files:**
- Modify: `Generator/Generator/*.swift`
- Modify: `Plugins/CodeGeneratorPlugin/plugin.swift`
- Modify: `Plugins/EntryPointGeneratorPlugin/EntryPointGeneratorPlugin.swift`
- Modify: `Sources/EntryPointGenerator/*.swift`

- [ ] **Step 1: Update generated file naming and imports**

Ensure generator/plugin output uses:

```swift
import FoundryExtensionC
```

and generated filenames:

```text
FoundrySwiftA.swift
FoundrySwiftB.swift
...
```

- [ ] **Step 2: Update macro scanning**

Ensure entry point scanning looks for `@Foundry` and `#initFoundryExtension`, not `@Foundry` or `#initFoundryExtension`.

- [ ] **Step 3: Run generator directly against Foundry API**

Run:

```bash
rm -rf /tmp/foundry-swift-generated
mkdir -p /tmp/foundry-swift-generated
swift run Generator Sources/ExtensionApi/extension_api.json /tmp/foundry-swift-generated
```

Expected: command exits `0` and `/tmp/foundry-swift-generated` contains generated Swift files.

### Task 8: Repair Runtime and Macro Compilation

**Files:**
- Modify: `Sources/FoundrySwift/**/*.swift`
- Modify: `Sources/FoundrySwiftMacroLibrary/**/*.swift`
- Modify: `Sources/FoundrySwiftTestMacros/**/*.swift`
- Modify: `Sources/FoundrySwiftTestMacrosLibrary/**/*.swift`
- Modify: `Tests/FoundrySwiftMacrosTests/**/*.swift`
- Modify: `Tests/FoundrySwiftUniversalTests/**/*.swift`

- [ ] **Step 1: Run package build to expose compile failures**

Run:

```bash
swift build
```

Expected initially: compile failures identifying stale names or C symbol mismatches.

- [ ] **Step 2: Fix stale names with targeted edits**

Use compile errors to replace stale internal names with Foundry equivalents. Preserve C ABI symbols that exist in `foundry_extension_interface.h`, especially `FoundryExtensionGodotVersion` and `FoundryExtensionInterfaceGetGodotVersion`.

- [ ] **Step 3: Re-run package build**

Run:

```bash
swift build
```

Expected: exit code `0`.

### Task 9: Convert Samples, Tests, Docs, and Scripts

**Files:**
- Modify: `README.md`
- Modify: `TESTING.md`
- Modify: `CHANGELOG.md`
- Modify: `Makefile`
- Modify: `Taskfile.yml`
- Modify/rename: `scripts/*`
- Modify: `Testbed/**`
- Modify: `TestEditor/**`
- Modify: `Sources/SimpleExtension/**`
- Modify: `Sources/ManualExtension/**`
- Modify: `Sources/FoundrySwift/FoundrySwift.docc/**`

- [ ] **Step 1: Update user-facing docs and examples**

Ensure docs show:

```swift
import FoundrySwift

#initFoundryExtension(cdecl: "swift_entry_point", types: [SpinningCube.self])

@Foundry(.tool)
class SpinningCube: Node3D {
}
```

and `.foundryextension` examples show:

```ini
[configuration]
entry_symbol = "swift_entry_point"
compatibility_minimum = 0.1.0
```

- [ ] **Step 2: Update scripts**

Rename script commands and paths from FoundrySwift/Godot addon language to FoundrySwift/Foundry extension language. Preserve executable bits.

- [ ] **Step 3: Run resource audit**

Run:

```bash
scripts/audit-foundry-product
```

Expected after conversion: exit code `0`, or only allowed legacy engine/API references after tightening the audit allowlist.

### Task 10: Verify Package, Tests, and Audit

**Files:**
- Modify any files needed to resolve verification failures.

- [ ] **Step 1: Run build**

Run:

```bash
swift build
```

Expected: exit code `0`.

- [ ] **Step 2: Run unit tests that do not require launching the editor**

Run:

```bash
swift test --filter FoundrySwiftUniversalTests
swift test --filter FoundrySwiftMacrosTests
```

Expected: exit code `0` for both, or a documented failing test with a concrete Foundry infrastructure reason.

- [ ] **Step 3: Run naming/resource audit**

Run:

```bash
scripts/audit-foundry-product
```

Expected: exit code `0`.

- [ ] **Step 4: Inspect final status**

Run:

```bash
git status --short
git diff --stat
```

Expected: only intentional Foundry-Swift fork changes.

### Task 11: Commit Implementation

**Files:**
- All implementation files changed by Tasks 1-10.

- [ ] **Step 1: Stage implementation**

Run:

```bash
git add -A
git status --short
```

Expected: all Foundry-Swift implementation changes are staged.

- [ ] **Step 2: Commit**

Run:

```bash
git commit -m "feat: create FoundrySwift product fork"
```

Expected: commit succeeds.

## Self-Review Checklist

- Spec coverage: tasks cover import, C bridge, Foundry dumps, public naming, generator, macros, samples/tests, docs/scripts, packaging, build/tests, and audit.
- Placeholder scan: no task relies on `TBD`, `TODO`, or unspecified "appropriate" behavior.
- Type consistency: public product and target names consistently use `FoundrySwift`; extension ABI target consistently uses `FoundryExtensionC`; extension resources consistently use `.foundryextension`.
