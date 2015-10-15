module ProgressScraper
  class SpreadsheetImporter
    def initialize spreadsheet, data
      @data = data
      @spreadsheet = spreadsheet
      @worksheet = spreadsheet.worksheets[0]
    end
    def get_students
      students = {}
      @worksheet.rows(2).each_with_index do |row, i|
        name = "#{row[1]} #{row[0]}"
        students[name] = (i + 3)
      end
      students
    end

  end
end
