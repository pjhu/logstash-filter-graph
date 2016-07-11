#!/bin/bash -xe

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. "$script_dir"/common.sh #use quote here to compliant with space in dir

docker run \
  -t --rm \
  -v "$project_home":/project \
  -w /project \
  -e "BUILD_NUM=$BUILD_NUM" \
  jruby:9.0.3 \
  scripts/build.sh \
