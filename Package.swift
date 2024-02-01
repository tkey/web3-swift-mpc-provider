// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Web3SwiftMpcProvider",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "MPCEthereumProvider",
            targets: ["MPCEthereumProvider"]),
        .library(
            name: "MPCBitcoinProvider",
            targets: ["MPCBitcoinProvider"]),


    ],
    dependencies: [
        .package(url: "https://github.com/argentlabs/web3.swift", from:"1.6.0"),
        .package(url: "https://github.com/tkey/mpc-kit-swift", branch: "main"),
    ],
    targets: [
        
        .target(
            name: "MPCEthereumProvider",
            dependencies: ["web3.swift",
               .product(name: "mpc-kit-swift", package: "mpc-kit-swift")
            ],
            path: "Sources/EthereumProvider"
        ),
        .target(
            name: "MPCBitcoinProvider",
            dependencies: [.product(name: "mpc-kit-swift", package: "mpc-kit-swift")],
            path: "Sources/BitcoinProvider"
        ),
        .testTarget(
            name: "Web3SwiftMpcProviderTests",
            dependencies: ["MPCEthereumProvider"],
            path: "Tests"),
    ]
//    swiftLanguageVersions: [.v5]
)
