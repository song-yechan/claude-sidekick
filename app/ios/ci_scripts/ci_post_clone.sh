#!/bin/sh

# =============================================================================
# Xcode Cloud Post-Clone Script
# =============================================================================
# This script runs automatically after Xcode Cloud clones the repository.
# It installs Flutter, fetches dependencies, and runs pod install.
# =============================================================================

set -e

echo "=============================================="
echo "Xcode Cloud Post-Clone Script"
echo "=============================================="

# Debug: Print environment info
echo ""
echo "=== Environment Info ==="
echo "HOME: $HOME"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "PWD: $(pwd)"
echo "========================"

# -----------------------------------------------------------------------------
# 1. Install Flutter
# -----------------------------------------------------------------------------
echo ""
echo "Step 1: Installing Flutter SDK..."

FLUTTER_HOME="$HOME/flutter"

if [ -d "$FLUTTER_HOME" ]; then
    echo "Flutter already exists, removing..."
    rm -rf "$FLUTTER_HOME"
fi

echo "Cloning Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_HOME"
export PATH="$PATH:$FLUTTER_HOME/bin"

echo "Flutter installed at: $FLUTTER_HOME"
"$FLUTTER_HOME/bin/flutter" --version

# -----------------------------------------------------------------------------
# 2. Determine App Directory
# -----------------------------------------------------------------------------
echo ""
echo "Step 2: Finding Flutter app directory..."

# Repository structure: repository/app/ (Flutter app is in 'app' subdirectory)
APP_DIR="$CI_PRIMARY_REPOSITORY_PATH/app"

echo "Looking for pubspec.yaml at: $APP_DIR"

if [ ! -f "$APP_DIR/pubspec.yaml" ]; then
    echo "ERROR: pubspec.yaml not found at $APP_DIR"
    echo ""
    echo "Repository contents:"
    ls -la "$CI_PRIMARY_REPOSITORY_PATH"
    echo ""
    echo "App directory contents (if exists):"
    ls -la "$APP_DIR" 2>/dev/null || echo "App directory does not exist"
    exit 1
fi

echo "App directory found: $APP_DIR"

# -----------------------------------------------------------------------------
# 3. Flutter Pub Get
# -----------------------------------------------------------------------------
echo ""
echo "Step 3: Getting Flutter dependencies..."

cd "$APP_DIR"
"$FLUTTER_HOME/bin/flutter" pub get

echo "Flutter dependencies installed"

# -----------------------------------------------------------------------------
# 4. Install CocoaPods (if needed)
# -----------------------------------------------------------------------------
echo ""
echo "Step 4: Checking CocoaPods..."

if command -v pod > /dev/null 2>&1; then
    echo "CocoaPods already installed"
else
    echo "Installing CocoaPods via Homebrew..."
    brew install cocoapods
fi

pod --version

# -----------------------------------------------------------------------------
# 5. Pod Install
# -----------------------------------------------------------------------------
echo ""
echo "Step 5: Running pod install..."

cd "$APP_DIR/ios"
pod install --repo-update

echo "Pods installed"

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "Post-clone script completed successfully!"
echo "=============================================="
