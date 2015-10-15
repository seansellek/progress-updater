module ProgressScraper
  class Scraper
    include Capybara::DSL

    def initialize cohort
      puts "Initializing..."
      Capybara.default_driver = :poltergeist
      Capybara.javascript_driver = :poltergeist
      sign_in
      @cohort = get_cohort
      @week_ids = week_ids
      @progress = {}
    end

    def sign_in
      print "Goodmeasure Username: "
      username = gets.chomp
      print "Goodmeasure Password: "
      password = gets.chomp
      visit "http://learn.wyncode.co/login"
      fill_in 'Username', with: username
      fill_in 'Password', with: password
      click_button 'Sign In'
      if has_content? 'Invalid'
        puts "Invalid credentials! Try Again."
        sign_in
      else
        puts "Successfully Signed in to Goodmeasure."
      end
    end

    def get_cohort
      print "Enter Cohort ID (http://learn.wyncode.co/cohorts/14 => 14): "
      gets.chomp.to_i
    end

    # Returns week id's for each week in the course
    def week_ids
      visit "http://learn.wyncode.co/cohorts/#{@cohort}/analyze"
      find('#select_course').all('option').collect(&:value).map(&:to_i)
    end

    def analyze
      @week_ids.each_with_index do |week_id, week|
        puts "Retrieving Week #{week.to_s} Results"
        analyze_week(week_id, week)
      end
      return self
    end

    def analyze_week(week_id, week)
      visit "http://learn.wyncode.co/cohorts/#{@cohort}/analyze?course=#{week_id}"
      @progress[week] = retrieve_results
      return self
    end

    def retrieve_results
      results = {}
      all(:xpath, ".//*[@id='content']/div[1]/*[@class='student']").map do |student_node|
        name = student_node.find('.student-name').text
        progress = student_node.find('.progress .progress-percent').text.to_i
        results[name] = progress
      end
      results
    end

    def results
      CohortProgress.new(@progress)
    end
  end
end
