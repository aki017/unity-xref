#! /bin/sh

if [ `git status --porcelain | wc -l` -eq 0 ]; then
    exit 0
fi

HUB=2.5.1
curl -LO "https://github.com/github/hub/releases/download/v$HUB/hub-linux-amd64-$HUB.tgz"
tar -C "$HOME" -zxf "hub-linux-amd64-$HUB.tgz"
export PATH="$PATH:$HOME/hub-linux-amd64-$HUB/bin"

key=`date "+%Y%m%d%H%M"`
git remote set-url origin https://aki017:$GITHUB_TOKEN@github.com/aki017/unity-xref
git checkout -b pr
git add .
git commit -m "Auto update doc"
git push origin pr:pr-$key
hub pull-request -m "Auto update doc $key" -h pr-$key
