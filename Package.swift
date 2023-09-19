// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FoundationPreview",
    platforms: [.macOS("13.3"), .iOS("16.4"), .tvOS("16.4"), .watchOS("9.4")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "FoundationPreview", targets: ["FoundationPreview"]),
        .library(name: "FoundationEssentials", targets: ["FoundationEssentials"]),
        .library(name: "FoundationInternationalization", targets: ["FoundationInternationalization"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections",
            revision: "d8003787efafa82f9805594bc51100be29ac6903"), // on release/1.1
        .package(
            url: "https://github.com/apple/swift-foundation-icu",
            revision: "0c1de7149a39a9ff82d4db66234dec587b30a3ad"),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.0.0")
    ],
    targets: [
        // Foundation (umbrella)
        .target(
            name: "FoundationPreview",
            dependencies: [
                "FoundationEssentials",
                "FoundationInternationalization",
            ],
            path: "Sources/Foundation"),

        // RustShims (Internal)
        .target(
            name: "RustShims",
            linkerSettings: [LinkerSetting.unsafeFlags(["-L./Sources/RustShims/", "-lpthread", "-ldl"])],
            //linkerSettings: [LinkerSetting.linkedLibrary("rustshims")],
            plugins: [.plugin(name: "RustShimsSourceGenPlugin")]),
        .plugin(
            name: "RustShimsSourceGenPlugin",
            capability: .buildTool()
        ),
        
        // TestSupport (Internal)
        .target(name: "TestSupport", dependencies: [
            "FoundationEssentials",
            "FoundationInternationalization",
        ]),

        // FoundationEssentials
        .target(
          name: "FoundationEssentials",
          dependencies: [
            "RustShims",
            .product(name: "_RopeModule", package: "swift-collections"),
          ],
          swiftSettings: [
            .enableExperimentalFeature("VariadicGenerics"),
            .enableExperimentalFeature("AccessLevelOnImport")
          ]
          //linkerSettings: [LinkerSetting.unsafeFlags(["-L./Sources/RustShims/", "-lpthread", "-ldl"])]
        ),
        .testTarget(name: "FoundationEssentialsTests", dependencies: [
            "TestSupport",
            "FoundationEssentials"
        ]),

        // FoundationInternationalization
        .target(
            name: "FoundationInternationalization",
            dependencies: [
                .target(name: "FoundationEssentials"),
                .target(name: "RustShims"),
                .product(name: "FoundationICU", package: "swift-foundation-icu")
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
            //linkerSettings: [LinkerSetting.unsafeFlags(["-L./Sources/RustShims/", "-lpthread", "-ldl"])]
        ),
        
        // FoundationMacros
        .macro(
            name: "FoundationMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "FoundationMacrosTests",
            dependencies: [
                "FoundationMacros",
                "TestSupport"
            ]
        )
    ]
)

#if canImport(RegexBuilder)
package.targets.append(contentsOf: [
    .testTarget(name: "FoundationInternationalizationTests", dependencies: [
        "TestSupport",
        "FoundationInternationalization"
    ]),
])
#endif

#if !os(Windows)
// Using macros at build-time is not yet supported on Windows
if let index = package.targets.firstIndex(where: { $0.name == "FoundationEssentials" }) {
    package.targets[index].dependencies.append("FoundationMacros")
}
#endif
