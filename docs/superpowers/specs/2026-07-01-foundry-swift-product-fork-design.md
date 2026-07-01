# Foundry-Swift Product Fork Design

## Summary

Foundry-Swift is a standalone Swift package forked from `/Users/christian/CafecitoGames/SwiftGodot/` and retargeted to the Foundry Engine fork at `/Users/christian/CafecitoGames/godot`. It is a hard break from Godot-facing package semantics: public package names, macro names, extension files, examples, docs, release assets, and addon packaging use Foundry naming.

The repository will be hosted at `github.com/cafecito-games/Foundry-Swift`.

## Source Context

The target directory `/Users/christian/CafecitoGames/Foundry-Swift` is an empty git repository with no commits on `main`.

The source package `/Users/christian/CafecitoGames/SwiftGodot` is the starting point. Its current `main` branch contains a Swift 6.3 package with:

- `SwiftGodot` runtime and generated bindings.
- `GDExtensionC` C bridge target.
- `SwiftGodotMacroLibrary` macros.
- `EntryPointGeneratorPlugin` and `CodeGeneratorPlugin`.
- Sample extensions, extension tests, release scripts, addon packaging scripts, and DocC documentation.

The Foundry fork in `/Users/christian/CafecitoGames/godot` has real engine API divergence:

- Foundry editor binary version observed locally: `0.1.dev.custom_build.89031bfb6`.
- Dump flags verified locally:
  - `--dump-extension-api` writes `extension_api.json`.
  - `--dump-foundryextension-interface` writes `foundry_extension_interface.h`.
  - `--dump-foundryextension-interface-json` writes `foundry_extension_interface.json`.
- The dumped API includes Foundry-specific classes such as `FoundryScript`, `FSReflection`, and `FoundryExtension`.
- The C extension API uses `FoundryExtension*` names and `FOUNDRY_EXTENSION_*` constants.
- Extension resource files use `.foundryextension`.
- The compatibility floor is Foundry `0.1.0`, not Godot `4.x`.

## Chosen Approach

Use a layered Foundry-native fork.

1. Copy the SwiftGodot package into Foundry-Swift.
2. Establish the Foundry C bridge, bundled Foundry API dumps, and generated bindings.
3. Rename public Swift package API to Foundry terminology.
4. Convert samples, tests, project files, scripts, docs, and release/addon packaging.
5. Verify build, generator, macro, extension-resource, runtime/editor, and packaging gates.

This approach is preferred over a single mechanical rename because it creates clear checkpoints and makes engine API failures easier to isolate. It is preferred over a rewrite because the existing SwiftGodot generator/runtime/package infrastructure remains the fastest route to a complete product fork.

## Naming Policy

The public API is Foundry-native.

Required public names include:

- Package: `FoundrySwift`.
- Main runtime target/product: `FoundrySwift`.
- C bridge target: `FoundryExtensionC`.
- Macro implementation target: `FoundrySwiftMacroLibrary`.
- Test macro targets: `FoundrySwiftTestMacrosLibrary` and related Foundry-named test support.
- Entry macro: `#initFoundryExtension`.
- Main class macro: `@Foundry`.
- Extension resource suffix: `.foundryextension`.
- Project file: `project.foundry`.
- Embed addon/extension: `FoundrySwiftEmbed`.

Compatibility aliases are out of scope. The package must not expose public aliases such as `@Godot`, `#initSwiftExtension`, `SwiftGodot`, or `GDExtensionC`.

Remaining `Godot` terms are allowed only when one of these is true:

- The exact term is still emitted by Foundry's `extension_api.json`.
- The term is part of upstream copyright, license, or historical attribution.
- The term is in inherited engine API names that Foundry has not renamed.
- A transitional internal implementation detail is not user-facing and is scheduled for cleanup before release.

User-facing docs, examples, scripts, release names, and generated public symbols should say Foundry.

## Architecture

### FoundryExtensionC

`FoundryExtensionC` replaces `GDExtensionC`. It includes the generated `foundry_extension_interface.h` and a support header that imports Foundry C API types. Swift code calls Foundry's real renamed C API:

- `FoundryExtensionInitialization`.
- `FoundryExtensionInterfaceGetProcAddress`.
- `FoundryExtensionClassLibraryPtr`.
- `FoundryExtensionVariantFromTypeConstructorFunc`.
- `FoundryExtensionTypeFromVariantConstructorFunc`.
- Other `FoundryExtension*` types emitted by the interface dump.

The target must not depend on Godot's `gdextension_interface.h`.

### ExtensionApi and ExtensionApiJson

The `ExtensionApi` and `ExtensionApiJson` targets may keep their generic names because Foundry still emits the API file as `extension_api.json`. The bundled JSON must come from the local Foundry binary, not from SwiftGodot or upstream Godot.

The JSON data models can retain generic internal names unless those names leak into public API. Public documentation should describe them as Foundry extension API dumps.

The repository will keep `foundry_extension_interface.json` as a checked-in reference artifact for future validation and regeneration workflows.

### Generator

The generator reads Foundry's `extension_api.json` and emits Swift files for the `FoundrySwift` target. It must generate Foundry C API symbols, Foundry module imports, Foundry-named preambles, and output filenames that no longer say SwiftGodot.

Generated bindings should include Foundry-specific API classes such as `FoundryScript`, `FSReflection`, and `FoundryExtension`.

### FoundrySwift Runtime

`FoundrySwift` is the main runtime and generated binding module. It contains:

- Hand-written runtime glue renamed from SwiftGodot.
- Generated bindings from Foundry's API dump.
- Foundry-native entry-point initialization.
- Foundry editor plugin helpers.
- Variant, object, callable, signal, property, memory, and class registration support using Foundry C types.

### Macros and Entry Point

The macro library exposes Foundry terminology:

- `@Foundry` registers Swift classes with Foundry.
- `#initFoundryExtension` declares the extension entry point.
- Existing general-purpose macros such as `@Callable`, `@Export`, `@Signal`, `@BindNode`, and RPC support can keep their names when they are not Godot-branded.

The entry point generator plugin scans for Foundry macros and emits a C-callable entry symbol accepted by `.foundryextension` files.

### Samples, Tests, and Projects

Sample extension files and test extension files use:

- `.foundryextension`.
- `compatibility_minimum = 0.1.0`.
- `project.foundry`.
- Foundry target/product names.
- Foundry import statements and macros.

Existing runtime and macro tests should be converted rather than removed when their behavior still applies. Tests that require unavailable Foundry editor/project infrastructure should be documented as deferred with a concrete reason.

### Release and Addon Packaging

Release scripts, binary manifest scripts, addon packaging scripts, and README instructions should stage Foundry-named products and assets.

The addon packaging model mirrors SwiftGodot's embed model, but with Foundry names:

- A no-op extension named `FoundrySwiftEmbed`.
- A `.foundryextension` file with `compatibility_minimum = "0.1.0"`.
- A dependency block that causes Apple exports to embed `FoundrySwift.framework` or `FoundrySwift.xcframework` once.

Release assets that name the Swift module, framework, xcframework, or addon use `FoundrySwift`. Release assets that name the GitHub repository archive use `Foundry-Swift`.

## Data Flow

1. The local Foundry editor binary dumps API artifacts:
   - `extension_api.json`.
   - `foundry_extension_interface.h`.
   - `foundry_extension_interface.json`.
2. `ExtensionApiJson` bundles the Foundry `extension_api.json`.
3. `FoundryExtensionC` exposes the Foundry C interface header to Swift.
4. `CodeGeneratorPlugin` invokes `Generator`.
5. `Generator` decodes the Foundry API JSON and emits generated Swift bindings into the `FoundrySwift` target.
6. `FoundrySwift` compiles hand-written runtime glue plus generated bindings into dynamic and static library products.
7. `EntryPointGeneratorPlugin` or `#initFoundryExtension` emits the C-callable entry point.
8. `.foundryextension` files point Foundry at the entry symbol and library paths.
9. Release/addon scripts stage the framework, macro artifact bundle, embed extension, and metadata for distribution.

## Error Handling

The implementation should fail early on inconsistent engine inputs:

- Missing `foundry_extension_interface.h` fails the C bridge build.
- Missing or stale `extension_api.json` fails generator or package tests.
- Generator references to unavailable Foundry classes fail explicitly rather than silently falling back to `Object`.
- Any `.gdextension` sample or public Godot-branded macro in the final product is a release blocker.
- Any `compatibility_minimum` below `0.1.0` in `.foundryextension` resources is a release blocker.

## Testing and Verification

The implementation plan should use these verification gates:

1. `swift build` compiles the renamed package and generated Foundry bindings.
2. A generator smoke test reads the dumped Foundry API and emits files without `GDExtension` or `SwiftGodot` public symbols.
3. Macro tests verify `@Foundry`, `@Callable`, `@Export`, and `#initFoundryExtension`.
4. Extension resource checks verify `.foundryextension`, `compatibility_minimum = "0.1.0"`, Foundry library target paths, and absence of stale `.gdextension` project resources.
5. Runtime/editor tests converted from SwiftGodot run under Foundry where local infrastructure supports them.
6. Packaging checks verify Foundry-named release assets, addon staging, binary manifest metadata, and embed extension resources.
7. A repository-wide naming audit reports remaining `Godot`, `GDExtension`, `gdextension`, `SwiftGodot`, and `.gd` terms and classifies allowed leftovers.

## Out of Scope

This design does not require:

- Godot compatibility shims.
- Backward-compatible SwiftGodot imports or macro aliases.
- Cross-platform support beyond the Apple-focused scope inherited from the Cafecito SwiftGodot fork.
- Rewriting the binding generator from scratch.
- Renaming Foundry engine APIs that still intentionally contain `Godot` in the Foundry dump.

## Open Implementation Notes

The implementation plan should decide exact file movement order after copying SwiftGodot into this repository. It should also decide whether to use Foundry's `tools/foundry-rename` map directly or a package-specific rename script derived from it. Either route must be validated by build and naming-audit gates.
