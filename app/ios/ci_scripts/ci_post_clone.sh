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
# 2. Flutter Pub Get
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 2: Getting Flutter dependencies..."

cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

echo "✅ Flutter dependencies installed"

# -----------------------------------------------------------------------------
# 3. Install CocoaPods
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 3: Installing CocoaPods..."

if ! command -v pod &> /dev/null; then
    brew install cocoapods
fi

echo "✅ CocoaPods ready"
pod --version

# -----------------------------------------------------------------------------
# 4. Pod Install
# -----------------------------------------------------------------------------
echo ""
echo "📦 Step 4: Running pod install..."

cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install --repo-update

echo "✅ Pods installed"

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "✅ Post-clone script completed successfully!"
echo "=============================================="
