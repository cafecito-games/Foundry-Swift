# Foundry alpha.7 interface compatibility

## Problem

FoundrySwift 0.1.0-alpha.1 loads extension interface functions removed or replaced by Foundry alpha.7. The first failure is the deprecated `mem_alloc`, `mem_realloc`, and `mem_free` family, but alpha.7 also replaces `classdb_construct_object`, `classdb_register_extension_class2`, and `callable_custom_create`. Any extension using the old loader aborts before its own initialization completes.

## Design

Refresh the checked-in extension API artifacts from the official Foundry v0.1.0-alpha.7 API package. Update the hand-written runtime interface to load `mem_alloc2`, `mem_realloc2`, `mem_free2`, `classdb_construct_object2`, `classdb_register_extension_class5`, and `callable_custom_create2`. Adapt the affected callback structs to alpha.7's added arguments and preserve the public Swift allocator behavior: callers continue to allocate, reallocate, and free through the existing `gmem_*` helpers. Because `classdb_construct_object2` creates objects without post-initialization, send `Object.notificationPostinitialize` only after concrete object construction completes; custom `InitContext` constructors use its explicit completion helper after `super.init(context)`.

The generated C declarations and Swift-imported types remain the source of truth for the alpha.7 function signatures. No compatibility fallback is needed because the release targets the current Foundry alpha.7 engine and loading the removed names is the failure being fixed.

## Components and data flow

1. Foundry alpha.7 calls the FoundrySwift entry point with its proc-address provider.
2. `loadFoundryInterface` resolves all required functions, including the three `*2` memory functions.
3. The resulting `FoundryInterface` stores the typed function pointers.
4. `FoundryMemoryInterface.swift` calls those pointers with the existing allocation semantics and zero pre-padding.
5. The extension proceeds through registration and can be exercised by the FoundrySwift test runner.

For objects created through `classdb_construct_object2`, Swift sends `NOTIFICATION_POSTINITIALIZE` after concrete wrapper construction completes. Existing Foundry-originated wrappers are not notified, and custom constructors call `InitContext.postinitialize(_:)` after `super.init(context)`.

The API refresh also keeps `extension_api.json`, `foundry_extension_interface.json`, and `foundry_extension_interface.h` synchronized with the exact engine release used for validation, so code generation and downstream binary artifacts are reproducible.

## Error handling

Required interface functions continue to fail fast when the engine does not provide them. The regression test models alpha.7 by omitting the deprecated memory names and providing the replacement names; it must complete interface loading without a fatal error. Optional interface functions retain their existing nullable loading behavior.

## Testing and release validation

- Add a focused Swift regression test that uses a proc-address provider with alpha.7 symbols only and rejects all six deprecated names.
- Run the focused test first against the old implementation to prove it fails, then after the fix.
- Run `swift test`, code generation checks, release helper tests, and the Foundry-based test runner with the official alpha.7 editor.
- Run the existing release workflow locally where possible and publish the source release/addon archive plus matching `Foundry-Swift-Binary` artifacts through the repository's release workflow after merge.
