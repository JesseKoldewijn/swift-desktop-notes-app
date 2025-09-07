// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "notes-manager-desktop",
    platforms: [
        .macOS(.v10_15)
    ],
    targets: [
        // System library for GTK4
        .systemLibrary(
            name: "CGtk",
            pkgConfig: "gtk4",
            providers: [
                // Linux distributions
                .apt(["libgtk-4-dev"]),
                .yum(["gtk4-devel"]),
                
                // macOS
                .brew(["gtk4"])
                
                // Note: Windows would require additional setup with MSYS2/vcpkg
            ]
        ),
        
        // Main executable target
        .executableTarget(
            name: "notes-manager-desktop",
            dependencies: ["CGtk"],
            resources: [
                .copy("styles.css")
            ]
        ),
    ]
)
