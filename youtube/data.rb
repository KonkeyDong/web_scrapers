#!/usr/bin/ruby

# Array format:
#   [0] = youtube url
#   [1] = directory name
#         You can nest directories by separating names with slashes.
#         All files from that URL will be written to the nested folder instead.

# --format bestaudio
AUDIO = [
    ["https://www.youtube.com/user/example_1", "example_1"],
    ["https://www.youtube.com/user/example_1_some_playlist", "example_1/playlist"],
]

# --format bestvideo
VIDEO = [
    ["https://www.youtube.com/user/example_1", "example_1"],
    ["https://www.youtube.com/user/example_1_some_playlist", "example_1/playlist"],
]
