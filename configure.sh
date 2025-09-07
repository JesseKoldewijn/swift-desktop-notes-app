#!/bin/bash

# Platform-aware configuration script for notes-manager-desktop
# This script helps configure the build environment for different platforms
# Note: GTK4 include paths are automatically handled by pkg-config and Swift Package Manager

set -e

echo "🔧 Configuring notes-manager-desktop for $(uname -s)..."

# Detect platform
case "$(uname -s)" in
    Linux*)
        PLATFORM=Linux
        echo "📋 Detected Linux platform"
        
        # Check for GTK4 development packages
        if command -v pkg-config >/dev/null 2>&1; then
            if pkg-config --exists gtk4; then
                GTK_VERSION=$(pkg-config --modversion gtk4)
                GTK_CFLAGS=$(pkg-config --cflags gtk4)
                GTK_LIBS=$(pkg-config --libs gtk4)
                echo "✅ GTK4 found: version $GTK_VERSION"
                echo "   CFLAGS: $GTK_CFLAGS"
                echo "   LIBS: $GTK_LIBS"
            else
                echo "❌ GTK4 not found. Please install:"
                echo "   Ubuntu/Debian: sudo apt install libgtk-4-dev"
                echo "   Fedora/RHEL: sudo yum install gtk4-devel"
                echo "   Arch Linux: sudo pacman -S gtk4"
                exit 1
            fi
        else
            echo "⚠️  pkg-config not found. Please install pkg-config"
            exit 1
        fi
        ;;
        
    Darwin*)
        PLATFORM=macOS
        echo "📋 Detected macOS platform"
        
        # Check for Homebrew GTK4
        if command -v brew >/dev/null 2>&1; then
            if brew list gtk4 >/dev/null 2>&1; then
                echo "✅ GTK4 found via Homebrew"
                GTK_PREFIX=$(brew --prefix gtk4)
                echo "   GTK4 prefix: $GTK_PREFIX"
            else
                echo "❌ GTK4 not found. Please install:"
                echo "   brew install gtk4"
                exit 1
            fi
        else
            echo "⚠️  Homebrew not found. Please install Homebrew or GTK4 manually"
            exit 1
        fi
        ;;
        
    MINGW*|MSYS*|CYGWIN*)
        PLATFORM=Windows
        echo "📋 Detected Windows platform (MSYS2/Cygwin)"
        
        # Check for GTK4 in MSYS2
        if command -v pkg-config >/dev/null 2>&1; then
            if pkg-config --exists gtk4; then
                GTK_VERSION=$(pkg-config --modversion gtk4)
                GTK_CFLAGS=$(pkg-config --cflags gtk4)
                GTK_LIBS=$(pkg-config --libs gtk4)
                echo "✅ GTK4 found: version $GTK_VERSION"
                echo "   CFLAGS: $GTK_CFLAGS"
                echo "   LIBS: $GTK_LIBS"
            else
                echo "❌ GTK4 not found. Please install:"
                echo "   MSYS2: pacman -S mingw-w64-x86_64-gtk4 mingw-w64-x86_64-pkg-config"
                exit 1
            fi
        else
            echo "❌ pkg-config not found. Please install:"
            echo "   MSYS2: pacman -S mingw-w64-x86_64-pkg-config"
            exit 1
        fi
        ;;
        
    *)
        echo "❓ Unknown platform: $(uname -s)"
        echo "⚠️  Proceeding with default configuration"
        PLATFORM=Unknown
        ;;
esac

# Validate Swift installation
if command -v swift >/dev/null 2>&1; then
    SWIFT_VERSION=$(swift --version | head -n1)
    echo "✅ Swift found: $SWIFT_VERSION"
else
    # In CI environments, Swift might be installed but not in current PATH
    if [ -n "$GITHUB_ACTIONS" ]; then
        echo "⚠️  Swift not found in current PATH, but this is a CI environment"
        echo "   Swift should be available in the build environment"
    else
        echo "❌ Swift not found. Please install Swift"
        exit 1
    fi
fi

# Update VS Code configuration for better IntelliSense
if [ -f "./update-vscode-config.sh" ]; then
    echo ""
    echo "🔧 Updating VS Code C/C++ configuration..."
    ./update-vscode-config.sh > /dev/null 2>&1 || echo "⚠️  Could not update VS Code config (this is optional)"
fi

echo "🎉 Configuration complete for $PLATFORM!"
echo "💡 You can now run: swift build"
