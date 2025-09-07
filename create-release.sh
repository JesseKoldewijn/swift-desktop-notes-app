#!/bin/bash

# Release script for Notes Manager Desktop
# Usage: ./create-release.sh <version>
# Example: ./create-release.sh 1.0.0

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

VERSION="$1"

# Validate semantic versioning format
# Pattern: MAJOR.MINOR.PATCH[-prerelease][+build]
# Examples: 1.0.0, 1.2.3-alpha.1, 1.0.0+build.123, 1.2.3-beta.2+exp.sha.5114f85
SEMVER_REGEX='^([0-9]+)\.([0-9]+)\.([0-9]+)(-[a-zA-Z0-9\-\.]+)?(\+[a-zA-Z0-9\-\.]+)?$'

if ! [[ $VERSION =~ $SEMVER_REGEX ]]; then
    echo "❌ Invalid version format: ${VERSION}"
    echo "📋 Version must follow semantic versioning (semver) format:"
    echo "   Examples:"
    echo "   - 1.0.0"
    echo "   - 1.2.3"
    echo "   - 2.0.0-alpha.1"
    echo "   - 1.5.2-beta.3+build.123"
    echo "   - 3.1.0+exp.sha.5114f85"
    exit 1
fi

TAG="v${VERSION}"

echo "📝 Preparing to create release with tag: ${TAG}"
git fetch --prune --prune-tags

echo "🚀 Creating release ${TAG}..."

# Check if tag already exists
if git tag -l | grep -q "^${TAG}$"; then
    echo "❌ Tag ${TAG} already exists!"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Warning: You're not on the main branch (currently on: $CURRENT_BRANCH)"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "❌ You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Create and push tag
echo "📦 Creating tag ${TAG}..."
git tag -a "${TAG}" -m "Release ${TAG}"

echo "🔄 Pushing tag to origin..."
git push origin "${TAG}"

echo "✅ Release ${TAG} created successfully!"
echo "🔗 GitHub Actions will now build and create the release automatically."
echo "📈 Monitor progress at: https://github.com/$(git config --get remote.origin.url | sed 's/.*github\.com[:\/]\([^\/]*\/[^\/]*\)\.git/\1/')/actions"
