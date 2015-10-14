require 'capybara'
require 'capybara/poltergeist'
require 'pry-byebug'

require './cohort_progress.rb'
require './scraper.rb'

scraper = ProgressScraper::Scraper.new(14)
results = scraper.analyze_week(38,0).results
binding.pry

p results
