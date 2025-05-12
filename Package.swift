// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "AazKiTazaKhabar",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AazKiTazaKhabar",
            targets: ["AazKiTazaKhabar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "AazKiTazaKhabar",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ]),
    ]
) 