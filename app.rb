require 'capybara'
require 'capybara/poltergeist'
require 'pry-byebug'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'

require './cohort_progress.rb'
require './scraper.rb'
require './gdrive_updater.rb'
# scraper = ProgressScraper::Scraper.new(14)
# results = scraper.analyze_week(38,0).results
# binding.pry
#
# p result
# binding.pry
updater = ProgressScraper::GDriveUpdater.new
