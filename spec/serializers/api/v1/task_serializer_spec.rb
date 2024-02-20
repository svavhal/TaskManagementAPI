# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TaskSerializer, type: :serializer do
  let(:user) { build(:user) }
  let(:task) { create(:task, user: user) }
  subject(:serialized_task) { described_class.new(task).as_json }

  describe 'attributes' do
    it 'includes the id' do
      expect(serialized_task[:task][:id]).to eq(task.id)
    end

    it 'includes the title' do
      expect(serialized_task[:task][:title]).to eq(task.title)
    end

    it 'includes the description' do
      expect(serialized_task[:task][:description]).to eq(task.description)
    end

    it 'includes the status' do
      expect(serialized_task[:task][:status]).to eq(task.status)
    end

    it 'includes the due_date' do
      expect(serialized_task[:task][:due_date].to_date).to eq(task.due_date.to_date)
    end
  end
end
