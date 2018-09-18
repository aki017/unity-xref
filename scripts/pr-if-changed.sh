#! /bin/sh

if [ `git status --porcelain | wc -l` -eq 0 ]; then
    exit 0
fi

HUB=2.5.1
curl -LO "https://github.com/github/hub/releases/download/v$HUB/hub-linux-amd64-$HUB.tgz"
tar -C "$HOME" -zxf "hub-linux-amd64-$HUB.tgz"
export PATH="$PATH:$HOME/hub-linux-amd64-$HUB/bin"

key=`date "+%Y%m%d%H%M"`
git config --global user.name  "aki017"
git config --global user.email "aki017@users.noreply.github.com"
git remote set-url origin https://aki017:$GITHUB_TOKEN@github.com/aki017/unity-xref
git checkout -b pr
git add .
git commit -m "Auto update doc"
git push origin pr:pr-$UNITY_VERSION-$key
hub pull-request -m "Auto update doc $UNITY_VERSION $key" -h pr-$UNITY_VERSION-$key
