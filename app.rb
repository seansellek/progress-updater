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


scraper = ProgressScraper::Scraper.new(14)
results = scraper.analyze.results

drive = ProgressScraper::GDrive.new
puts "Enter Spreadsheet ID: "
spreadsheet_id = gets.chomp
spreadsheet = drive.spreadsheet(spreadsheet_id)

importer = ProgressScraper::SpreadsheetImporter.new(spreadsheet, results)
importer.run
