module ProgressScraper
  class Scraper
    include Capybara::DSL

    def initialize(opts = {})
      configure_capybara
      sign_in(opts["username"], opts["password"])
      @cohort = opts["cohort_id"] || request_input("Cohort ID")
      @week_ids = week_ids
      @progress = {}
    end

    def sign_in(username = nil, password = nil)
      username ||= request_input("Goodmeasure Username")
      password ||= request_input("Goodmeasure Password")
      visit "http://learn.wyncode.co/login"
      fill_in 'Username', with: username
      fill_in 'Password', with: password
      click_button 'Sign In'
      verify_sign_in
    end

    def verify_sign_in
      if has_content? 'Invalid'
        puts "Invalid credentials! Try Again.".colorize(:red)
        sign_in
      else
        puts "Successfully Signed in to Goodmeasure.".colorize(:yellow)
      end
    end

    def request_input(item_name)
      print "Enter #{item_name}: ".colorize(:blue)
      $stdin.gets.chomp.to_i
    end

    # Returns week id's for each week in the course
    def week_ids
      visit "http://learn.wyncode.co/cohorts/#{@cohort}/analyze"
      find('#select_course').all('option').collect(&:value).map(&:to_i)
    end

    def analyze
      @week_ids.each_with_index do |week_id, week|
        puts "Retrieving Week #{week} Results".colorize(:yellow)
        analyze_week(week_id, week)
      end
      self
    end

    def analyze_week(week_id, week)
      visit "http://learn.wyncode.co/cohorts/#{@cohort}/analyze?course=#{week_id}"
      @progress[week] = retrieve_results
      self
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

    def configure_capybara
      Capybara.default_driver = :webkit
      # Capybara.javascript_driver = :poltergeist
      Capybara::Webkit.configure do |config|
        config.block_unknown_urls
        config.allow_url("learn.wyncode.co")
      end
    end
  end
end
