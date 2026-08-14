#!/usr/bin/env python3
# pylint: disable=import-error

"""
This script is designed to download audio from YouTube videos using the pytubefix library.
It reads one URL per line from a file and pauses between downloads.
Failed downloads are re-queued until they succeed; completed URLs are removed from the input file.
"""

from pathlib import Path
from queue import Empty, Queue
from sys import argv
from time import sleep

from pytubefix import YouTube
from pytubefix.cli import on_progress

MAX_ATTEMPTS_PER_RUN = 3
SLEEP_SECONDS = 3


def read_urls(file_path: Path) -> list[str]:
	with file_path.open("r", encoding="utf-8") as file_handle:
		return [
			line.strip()
			for line in file_handle
			if line.strip() and not line.lstrip().startswith("#")
		]


def remove_url_from_file(file_path: Path, url: str) -> None:
	with file_path.open("r", encoding="utf-8") as file_handle:
		lines = file_handle.readlines()
	remaining = [line for line in lines if line.strip() != url]
	file_path.write_text("".join(remaining), encoding="utf-8")


def download_audio(url: str) -> None:
	yt = YouTube(url, on_progress_callback=on_progress)
	print(yt.title)

	audio_stream = yt.streams.get_audio_only()
	audio_stream.download()


def print_summary(total: int, downloaded: int, failed_urls: list[str]) -> None:
	print("\nSummary")
	print(f"Total videos: {total}")
	print(f"Downloaded: {downloaded}")
	print(f"Could not download: {len(failed_urls)}")
	if failed_urls:
		print("Failed URLs:")
		for url in failed_urls:
			print(f"  {url}")


def process_downloads(urls: list[str], urls_file: Path) -> None:
	download_queue: Queue[str] = Queue()
	for url in urls:
		download_queue.put(url)

	attempts: dict[str, int] = {}
	downloaded = 0
	failed_urls: list[str] = []

	while True:
		try:
			url = download_queue.get_nowait()
		except Empty:
			break
		try:
			download_audio(url)
			remove_url_from_file(urls_file, url)
			downloaded += 1
		except Exception as exc:  # pylint: disable=broad-exception-caught
			attempts[url] = attempts.get(url, 0) + 1
			print(f"Error downloading {url}: {exc}")
			if attempts[url] < MAX_ATTEMPTS_PER_RUN:
				print(
					"Re-queued for retry "
					f"({attempts[url]}/{MAX_ATTEMPTS_PER_RUN})"
				)
				download_queue.put(url)
			else:
				print(
					f"Leaving in {urls_file} after {MAX_ATTEMPTS_PER_RUN} "
					"failed attempts this run"
				)
				failed_urls.append(url)
		if not download_queue.empty():
			sleep(SLEEP_SECONDS)

	print_summary(len(urls), downloaded, failed_urls)


if len(argv) < 2:
	raise SystemExit("Usage: yt_audio_downloader.py <urls_file>")

urls_file = Path(argv[1])
if not urls_file.is_file():
	raise SystemExit(f"File not found: {urls_file}")

urls = read_urls(urls_file)
if not urls:
	raise SystemExit(f"No URLs found in {urls_file}")

process_downloads(urls, urls_file)
