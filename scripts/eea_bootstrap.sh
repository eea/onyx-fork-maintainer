#!/bin/bash
set -e

# EEA Fork Bootstrap Script
# This script sets up a local copy of the EEA fork of Onyx (Danswer)
# and configures the upstream Onyx repository.

EEA_REPO="git@github.com:eea/danswer.git"
ONYX_REPO="git@github.com:onyx-dot-app/onyx.git"
MAIN_BRANCH="eea"
TARGET_DIR="danswer-eea"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the root directory of the current maintainer repository
MAINTAINER_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET_TAG=$1

if [ -z "$TARGET_TAG" ]; then
    echo "No Onyx tag provided. Fetching latest releases from onyx-dot-app/onyx..."
    
    # Try to use gh CLI to get the latest releases
    if command -v gh >/dev/null 2>&1; then
        TAGS=$(gh release list --repo onyx-dot-app/onyx --limit 10 | awk '{print $1}')
    fi

    # Fallback to git ls-remote if gh failed or returned nothing
    if [ -z "$TAGS" ]; then
        echo "Warning: Could not fetch releases using 'gh'. Falling back to git ls-remote (this may be slower)..."
        TAGS=$(git ls-remote --tags --sort='-v:refname' "$ONYX_REPO" | awk -F'/' '{print $3}' | grep -v "\^{}" | head -n 10)
    fi

    if [ -z "$TAGS" ]; then
        echo "Error: Could not retrieve tags from $ONYX_REPO."
        exit 1
    fi

    echo "Available Onyx tags:"
    select TAG in $TAGS; do
        if [ -n "$TAG" ]; then
            TARGET_TAG=$TAG
            break
        fi
    done
    
    if [ -z "$TARGET_TAG" ]; then
        echo "Error: No tag selected."
        exit 1
    fi
fi

echo "Selected Onyx target tag: $TARGET_TAG"

echo "Cloning EEA fork (branch: $MAIN_BRANCH) from $EEA_REPO into $TARGET_DIR..."
if [ -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR already exists. Please remove it first if you want a clean bootstrap."
    exit 1
fi

# Optimized clone: single branch, no tags from origin yet
git clone --single-branch --branch "$MAIN_BRANCH" --no-tags "$EEA_REPO" "$TARGET_DIR"
cd "$TARGET_DIR"

echo "Adding upstream Onyx repository as 'onyx': $ONYX_REPO..."
git remote add onyx "$ONYX_REPO"
# Disable automatic tag fetching for the onyx remote to keep it lean
git config remote.onyx.tagOpt --no-tags

echo "Fetching ONLY the target tag $TARGET_TAG from onyx..."
git fetch onyx "tag" "$TARGET_TAG" --no-recurse-submodules --force

echo "Linking maintainer scripts to $TARGET_DIR/eea-artifacts..."
# Create a symlink so the merge scripts can be called as eea-artifacts/scripts/...
ln -s "$MAINTAINER_DIR" "eea-artifacts"

echo ""
echo "Bootstrap complete!"
echo "Target directory: $TARGET_DIR"
echo "Target Onyx tag: $TARGET_TAG"
echo "Main branch: $MAIN_BRANCH"
echo "Maintainer scripts linked at: $TARGET_DIR/eea-artifacts"
echo ""
echo "To start the merge process, run:"
echo "  cd $TARGET_DIR"
echo "  python3 eea-artifacts/scripts/eea_merge_master.py $TARGET_TAG"
