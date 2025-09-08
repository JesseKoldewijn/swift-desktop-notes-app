# Notes Manager Desktop

A modern cross-platform desktop notes application built with Sw### 🎯 Alternative Scripts

The project includes convenient scripts:

```bash
# Build with optimizations
./build.sh

# Launch the application
./launch.sh

# Create a release build
./create-release.sh
```

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

## 📦 Status

<p>
    <a href="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/ci.yml">
        <img src="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/ci.yml/badge.svg" alt="CI">
    </a>
    <a href="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/release.yml">
        <img src="https://github.com/JesseKoldewijn/swift-desktop-notes-app/actions/workflows/release.yml/badge.svg" alt="Build and Release">
    </a>
</p>

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

This project uses GitHub Actions for automated cross-platform builds and releases.

### Creating a Release

Create a new release with cross-platform binaries:

```bash
# Tag a new version
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically:

-   ✅ Build for Linux and macOS
-   ✅ Create a new GitHub release
-   ✅ Upload binaries as release assets

### Release Assets

Each release includes:

-   `notes-manager-desktop-linux-x64.tar.gz` - Linux binary
-   `notes-manager-desktop-macos-x64.tar.gz` - macOS binary

### CI/CD Workflows

-   **CI Workflow**: Runs on every push/PR to main/develop branches
-   **Release Workflow**: Triggered by version tags (`v*`) for automated releases

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
