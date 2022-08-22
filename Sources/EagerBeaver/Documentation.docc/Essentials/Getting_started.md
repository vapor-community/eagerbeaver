# Getting started

Learn how to use it.

### Requirements

EagerBeaver requires Swift 5.6 or higher.

### Installation

First add it as a dependency to your package description.

```swift
let package = Package(
    ...
    dependencies: [
        // 1. Add the package
        .package(url: "https://github.com/vapor-community/eagerbeaver.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            ...
            dependencies: [
                /// 2. Add the product
                .product(name: "EagerBeaver", package: "eagerbeaver"),
            ]
        ),
        ...
    ]
)
```
