#!/bin/sh

# =============================================================================
# Xcode Cloud Post-Clone Script
# =============================================================================
# This script runs automatically after Xcode Cloud clones the repository.
# It installs Flutter, fetches dependencies, and runs pod install.
# =============================================================================

set -e

echo "=============================================="
echo "🚀 Xcode Cloud Post-Clone Script"
echo "=============================================="

# -----------------------------------------------------------------------------
# 1. Install Flutter
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 1: Installing Flutter SDK..."

FLUTTER_VERSION="3.29.2"
FLUTTER_HOME="$HOME/flutter"

if [ -d "$FLUTTER_HOME" ]; then
    echo "Flutter already exists, removing..."
    rm -rf "$FLUTTER_HOME"
fi

git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_HOME"
export PATH="$PATH:$FLUTTER_HOME/bin"

echo "✅ Flutter installed"
flutter --version

# -----------------------------------------------------------------------------
# 2. Determine App Directory
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 2: Finding Flutter app directory..."

# Repository structure: repository/app/ (Flutter app is in 'app' subdirectory)
APP_DIR="$CI_PRIMARY_REPOSITORY_PATH/app"

if [ ! -f "$APP_DIR/pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found at $APP_DIR"
    echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
    ls -la "$CI_PRIMARY_REPOSITORY_PATH"
    exit 1
fi

echo "✅ App directory: $APP_DIR"

# -----------------------------------------------------------------------------
# 3. Flutter Pub Get
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 3: Getting Flutter dependencies..."

cd "$APP_DIR"
flutter pub get

echo "✅ Flutter dependencies installed"

# -----------------------------------------------------------------------------
# 4. Install CocoaPods
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 4: Installing CocoaPods..."

if ! command -v pod &> /dev/null; then
    brew install cocoapods
fi

echo "✅ CocoaPods ready"
pod --version

# -----------------------------------------------------------------------------
# 5. Pod Install
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 5: Running pod install..."

cd "$APP_DIR/ios"
pod install --repo-update

echo "✅ Pods installed"

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "✅ Post-clone script completed successfully!"
echo "=============================================="
