module ProgressScraper
  class SpreadsheetImporter
    Week = Struct.new(:number, :column)
    Student = Struct.new(:name, :row)
    def initialize spreadsheet, data
      @data = data
      @spreadsheet = spreadsheet
      @worksheet = spreadsheet.worksheets[0]
      get_students
      get_weeks
    end
    def get_students
      @students = []
      @worksheet.rows(2).each_with_index do |row, i|
        name = "#{row[1]} #{row[0]}"
        @students << Student.new(name, (i + 3)) unless row[1].empty? || row[0].empty?
      end
      @students
    end
    def get_weeks

      @weeks = []
      last_column = @worksheet.num_cols
      first_column = 1
      top_row = @worksheet.rows[0]
      (first_column..last_column).each do |column|
        content = top_row[column]
        match = /Week (\d)/.match(content)
        if match
          @weeks << Week.new(match[1].to_i, (column + 1))
        end
      end
      @weeks
    end

    def run
      @students.each do |student|
        @weeks.each do |week|
          if @data[week.number]
            progress = @data[week.number][student.name] / 100.0
            @worksheet[student.row, week.column] = progress
          end
        end
      end
      updated = @worksheet.instance_variable_get(:@modified).length
      total = @weeks.length * @students.length
      @worksheet.save
      puts "#{total} records checked. #{updated} updated."
    end
  end
end
