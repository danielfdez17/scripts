#!/bin/bash

set -e

updating_msg="Updating submodules..."
print_info "$updating_msg" || echo "$updating_msg"
git submodule update --init --recursive --remote

echo 
success_msg="Successfully updated submodules."
print_ok "$success_msg" || echo "$success_msg"