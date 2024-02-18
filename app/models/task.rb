# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user
  enum status: { todo: 0, in_progress: 1, done: 2 }

  validates :title, :status, presence: true
end
