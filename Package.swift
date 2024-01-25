// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Web3SwiftMpcProvider",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "Web3SwiftMpcProvider",
            targets: ["Web3SwiftMpcProvider"]),
        .library(
            name: "MPCEthereumProvider",
            targets: ["MPCEthereumProvider"]),
        .library(
            name: "MPCBitcoinProvider",
            targets: ["MPCBitcoinProvider"]),


    ],
    dependencies: [
        .package(url: "https://github.com/argentlabs/web3.swift", from:"1.6.0"),
        .package(url: "https://github.com/torusresearch/tss-client-swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Web3SwiftMpcProvider",
            dependencies: ["tss-client-swift"],
            path: "Sources/Web3SwiftMpcProvider"
        ),
        .target(
            name: "MPCEthereumProvider",
            dependencies: ["web3.swift", "Web3SwiftMpcProvider"],
            path: "Sources/EthereumProvider"
        ),
        .target(
            name: "MPCBitcoinProvider",
            dependencies: ["Web3SwiftMpcProvider"],
            path: "Sources/BitcoinProvider"
        ),
        .testTarget(
            name: "Web3SwiftMpcProviderTests",
            dependencies: ["MPCEthereumProvider"],
            path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
