# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  # Ensure User has a secure password
  describe 'password encryption' do
    it 'should have a secure password' do
      expect(subject).to have_secure_password
    end
  end

  # Associations
  describe 'associations' do
    it { should have_many(:tasks).dependent(:destroy) }
  end
end
