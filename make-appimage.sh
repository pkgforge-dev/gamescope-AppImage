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
	/usr/bin/gamescope*                \
	/usr/lib/*gamescope*.so*           \
	/usr/share/gamescope               \
	/usr/share/vulkan/implicit_layer.d \
	/usr/bin/Xwayland

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
#
# simple-test is needed because using vulkan-swrast in the CI results in this error:
# [gamescope] [Info]  vulkan: physical device does not support DRM format modifiers
# [gamescope] [Error] vulkan: physical device doesn't support VK_EXT_physical_device_drm
#
quick-sharun --simple-test ./dist/*.AppImage
