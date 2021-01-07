// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DimigoinKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "DimigoinKit",
            targets: ["DimigoinKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.2.2"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "DimigoinKit",
            dependencies: ["Alamofire", "SwiftyJSON", "SDWebImageSwiftUI"])
    ]
)
