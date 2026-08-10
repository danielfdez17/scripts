#!/usr/bin/env python3
# pylint: disable=import-error

"""
This script is designed to download audio from YouTube videos using the pytubefix library.
It reads one URL per line from a file and pauses 1 second between downloads.
"""

from pathlib import Path
from sys import argv
from time import sleep

from pytubefix import YouTube
from pytubefix.cli import on_progress


def read_urls(file_path: Path) -> list[str]:
	with file_path.open("r", encoding="utf-8") as file_handle:
		return [
			line.strip()
			for line in file_handle
			if line.strip() and not line.lstrip().startswith("#")
		]


def download_audio(url: str) -> None:
	yt = YouTube(url, on_progress_callback=on_progress)
	print(yt.title)

	audio_stream = yt.streams.get_audio_only()
	audio_stream.download()


if len(argv) < 2:
	raise SystemExit("Usage: yt_audio_downloader.py <urls_file>")

urls_file = Path(argv[1])
if not urls_file.is_file():
	raise SystemExit(f"File not found: {urls_file}")

urls = read_urls(urls_file)
if not urls:
	raise SystemExit(f"No URLs found in {urls_file}")

# Get the videos that had problems downloading and write them to a backup file
# Handling exceptions during download to ensure the script continues with the next URL

for index, url in enumerate(urls):
	download_audio(url)
	if index < len(urls) - 1:
		sleep(2)
