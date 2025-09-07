#!/bin/bash

# Notes Manager Desktop Launcher
# This script launches the native GTK4 Notes Manager application

echo "🚀 Starting Notes Manager Desktop..."

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo "❌ Swift is not installed or not in PATH"
    echo "Please install Swift from https://swift.org/download/"
    exit 1
fi

# Check for GTK4
if ! pkg-config --exists gtk4; then
    echo "❌ GTK4 not found"
    echo ""
    echo "Please install GTK4:"
    echo "  Arch Linux: sudo pacman -S gtk4"
    echo "  Ubuntu/Debian: sudo apt install libgtk-4-dev"
    echo "  macOS: brew install gtk4"
    exit 1
fi

# Build if needed
if [ ! -f ".build/debug/notes-manager-desktop" ]; then
    echo "� Building application..."
    swift build
fi

# Launch the native GTK4 application
echo "�️  Launching GTK4 application..."
swift run

echo "✨ Notes Manager closed"
