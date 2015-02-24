require 'rails_helper'

describe Project do
  def create_task(start_date, end_date=nil)
    create(:task, project: project, start_date: start_date, end_date: end_date)
  end

  it 'can be created' do
    create :project
  end

  describe 'associations' do
    it { should have_many(:holidays) }
    it { should have_many(:tasks) }

    describe 'finished tasks' do
      let(:project) { create :project }

      before do
        create_task '2015-02-02', '2015-02-09'
        create_task '2015-02-03'
        create_task '2015-02-04', '2015-02-05'
        create_task '2015-02-04', '2015-02-06'
      end

      it 'skips tasks without end date, orders by end date' do
        expect(project.finished_tasks.map {|task| task.end_date.strftime('%Y-%m-%d')}).to eq(['2015-02-05', '2015-02-06', '2015-02-09'])
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'callbacks' do
    it 'generates key on create' do
      project = create :project
      expect(project.key).not_to be_nil
      expect(project.key.length).to eq 30
    end

    it 'keeps the same key on update' do
      project = create :project
      key = project.key
      project.save!
      expect(project.key).to eq key
    end
  end

  describe '#to_param' do
    it 'returns key' do
      project = create :project
      expect(project.to_param).to eq project.key
    end
  end

  describe '#min_date' do
    let(:project) { create :project }

    before do
      create_task '2015-02-02'
      create_task '2015-01-29'
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

  describe '#create_task' do
    let(:project) { create :project }

    it 'creates task with given name and start date' do
      project.create_task 'New task', '2015-02-23'
      task = Task.last
      expect(task).not_to be_nil
      expect(task.project).to eq(project)
      expect(task.name).to eq('New task')
      expect(task.start_date.strftime('%Y-%m-%d')).to eq('2015-02-23')
      expect(task.end_date).to be_nil
    end
  end

  describe 'statistics and forecasts' do
    context 'when no tasks' do
      let(:project) { build :project }

      it 'wip / day is empty hash' do
        expect(project.wip_per_day).to eq({})
      end

      it 'average wip is nil' do
        expect(project.avg_wip).to be_nil
      end

      it 'weekly throughput is empty hash' do
        expect(project.weekly_throughput).to eq({})
      end

      it 'average throughput is nil' do
        expect(project.avg_throughput).to be_nil
      end

      it 'average lead time is nil' do
        expect(project.avg_lead_time).to be_nil
      end

      it 'average days per task is nil' do
        expect(project.avg_days_per_task).to be_nil
      end

      it 'average takt time is nil' do
        expect(project.avg_takt_time).to be_nil
      end

      it 'throughput forecast is nil' do
        expect(project.throughput_forecast_for(5)).to be_nil
      end

      it 'lead time / WIP forecast is nil' do
        expect(project.lead_time_wip_forecast_for(20)).to be_nil
      end

      it 'takt time forecast is nil' do
        expect(project.takt_time_forecast_for(8)).to be_nil
      end
    end

    context 'when tasks' do
      describe '#wip_per_day' do
        let(:project) { create :project }
        let(:today) { Date.new(2015, 2, 13) }

        before do
          create_task '2015-01-30', '2015-02-03'
          create_task '2015-02-02', '2015-02-04'
          create_task '2015-02-06', '2015-02-10'
          create_task '2015-02-09', '2015-02-10'
          create_task '2015-02-10'
          create_task '2015-02-12'
          expect(project).to receive(:min_date).and_return(Date.new(2015, 1, 28))
          expect(project).to receive(:max_date).and_return(today)
          allow(Date).to receive(:today).and_return(today)
        end

        it 'is amount of tasks in progress each day so that start and end dates count to 0.5' do
          expect(project.wip_per_day).to eq({Date.new(2015, 1, 28) => 0, Date.new(2015, 1, 29) => 0,
                                             Date.new(2015, 1, 30) => 0.5, Date.new(2015, 2, 2) => 1.5,
                                             Date.new(2015, 2, 3) => 1.5, Date.new(2015, 2, 4) => 0.5,
                                             Date.new(2015, 2, 5) => 0, Date.new(2015, 2, 6) => 0.5,
                                             Date.new(2015, 2, 9) => 1.5, Date.new(2015, 2, 10) => 1.5,
                                             Date.new(2015, 2, 11) => 1, Date.new(2015, 2, 12) => 1.5,
                                             Date.new(2015, 2, 13) => 2})
        end

        context 'when having tasks that are finished on same day as started' do
          before do
            create_task '2015-02-05', '2015-02-05'
          end

          it 'increase WIP by 1 for those dates' do
            expect(project.wip_per_day[Date.new(2015, 2, 5)]).to eq 1
          end
        end
      end

      describe '#avg_wip' do
        let(:project) { build :project }
        let(:wip_per_day) { {'day 1' => 1, 'day 2' => 3, 'day 3' => 0, 'day 4' => 2} }

        before do
          expect(project).to receive(:wip_per_day).and_return(wip_per_day)
        end

        it 'is average of daily wips' do
          expect(project.avg_wip).to eq 1.5
        end

        it 'is average of last 2 days wips when last 2 days wanted' do
          expect(project.avg_wip(2)).to eq 1.0
        end
      end

      describe 'throughput' do
        let(:project) { create :project }
        let(:today) { Date.new(2015, 2, 11) }

        before do
          create_task '2015-01-16', '2015-01-19'
          create_task '2015-01-19', '2015-01-22'

          create_task '2015-01-19', '2015-01-28'
          create_task '2015-01-19', '2015-01-29'

          create_task '2015-01-27', '2015-02-02'
          create_task '2015-02-03', '2015-02-04'
          create_task '2015-02-03', '2015-02-06'

          create_task '2015-02-05', '2015-02-11'

          create_task '2015-02-04'

          allow(Date).to receive(:today).and_return(today)
        end

        it 'weekly throughput is hash where key is beginning of the week and value is finished tasks count for that week' do
          expect(project.weekly_throughput).to eq({Date.new(2015, 1, 12).beginning_of_week => 0,
                                                   Date.new(2015, 1, 19).beginning_of_week => 2,
                                                   Date.new(2015, 1, 26).beginning_of_week => 2,
                                                   Date.new(2015, 2, 2).beginning_of_week => 3,
                                                   Date.new(2015, 2, 9).beginning_of_week => 1})
        end

        it 'average throughput for all tasks is finished count divided by work week count' do
          expect(project.avg_throughput).to eq(8.0 / (19.0/5.0))
        end

        it 'average throughput for last two weeks is finished count during last 14 days divided by 2' do
          expect(project.avg_throughput(2)).to eq(5.0 / 2.0)
        end
      end

      describe '#avg_lead_time' do
        let(:project) { create :project }

        before do
          create_task '2015-02-02', '2015-02-03' # 2
          create_task '2015-02-03', '2015-02-05' # 3
          create_task '2015-02-09', '2015-02-13' # 5
          create_task '2015-02-10'
        end

        it 'is the average of task work day counts for finished tasks' do
          expect(project.avg_lead_time).to eq(10.0 / 3)
        end

        it 'for last 2 tasks is the average of the work day count for last two finished tasks' do
          expect(project.avg_lead_time(2)).to eq(8.0 / 2)
        end
      end

      describe '#avg_days_per_task' do
        let(:project) { build :project }
        let(:last_days) { 10 }
        let(:last_tasks) { 5 }
        let(:avg_wip) { 2.6 }
        let(:avg_lead_time) { 3.7 }

        it 'is average lead time for all tasks divided by average wip for all tasks' do
          expect(project).to receive(:avg_wip).with(nil).and_return(avg_wip)
          expect(project).to receive(:avg_lead_time).with(nil).and_return(avg_lead_time)
          expect(project.avg_days_per_task()).to eq(3.7 / 2.6)
        end

        it 'for last 5 tasks and last 10 days is average lead time for last 5 tasks divided by average wip for last 10 days' do
          expect(project).to receive(:avg_wip).with(last_days).and_return(avg_wip)
          expect(project).to receive(:avg_lead_time).with(last_tasks).and_return(avg_lead_time)
          expect(project.avg_days_per_task(last_tasks, last_days)).to eq(3.7 / 2.6)
        end
      end

      describe '#avg_takt_time' do
        let(:project) { create :project }
        let(:today) { Date.new(2015, 2, 18) }

        before do
          allow(Date).to receive(:today).and_return(today)
          create_task '2015-02-02', '2015-02-02'
          create_task '2015-02-02', '2015-02-04'
          create_task '2015-02-04', '2015-02-05'
          create_task '2015-02-03', '2015-02-05'
          create_task '2015-02-06', '2015-02-11'
        end

        it 'is average time between end (work) dates of finished tasks' do
          expect(project.avg_takt_time).to eq((2+1+0+4).to_f / 4)
        end

        it 'for last 2 weeks is average takt time for tasks finished during last 2 weeks' do
          expect(project.avg_takt_time(2)).to eq((1+0+4).to_f / 3)
        end
      end

      describe '#throughput_forecast_for 5 tasks' do
        let(:project) { build :project }

        context 'when average throughput per week is 2.5' do
          it 'is 10 work days (2 weeks)' do
            expect(project).to receive(:avg_throughput).and_return(2.5)
            expect(project.throughput_forecast_for(5)).to eq(10)
          end
        end

        context 'when average throughput for last 4 weeks is 2' do
          it 'is 12.5 work days (2.5 weeks) when calculated based on last 4 weeks throughput' do
            expect(project).to receive(:avg_throughput).with(4).and_return(2)
            expect(project.throughput_forecast_for(5, 4)).to eq(12.5)
          end
        end
      end

      describe '#lead_time_wip_forecast_for 15 tasks' do
        let(:project) { build :project }

        context 'when average lead time is 4 days and average wip is 2' do
          it 'is 30 work days' do
            expect(project).to receive(:avg_lead_time).and_return(4)
            expect(project).to receive(:avg_wip).and_return(2)
            expect(project.lead_time_wip_forecast_for(15)).to eq(30)
          end
        end

        context 'when average lead time is 6 days for last 10 tasks and average wip is 4 for last 20 days' do
          it 'is 22.5 work days' do
            expect(project).to receive(:avg_lead_time).with(10).and_return(6)
            expect(project).to receive(:avg_wip).with(20).and_return(4)
            expect(project.lead_time_wip_forecast_for(15, 10, 20)).to eq(22.5)
          end
        end
      end

      describe '#takt_time_forecast_for 5 tasks' do
        let(:project) { build :project }

        context 'when average takt time is 2.2 days' do
          it 'is 11 work days' do
            expect(project).to receive(:avg_takt_time).and_return(2.2)
            expect(project.takt_time_forecast_for(5)).to eq(11)
          end
        end

        context 'when average takt time is 1.5 days for last 4 weeks' do
          it 'is 7.5 work days' do
            expect(project).to receive(:avg_takt_time).with(4).and_return(1.5)
            expect(project.takt_time_forecast_for(5, 4)).to eq(7.5)
          end
        end
      end
    end
  end
end