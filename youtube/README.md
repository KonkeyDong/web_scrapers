# Backup Youtube Videos & Audio

A wrapper script to download entire playlists or channels into either (the best possible) audio or video format.

Simply edit the `data.rb` file with URLs and directory names.

Edit the `config.rb` to change configurations, such as base file paths and the file name format of downloading videos.

An `archive.txt` file will be written inside of each folder. This will drastically speed up traversing larger channels.

---

## Command Line Options

Run `ruby download.rb --help` to see a listing of available options.

**Note** on the cookie option: You may need to download your **logged-in user cookie information** and save it to a `.txt` file. [This link](https://apple.stackexchange.com/a/385485) should help you out. Alternatively, you can probably find a plugin/extension to figure this out for you.

---

## Tech Stack
* [youtube-dl](https://youtube-dl.org/) -- Main program to download from Youtube.
* `Ruby 2.7`
  * [byebug](https://rubygems.org/gems/byebug/versions/11.1.3) -- Debugging purposes only.

Simply run `bundle install` to install all required gems.
