class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :library

  validates :content, presence: true

end
