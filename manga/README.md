# Backup Manga

I noticed that some countries are now trying to censor graphic novels / manga because of some unspecified, made up reasons. Literature should NEVER be censored as it preserves the history of the time along with what was acceptable. (Though, one could argue that the books downloaded at this site aren't the official translations...)

> “Those who fail to learn from history are doomed to repeat it.” ~ Sir Winston Churchill

> "Time flows like a river, and history repeats. ~ Secret of Mana

---

## How To Use

Simply run `ruby download.rb`. The script will look up and traverse through the `URL_DATA` constant located under `config.rb`.

Set the `BASE_DIRECTORY_PATH` constant to your desired location.

---

## Tech Stack

* `Ruby 2.7`
  * [byebug](https://rubygems.org/gems/byebug/versions/11.1.3) -- Debugging purposes only.
  * [nokogiri](https://rubygems.org/gems/nokogiri/versions/1.11.1) -- Main web scraping module.

Simply run `bundle install` to install all required gems.
