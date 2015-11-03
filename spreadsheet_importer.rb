module ProgressScraper
  class SpreadsheetImporter
    Week = Struct.new(:number, :column)
    Student = Struct.new(:name, :row)

    def initialize(spreadsheet, data)
      @data = data
      @spreadsheet = spreadsheet
      @worksheet = spreadsheet.worksheets[0]
      read_students
      read_weeks
    end

    def read_students
      @students = []
      @worksheet.rows(2).each_with_index do |row, i|
        name = "#{row[1]} #{row[0]}"
        @students << Student.new(name, (i + 3)) unless row[1].empty? || row[0].empty?
      end
      @students
    end

    def read_weeks
      @weeks = []
      last_column = @worksheet.num_cols
      first_column = 1
      top_row = @worksheet.rows[0]
      (first_column..last_column).each do |column|
        content = top_row[column]
        match = /Week (\d)/.match(content)
        @weeks << Week.new(match[1].to_i, (column + 1)) if match
      end
      @weeks
    end

    def run
      @students.each do |student|
        @weeks.each do |week|
          check_cell(student, week)
        end
      end
      save
    end

    def save
      updated = @worksheet.instance_variable_get(:@modified).length
      total = @weeks.length * @students.length
      @worksheet.save
      puts "#{total} records checked. #{updated} updated.".colorize(:green)
    end

    def check_cell(student, week)
      week_results = @data[week.number]
      return unless week_results
      binding.pry unless week_results[student.name]
      progress = week_results[student.name] / 100.0
      past_progress = @worksheet[student.row, week.column].to_f / 100
      return if past_progress == progress
      @worksheet[student.row, week.column] = progress
    end
  end
end
