class BugsController < ApplicationController
    before_action :find_bug, only: [:show, :update, :destroy, :mark_resolved_or_completed, :assign_bug_or_feature]
    before_action :authenticate_user!
    load_and_authorize_resource
  
    def index
      bugs = Bug.all
      render json: BugSerializer.new(bugs).serializable_hash[:data].map { |item| item[:attributes] }
    end
  
    def show
      render json: BugSerializer.new(@bug).serializable_hash[:data][:attributes]
    end
  
    def create
      bug = Bug.new(bug_params)
      if bug.save
        render json: { 
          bug: BugSerializer.new(bug).serializable_hash[:data][:attributes],
          message: 'Bug created successfully'
        }, status: :created
      else
        render json: { error: bug.errors.messages }, status: 422
      end
    end
  
    def update
      if @bug.update(bug_params)
        render json: {
          bug: BugSerializer.new(@bug).serializable_hash[:data][:attributes],
          message: 'Bug updated successfully'
        }
      else
        render json: { error: @bug.errors.messages }, status: 422
      end
    end
  
    def destroy
      if @bug.destroy
        render json: { message: 'Bug deleted successfully' }
      else
        render json: { error: @bug.errors.messages }, status: 422
      end
    end
  
    def assign_bug_or_feature
      if @bug.user_id == current_user.id
        puts @bug.user_id
        puts current_user.id
        render json: { error: 'Bug is already assigned to a user' }, status: :unprocessable_entity
        return
      end
  
      @bug.user_id = current_user.id
      if @bug.save
        @bug.status = 'started'
        if @bug.bug?
          render json: { message: 'Bug assigned successfully' }
        else
          render json: { message: 'Feature assigned successfully' }
        end
      else
        render json: { error: bug.errors.messages }, status: 422
      end
    end

    def mark_resolved_or_completed
        if @bug.user_id != current_user.id
          render json: { error: 'You are not authorized to mark this as resolved' }, status: :unauthorized
          return
        end
      
        if @bug.completed? || @bug.resolved?
          message = @bug.completed? ? "Bug is already completed" : "Bug is already resolved"
          render json: { message: message }
          return
        end
      
        @bug.status = @bug.feature? ? 'completed' : 'resolved'
        if @bug.save
          render json: { message: 'Marked as resolved' }
        else
          render json: { error: @bug.errors.messages }, status: 422
        end
      end
      
  
    private
  
    def bug_params
      params.require(:bug).permit(:title, :description, :status, :deadline, :bug_type, :project_id, :user_id)
    end
  
    def find_bug
      @bug = Bug.find_by(id: params[:id])
      unless @bug
        render json: { error: 'Bug not found' }, status: :not_found
        return
      end
    end
  end
  