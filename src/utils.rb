class Utils
  class << self
    def alternating_rate(timer, interval)
      (timer >= interval * 0.5 ? interval - timer : timer).to_f / (interval * 0.5)
    end
  end
end
