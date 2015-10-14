module ProgressScraper
  class CohortProgress
    def initialize progress
      @progress = progress
    end

    def weeks
      @progress.keys
    end

    def week week_number
      @progress[week_number]
    end
  end
end
