// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Web3SwiftMpcProvider",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "Web3SwiftMpcProvider",
            targets: ["Web3SwiftMpcProvider"]),
        .library(
            name: "MPCEthereumProvider",
            targets: ["MPCEthereumProvider"]),

    ],
    dependencies: [
        .package(url: "https://github.com/argentlabs/web3.swift", from:"1.6.0"),
        .package(url: "https://github.com/torusresearch/tss-client-swift.git", from: "4.0.0"),
        .package(url: "https://github.com/tkey/curvelib.swift", from: "1.0.1"),
        .package(url: "https://github.com/tkey/mpc-core-kit-swift", branch: "feat/signer"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),

    ],
    targets: [
        .target(
            name: "Web3SwiftMpcProvider",
            dependencies: ["web3.swift", .product(name: "tssClientSwift", package: "tss-client-swift"), .product(name: "curveSecp256k1", package: "curvelib.swift")],
            path: "Sources/Web3SwiftMpcProvider"
        ),
        .target(
            name: "MPCEthereumProvider",
            dependencies: ["web3.swift",
                           .product(name: "curveSecp256k1", package: "curvelib.swift"),
            ],
            path: "Sources/MPCEthereumProvider"
        ),
        
        .testTarget(
            name: "Web3SwiftMpcProviderTests",
            dependencies: ["Web3SwiftMpcProvider", "MPCEthereumProvider",
              .product(name: "mpcEvmSigner", package: "mpc-core-kit-swift"),
              .product(name: "JWTKit", package: "jwt-kit")
            ],
            path: "Tests"),
    ],
    swiftLanguageVersions: [.v5]
)
