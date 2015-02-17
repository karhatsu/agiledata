class Holiday < ActiveRecord::Base
  belongs_to :project

  validates :date, presence: true
end
