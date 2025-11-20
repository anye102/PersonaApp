////
////  Package.swift
////  Persona_v1.0
////
////  Created by 邹坤 on 2025/11/27.
////
//
//// swift-tools-version: 5.9
//import PackageDescription
//
//let package = Package(
//    name: "Persona",
//    platforms: [.iOS(.v16), .macOS(.v13)],
//    products: [
//        .library(
//            name: "Persona",
//            targets: ["Persona"]
//        ),
//    ],
//    dependencies: [
//        .package(url: "https://github.com/gonzalezreal/MarkdownUI", from: "2.1.0")
//    ],
//    targets: [
//        .target(
//            name: "Persona",
//            dependencies: ["MarkdownUI"],
//            path: ".",
//            sources: [
//                "ContentView.swift",
//                "Models/",
//                "Views/",
//                "PersonaApp.swift",
//                "PreviewProvider.swift"
//            ],
//            resources: [
//                .process("Resources")
//            ]
//        )
//    ]
//)
