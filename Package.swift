// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "libv4l2",
    providers: [
        .apt(["libv4l2-dev"])
    ],
    products: [ .library(name: "libv4l2", targets: ["libv4l2"]) ],
    dependencies: [
    ]
)
