#!/usr/bin/env python3
# pylint: disable=import-error

"""
This script is designed to download videos from a YouTube video using the pytubefix library.
"""

from sys import argv
from pytubefix import YouTube
from pytubefix.cli import on_progress

URL = argv[1] if len(argv) > 1 else input("Enter YouTube video URL: ")

yt = YouTube(URL, on_progress_callback=on_progress)
print(yt.title)

ys = yt.streams.get_highest_resolution()
ys.download()
