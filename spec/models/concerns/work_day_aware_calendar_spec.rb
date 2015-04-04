require 'rails_helper'

describe WorkDayAwareCalendar do
  class FakeModel
    include WorkDayAwareCalendar

    def holidays
      [Holiday.new(date: christmas_day), Holiday.new(date: new_year_day)]
    end

    def christmas_day
      Date.new(2014, 12, 25)
    end

    def new_year_day
      Date.new(2015, 1, 1)
    end
  end

  let(:model) { FakeModel.new }

  describe '#holiday?' do
    it 'true for Saturday and Sunday' do
      expect(model.holiday? Date.new(2015, 2, 14)).to be_truthy
      expect(model.holiday? Date.new(2015, 2, 15)).to be_truthy
    end

    it 'false for Monday-Friday' do
      expect(model.holiday? Date.new(2015, 2, 9)).to be_falsey
      expect(model.holiday? Date.new(2015, 2, 10)).to be_falsey
      expect(model.holiday? Date.new(2015, 2, 11)).to be_falsey
      expect(model.holiday? Date.new(2015, 2, 12)).to be_falsey
      expect(model.holiday? Date.new(2015, 2, 13)).to be_falsey
    end

    it 'true for a pre-defined holiday date' do
      expect(model.holiday? model.christmas_day).to be_truthy
      expect(model.holiday? model.new_year_day).to be_truthy
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

    context 'when min date is today (and not holiday)' do
      let(:today) { Date.new(2015, 2, 10) }
      it 'returns today in an array' do
        expect(model.date_range(today, today)).to eq [today]
      end
    end

    context 'when start date is before end date' do
      it 'returns all date_range between them excluding holidays' do
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

    it 'excludes holidays' do
      expect(model.days_between(Date.new(2015, 2, 12), Date.new(2015, 2, 16))).to eq 2
    end

    it 'raises error when date2 is less than date1' do
      expect { model.days_between(Date.today, 1.day.ago) }.to raise_error
    end
  end

  describe '#latest_work_day' do
    context 'when latest work day wanted' do
      it 'asks latest work day for today' do
        work_day = instance_double Date
        expect(model).to receive(:latest_work_day_for).with(Date.today, 0).and_return(work_day)
        expect(model.latest_work_day).to eql(work_day)
      end
    end

    context 'when nth latest work day wanted' do
      it 'asks nth latest work day for today' do
        work_day = instance_double Date
        expect(model).to receive(:latest_work_day_for).with(Date.today, 15).and_return(work_day)
        expect(model.latest_work_day(15)).to eql(work_day)
      end
    end
  end

  describe '#latest_work_day_for' do
    context 'when given date is work day' do
      let(:date) { Date.new(2015, 3, 27) }
      it 'returns today' do
        expect(model.latest_work_day_for(date)).to eq date
      end

      it 'returns nth work day before that when asked' do
        expect(model.latest_work_day_for(date, 4)).to eq(date - 4)
      end
    end

    context 'when given date is Sunday' do
      let(:date) { Date.new(2015, 3, 29) }
      it 'returns previous Friday before the given date' do
        expect(model.latest_work_day_for(date)).to eq Date.new(2015, 3, 27)
      end

      it 'returns nth work day before previous Friday when asked' do
        expect(model.latest_work_day_for(date, 5)).to eq Date.new(2015, 3, 20)
      end
    end

    context 'when today is holiday' do
      let(:date) { model.new_year_day }
      it 'returns previous work day before the given date' do
        expect(model.latest_work_day_for(date)).to eq(model.new_year_day - 1)
      end

      it 'returns nth work day before previous work day when asked' do
        expect(model.latest_work_day_for(date, 7)).to eq Date.new(2014, 12, 19)
      end
    end
  end
end