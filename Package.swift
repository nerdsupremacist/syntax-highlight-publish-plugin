// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "syntax-highlight-publish-plugin",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "SyntaxHighlightPublishPlugin",
                 targets: ["SyntaxHighlightPublishPlugin"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nerdsupremacist/Syntax.git", .branch("develop")),
        .package(url: "https://github.com/nerdsupremacist/syntax-highlight.git", .branch("main")),
        .package(url: "https://github.com/nerdsupremacist/TextMate.git", .branch("main")),
        .package(url: "https://github.com/JohnSundell/Splash.git", from: "0.15.0"),
        .package(url: "https://github.com/JohnSundell/Publish.git", from: "0.7.0"),
    ],
    targets: [
        .target(name: "SyntaxHighlightPublishPlugin",
                dependencies: [
                    "Syntax",
                    "TextMate",
                    "Splash",
                    "Publish",
                    .product(name: "SyntaxHighlight", package: "syntax-highlight"),
                ]),
        .testTarget(name: "SyntaxHighlightPublishPluginTests",
                    dependencies: ["SyntaxHighlightPublishPlugin"]),
    ]
)
