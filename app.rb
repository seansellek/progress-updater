require 'capybara'
require 'capybara/poltergeist'
require 'pry-byebug'
require 'google/api_client'
require "google_drive"
require 'google/api_client/client_secrets'
require 'launchy'

require './cohort_progress.rb'
require './scraper.rb'
require './gdrive.rb'
require './spreadsheet_importer.rb'


# scraper = ProgressScraper::Scraper.new(14)
# results = scraper.analyze.results
# binding.pry
drive = ProgressScraper::GDrive.new
spreadsheet = drive.spreadsheet("1XepDFVyPDgw_O4gZ1Qzi6ODiBVP_8etmM5gg4PxQkS8")
importer = ProgressScraper::SpreadsheetImporter.new(spreadsheet, {})
p importer.get_students
# binding.pry
# updater = ProgressScraper::GDriveUpdater.new
