// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "TIL",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built onPostgresql.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "3.0.0-rc")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPosgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

