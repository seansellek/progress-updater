module ProgressScraper
  class Scraper

    def initialize(opts = {})
      opts ||= {}
      configure_mechanize
      sign_in(opts["username"], opts["password"])
      @cohort = opts["cohort_id"] || request_input("Cohort ID")
      @week_ids = week_ids
      @progress = {}
      analyze
    end

    def sign_in(username = nil, password = nil)
      username ||= request_input("Goodmeasure Username")
      password ||= request_input("Goodmeasure Password")
      form = @agent.get("http://learn.wyncode.co/login").form
      form.username = username
      form.login_password = password
      @page = @agent.submit(form, form.buttons.first)
      verify_sign_in
    end

    def verify_sign_in
      if @page.search(".error").empty?
        puts "Successfully Signed in to Goodmeasure.".colorize(:yellow)
      else
        puts "Invalid credentials! Try Again.".colorize(:red)
        sign_in
      end
    end

    def request_input(item_name)
      print "Enter #{item_name}: ".colorize(:blue)
      $stdin.gets.chomp.to_i
    end

    # Returns week id's for each week in the course
    def week_ids
      @page = @agent.get("http://learn.wyncode.co/cohorts/#{@cohort}/analyze")
      @page.search("#select_course option").collect do |option|
        option.attributes["value"].value.to_i
      end
    end

    def analyze
      @week_ids.each_with_index do |week_id, week|
        puts "Retrieving Week #{week} Results".colorize(:yellow)
        analyze_week(week_id, week)
      end
      self
    end

    def analyze_week(week_id, week)
      @page = @agent.get("http://learn.wyncode.co/cohorts/#{@cohort}/analyze?course=#{week_id}")
      @progress[week] = retrieve_results
      self
    end

    def retrieve_results
      week_results = {}
      @page.search(".//*[@id='content']/div[1]/*[@class='student']").each do |student_node|
        name = student_node.at_css('.student-name').text
        progress = student_node.at_css('.progress .progress-percent').text.to_i
        week_results[name] = progress
      end
      week_results
    end

    def results
      CohortProgress.new(@progress)
    end

    def configure_mechanize
      @agent = Mechanize.new
    end
  end
end
