require 'rails_helper'

describe Task do
  it 'can be created' do
    create :task
  end

  describe 'associations' do
    it { should belong_to(:project) }
  end

  describe 'validations' do
    it { should validate_presence_of(:start_date) }

    describe 'start date' do
      it 'cannot be Saturday' do
        expect_invalid_start_date '2015-01-31'
        expect_invalid_start_date '2015-02-07'
      end

      it 'cannot be Sunday' do
        expect_invalid_start_date '2015-02-01'
        expect_invalid_start_date '2015-02-08'
      end

      it 'can be Mon-Fri' do
        expect_valid_start_date '2015-02-03'
        expect_valid_start_date '2015-02-04'
        expect_valid_start_date '2015-02-05'
        expect_valid_start_date '2015-02-06'
        expect_valid_start_date '2015-02-09'
        expect_valid_start_date '2015-02-10'
      end

      it 'cannot be in future' do
        expect_invalid_start_date get_future_work_day
      end

      def expect_invalid_start_date(start_date)
        task = build :task, start_date: start_date
        expect(task).to have(1).errors_on(:start_date)
      end

      def expect_valid_start_date(start_date)
        task = build :task, start_date: start_date
        expect(task).to be_valid
      end
    end

    describe 'end date' do
      it 'cannot be Saturday' do
        expect_invalid_end_date '2015-01-31'
        expect_invalid_end_date '2015-02-07'
      end

      it 'cannot be Sunday' do
        expect_invalid_end_date '2015-02-01'
        expect_invalid_end_date '2015-02-08'
      end

      it 'can be Mon-Fri' do
        expect_valid_end_date '2015-02-03'
        expect_valid_end_date '2015-02-04'
        expect_valid_end_date '2015-02-05'
        expect_valid_end_date '2015-02-06'
        expect_valid_end_date '2015-02-09'
        expect_valid_end_date '2015-02-10'
      end

      it 'cannot be in future' do
        expect_invalid_end_date get_future_work_day
      end

      it 'cannot be before start date' do
        task = build :task, start_date: '2015-02-04', end_date: '2015-02-03'
        expect(task).to have(1).errors_on(:end_date)
      end

      def expect_invalid_end_date(end_date)
        task = build :task, end_date: end_date
        expect(task).to have(1).errors_on(:end_date)
      end

      def expect_valid_end_date(end_date)
        task = build :task, end_date: end_date
        expect(task).to be_valid
      end
    end

    def get_future_work_day
      if Date.tomorrow.saturday?
        3.days.from_now
      elsif Date.tomorrow.sunday?
        2.days.from_now
      else
        1.day.from_now
      end
    end
  end

  describe '#work_days_count' do
    context 'when end date defined' do
      it 'returns days count without weekends' do
        task = build :task, start_date: '2015-01-29', end_date: '2015-02-10'
        expect(task.work_days_count).to eq 9
      end
    end

    context 'when end date not defined' do
      it 'returns nil' do
        task = build :task, start_date: '2015-01-29', end_date: nil
        expect(task.work_days_count).to be_nil
      end
    end
  end

  describe '#dates' do
    let(:start_date) { Date.new 2015, 2, 3 }
    let(:end_date) { Date.new 2015, 2, 5 }
    let(:task) { build :task, start_date: start_date, end_date: end_date }
    let(:dates) { double }

    context 'when end date defined' do
      it 'returns date range using start and end date' do
        expect(task).to receive(:date_range).with(start_date, end_date).and_return(dates)
        expect(task.dates).to eq dates
      end
    end

    context 'when no end date' do
      it 'returns date range using start date and today' do
        task.end_date = nil
        expect(task).to receive(:date_range).with(start_date, Date.today).and_return(dates)
        expect(task.dates).to eq dates
      end
    end
  end

  describe '#finished?' do
    it 'is true when end date' do
      expect(Task.new(end_date: '2015-02-09')).to be_finished
    end

    it 'is false when no end date' do
      expect(Task.new(end_date: nil)).not_to be_finished
    end
  end
end