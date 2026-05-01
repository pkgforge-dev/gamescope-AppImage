#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q gamescope | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=DUMMY
export DESKTOP=DUMMY
export MAIN_BIN=gamescope
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1

# Deploy dependencies
quick-sharun \
	/usr/bin/gamescope*      \
	/usr/lib/*gamescope*.so* \
	/usr/share/gamescope     \
	/usr/share/vulkan/implicit_layer.d

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# becasue this app launches vkcube and there is no gpu in the CI, we have to
# install vkswrast, we do not normally bundle this since it is slow and has
# a massive dependency to llvm
pacman -S --noconfirm vulkan-swrast vulkan-tools

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage vkcube
