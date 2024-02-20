# frozen_string_literal: true

module Api
  module V1
    class TasksController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_task, only: %i[show edit update destroy mark_completed]

      # GET v1/tasks
      def index
        @tasks = @current_user.tasks
        @tasks = filter_tasks(@tasks, params)
        # Use a helper method for sorting
        @tasks = sort_tasks(@tasks, params[:sort_by], params[:sort_order])
        @tasks = paginate_tasks(@tasks, params[:page], params[:per_page])
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

      def filter_tasks(tasks, params)
        # Filter by status
        tasks = tasks.where(status: params[:status]) if params[:status].present?

        # Filter by title
        if params[:title].present?
          filter = JSON.parse(params[:title])
          tasks = tasks.where('title LIKE ?', filter)
        end

        # Filter by description
        if params[:description].present?
          filter = JSON.parse(params[:description])
          tasks = tasks.where('description LIKE ?', filter)
        end
        # Filter by due date
        tasks = tasks.where(due_date: params[:due_date]) if params[:due_date].present?

        tasks
      end

      def sort_tasks(tasks, sort_by, sort_order)
        allowed_sort_attributes = %w[title description status due_date created_at]
        sort_by = allowed_sort_attributes.include?(sort_by&.downcase) ? sort_by : 'created_at'
        sort_order = %w[asc desc].include?(sort_order&.downcase) ? sort_order : 'asc'
        tasks.order(sort_by => sort_order)
      end

      def paginate_tasks(tasks, page, per_page)
        per_page = (per_page.to_i.positive? ? per_page : 10).to_i
        page = (page.to_i.positive? ? page : 1).to_i

        tasks.paginate(page: page, per_page: per_page)
      end

      def task_params
        params.require(:task).permit(:title, :description, :status, :due_date, :sort_by, :sort_order)
      end
    end
  end
end
