#!/bin/bash

# Script to update VS Code C/C++ configuration with GTK4 include paths
# This ensures VS Code IntelliSense can find GTK4 headers

set -e

echo "🔧 Updating VS Code C/C++ configuration for GTK4..."

# Check if pkg-config and gtk4 are available
if ! command -v pkg-config >/dev/null 2>&1; then
    echo "❌ pkg-config not found. Please install pkg-config"
    exit 1
fi

if ! pkg-config --exists gtk4; then
    echo "❌ GTK4 not found. Please install GTK4 development packages"
    exit 1
fi

# Get GTK4 include paths
GTK_CFLAGS=$(pkg-config --cflags gtk4)
echo "📋 GTK4 CFLAGS: $GTK_CFLAGS"

# Extract include paths (remove -I prefix and filter only include paths)
INCLUDE_PATHS=$(echo "$GTK_CFLAGS" | grep -o -- '-I[^[:space:]]*' | sed 's/^-I//' | sort | uniq)

echo "📁 Detected include paths:"
echo "$INCLUDE_PATHS" | sed 's/^/   /'

# Create the includePath JSON array
INCLUDE_PATH_JSON=$(echo "$INCLUDE_PATHS" | sed 's/^/                "/' | sed 's/$/",/')

# Create .vscode directory if it doesn't exist
mkdir -p .vscode

# Generate the c_cpp_properties.json file
cat > .vscode/c_cpp_properties.json << EOF
{
    "configurations": [
        {
            "name": "Linux",
            "includePath": [
                "\${workspaceFolder}/**",
$INCLUDE_PATH_JSON
            ],
            "defines": [],
            "compilerPath": "/usr/bin/gcc",
            "cStandard": "c17",
            "cppStandard": "gnu++17",
            "intelliSenseMode": "linux-gcc-x64"
        }
    ],
    "version": 4
}
EOF

echo "✅ Updated .vscode/c_cpp_properties.json with GTK4 include paths"
echo "🎉 VS Code IntelliSense should now work correctly with GTK4 headers"
echo ""
echo "💡 If you still see warnings, try:"
echo "   1. Reload VS Code window (Ctrl+Shift+P -> 'Developer: Reload Window')"
echo "   2. Or restart the C/C++ extension"
