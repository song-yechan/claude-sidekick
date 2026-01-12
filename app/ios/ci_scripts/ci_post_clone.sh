#!/bin/sh

# =============================================================================
# Xcode Cloud Post-Clone Script for Flutter
# =============================================================================

# Exit on error, but print what failed
set -e
trap 'echo "ERROR: Script failed at line $LINENO"' ERR

echo "=============================================="
echo "Xcode Cloud Post-Clone Script"
echo "=============================================="

# -----------------------------------------------------------------------------
# 0. Determine paths from script location
# -----------------------------------------------------------------------------
echo ""
echo "Step 0: Determining paths..."

# Script is at: app/ios/ci_scripts/ci_post_clone.sh
# So app directory is 2 levels up from script location
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IOS_DIR="$(dirname "$SCRIPT_DIR")"
APP_DIR="$(dirname "$IOS_DIR")"

echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "IOS_DIR: $IOS_DIR"
echo "APP_DIR: $APP_DIR"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "CI_WORKSPACE: $CI_WORKSPACE"

# Verify app directory
if [ ! -f "$APP_DIR/pubspec.yaml" ]; then
    echo "ERROR: pubspec.yaml not found at $APP_DIR"
    echo "Contents of APP_DIR:"
    ls -la "$APP_DIR" 2>/dev/null || echo "Directory does not exist"
    exit 1
fi
echo "App directory verified: $APP_DIR"

# -----------------------------------------------------------------------------
# 1. Install Flutter
# -----------------------------------------------------------------------------
echo ""
echo "Step 1: Installing Flutter SDK..."

FLUTTER_HOME="$HOME/flutter"

# Clean up existing Flutter
if [ -d "$FLUTTER_HOME" ]; then
    echo "Removing existing Flutter..."
    rm -rf "$FLUTTER_HOME"
fi

# Clone Flutter
echo "Cloning Flutter (this may take a few minutes)..."
if ! git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_HOME"; then
    echo "ERROR: Failed to clone Flutter"
    exit 1
fi

export PATH="$PATH:$FLUTTER_HOME/bin"
echo "Flutter PATH added"

# Verify Flutter
echo "Verifying Flutter installation..."
"$FLUTTER_HOME/bin/flutter" --version
"$FLUTTER_HOME/bin/flutter" doctor -v

# -----------------------------------------------------------------------------
# 2. Flutter Pub Get
# -----------------------------------------------------------------------------
echo ""
echo "Step 2: Getting Flutter dependencies..."

cd "$APP_DIR"
echo "Working directory: $(pwd)"

"$FLUTTER_HOME/bin/flutter" pub get
echo "Flutter dependencies installed"

# -----------------------------------------------------------------------------
# 3. Precache iOS artifacts
# -----------------------------------------------------------------------------
echo ""
echo "Step 3: Precaching iOS artifacts..."

"$FLUTTER_HOME/bin/flutter" precache --ios
echo "iOS artifacts cached"

# -----------------------------------------------------------------------------
# 4. CocoaPods
# -----------------------------------------------------------------------------
echo ""
echo "Step 4: Setting up CocoaPods..."

# Check if pod is available
if ! command -v pod > /dev/null 2>&1; then
    echo "Installing CocoaPods..."
    brew install cocoapods
fi

echo "CocoaPods version:"
pod --version

# -----------------------------------------------------------------------------
# 5. Pod Install
# -----------------------------------------------------------------------------
echo ""
echo "Step 5: Running pod install..."

cd "$IOS_DIR"
echo "Working directory: $(pwd)"

# List Podfile to verify
if [ ! -f "Podfile" ]; then
    echo "ERROR: Podfile not found in $IOS_DIR"
    ls -la
    exit 1
fi

pod install --repo-update
echo "Pods installed successfully"

# -----------------------------------------------------------------------------
# 6. Create .env file (for Xcode Cloud)
# -----------------------------------------------------------------------------
echo ""
echo "Step 6: Creating .env file..."

cd "$APP_DIR"

# .env 파일이 없으면 .env.prod를 복사 (프로덕션 빌드용)
if [ ! -f ".env" ]; then
    if [ -f ".env.prod" ]; then
        cp .env.prod .env
        echo ".env file created from .env.prod"
    else
        # .env.prod도 없으면 빈 파일 생성
        touch .env
        echo "Empty .env file created"
    fi
else
    echo ".env file already exists"
fi

# -----------------------------------------------------------------------------
# 7. Flutter Build iOS (for Xcode Cloud)
# -----------------------------------------------------------------------------
echo ""
echo "Step 7: Building Flutter iOS..."

cd "$APP_DIR"
echo "Working directory: $(pwd)"

# Build Flutter iOS (config only - let Xcode do the actual build)
"$FLUTTER_HOME/bin/flutter" build ios --release --no-codesign
echo "Flutter iOS build completed"

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "Post-clone script completed successfully!"
echo "=============================================="
