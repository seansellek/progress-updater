module ProgressScraper
  class CohortProgress
    attr_accessor :progress
    def initialize progress
      @progress = progress
    end

    def [](key)
      @progress[key]
    end

    def weeks
      @progress.keys
    end

    def week week_number
      @progress[week_number]
    end
  end
end
