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

  describe '#holidays' do
    it 'returns project holidays' do
      project = build :project
      task = build :task, project: project
      holidays = double
      expect(project).to receive(:holidays).and_return(holidays)
      expect(task.holidays).to eq holidays
    end
  end

  describe '#work_days_count' do
    context 'when end date defined' do
      it 'returns days count without holidays' do
        task = build :task, start_date: '2015-01-29', end_date: '2015-02-10'
        expect(task.work_days_count).to eq 9
      end
    end

    context 'when end date not defined' do
      let(:today) { Date.new(2015, 3, 29) }

      it 'returns days count without holidays using today as end date' do
        allow(Date).to receive(:today).and_return(today)
        task = build :task, start_date: '2015-03-20', end_date: nil
        expect(task.work_days_count).to eq 6
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