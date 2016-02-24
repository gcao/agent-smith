#!/bin/bash

set -e

source $HOME/.rvm/scripts/rvm
rvm use 2.2.3@mr-smith
bundle install

# PROC_NAME is a unique string to be used by kill command
export PROC_NAME=mr-smith
export PROCESS=`ps aux | grep $PROC_NAME | grep -v grep | cut -b 10-16`
test -n "$PROCESS" && kill -9 $PROCESS

# https://wiki.jenkins-ci.org/display/JENKINS/ProcessTreeKiller
BUILD_ID=dontKillMe bundle exec ruby main.rb $PROC_NAME > app.log 2>&1 &
