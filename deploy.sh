#!/bin/sh

# cd & check
if ! cd "$(dirname "$0")"; then exit; fi

# check TODO
buildFolder="build";

# check options
# build
if [ "$1" = "--build" -o "$1" = "-b" ]; then
  ./build.sh
fi

# upload to webserver
host="ilux150"
targetFolder="~/upload_arbeiten-mit-git-und-asciidoc"
gitBranch=`git rev-parse --abbrev-ref HEAD`
if [ "$gitBranch" = "next" ]; then
  targetFolder="${targetFolder}_next";
fi
echo "Upload to Server:"
if [ $(uname -s) = "Darwin" ]; then
  rsync --delete -avze ssh "$buildFolder/" "$host:$targetFolder/" --exclude=".*" --exclude="files/*" --exclude="images/videos/*" --chmod=Du+rwx,Dgo+x,Fu+rw,Fgo+r #macOS
else
  rsync --delete -avze ssh "$buildFolder/" "$host:$targetFolder/" --exclude=".*" --exclude="files/*" --exclude="images/videos/*" --chmod=D0711,F0644 #Linux
fi
