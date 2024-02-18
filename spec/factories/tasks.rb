# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    title { 'Sample task' }
    description { 'Sample description' }
    status { 'todo' }
    due_date { Date.tomorrow }
  end
end
