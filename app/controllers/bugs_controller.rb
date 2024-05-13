class BugsController < ApplicationController
    before_action :find_bug, only: [:show, :update, :destroy, :mark_resolved_or_completed, :assign_bug_or_feature]
    before_action :authenticate_user!
    load_and_authorize_resource

    def index
      if current_user.developer?
        bugs = Bug.includes(:project)
               .joins(project: :users)
               .where(users: { id: current_user.id })
      else
        bugs = Bug.includes(:project).all
      end
    
      serialized_data = serialize_bugs_with_project_name(bugs)
    
      if serialized_data.empty?
        render json: { error: 'No bugs found for the current user' }, status: :unprocessable_entity
      else
        render json: serialized_data
      end
    end
    
  
    def show
      render json: BugSerializer.new(@bug).serializable_hash[:data][:attributes]
    end
  
    def create
      bug = Bug.new(bug_params.merge(developer_id: nil))
      puts params[:bug][:screenshot]
      if bug.save
        render json: { 
          bug: BugSerializer.new(bug).serializable_hash[:data][:attributes],
          message: 'Bug created successfully'
        }, status: :created
        BugMailer.with(bug: bug).notify_bug_creation.deliver_later
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
        render json: { message: 'Bug deleted successfully', bug: @bug }
      else
        render json: { error: @bug.errors.messages }, status: 422
      end
    end
  
    def assign_bug_or_feature
      if @bug.developer_id == current_user.id
        render json: { error: 'Bug is already assigned to a user' }, status: :unprocessable_entity
        return
      end
  
      @bug.developer_id = current_user.id
      @bug.status = 'started'
      if @bug.save
        if @bug.bug?
          render json: { message: 'Bug assigned successfully', bug: @bug}
        else
          render json: { message: 'Feature assigned successfully', bug: @bug}
        end

        BugMailer.with(bug: @bug, user: current_user).notify_bug_assignment.deliver_later
      else
        render json: { error: bug.errors.messages }, status: 422
      end
    end

    def mark_resolved_or_completed
        if @bug.developer_id != current_user.id
          render json: { error: 'You are not authorized to mark this as resolved' }, status: :unauthorized
          return
        end
      
        if @bug.completed? || @bug.resolved?
          message = @bug.completed? ? "Bug is already completed" : "Bug is already resolved"
          render json: { error: message }, status: :unprocessable_entity
          return
        end
      
        @bug.status = @bug.feature? ? 'completed' : 'resolved'
        if @bug.save
          render json: { message: 'Marked as resolved', bug: @bug }
          BugMailer.with(bug: @bug, user: current_user).notify_bug_status.deliver_later
        else
          render json: { error: @bug.errors.messages }, status: 422
        end
      end
  
    private
  
    def bug_params
      params.require(:bug).permit(:title, :description, :status, :deadline, :bug_type, :project_id, :creator_id, :screenshot)
    end
     
    def serialize_bugs_with_project_name(bugs)
      bugs.map do |bug|
        attributes = BugSerializer.new(bug).serializable_hash[:data][:attributes]
        attributes[:project_name] = bug.project.name
        attributes[:project_id] = bug.project.id
        attributes
      end
    end
  
    def find_bug
      @bug = Bug.find_by(id: params[:id])
      unless @bug
        render json: { error: 'Bug not found' }, status: :not_found
        return
      end
    end
  end
  