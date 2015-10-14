module ProgressScraper
  Student = Struct.new(:name, :progress)
  class Scraper
    include Capybara::DSL

    def initialize cohort
      puts "Initializing..."
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      sign_in
      @cohort = cohort
      @week_ids = week_ids
      @progress = {}
    end

    def sign_in
      puts "Signing In..."
      visit "http://learn.wyncode.co/login"
      fill_in 'Username', with: 'seansellek'
      fill_in 'Password', with: 'fgtc2514414'
      click_button 'Sign In'
    end

    # Returns week id's for each week in the course
    def week_ids
      puts "Retreiving Week IDs..."
      visit "http://learn.wyncode.co/cohorts/#{@cohort}/analyze"
      find('#select_course').all('option').collect(&:value).map(&:to_i)
    end

    def analyze
      @week_ids.each_with_index do |week_id, week|
        analyze_week(week_id, week)
      end
    end

    def analyze_week(week_id, week)
      puts "Analyzing Week #{week_id}..."
      visit "http://learn.wyncode.co/cohorts/#{@cohort}/analyze?course=#{week_id}"
      @progress[week] = retrieve_results
      return self
    end

    def retrieve_results
      puts "Finding students"
      all(:xpath, ".//*[@id='content']/div[1]/*[@class='student']").map do |student_node|
        name = student_node.find('.student-name').text
        progress = student_node.find('.progress .progress-percent').text.to_i
        Student.new(name, progress)
      end
    end

    def results
      CohortProgress.new(@progress)
    end
  end
end
