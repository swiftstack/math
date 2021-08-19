// swift-tools-version:5.0
import PackageDescription

var package = Package(
    name: "Math",
    products: [
        .library(
            name: "Math",
            targets: ["Math"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftstack/test.git",
            .branch("fiber"))
    ],
    targets: [
        .target(
            name: "Math",
            dependencies: []),
        .testTarget(
            name: "MathTests",
            dependencies: ["Test", "Math"]),
    ]
)

#if arch(x86_64)
package.targets.append(.target(name: "X86_64"))
package.targets[0].dependencies.append("X86_64")
#endif
// Temporary
package.targets.append(.target(name: "libc"))
package.targets[0].dependencies.append("libc")
package.targets.append(.testTarget(
    name: "LibcTests",
    dependencies: ["Test", "libc"]))
