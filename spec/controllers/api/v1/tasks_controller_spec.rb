# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :controller do
  let(:current_user) { create(:user) }
  let(:token) { JsonWebToken.encode(user_id: current_user.id) }
  before do
    @request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #index' do
    before do
      current_user.tasks.create!(title: 'Test Task', description: 'This is a test task', status: 'todo')
    end

    it 'assigns all tasks as @tasks and renders them as json' do
      get :index, params: {}

      expect(response).to be_successful
      expect(json_response.size).to eq(current_user.tasks.count)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) do
        { title: 'New Test Task', description: 'Task Description', status: 'todo' }
      end

      it 'creates a new Task and returns created status' do
        post :create, params: { task: valid_attributes }

        expect(response).to have_http_status(:created)
        expect(json_response['title']).to eq('New Test Task')
      end
    end
  end

  describe 'GET #show' do
    let(:task) { current_user.tasks.create!(title: 'Test Task', description: 'This is a test task', status: 'todo') }

    it 'returns the requested task as json' do
      get :show, params: { id: task.id }

      expect(response).to be_successful
      expect(json_response['task']['id'].to_i).to eq(task.id)
    end
  end

  describe 'PATCH/PUT #update' do
    let(:task) { current_user.tasks.create!(title: 'Task to Update', description: 'Update this task', status: 'todo') }
    let(:new_attributes) do
      { title: 'Updated Task Title', description: 'Updated Description', status: 'done' }
    end

    it 'updates the requested task' do
      put :update, params: { id: task.id, task: new_attributes }

      task.reload
      expect(response).to have_http_status(:ok)
      expect(task.title).to eq('Updated Task Title')
    end
  end

  describe 'DELETE #destroy' do
    let!(:task) do
      current_user.tasks.create!(title: 'Delete Me', description: 'Delete this task please', status: 'todo')
    end

    it 'destroys the requested task' do
      expect do
        delete :destroy, params: { id: task.id }
      end.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'PATCH #mark_completed' do
    let(:task) do
      current_user.tasks.create!(title: 'Complete Me', description: 'I should be completed', status: 'todo')
    end

    it 'marks the task as completed' do
      patch :mark_completed, params: { id: task.id }

      task.reload
      expect(response).to have_http_status(:ok)
      expect(json_response['status']).to eq('success')
      expect(task.status).to eq('done')
    end
  end
end

def json_response
  JSON.parse(response.body)
end
