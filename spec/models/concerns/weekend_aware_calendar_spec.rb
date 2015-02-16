require 'rails_helper'

describe WeekendAwareCalendar do
  class FakeModel
    include WeekendAwareCalendar
  end

  let(:model) { FakeModel.new }

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
      expect(model.weekend? date).to eq(weekend)
    end
  end

  describe '#date_range' do
    context 'when min date nil' do
      it 'is empty array' do
        expect(model.date_range(nil, Date.today)).to eq []
      end
    end

    context 'when max date nil' do
      it 'is empty array' do
        expect(model.date_range(Date.today, nil)).to eq []
      end
    end

    context 'when min date is today (and not weekend)' do
      let(:today) { Date.new(2015, 2, 10) }
      it 'returns today in an array' do
        expect(model.date_range(today, today)).to eq [today]
      end
    end

    context 'when start date is before end date' do
      it 'returns all date_range between them excluding weekends' do
        min_date = Date.new(2015, 1, 30)
        max_date = Date.new(2015, 2, 10)
        expected_dates = [Date.new(2015, 1, 30), Date.new(2015, 2, 2), Date.new(2015, 2, 3),
                          Date.new(2015, 2, 4), Date.new(2015, 2, 5), Date.new(2015, 2, 6),
                          Date.new(2015, 2, 9), Date.new(2015, 2, 10)]
        expect(model.date_range(min_date, max_date)).to eq expected_dates
      end
    end
  end

  describe '#days_between' do
    it 'is 0 when same date' do
      expect(model.days_between(Date.new(2015, 2, 11), Date.new(2015, 2, 11))).to eq 0
    end

    it 'is 2 when one day in between' do
      expect(model.days_between(Date.new(2015, 2, 11), Date.new(2015, 2, 13))).to eq 2
    end

    it 'excludes weekends' do
      expect(model.days_between(Date.new(2015, 2, 12), Date.new(2015, 2, 16))).to eq 2
    end

    it 'raises error when date2 is less than date1' do
      expect { model.days_between(Date.today, 1.day.ago) }.to raise_error
    end
  end
end