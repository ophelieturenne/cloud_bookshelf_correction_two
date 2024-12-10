class LibraryUser < ApplicationRecord
  belongs_to :user
  belongs_to :library

  validates :user_id, uniqueness: { scope: :library_id, message: "is already a member of this library" }
  paginates_per 4
end
