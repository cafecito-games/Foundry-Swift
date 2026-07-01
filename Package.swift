// swift-tools-version: 6.3

import CompilerPluginSupport
import PackageDescription

let withMultiProcessTrait = "with_multi_process"

// Products define the executables and libraries a package produces, and make them visible to other packages.
var products: [Product] = [
    .library(
        name: "FoundrySwift",
        type: .dynamic,
        targets: ["FoundrySwift"]
    ),

    .library(
        name: "FoundrySwiftStatic",
        targets: ["FoundrySwift"]
    ),

    .library(
        name: "ExtensionApi",
        targets: [
            "ExtensionApi",
            "ExtensionApiJson",
        ]
    ),

    .plugin(
        name: "CodeGeneratorPlugin",
        targets: ["CodeGeneratorPlugin"]
    ),

    .plugin(
        name: "EntryPointGeneratorPlugin",
        targets: ["EntryPointGeneratorPlugin"]
    ),

    .library(
        name: "SimpleExtension",
        type: .dynamic,
        targets: ["SimpleExtension"]
    ),

    .library(
        name: "ManualExtension",
        type: .dynamic,
        targets: ["ManualExtension"]
    ),

    .library(
        name: "FoundrySwiftEmbed",
        type: .dynamic,
        targets: ["FoundrySwiftEmbed"]
    ),

    .executable(
        name: "FoundrySwiftTestRunner",
        targets: ["FoundrySwiftTestRunner"]
    ),

    .library(
        name: "FoundrySwiftTestExtension",
        type: .dynamic,
        targets: ["FoundrySwiftTestExtension"]
    ),
]

/// Targets are the basic building blocks of a package. A target can define a module, plugin, test suite, etc.
var targets: [Target] = [
    .executableTarget(
        name: "EntryPointGenerator",
        dependencies: [
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // This contains FoundryExtension's JSON API data models
    .target(
        name: "ExtensionApi",
        exclude: ["ExtensionApiJson.swift", "extension_api.json", "foundry_extension_interface.json"],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // This contains a resource bundle with extension_api.json
    .target(
        name: "ExtensionApiJson",
        path: "Sources/ExtensionApi",
        exclude: ["ApiJsonModel.swift", "ApiJsonModel+Extra.swift"],
        sources: ["ExtensionApiJson.swift"],
        resources: [
            .process("extension_api.json"),
            .copy("foundry_extension_interface.json"),
        ],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // The generator takes Foundry's JSON-based API description as input and
    // produces Swift API bindings that can be used to call into Foundry.
    .executableTarget(
        name: "Generator",
        dependencies: [
            "ExtensionApi",
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
        ],
        path: "Generator",
        exclude: ["README.md"],
        swiftSettings: [
            .swiftLanguageMode(.v6)
            // Uncomment for using legacy array-based marshalling
            //.define("LEGACY_MARSHALING")
        ]
    ),

    // This is a build-time plugin that invokes the generator and produces
    // the bindings that are compiled into FoundrySwift.
    .plugin(
        name: "CodeGeneratorPlugin",
        capability: .buildTool(),
        dependencies: ["Generator"]
    ),

    // This is a build-time plugin that generates the EntryPoint.swift file,
    // which is used to bootstrap the FoundrySwift API and register your
    // extension and classes with Foundry.
    .plugin(
        name: "EntryPointGeneratorPlugin",
        capability: .buildTool(),
        dependencies: ["EntryPointGenerator"]
    ),

    // This allows the Swift code to call into the Foundry bridge API (FoundryExtension)
    .target(
        name: "FoundryExtensionC",
        path: "Sources/FoundryExtension",
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // These are macros that can be used by third parties to simplify their
    // FoundrySwift development experience, these are used at compile time by
    // third party projects
    .macro(
        name: "FoundrySwiftMacroLibrary",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "SwiftBasicFormat", package: "swift-syntax"),
        ],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // Test macro implementations for @FoundrySwiftTest and @FoundrySwiftTestSuite
    .macro(
        name: "FoundrySwiftTestMacrosLibrary",
        dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // Test macro definitions and FoundrySwiftTestSuiteProtocol
    .target(
        name: "FoundrySwiftTestMacros",
        dependencies: ["FoundrySwift"],
        swiftSettings: [.swiftLanguageMode(.v6)],
        plugins: ["FoundrySwiftTestMacrosLibrary"]
    ),
    // This contains sample code showing how to use the FoundrySwift API
    .target(
        name: "SimpleExtension",
        dependencies: ["FoundrySwift"],
        exclude: ["SimpleExtension.foundryextension", "README.md"],
        swiftSettings: [.swiftLanguageMode(.v6)],
        plugins: [.plugin(name: "EntryPointGeneratorPlugin")]
    ),

    // This contains sample code showing how to use the FoundrySwift API
    // with manual registration of methods and properties
    .target(
        name: "ManualExtension",
        dependencies: ["FoundrySwift"],
        exclude: ["ManualExtension.foundryextension", "README.md"],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // No-op FoundryExtension shipped inside the FoundrySwift Foundry addon. Its sole
    // purpose is to give Foundry's iOS/macOS exporters a registered extension
    // whose .foundryextension lists FoundrySwift under `[dependencies]`, so
    // FoundrySwift.framework is embedded into the exported app exactly once.
    //
    // Intentionally a C target with no FoundrySwift dependency: SwiftPM links
    // same-package target dependencies statically, so a Swift shim depending
    // on FoundrySwift would inline the entire FoundrySwift module (~33 MB per
    // slice). The C shim is a few KB; the .foundryextension's [dependencies]
    // block is what triggers FoundrySwift embedding, not this binary's link
    // graph.
    .target(
        name: "FoundrySwiftEmbed",
        publicHeadersPath: "include"
    ),

    // The full FoundrySwift API: hand-written core + the generated Foundry API,
    // all in one module. The release build stages CodeGeneratorPlugin output
    // into Sources/FoundrySwift/_generated/ inside a temporary package.
    .target(
        name: "FoundrySwift",
        dependencies: ["FoundryExtensionC"],
        exclude: ["_generated"],
        swiftSettings: [
            .swiftLanguageMode(.v6),
            .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
            .define("FOUNDRYSWIFT_WITH_MULTI_PROCESS", .when(traits: [withMultiProcessTrait])),
            .unsafeFlags(
                [
                    "-Xfrontend", "-conditional-runtime-records",
                    "-Xfrontend", "-internalize-at-link",
                    "-Xfrontend", "-lto=llvm-full",
                ]
            ),
        ],
        plugins: ["CodeGeneratorPlugin", "FoundrySwiftMacroLibrary"]
    ),

    // General purpose cross-platform tests
    .testTarget(
        name: "FoundrySwiftUniversalTests",
        dependencies: [
            "FoundrySwift",
            "ExtensionApi",
            "ExtensionApiJson",
        ],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // Test runner CLI executable
    .executableTarget(
        name: "FoundrySwiftTestRunner",
        dependencies: [],
        path: "Sources/FoundrySwiftTestRunner",
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),

    // Test extension (loaded by Foundry) - includes all test infrastructure and test suites
    .target(
        name: "FoundrySwiftTestExtension",
        dependencies: ["FoundrySwift", "FoundrySwiftTestMacros"],
        path: "Tests/FoundrySwiftTestExtension",
        swiftSettings: [.swiftLanguageMode(.v6)]
    ),
]

// Idea: -mark_dead_strippable_dylib
targets.append(
    .testTarget(
        name: "FoundrySwiftMacrosTests",
        dependencies: [
            "FoundrySwiftMacroLibrary",
            "FoundrySwift",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ],
        exclude: ["Resources"],
        resources: [
            .copy("Resources")
        ],
        swiftSettings: [.swiftLanguageMode(.v6)]
    ))

let package = Package(
    name: "FoundrySwift",
    platforms: [
        .macOS(.v14),
        .iOS (.v17)
    ],
    products: products,
    traits: [
        .trait(
            name: withMultiProcessTrait,
            description: "Use multi-process-safe code generation with reinitialization support."
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.1"),
    ],
    targets: targets
)
