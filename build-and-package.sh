#!/bin/bash

# Build and Create Installer Script
# This script builds the project and creates an installer in one go

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

# Default configuration
BUILD_CONFIG="release"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            BUILD_CONFIG="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "This script builds the project and creates an installer."
            echo ""
            echo "Options:"
            echo "  -c, --config BUILD_CONFIG    Build configuration (debug|release) [default: release]"
            echo "  -h, --help                   Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                          Build and create release installer"
            echo "  $0 -c debug                 Build and create debug installer"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_info "Building and creating installer for $BUILD_CONFIG configuration"
echo "=================================================================="

# Step 1: Build the project
print_info "Step 1: Building the project..."
if swift build -c "$BUILD_CONFIG"; then
    print_success "Build completed successfully"
else
    print_error "Build failed"
    exit 1
fi

# Step 2: Create installer
print_info "Step 2: Creating installer..."
if ./create-installer.sh -c "$BUILD_CONFIG"; then
    print_success "Installer created successfully"
else
    print_error "Installer creation failed"
    exit 1
fi

print_success "All done! Your installer is ready in the ./dist directory"
