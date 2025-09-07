#!/bin/bash

# Notes Manager Desktop - Build Script
# This script helps set up and build the Notes Manager desktop application

set -e

echo "🏗️  Notes Manager Desktop Build Script"
echo "======================================"

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed or not in PATH"
    echo "Please install Swift from https://swift.org/download/"
    exit 1
fi

echo "✅ Swift found: $(swift --version | head -n1)"

# Check for GTK4
if ! pkg-config --exists gtk4; then
    echo "❌ GTK4 not found"
    echo ""
    echo "Please install GTK4:"
    echo "  Arch Linux: sudo pacman -S gtk4 gobject-introspection pkgconf"
    echo "  Ubuntu/Debian: sudo apt install libgtk-4-dev gobject-introspection libgirepository1.0-dev"
    echo "  macOS: brew install gtk4 gobject-introspection pkg-config"
    exit 1
fi

echo "✅ GTK4 found: $(pkg-config --modversion gtk4)"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
swift package clean

# Resolve dependencies
echo "📦 Resolving dependencies..."
swift package resolve

# Build the project
echo "🔨 Building project..."
if [ "$1" = "release" ]; then
    echo "Building release version..."
    swift build -c release
    echo "✅ Release build complete!"
    echo "📍 Executable: .build/release/notes-manager-desktop"
else
    echo "Building debug version..."
    swift build
    echo "✅ Debug build complete!"
    echo "📍 Executable: .build/debug/notes-manager-desktop"
fi

echo ""
echo "🎉 Build successful!"
echo ""
echo "To run the application:"
echo "  swift run"
echo ""
echo "Or run the executable directly:"
if [ "$1" = "release" ]; then
    echo "  ./.build/release/notes-manager-desktop"
else
    echo "  ./.build/debug/notes-manager-desktop"
fi
