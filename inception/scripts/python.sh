#!/bin/bash

echo "Checking Python version"
python3 --version

echo "Installing Python pip"
sudo apt install python3-pip -y

echo "Installing distutils"
pip install distutils
