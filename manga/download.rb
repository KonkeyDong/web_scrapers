require 'byebug'
require 'fileutils'
require 'ap'
require 'open-uri'
require 'nokogiri'
require 'optparse'
require 'logger'

require_relative './config'
require_relative './stopwatch'

options = {}
OptionParser.new do |opt|
    opt.on('--verbose') { |o| options[:verbose] = o }
end.parse!

LOGGER = Logger.new(STDOUT)
LOGGER.level = options[:verbose] ? Logger::DEBUG : Logger::INFO 

def pre_download(url)
    LOGGER.debug("BEFORE PRE-DOWNLOAD URL [#{url}]...")
    html = Nokogiri::HTML(URI.open(url, read_timeout: READ_TIMEOUT))
    LOGGER.debug("AFTER PRE-DOWNLOAD URL [#{url}] SUCCESS!")
    html.css('.main-content .chp-ls')
        .css('a')
        .reverse
        .each_with_index
        .map do |chapter, index|
             {

                 title: ["chapter", (index + 1).to_s
                                               .rjust(4, "0")]
                                               .join('_'),
                 href: chapter["href"]
             }
        end
end

def download(chapters_and_href, book_name, archive, archive_hash)
    first_write = true
    chapters_downloaded = 0
    chapters_and_href.each_with_index do |data, chapter_index|
        begin
            retries = 10
            STDOUT.flush
            title = data[:title]
            href = data[:href]

            # Skip downloading the chapter/pages if we already have the chapter downloaded!
            if archive_hash[href]
                LOGGER.info("Skipping [#{title}] as it has already been downloaded.")
                next
            end

            directory = [BASE_DIRECTORY_PATH, book_name, title].join("/")
            FileUtils.mkdir_p(directory)

            LOGGER.info("Downloading book #{book_name}, #{title}... (out of #{chapters_and_href.length})")
            LOGGER.info("Book href: #{href}")
            LOGGER.debug("BEFORE EXTRACTING CHAPTER HTML [#{href}]...")
            html = Nokogiri::HTML(URI.open(href, read_timeout: READ_TIMEOUT))
                        .css('.option-item-trigger.chp-page-trigger.chp-selection-item')
            LOGGER.debug("EXTRACTING CHAPTER HTML [#{href}] SUCCESS!")

            archive_flags = []

            # The website doubles the amount of chapter pages in the source code for some reason.
            # So, only take from the first half to avoid doubling the amount of pages in the directory.
            html[0...(html.length / 2)].each_with_index do |page, index|
                page_url = page["option_val"]


                LOGGER.DEBUG("BEFORE OPENING PAGE [#{page_url}]...")
                image_url = Nokogiri::HTML(URI.open(page_url, read_timeout: READ_TIMEOUT))
                                    .css('.manga_pic')
                                    .first["src"]
                LOGGER.DEBUG("OPENING PAGE [#{page_url}] SUCCESS!")
                LOGGER.DEBUG("  image_url = [#{image_url}]")


                file_extension = image_url.match(/\.(\w+)$/)
                                        .captures
                                        .first
                                        .downcase

                file_name = directory + '/' + (index + 1).to_s.rjust(3, "0") + ".#{file_extension}"
                LOGGER.DEBUG("  file_name = [#{file_name}]")

                # avoid re-writing the page
                if File.file?(file_name)
                    LOGGER.info("   File name [#{file_name}] already written; sipping...")
                    next
                else
                    LOGGER.info("   Downloading image from url [#{image_url}]...")
                end

                archive_flags.push write_image(image_url, file_name, directory, href)
            end

            # update the archive file
            unless archive_flags.include?(false)
                File.write(archive, "#{href}\n", mode: 'a')
            else
                LOGGER.info("Skipping writing to archive...")
            end

            chapters_downloaded += 1
        rescue Exception => e
            LOGGER.warn("Exception: #{e.message}")
            LOGGER.warn("waiting 5 seconds and then retrying...")
            sleep(5) # seconds
            
            if retries > 0
                LOGGER.debug("retries = [#{retries}]; decrementing...")
                retries -= 1
                retry
            else
                LOGGER.warn("Number of retries exhausted. Trying next book on list...")
                return chapters_downloaded
            end
        end
    end

    return chapters_downloaded
end

def write_image(image_url, file_name, directory, href)
    # write image file
    LOGGER.debug("BEFORE IMAGE DOWNLOAD. URL: #{image_url}")
    URI.open(image_url, read_timeout: 5) do |image|
        LOGGER.debug("AFTER IMAGE DOWNLOAD COMPLETE!")
        File.open(file_name, "wb") do |file|
            LOGGER.debug("BEFORE WRITING IMAGE TO [#{file_name}]")
            file.write(image.read)
            LOGGER.debug("AFTER WRITING IMAGE TO [#{file_name}]")
        end
    end

    return true
rescue Timeout::Error => e
    LOGGER.warn("Timeout trying to download image from url! #{image_url}")

    return false
rescue
    error_file = "#{directory}/errors.txt"
    LOGGER.warn("Error written to: [#{error_file}]")
    File.open(error_file, "a") do |file|
        file.write("Hyper link reference [#{href}] had a problem downloading an image!\n")
        file.write("Image URL: #{image_url}\n")
        file.write("File name: #{file_name}\n")
        file.write("\n") # new line
    end

    return false
end

chapters_downloaded = 0
stopwatch = Stopwatch.new()
URL_DATA.each do |(url, book_name)|
    LOGGER.info("Now downloading [#{book_name}]...")
    chapters_and_href = pre_download(url)

    directory = [BASE_DIRECTORY_PATH, book_name].join("/")
    FileUtils.mkdir_p(directory)

    # look through archive to avoid unnecessary rewrites.
    archive = [directory, "archive.txt"].join("/")
    FileUtils.touch(archive) # create file if it doesn't exist
    archive_hash = File.open(archive)
                       .readlines
                       .map(&:chomp)
                       .map { |url| [url, true] }.to_h

    chapters_downloaded += download(chapters_and_href, book_name, archive,  archive_hash)

    # prevent output hanging after sufficient output messages.
    STDOUT.flush
end
stopwatch.elapsed_time
LOGGER.info("Chapters downloaded: #{chapters_downloaded}")

LOGGER.info("Complete!")
