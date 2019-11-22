// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Video4Linux",
  products: [
    .library(name: "Video4Linux", targets: ["Video4Linux"]),
  ],
  targets: [
    .target(
      name: "Video4Linux",
      dependencies: ["Clibv4l2"]
    ),
    .systemLibrary(
      name: "Clibv4l2"
    ),
  ]
)
