# Notes Manager Desktop

A modern cross-platform desktop notes application built with Swift

## 📦 Status

<p>
    <a href="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/ci.yml">
        <img src="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/ci.yml/badge.svg" alt="CI">
    </a>
    <a href="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/release.yml">
        <img src="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/release.yml/badge.svg" alt="Build and Release">
    </a>
</p>

### 📦 Creating Installers

The project includes an automated installer creation script that detects your OS and Linux distribution to create appropriate installation packages:

```bash
# Create release installer (default)
./create-installer.sh

# Create debug installer
./create-installer.sh -c debug

# Create installer in custom directory
./create-installer.sh -c release -o /path/to/packaged

# Build and create installer in one step
./build-and-package.sh
```

**Supported Package Formats:**

-   **Linux (Debian/Ubuntu)**: `.deb` packages
-   **Linux (Red Hat/Fedora)**: `.rpm` packages
-   **Linux (Arch)**: `.pkg.tar.zst` packages
-   **Linux (Generic)**: Portable installer with install/uninstall scripts
-   **macOS**: `.app` bundle
-   **All platforms**: Compressed `.tar.gz` archive

The installer script automatically:

-   Detects your OS and distribution
-   Creates platform-specific packages
-   Includes desktop integration files
-   Bundles all required resources
-   Generates installation instructions

## 📱 Application Overview. This application provides a native desktop experience with a clean, intuitive interface for managing your personal notes.

## 🎯 Features

-   ✅ **Native Desktop App**: Built with GTK4 for true native experience
-   ✅ **Cross-platform**: Supports Linux and macOS
-   ✅ **Modern Swift 6.0**: Leverages latest Swift concurrency and safety features
-   ✅ **GUID-based Notes**: Each note has a unique identifier for better organization
-   ✅ **JSON Index**: Efficient note metadata management with JSON storage
-   ✅ **Two-pane Interface**: Notes list on left, editor on right
-   ✅ **Real-time Updates**: Live UI updates with GTK4 callbacks
-   ✅ **Custom Styling**: GTK4 CSS theming for modern appearance
-   ✅ **File-based Storage**: Notes stored in your Documents folder

## 🚀 Quick Start

### Prerequisites

-   **Swift 6.0+** - We recommend using [Swiftly](https://github.com/swiftlang/swiftly) to install and manage Swift versions
-   **GTK4 development libraries** and **pkg-config**

#### Install Swift with Swiftly

Swiftly is the recommended way to install and manage Swift versions:

```bash
# Install Swiftly (Linux/macOS)
curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | bash

# Install Swift 6.0 or later
swiftly install latest
swiftly use latest

# Verify installation
swift --version  # Should be 6.0+
```

#### Install Dependencies:

**Linux (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install libgtk-4-dev pkg-config
```

**Linux (Fedora/RHEL):**

```bash
sudo dnf install gtk4-devel pkg-config
```

**macOS:**

```bash
brew install gtk4 pkg-config
```

### �️ Build and Run

```bash
# Clone the repository
git clone https://github.com/JesseKoldewijn/swift-desktop-notes-app.git
cd swift-desktop-notes-app

# Configure environment (optional but recommended)
./configure.sh

# Build the application
swift build

# Run the application
.build/debug/notes-manager-desktop
```

### � Alternative Scripts

The project includes convenient scripts:

```bash
# Build with optimizations
./build.sh

# Launch the application
./launch.sh

# Create a release build
./create-release.sh
```

## 📱 Application Overview

The application will:

1. **Launch** as a native GTK4 desktop window
2. **Create** a "NotesManager" folder in your Documents directory
3. **Display** a two-pane interface:
    - Left pane: List of all your notes
    - Right pane: Note editor with title and content
4. **Store** notes as individual files with JSON metadata index

### User Interface

-   **New Note**: Create a new note (button in toolbar)
-   **Save Note**: Save current note (button in toolbar)
-   **Delete Note**: Remove selected note (button in editor)
-   **Note Selection**: Click any note in the left pane to open it
-   **Live Updates**: Interface updates automatically as you work

## 🏗️ Architecture

### Technical Stack

```
┌─────────────────┐    C API     ┌──────────────────┐
│      Swift      │◄────────────►│      GTK4 UI     │
│                 │              │                  │
│ • main.swift    │              │ • Native Widgets │
│ • NotesManager  │              │ • Event Handling │
│ • File I/O      │              │ • CSS Styling    │
└─────────────────┘              └──────────────────┘
```

### Key Components

1. **Swift Application Core**: Business logic and file management with GUID-based note identification
2. **GTK4 Native UI**: Direct C API calls for maximum performance and native feel
3. **CGtk Module**: Swift bindings for GTK4 C headers
4. **Structured Storage**: JSON index with individual note files for efficient management

## 📁 Project Structure

```
notes-manager-desktop/
├── 📜 Package.swift                    # Swift Package Manager configuration
├── 🔧 Scripts/
│   ├── build.sh                       # Build script
│   ├── configure.sh                   # Environment setup
│   ├── launch.sh                      # Run application
│   └── create-release.sh              # Release build
├── 📂 Sources/
│   ├── CGtk/                          # GTK4 C bindings module
│   │   ├── include/
│   │   │   ├── CGtk.h                # Main GTK4 C headers
│   │   │   └── gtkhelpers.h          # Helper functions
│   │   └── module.modulemap          # Swift module definition
│   └── notes-manager-desktop/         # Main application
│       ├── main.swift                # GTK4 application entry point
│       ├── NotesManager.swift        # Note management & storage
│       └── styles.css               # GTK4 CSS styling
└── � notes-manager.desktop            # Linux desktop entry
```

## 🗂️ Data Storage

Notes are stored in a structured format:

**Location**: `~/Documents/NotesManager/`

**Structure**:

```
NotesManager/
├── notes_index.json      # Metadata index (titles, IDs, timestamps)
├── {note-guid-1}.txt     # Individual note content files
├── {note-guid-2}.txt
└── ...
```

**Note Structure**:

-   Each note has a unique GUID identifier
-   Metadata stored in JSON index for fast loading
-   Content stored in separate UTF-8 text files
-   Automatic timestamp tracking (created/modified)

## �️ Development

### Environment Setup

1. **Install Prerequisites** (see Quick Start section)

2. **Configure Development Environment**:

    ```bash
    # Run configuration script (sets up VS Code IntelliSense, validates environment)
    ./configure.sh

    # Update VS Code C/C++ configuration if needed
    ./update-vscode-config.sh
    ```

### Building

```bash
# Development build
swift build

# Release build (optimized)
swift build -c release
.build/release/notes-manager-desktop

# Using convenience scripts
./build.sh        # Development build
./create-release.sh  # Release build
```

### CI/CD Integration

The project features a robust CI/CD pipeline with platform-specific optimizations:

#### **Development Workflow**

-   **Continuous Integration**: Automated testing on every PR/push
-   **Multi-platform Support**: Ubuntu, Fedora, Arch Linux, and macOS
-   **Smart Caching**: Swift toolchain and build artifacts cached for faster builds
-   **Native Package Management**: Uses each platform's preferred package manager

#### **Swift Toolchain Management**

-   **Version Consistency**: All builds respect the project's `.swift-version` file
-   **Platform-Optimized Installation**:
    -   **Ubuntu/macOS**: Pre-compiled Swiftly binaries (fastest)
    -   **Fedora**: Copr community repository with source fallback
    -   **Arch**: AUR packages via `yay` (most native)
-   **Automatic Fallbacks**: If package managers fail, builds from source

#### **Release Automation**

-   **Semantic Versioning**: Tag-triggered releases (`v1.0.0`, `v1.0.1`, etc.)
-   **Multi-format Packages**: `.deb`, `.rpm`, `.pkg.tar.zst`, and portable tarballs
-   **GitHub Integration**: Automatic asset upload to GitHub Releases
-   **Cross-platform Consistency**: Same Swift version across all platforms

### Code Architecture

**main.swift** - GTK4 Application:

-   Application initialization and main loop
-   UI widget creation and layout
-   Event handlers and callbacks
-   Global state management with `nonisolated(unsafe)`

**NotesManager.swift** - Data Management:

-   GUID-based note identification
-   JSON index for metadata
-   File I/O operations
-   Note CRUD operations

**styles.css** - GTK4 Theming:

-   Custom widget styling
-   Color schemes and typography
-   Layout and spacing definitions

### Swift 6.0 Features Used

-   **Concurrency Safety**: `nonisolated(unsafe)` for GTK global state
-   **C Interoperability**: Direct GTK4 C API integration
-   **Modern Memory Management**: Reference counting with GTK objects
-   **Type Safety**: Swift's safety features where applicable with C interop

### Adding Features

1. **UI Changes**: Modify `main.swift` to add GTK4 widgets and callbacks
2. **Data Operations**: Extend `NotesManager.swift` for new storage features
3. **Styling**: Update `styles.css` for visual customizations
4. **Build System**: Update `Package.swift` for new dependencies

### Debugging

```bash
# Verbose build output
swift build -v

# Check GTK4 installation
pkg-config --cflags --libs gtk4

# Verify Swift version (should be 6.0+)
swift --version

# If using Swiftly, manage Swift versions
swiftly list           # Show installed versions
swiftly use latest     # Use latest Swift version
swiftly install 6.0    # Install specific version

# Clean and rebuild if needed
swift package clean && swift build
```

## 🚀 Automated Releases

This project uses GitHub Actions for automated cross-platform builds and releases across all supported Linux distributions and macOS.

### Creating a Release

Create a new release with comprehensive platform coverage:

```bash
# Tag a new version
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically:

-   ✅ Build for all supported platforms
-   ✅ Create platform-specific installers
-   ✅ Generate distribution packages
-   ✅ Upload all assets to GitHub Release

### Supported Platforms & Package Formats

**Linux Distributions:**

-   **Ubuntu**: `.deb` packages + tarballs
-   **Debian**: `.deb` packages + tarballs
-   **Fedora**: `.rpm` packages + tarballs
-   **Arch Linux**: `.pkg.tar.zst` packages + tarballs
-   **openSUSE**: `.rpm` packages + tarballs
-   **Alpine Linux**: Portable tarballs with install scripts

**macOS:**

-   **macOS**: `.app` bundles + tarballs

### Release Assets

Each release includes comprehensive platform coverage:

**Linux Packages:**

-   `notes-manager-desktop-{version}-ubuntu.deb` - Ubuntu/Debian package
-   `notes-manager-desktop-{version}-fedora.rpm` - Fedora/RHEL package
-   `notes-manager-desktop-{version}-opensuse.rpm` - openSUSE package
-   `notes-manager-desktop-{version}-arch.pkg.tar.zst` - Arch Linux package

**Distribution Tarballs:**

-   `notes-manager-desktop-{version}-linux-ubuntu-x64.tar.gz` - Ubuntu binary
-   `notes-manager-desktop-{version}-linux-debian-x64.tar.gz` - Debian binary
-   `notes-manager-desktop-{version}-linux-fedora-x64.tar.gz` - Fedora binary
-   `notes-manager-desktop-{version}-ubuntu.deb` - Ubuntu/Debian package
-   `notes-manager-desktop-{version}-fedora.rpm` - Fedora/RHEL package
-   `notes-manager-desktop-{version}-arch.pkg.tar.zst` - Arch Linux package
-   `notes-manager-desktop-{version}-linux-ubuntu-x64.tar.gz` - Ubuntu binary
-   `notes-manager-desktop-{version}-linux-fedora-x64.tar.gz` - Fedora binary
-   `notes-manager-desktop-{version}-linux-arch-x64.tar.gz` - Arch Linux binary
-   `notes-manager-desktop-{version}-macos-arm64.tar.gz` - macOS binary (Apple Silicon)

### Installation Instructions

Each release provides multiple installation options per platform:

**Package Installation (Recommended):**

```bash
# Ubuntu/Debian
sudo dpkg -i notes-manager-desktop-{version}-ubuntu.deb

# Fedora/RHEL
sudo rpm -i notes-manager-desktop-{version}-fedora.rpm

# Arch Linux
sudo pacman -U notes-manager-desktop-{version}-arch.pkg.tar.zst
```

**Manual Installation:**

```bash
# Download and extract tarball for your distribution
tar -xzf notes-manager-desktop-{version}-linux-{distro}-x64.tar.gz
cd notes-manager-desktop-{version}-release
./install.sh
```

**Supported Platforms:**

-   ✅ **Ubuntu 20.04+** - Native `.deb` packages + portable tarballs
-   ✅ **Fedora/RHEL** - Native `.rpm` packages + portable tarballs
-   ✅ **Arch Linux** - Native `.pkg.tar.zst` packages + portable tarballs
-   ✅ **macOS** - Universal app bundles for Apple Silicon

### CI/CD Workflows

Our automated CI/CD pipeline ensures reliable builds across multiple platforms:

#### **CI Workflow**

Runs on every push/PR to main/develop branches:

-   **Ubuntu**: Uses pre-compiled Swiftly binary with caching
-   **Fedora**: Installs Swiftly via Copr repository (fallback to source build)
-   **Arch Linux**: Installs Swiftly from AUR using `yay` package manager
-   **macOS**: Uses pre-compiled Swiftly installer with Homebrew dependencies

#### **Release Workflow**

Triggered by version tags (`v*`) for automated releases:

-   **Cross-platform**: Builds for Ubuntu, Fedora, Arch Linux, and macOS
-   **Native Package Managers**: Uses distribution-specific package managers where possible
-   **Automatic Packaging**: Creates `.deb`, `.rpm`, `.pkg.tar.zst`, and `.tar.gz` archives
-   **GitHub Releases**: Automatically uploads all build artifacts
-   **Version Management**: Respects `.swift-version` file for consistent Swift toolchain

#### **Swiftly Installation Strategy**

Each distribution uses the most appropriate installation method:

-   **Ubuntu/macOS**: Pre-compiled binaries (fast, cached)
-   **Fedora**: Copr community repository → source build fallback
-   **Arch Linux**: AUR package via `yay` → native package management
-   **All platforms**: Respect project's `.swift-version` for consistency

## 🐛 Troubleshooting

### Application Won't Start

```bash
# Verify GTK4 installation
pkg-config --cflags --libs gtk4

# Check Swift version (should be 6.0+)
swift --version

# If using Swiftly, ensure you're using the right version
swiftly list    # Show installed versions
swiftly use latest  # Switch to latest version

# Test with verbose output
.build/debug/notes-manager-desktop --verbose
```

### Build Issues

```bash
# Clean build artifacts
swift package clean

# Rebuild with verbose output
swift build -v

# Check for missing dependencies
./configure.sh
```

### Notes Not Saving

-   ✅ Check file permissions in Documents folder
-   ✅ Verify available disk space
-   ✅ Ensure NotesManager directory is writable
-   ✅ Check console output for error messages

### GTK4 Runtime Warnings

Most GTK4 warnings are informational. To minimize them:

-   Ensure proper widget lifecycle management
-   Use correct GTK4 API calling patterns
-   Check for deprecated function usage

## 🔮 Future Features

Planned enhancements:

-   [ ] **Rich Text Editing**: GTK4 rich text widgets with formatting
-   [ ] **Note Categories**: Organize notes with tags/folders
-   [ ] **Full-text Search**: Search across all note content
-   [ ] **Dark Theme**: GTK4 dark mode support
-   [ ] **Auto-save**: Automatic saving while typing
-   [ ] **Import/Export**: Support for various file formats
-   [ ] **Note Encryption**: Optional security features
-   [ ] **Plugin System**: Extensibility framework

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature-name`
3. **Make** your changes and test thoroughly
4. **Submit** a pull request with clear description
5. **Celebrate** your contribution! 🎉

### Development Guidelines

-   Follow Swift 6.0 conventions and safety features
-   Maintain GTK4 C API integration patterns
-   Update tests and documentation for new features
-   Ensure cross-platform compatibility
-   Run `./configure.sh` to validate environment setup

---

**Built with ❤️ using Swift 6.0 and GTK4**
