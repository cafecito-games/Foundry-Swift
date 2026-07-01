// swift-tools-version: 6.3

import PackageDescription

let withMultiProcessTrait = "with_multi_process"

let package = Package(
    name: "FoundrySwift",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
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
            name: "FoundrySwiftEmbed",
            type: .dynamic,
            targets: ["FoundrySwiftEmbed"]
        ),
    ],
    traits: [
        .trait(
            name: withMultiProcessTrait,
            description: "Use multi-process-safe code generation with reinitialization support."
        ),
    ],
    targets: [
        .target(
            name: "FoundryExtensionC",
            path: "Sources/FoundryExtension",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),

        // The full FoundrySwift API in one module. The release build stages
        // CodeGeneratorPlugin output into Sources/FoundrySwift/_generated/
        // inside this temporary package.
        .target(
            name: "FoundrySwift",
            dependencies: ["FoundryExtensionC"],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .define("CUSTOM_BUILTIN_IMPLEMENTATIONS"),
                .define("FOUNDRYSWIFT_WITH_MULTI_PROCESS", .when(traits: [withMultiProcessTrait])),
                .unsafeFlags(
                    [
                        "-enable-library-evolution",
                        "-suppress-warnings",
                        "-Xfrontend", "-conditional-runtime-records",
                        "-Xfrontend", "-internalize-at-link",
                        "-Xfrontend", "-lto=llvm-full",
                    ]
                ),
            ]
        ),

        // No-op embed shim. The Foundry addon ships it as a registered
        // FoundryExtension whose `[dependencies]` references FoundrySwift.framework,
        // so Foundry's exporters embed FoundrySwift exactly once. C target with
        // no FoundrySwift dependency so SwiftPM does not statically link the
        // entire FoundrySwift module into this binary.
        .target(
            name: "FoundrySwiftEmbed",
            publicHeadersPath: "include"
        ),
    ]
)
