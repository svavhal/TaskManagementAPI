# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(todo: 0, in_progress: 1, done: 2) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:status) }
  end

  describe 'creating a valid task' do
    let(:user) { create(:user) }

    it 'is valid with a title and status as todo' do
      task = build(:task, user: user, title: 'Test Task', status: :todo)
      expect(task).to be_valid
    end

    it 'is valid with a title and status as in_progress' do
      task = build(:task, user: user, title: 'Test Task', status: :in_progress)
      expect(task).to be_valid
    end

    it 'is valid with a title and status as done' do
      task = build(:task, user: user, title: 'Test Task', status: :done)
      expect(task).to be_valid
    end
  end
end
