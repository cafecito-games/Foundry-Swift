<p align="center">
  <img src="assets/logo/png/foundryswift-banner.png" alt="FoundrySwift" width="720">
</p>

# FoundrySwift

Swift bindings for the Foundry Engine, maintained by [Cafecito Games](https://github.com/cafecito-games) at [cafecito-games/Foundry-Swift](https://github.com/cafecito-games/Foundry-Swift).

**Scope of this fork:**
- Apple platforms only: **iOS and macOS**
- Targets **Foundry 0.1**
- Requires **Swift 6** (swift-tools-version 6.3, strict concurrency)

FoundrySwift is Foundry-specific. It uses Foundry's `extension_api.json`, `foundry_extension_interface.h`, `.foundryextension` metadata, and `FoundryExtension*` C API names.

---

FoundrySwift provides Swift language bindings for Foundry using the FoundryExtension system.

## Consuming this Package

**Source build** — reference the package directly from SwiftPM:

```swift
// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "MyFirstGame",
    products: [
        .library(name: "MyFirstGame", type: .dynamic, targets: ["MyFirstGame"]),
    ],
    dependencies: [
        .package(url: "https://github.com/cafecito-games/Foundry-Swift", branch: "main")
    ],
    targets: [
        .target(
            name: "MyFirstGame",
            dependencies: ["FoundrySwift"]
        )
    ]
)
```

**Binary (xcframework + prebuilt macro plugin)** — faster iteration, no source compilation, no `swift-syntax` dependency. Published separately from the source package:

```swift
dependencies: [
    .package(url: "https://github.com/cafecito-games/Foundry-Swift-Binary", from: "0.1.0")
],
targets: [
    .target(
        name: "MyFirstGame",
        dependencies: [
            .product(name: "FoundrySwift", package: "Foundry-Swift-Binary"),
        ]
    )
]
```

The `FoundrySwift` product carries the prebuilt runtime *and* the prebuilt macro compiler plugin, so `@Foundry`, `@Callable`, `@Export`, `#initFoundryExtension`, etc. work without depending on `swift-syntax` or building macros from source. The plugin is shipped as a universal macOS (arm64 + x86_64) artifact bundle; if you're on a Swift toolchain that's incompatible with the prebuilt plugin, use the source build above instead.

## Using FoundrySwift as a Foundry Addon

Foundry projects that use Swift-based addons can install the shared FoundrySwift binary addon with gpm:

```toml
[addons.FoundrySwift]
source      = "github-release"
repo        = "cafecito-games/Foundry-Swift"
version     = "v<X.Y.Z>"
asset       = "FoundrySwift-v<X.Y.Z>.zip"
source_path = "addons/FoundrySwift"
```

The addon registers a single no-op FoundryExtension named **FoundrySwiftEmbed** whose only job is to own embedding `FoundrySwift.framework` / `FoundrySwift.xcframework` into iOS and macOS exports. Its `[dependencies]` block points at the bundled FoundrySwift binary, so Foundry's exporter copies FoundrySwift into `App.app/Frameworks/` exactly once regardless of how many downstream Swift FoundryExtensions are installed alongside it.

Because of this:

- Downstream FoundryExtensions (e.g. cafecito-games/AuthenticationKit, cafecito-games/PurchaseKit) that link against FoundrySwift **must not** list FoundrySwift under their own `.foundryextension`'s `[dependencies]`. Embedding is owned exclusively by FoundrySwiftEmbed.
- They still depend on this addon at runtime: FoundrySwiftEmbed is what causes the shared FoundrySwift binary to be present in the exported app, and dynamic loading via `@rpath/FoundrySwift.framework/FoundrySwift` resolves through that.
- FoundrySwiftEmbed registers zero Foundry classes; it is loaded purely for its side effect on the exporter's copy-frameworks phase.

**Compatibility note for downstream addon authors:** if your `.foundryextension` declares FoundrySwift under `[dependencies]`, remove it when targeting the FoundrySwift addon. Two extensions that both list the same FoundrySwift path cause Foundry's iOS exporter to emit two `Embed Frameworks` entries for the same path, which Xcode rejects with `Multiple commands produce '.../Frameworks/FoundrySwift.framework'` during archive.

## Targets

| Target | Description |
|--------|-------------|
| `FoundrySwift` | Full Foundry API bindings |

## Creating a FoundryExtension

### Entry point

The simplest approach uses the `#initFoundryExtension` macro:

```swift
import FoundrySwift

#initFoundryExtension(cdecl: "swift_entry_point", types: [SpinningCube.self])

@Foundry(.tool)
class SpinningCube: Node3D {
    public override func _ready() {
        let meshRender = MeshInstance3D()
        meshRender.mesh = BoxMesh()
        addChild(node: meshRender)
    }

    public override func _process(delta: Double) {
        rotateY(angle: delta)
    }
}
```

Alternatively, `EntryPointGeneratorPlugin` scans your target's source files and generates the entry point automatically. Add it to your target in `Package.swift`:

```swift
.target(
    name: "MyFirstGame",
    dependencies: ["FoundrySwift"],
    plugins: [
        .plugin(name: "EntryPointGeneratorPlugin", package: "FoundrySwift")
    ]
)
```

### `.foundryextension` file

```ini
[configuration]
entry_symbol = "swift_entry_point"
compatibility_minimum = "0.1.0"

[libraries]
macos.debug = "res://bin/MyFirstGame"
macos.release = "res://bin/MyFirstGame"
ios.debug = "res://bin/MyFirstGame"
ios.release = "res://bin/MyFirstGame"
```

Copy the `.foundryextension` file and its referenced binaries into your Foundry project. Foundry will load the extension automatically on startup.

## Working with this Repository

Clone and open in Xcode via `Package.swift`. If you only need to work on the binding generator, open the `Generator` project and edit the `okList` variable to reduce build times.

## License

MIT — see [LICENSE](LICENSE).
