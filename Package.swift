// swift-tools-version:4.2

//
//  Package.swift
//  LSFileWrapper
//
//  Created by Adam Kopeć on 10/13/19.
//  Copyright © 2019 Adam Kopeć.
//
//  Licensed under the MIT License
//

import PackageDescription

let package = Package(
        name: "LSFileWrapper",
        products: [
            .library(name: "LSFileWrapper", type: .dynamic, targets: ["LSFileWrapper"])
        ],
        dependencies: [],
        targets: [
            .target(name: "LSFileWrapper", path: "", publicHeadersPath: "")
        ]
)
