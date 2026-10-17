#!/usr/bin/bash

set -e

readme=README.md

# todo: Get usernames as parameters
usernames=login1,login2

{
    echo "*This project has been created as part of the 42 curriculum by $usernames*";
    echo;
    echo "# Description";
    echo
    echo
    echo
    echo "# Instructions"
    echo
    echo
    echo
    echo "# Resources"
    } > $readme





