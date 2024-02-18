# frozen_string_literal: true

module Api
  module V1
    class TaskSerializer < ActiveModel::Serializer
      attributes :id, :title, :description, :status, :due_date
    end
  end
end
