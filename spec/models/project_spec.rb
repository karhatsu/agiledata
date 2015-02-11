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
end