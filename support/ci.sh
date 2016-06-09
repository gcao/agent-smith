#!/bin/bash

set -e

source $HOME/.rvm/scripts/rvm
rvm use 2.2.3@agent-smith
bundle install

# PROC_NAME is a unique string to be used by kill command
export PROC_NAME=agent-smith
export PROCESS=`ps aux | grep $PROC_NAME | grep -v grep | awk '{print $2}'`
test -n "$PROCESS" && kill -9 $PROCESS

# https://wiki.jenkins-ci.org/display/JENKINS/ProcessTreeKiller
BUILD_ID=dontKillMe bundle exec ruby main.rb $PROC_NAME > app.log 2>&1 &

