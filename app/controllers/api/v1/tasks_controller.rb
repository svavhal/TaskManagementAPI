# frozen_string_literal: true

module Api
  module V1
    class TasksController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_task, only: %i[show edit update destroy mark_completed]

      # GET v1/tasks
      def index
        @tasks = @current_user.tasks
        @tasks = @tasks.where(status: params[:status]) if params[:status].present?
        @tasks = @tasks.paginate(page: params[:page], per_page: params[:per_page])
        render json: @tasks, each_serializer: TaskSerializer
      end

      # POST v1/tasks
      def create
        @task = @current_user.tasks.build(task_params)
        if @task.save
          render json: TaskSerializer.new(@task).serializable_hash.to_json, status: :created
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      def show
        render json: @task, serializer: TaskSerializer
      end

      # PATCH/PUT v1/tasks/:id
      def update
        if @task.update(task_params)
          render json: @task, serializer: TaskSerializer
        else
          render json: @task.errors, status: :unprocessable_entity
        end
      end

      # DELETE v1/tasks/:id
      def destroy
        @task.destroy
        head :no_content
      end

      # PATCH v1/tasks/:id/mark_completed
      def mark_completed
        if @task.update(status: :done)
          render json: { status: 'success', message: 'Task marked as completed', data: @task }, status: :ok
        else
          render json: { status: 'error', message: 'Task cannot be marked as completed', errors: @task.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def set_task
        @task = @current_user.tasks.find_by(id: params[:id])
        return unless @task.blank?

        render json: { status: 'error', message: 'Task not found' }, status: :not_found
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :due_date)
      end
    end
  end
end
