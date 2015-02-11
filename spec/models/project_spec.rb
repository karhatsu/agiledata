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
end