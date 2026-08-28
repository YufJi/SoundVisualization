// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SoundViz",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "SoundViz",
            path: "Sources/SoundViz"
        ),
        .testTarget(
            name: "SoundVizTests",
            dependencies: ["SoundViz"],
            path: "Tests/SoundVizTests"
        )
    ]
)
