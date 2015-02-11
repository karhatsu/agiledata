require 'rails_helper'

describe WeekendHelper do
  class FakeModel
    include WeekendHelper
  end

  describe '#weekend?' do
    it 'true for Saturday and Sunday' do
      expect_weekend_for_wday 6, true
      expect_weekend_for_wday 0, true
    end

    it 'false for Monday-Friday' do
      expect_weekend_for_wday 1, false
      expect_weekend_for_wday 2, false
      expect_weekend_for_wday 3, false
      expect_weekend_for_wday 4, false
      expect_weekend_for_wday 5, false
    end

    def expect_weekend_for_wday(wday, weekend)
      date = double wday: wday
      expect(FakeModel.new.weekend? date).to eq(weekend)
    end
  end
end