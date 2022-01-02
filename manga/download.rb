require 'byebug'
require 'fileutils'
require 'ap'
require 'open-uri'
require 'nokogiri'

require_relative './config'
require_relative './stopwatch'

def pre_download(url)
    html = Nokogiri::HTML(URI.open(url, read_timeout: READ_TIMEOUT))
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
        STDOUT.flush
        title = data[:title]
        href = data[:href]

        # Skip downloading the chapter/pages if we already have the chapter downloaded!
        if archive_hash[href]
            puts "Skipping [#{title}] as it has already been downloaded."
            next
        end

        directory = [BASE_DIRECTORY_PATH, book_name, title].join("/")
        FileUtils.mkdir_p(directory)

        puts "Downloading book #{book_name}, #{title}..."
        html = Nokogiri::HTML(URI.open(href, read_timeout: READ_TIMEOUT))
                       .css('.option-item-trigger.chp-page-trigger.chp-selection-item')

        archive_flags = []

        # The website doubles the amount of chapter pages in the source code for some reason.
        # So, only take from the first half to avoid doubling the amount of pages in the directory.
        html[0...(html.length / 2)].each_with_index do |page, index|
            page_url = page["option_val"]


            image_url = Nokogiri::HTML(URI.open(page_url, read_timeout: READ_TIMEOUT))
                                .css('.manga_pic')
                                .first["src"]


            file_extension = image_url.match(/\.(\w+)$/)
                                      .captures
                                      .first
                                      .downcase

            file_name = directory + '/' + (index + 1).to_s.rjust(3, "0") + ".#{file_extension}"

            # avoid re-writing the page
            if File.file?(file_name)
                puts "file name #{file_name} already written"
                next
            end

            archive_flags.push write_image(image_url, file_name, directory, href)
        end

        # update the archive file
        unless archive_flags.include?(false)
            File.write(archive, "#{href}\n", mode: 'a')
        else
            puts "Skipping writing to archive..."
        end

        chapters_downloaded += 1
    end

    chapters_downloaded
end

def write_image(image_url, file_name, directory, href)
    # write image file
    URI.open(image_url) do |image|
        File.open(file_name, "wb") do |file|
            file.write(image.read)
        end
    end

    return true
rescue
    error_file = "#{directory}/errors.txt"
    puts "Error written to: [#{error_file}]"
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
    puts "Now downloading [#{book_name}]..."
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
puts "Chapters downloaded: #{chapters_downloaded}"

puts "Complete!"