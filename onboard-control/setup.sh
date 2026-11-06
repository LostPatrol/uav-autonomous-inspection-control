#!/usr/bin/env bash
# Install native build prerequisites and compile the onboard control software.
set -eo pipefail
root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
sudo apt-get update
sudo apt-get install -y build-essential cmake python3-colcon-common-extensions \
  libeigen3-dev nlohmann-json3-dev ros-jazzy-mavros ros-jazzy-geographic-msgs \
  ros-jazzy-ament-cmake-gtest
exec "${root}/build.sh"
