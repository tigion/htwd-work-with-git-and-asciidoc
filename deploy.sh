#!/usr/bin/env bash

# This script deploys the contents of the 'build' folder
# via rsync to the web server.

# Sets the build folder.
build_folder="build"

# Ensures that the script runs from its own folder.
if ! cd "$(dirname "$0")"; then exit; fi

# Runs the build script if needed.
if [ "$1" = "--build" ]; then
  ./build.sh
fi

# Checks the build folder.
if [ ! -d "$build_folder" ]; then
  echo "Error: Build folder '$build_folder' does not exist. Run the build script first."
  exit 1
fi

# Sets the host and target folder.
host="ilux150"
target_folder="~/upload_arbeiten-mit-git-und-asciidoc"
git_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$git_branch" = "next" ]; then
  target_folder="${target_folder}_next"
fi

# Uploads the content of the build folder to the web server.
echo "Upload to server:"
if [ "$(uname -s)" = "Darwin" ]; then
  rsync --delete -avze ssh "$build_folder/" "$host:$target_folder/" --exclude=".*" --exclude="files/*" --exclude="images/videos/*" --chmod=Du+rwx,Dgo+x,Fu+rw,Fgo+r #macOS
else
  rsync --delete -avze ssh "$build_folder/" "$host:$target_folder/" --exclude=".*" --exclude="files/*" --exclude="images/videos/*" --chmod=D0711,F0644 #Linux
fi
