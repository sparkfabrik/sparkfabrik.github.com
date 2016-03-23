#!/bin/sh
export GIT_DEPLOY_DIR=output
export GIT_DEPLOY_BRANCH=master
./run.sh hugo --buildDrafts --theme spark -d /output --baseUrl=sparkfabrik.github.io
./git.sh
