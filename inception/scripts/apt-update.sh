#!/bin/bash

echo "Updating package lists..."
sudo apt update && sudo apt upgrade -y && sudo apt install -y
