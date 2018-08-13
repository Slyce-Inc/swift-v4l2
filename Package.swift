// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "Video4Linux",
  products: [
    .library(name: "Video4Linux", targets: ["Video4Linux"]),
    .library(name: "Clibv4l2", targets: ["Clibv4l2"])
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Clibv4l2",
      dependencies: []
    ),
    .target(
      name: "Video4Linux",
      dependencies: ["Clibv4l2"]
    ),
  ]
)
