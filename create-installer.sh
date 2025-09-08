#!/bin/bash

# Notes Manager Desktop - Installer Creation Script
# Creates platform-specific installers for debug or release builds

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Notes Manager Desktop"
EXECUTABLE_NAME="notes-manager-desktop"
VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "dev-$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')")DESCRIPTION="A desktop notes management application built with Swift and GTK4"
AUTHOR="Jesse Koldewijn"
HOMEPAGE="https://github.com/JesseKoldewijn/swift-desktop-notes-app"

# Print colored output
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --config BUILD_CONFIG    Build configuration (debug|release) [default: release]"
    echo "  -o, --output OUTPUT_DIR      Output directory for installer [default: ./.packaged]"
    echo "  -h, --help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           Create release installer"
    echo "  $0 -c debug                  Create debug installer"
    echo "  $0 -c release -o /tmp/packaged   Create release installer in /tmp/packaged"
}

# Default values
BUILD_CONFIG="release"
OUTPUT_DIR="./.packaged"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            BUILD_CONFIG="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate build configuration
if [[ "$BUILD_CONFIG" != "debug" && "$BUILD_CONFIG" != "release" ]]; then
    print_error "Invalid build configuration: $BUILD_CONFIG (must be 'debug' or 'release')"
    exit 1
fi

print_info "Creating $BUILD_CONFIG installer for $APP_NAME"
echo "======================================================"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Detect Linux distribution
detect_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            ubuntu|debian) echo "debian" ;;
            fedora|rhel|centos|rocky|alma) echo "redhat" ;;
            arch|manjaro) echo "arch" ;;
            opensuse*|sles) echo "suse" ;;
            alpine) echo "alpine" ;;
            *) echo "$ID" ;;
        esac
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/redhat-release ]]; then
        echo "redhat"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# Get architecture
get_arch() {
    case $(uname -m) in
        x86_64) echo "x86_64" ;;
        aarch64|arm64) echo "arm64" ;;
        armv7l) echo "arm" ;;
        i386|i686) echo "i386" ;;
        *) echo $(uname -m) ;;
    esac
}

OS=$(detect_os)
ARCH=$(get_arch)
DISTRO=""

if [[ "$OS" == "linux" ]]; then
    DISTRO=$(detect_linux_distro)
    print_info "Detected: Linux ($DISTRO) on $ARCH"
else
    print_info "Detected: $OS on $ARCH"
fi

# Find the binary
if [[ "$OS" == "linux" ]]; then
    BINARY_PATH=".build/$ARCH-unknown-linux-gnu/$BUILD_CONFIG/$EXECUTABLE_NAME"
elif [[ "$OS" == "macos" ]]; then
    BINARY_PATH=".build/$ARCH-apple-macosx/$BUILD_CONFIG/$EXECUTABLE_NAME"
else
    print_error "Unsupported OS: $OS"
    exit 1
fi

if [[ ! -f "$BINARY_PATH" ]]; then
    print_error "Binary not found at: $BINARY_PATH"
    print_info "Please build the project first with: swift build -c $BUILD_CONFIG"
    exit 1
fi

print_success "Found binary at: $BINARY_PATH"

# Create output directory
mkdir -p "$OUTPUT_DIR"
INSTALLER_DIR="$OUTPUT_DIR/$EXECUTABLE_NAME-$VERSION-$BUILD_CONFIG"
rm -rf "$INSTALLER_DIR"
mkdir -p "$INSTALLER_DIR"

# Copy binary and resources
print_info "Preparing installer files..."
cp "$BINARY_PATH" "$INSTALLER_DIR/"
chmod +x "$INSTALLER_DIR/$EXECUTABLE_NAME"

# Copy CSS file if it exists
if [[ -f "Sources/$EXECUTABLE_NAME/styles.css" ]]; then
    cp "Sources/$EXECUTABLE_NAME/styles.css" "$INSTALLER_DIR/"
fi

# Create README for installer
cat > "$INSTALLER_DIR/README.txt" << EOF
$APP_NAME - $BUILD_CONFIG Build
===============================

Version: $VERSION
Build: $BUILD_CONFIG
Architecture: $ARCH
Platform: $OS$([ -n "$DISTRO" ] && echo " ($DISTRO)")

Installation Instructions:
-------------------------

EOF

# Create platform-specific installer
create_linux_installer() {
    local distro="$1"
    
    case "$distro" in
        debian)
            create_deb_package
            ;;
        redhat)
            create_rpm_package
            ;;
        arch)
            create_arch_package
            ;;
        *)
            create_generic_linux_installer
            ;;
    esac
}

# Create DEB package for Debian/Ubuntu
create_deb_package() {
    print_info "Creating DEB package..."
    
    local deb_dir="$INSTALLER_DIR/debian"
    mkdir -p "$deb_dir/DEBIAN"
    mkdir -p "$deb_dir/usr/local/bin"
    mkdir -p "$deb_dir/usr/share/applications"
    mkdir -p "$deb_dir/usr/share/doc/$EXECUTABLE_NAME"
    
    # Copy binary
    cp "$BINARY_PATH" "$deb_dir/usr/local/bin/"
    chmod 755 "$deb_dir/usr/local/bin/$EXECUTABLE_NAME"
    
    # Copy resources
    if [[ -f "Sources/$EXECUTABLE_NAME/styles.css" ]]; then
        mkdir -p "$deb_dir/usr/share/$EXECUTABLE_NAME"
        cp "Sources/$EXECUTABLE_NAME/styles.css" "$deb_dir/usr/share/$EXECUTABLE_NAME/"
    fi
    
    # Create control file
    cat > "$deb_dir/DEBIAN/control" << EOF
Package: $EXECUTABLE_NAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: amd64
Depends: libgtk-4-1
Maintainer: $AUTHOR
Description: $DESCRIPTION
Homepage: $HOMEPAGE
EOF
    
    # Create desktop file
    cat > "$deb_dir/usr/share/applications/$EXECUTABLE_NAME.desktop" << EOF
[Desktop Entry]
Name=$APP_NAME
Comment=$DESCRIPTION
Exec=/usr/local/bin/$EXECUTABLE_NAME
Icon=text-editor
Terminal=false
Type=Application
Categories=Utility;Office;
EOF
    
    # Create copyright file
    cat > "$deb_dir/usr/share/doc/$EXECUTABLE_NAME/copyright" << EOF
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: $EXECUTABLE_NAME
Source: $HOMEPAGE

Files: *
Copyright: $(date +%Y) $AUTHOR
License: MIT
EOF
    
    # Build DEB package
    if command -v dpkg-deb &> /dev/null; then
        dpkg-deb --build "$deb_dir" "$OUTPUT_DIR/$EXECUTABLE_NAME-${VERSION}_amd64.deb"
        print_success "DEB package created: $OUTPUT_DIR/$EXECUTABLE_NAME-${VERSION}_amd64.deb"
        
        echo "sudo dpkg -i $EXECUTABLE_NAME-${VERSION}_amd64.deb" >> "$INSTALLER_DIR/README.txt"
        echo "sudo apt-get install -f  # Fix dependencies if needed" >> "$INSTALLER_DIR/README.txt"
    else
        print_warning "dpkg-deb not found, creating generic installer instead"
        create_generic_linux_installer
    fi
}

# Create RPM package for Red Hat/Fedora
create_rpm_package() {
    print_info "Creating RPM package..."
    
    if command -v rpmbuild &> /dev/null; then
        local rpm_dir="$INSTALLER_DIR/rpm"
        mkdir -p "$rpm_dir"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
        
        # Create spec file
        cat > "$rpm_dir/SPECS/$EXECUTABLE_NAME.spec" << EOF
Name: $EXECUTABLE_NAME
Version: $VERSION
Release: 1%{?dist}
Summary: $DESCRIPTION
License: MIT
URL: $HOMEPAGE
BuildArch: x86_64
Requires: gtk4

%description
$DESCRIPTION

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/share/applications
cp $PWD/$BINARY_PATH %{buildroot}/usr/local/bin/
chmod 755 %{buildroot}/usr/local/bin/$EXECUTABLE_NAME

cat > %{buildroot}/usr/share/applications/$EXECUTABLE_NAME.desktop << EOL
[Desktop Entry]
Name=$APP_NAME
Comment=$DESCRIPTION
Exec=/usr/local/bin/$EXECUTABLE_NAME
Icon=text-editor
Terminal=false
Type=Application
Categories=Utility;Office;
EOL

%files
/usr/local/bin/$EXECUTABLE_NAME
/usr/share/applications/$EXECUTABLE_NAME.desktop

%changelog
* $(date +'%a %b %d %Y') $AUTHOR - $VERSION-1
- Initial package
EOF
        
        rpmbuild --define "_topdir $rpm_dir" -bb "$rpm_dir/SPECS/$EXECUTABLE_NAME.spec"
        
        # Find and copy the created RPM
        local rpm_file=$(find "$rpm_dir/RPMS" -name "*.rpm" | head -n1)
        if [[ -n "$rpm_file" ]]; then
            cp "$rpm_file" "$OUTPUT_DIR/"
            print_success "RPM package created: $OUTPUT_DIR/$(basename "$rpm_file")"
            echo "sudo rpm -i $(basename "$rpm_file")" >> "$INSTALLER_DIR/README.txt"
        fi
    else
        print_warning "rpmbuild not found, creating generic installer instead"
        create_generic_linux_installer
    fi
}

# Create Arch package
create_arch_package() {
    print_info "Creating Arch package..."
    
    if command -v makepkg &> /dev/null; then
        local arch_dir="$INSTALLER_DIR/arch"
        mkdir -p "$arch_dir"
        
        # Create PKGBUILD
        cat > "$arch_dir/PKGBUILD" << EOF
# Maintainer: $AUTHOR
pkgname=$EXECUTABLE_NAME
pkgver=$VERSION
pkgrel=1
pkgdesc="$DESCRIPTION"
arch=('x86_64')
url="$HOMEPAGE"
license=('MIT')
depends=('gtk4')
source=()

package() {
    install -Dm755 "$PWD/$BINARY_PATH" "\$pkgdir/usr/local/bin/$EXECUTABLE_NAME"
    
    # Desktop file
    install -Dm644 /dev/stdin "\$pkgdir/usr/share/applications/$EXECUTABLE_NAME.desktop" << EOL
[Desktop Entry]
Name=$APP_NAME
Comment=$DESCRIPTION
Exec=/usr/local/bin/$EXECUTABLE_NAME
Icon=text-editor
Terminal=false
Type=Application
Categories=Utility;Office;
EOL
}
EOF
        
        (cd "$arch_dir" && makepkg -f)
        
        # Find and copy the created package
        local pkg_file=$(find "$arch_dir" -name "*.pkg.tar.*" | head -n1)
        if [[ -n "$pkg_file" ]]; then
            cp "$pkg_file" "$OUTPUT_DIR/"
            print_success "Arch package created: $OUTPUT_DIR/$(basename "$pkg_file")"
            echo "sudo pacman -U $(basename "$pkg_file")" >> "$INSTALLER_DIR/README.txt"
        fi
    else
        print_warning "makepkg not found, creating generic installer instead"
        create_generic_linux_installer
    fi
}

# Create generic Linux installer
create_generic_linux_installer() {
    print_info "Creating generic Linux installer..."
    
    # Create install script
    cat > "$INSTALLER_DIR/install.sh" << 'EOF'
#!/bin/bash

set -e

APP_NAME="Notes Manager Desktop"
EXECUTABLE_NAME="notes-manager-desktop"
INSTALL_DIR="/usr/local/bin"
APPLICATIONS_DIR="/usr/share/applications"

echo "Installing $APP_NAME..."

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Install binary
$SUDO cp "./$EXECUTABLE_NAME" "$INSTALL_DIR/"
$SUDO chmod 755 "$INSTALL_DIR/$EXECUTABLE_NAME"

# Install desktop file
$SUDO mkdir -p "$APPLICATIONS_DIR"
$SUDO tee "$APPLICATIONS_DIR/$EXECUTABLE_NAME.desktop" > /dev/null << EOL
[Desktop Entry]
Name=$APP_NAME
Comment=A desktop notes management application
Exec=$INSTALL_DIR/$EXECUTABLE_NAME
Icon=text-editor
Terminal=false
Type=Application
Categories=Utility;Office;
EOL

echo "✅ Installation complete!"
echo "You can now run the application with: $EXECUTABLE_NAME"
echo "Or find it in your application menu."
EOF
    
    chmod +x "$INSTALLER_DIR/install.sh"
    
    # Create uninstall script
    cat > "$INSTALLER_DIR/uninstall.sh" << 'EOF'
#!/bin/bash

EXECUTABLE_NAME="notes-manager-desktop"
INSTALL_DIR="/usr/local/bin"
APPLICATIONS_DIR="/usr/share/applications"

echo "Uninstalling Notes Manager Desktop..."

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Remove binary
$SUDO rm -f "$INSTALL_DIR/$EXECUTABLE_NAME"

# Remove desktop file
$SUDO rm -f "$APPLICATIONS_DIR/$EXECUTABLE_NAME.desktop"

echo "✅ Uninstall complete!"
EOF
    
    chmod +x "$INSTALLER_DIR/uninstall.sh"
    
    echo "./install.sh" >> "$INSTALLER_DIR/README.txt"
    echo "" >> "$INSTALLER_DIR/README.txt"
    echo "To uninstall: ./uninstall.sh" >> "$INSTALLER_DIR/README.txt"
    
    print_success "Generic Linux installer created"
}

# Create macOS installer
create_macos_installer() {
    print_info "Creating macOS installer..."
    
    local app_dir="$INSTALLER_DIR/$APP_NAME.app"
    mkdir -p "$app_dir/Contents/MacOS"
    mkdir -p "$app_dir/Contents/Resources"
    
    # Copy binary
    cp "$BINARY_PATH" "$app_dir/Contents/MacOS/$EXECUTABLE_NAME"
    chmod +x "$app_dir/Contents/MacOS/$EXECUTABLE_NAME"
    
    # Copy resources
    if [[ -f "Sources/$EXECUTABLE_NAME/styles.css" ]]; then
        cp "Sources/$EXECUTABLE_NAME/styles.css" "$app_dir/Contents/Resources/"
    fi
    
    # Create Info.plist
    cat > "$app_dir/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$EXECUTABLE_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.jessekoldewijn.$EXECUTABLE_NAME</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
</dict>
</plist>
EOF
    
    echo "Drag $APP_NAME.app to your Applications folder" >> "$INSTALLER_DIR/README.txt"
    print_success "macOS app bundle created"
}

# Main installer creation logic
case "$OS" in
    linux)
        create_linux_installer "$DISTRO"
        ;;
    macos)
        create_macos_installer
        ;;
    *)
        print_error "Unsupported operating system: $OS"
        exit 1
        ;;
esac

# Add general information to README
cat >> "$INSTALLER_DIR/README.txt" << EOF

Requirements:
- GTK4 runtime libraries

For more information, visit: $HOMEPAGE
EOF

# Create tarball
print_info "Creating distribution archive..."
ARCHIVE_NAME="$EXECUTABLE_NAME-$VERSION-$BUILD_CONFIG-$OS$([ -n "$DISTRO" ] && echo "-$DISTRO")-$ARCH.tar.gz"
(cd "$OUTPUT_DIR" && tar -czf "$ARCHIVE_NAME" "$(basename "$INSTALLER_DIR")")

print_success "Installer created successfully!"
echo ""
print_info "Output directory: $OUTPUT_DIR"
print_info "Installer directory: $INSTALLER_DIR"
print_info "Archive: $OUTPUT_DIR/$ARCHIVE_NAME"
echo ""
print_info "Check the README.txt file in the installer directory for installation instructions."
