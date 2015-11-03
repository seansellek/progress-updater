require 'mechanize'
require 'json'
require 'pry-byebug'
require 'google/api_client'
require "google_drive"
require 'google/api_client/client_secrets'
require 'launchy'
require 'colorize'

require './cohort_progress.rb'
require './scraper.rb'
require './gdrive.rb'
require './spreadsheet_importer.rb'

opts = JSON.parse(File.read("./gm_secrets.json")) if ARGV[0] == "-d"

scraper = ProgressScraper::Scraper.new(opts)
results = scraper.results

drive = ProgressScraper::GDrive.new
spreadsheet_id = opts["spreadsheet_id"]

unless spreadsheet_id
  print "Enter Spreadsheet ID: ".colorize(:blue)
  spreadsheet_id = gets.chomp
end

spreadsheet = drive.spreadsheet(spreadsheet_id)

importer = ProgressScraper::SpreadsheetImporter.new(spreadsheet, results)
importer.run
