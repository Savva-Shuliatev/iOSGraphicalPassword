// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GraphicalPassword",
  platforms: [.iOS("14")],
  products: [
    .library(
      name: "GraphicalPassword",
      targets: ["GraphicalPassword"]
    ),
  ],
  targets: [
    .target(
      name: "GraphicalPassword"),

  ]
)
