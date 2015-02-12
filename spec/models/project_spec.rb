require 'rails_helper'

describe Project do
  it 'can be created' do
    create :project
  end

  describe 'associations' do
    it { should have_many(:tasks) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe '#min_date' do
    let(:project) { create :project }

    before do
      project.tasks << build(:task, project: project, start_date: '2015-02-02')
      project.tasks << build(:task, project: project, start_date: '2015-01-29')
    end

    it 'is the smallest task start date' do
      expect(project.min_date.strftime('%Y-%m-%d')).to eq('2015-01-29')
    end
  end

  describe '#max_date' do
    let(:project) { build :project }
    let(:friday) { instance_double Date, wday: 5 }
    let(:saturday) { instance_double Date, wday: 6 }
    let(:sunday) { instance_double Date, wday: 0 }

    context 'when today is Mon-Fri' do
      it 'is today' do
        allow(Date).to receive(:today).and_return(friday)
        expect(project.max_date).to eq(friday)
      end
    end

    context 'when today is Saturday' do
      it 'is yesterday' do
        allow(Date).to receive(:today).and_return(saturday)
        allow(Date).to receive(:yesterday).and_return(friday)
        expect(project.max_date).to eq(friday)
      end
    end

    context 'when today is Sunday' do
      it 'is day before yesterday' do
        allow(Date).to receive(:today).and_return(sunday)
        allow(Date).to receive(:yesterday).and_return(saturday)
        allow(saturday).to receive(:yesterday).and_return(friday)
        expect(project.max_date).to eq(friday)
      end
    end
  end

  describe '#dates' do
    let(:project) { build :project }
    let(:min_date) { double }
    let(:max_date) { double }
    let(:dates) { double }

    it 'returns date range using min and max date' do
      expect(project).to receive(:min_date).and_return(min_date)
      expect(project).to receive(:max_date).and_return(max_date)
      expect(project).to receive(:date_range).with(min_date, max_date).and_return(dates)
      expect(project.dates).to eq dates
    end
  end

  describe '#wip_per_day' do
    let(:project) { create :project }

    it 'returns empty hash when no tasks' do
      expect(Project.new.wip_per_day).to eq({})
    end

    context 'when project has tasks' do
      before do
        project.tasks << Task.new(start_date: '2015-01-30', end_date: '2015-02-03')
        project.tasks << Task.new(start_date: '2015-02-02', end_date: '2015-02-04')
        project.tasks << Task.new(start_date: '2015-02-06', end_date: '2015-02-10')
        project.tasks << Task.new(start_date: '2015-02-10', end_date: nil)
        project.tasks << Task.new(start_date: '2015-02-12', end_date: nil)
        expect(project).to receive(:min_date).and_return(Date.new(2015, 1, 28))
        expect(project).to receive(:max_date).and_return(Date.new(2015, 2, 12))
      end

      it 'calculates wip for each work day using task start and end dates' do
        expect(project.wip_per_day).to eq({Date.new(2015, 1, 28) => 0, Date.new(2015, 1, 29) => 0,
                                           Date.new(2015, 1, 30) => 1, Date.new(2015, 2, 2) => 2,
                                           Date.new(2015, 2, 3) => 2, Date.new(2015, 2, 4) => 1,
                                           Date.new(2015, 2, 5) => 0, Date.new(2015, 2, 6) => 1,
                                           Date.new(2015, 2, 9) => 1, Date.new(2015, 2, 10) => 2,
                                           Date.new(2015, 2, 11) => 1, Date.new(2015, 2, 12) => 2})
      end
    end
  end

  describe '#avg_wip' do
    let(:project) { build :project }

    context 'when no data' do
      it 'returns nil' do
        expect(project).to receive(:wip_per_day).and_return({})
        expect(project.avg_wip).to be_nil
      end
    end

    context 'when data available' do
      let(:wip_per_day) { {'day 1' => 1, 'day 2' => 3, 'day 3' => 0, 'day 4' => 2} }

      before do
        expect(project).to receive(:wip_per_day).and_return(wip_per_day)
      end

      context 'and total avg wanted' do
        it 'returns average of daily wips' do
          expect(project.avg_wip).to eq 1.5
        end
      end

      context 'and only last 2 days wanted' do
        it 'returns average of last 2 days wips' do
          expect(project.avg_wip(2)).to eq 1.0
        end
      end
    end
  end
end