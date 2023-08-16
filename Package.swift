// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

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
            revision: "0c1de7149a39a9ff82d4db66234dec587b30a3ad")
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
          ],
          linkerSettings: [LinkerSetting.unsafeFlags(["-L./Sources/RustShims/", "-lpthread", "-ldl"])]
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
            ],
            linkerSettings: [LinkerSetting.unsafeFlags(["-L./Sources/RustShims/", "-lpthread", "-ldl"])]
        ),
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
