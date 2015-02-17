require 'rails_helper'

describe Holiday, :type => :model do
  it 'can be created' do
    create :holiday
  end

  describe 'associations' do
    it { should belong_to(:project) }
  end

  describe 'validations' do
    it { should validate_presence_of(:date) }
  end
end
