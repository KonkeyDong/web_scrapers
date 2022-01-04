module Config
    YOUTUBE_DL_BASE = "/usr/local/bin/yt-dlp --ignore-errors"
    HDD_DESTINATION_BASE = "/media/HDD_4TB_01/YouTube"
    DESIRED_FILE_FORMAT = "%(upload_date)s_%(title)s.%(ext)s"
    #AUDIO_FORMAT = "--format bestaudio --extract-audio --audio-format mp3"
    AUDIO_FORMAT = "--format bestaudio"
end
