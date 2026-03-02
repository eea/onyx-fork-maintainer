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

echo "Cloning EEA fork from $EEA_REPO into $TARGET_DIR..."
if [ -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR already exists."
    exit 1
fi

git clone "$EEA_REPO" "$TARGET_DIR"
cd "$TARGET_DIR"

echo "Checking out main branch: $MAIN_BRANCH..."
git checkout "$MAIN_BRANCH"

echo "Adding upstream Onyx repository as 'onyx': $ONYX_REPO..."
# We use 'onyx' as the remote name for the upstream to be compatible with merge scripts.
git remote add onyx "$ONYX_REPO"

echo "Fetching tags from upstream (without fetching all branches)..."
# We fetch tags so they are available for merging.
# To avoid fetching all branches, we use --no-tags in the remote config and fetch tags explicitly.
git config remote.onyx.tagOpt --no-tags
git fetch onyx --tags --no-recurse-submodules

echo "Linking maintainer scripts to $TARGET_DIR/eea-artifacts..."
# Create a symlink so the merge scripts can be called as eea-artifacts/scripts/...
ln -s "$MAINTAINER_DIR" "eea-artifacts"

echo ""
echo "Bootstrap complete!"
echo "Target directory: $TARGET_DIR"
echo "Upstream remote: onyx ($ONYX_REPO)"
echo "Main branch: $MAIN_BRANCH"
echo "Maintainer scripts linked at: $TARGET_DIR/eea-artifacts"
echo ""
echo "To start a merge, you can now run:"
echo "  cd $TARGET_DIR"
echo "  python3 eea-artifacts/scripts/eea_merge_master.py <target_tag>"
