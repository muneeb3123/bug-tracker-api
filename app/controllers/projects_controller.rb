class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_project, only: [:show, :update, :destroy ]
  load_and_authorize_resource

  def index
    projects = Project.all
    render json: ProjectSerializer.new(projects).serializable_hash[:data].map { |item| item[:attributes] }
  end

  def show
    render json: ProjectSerializer.new(@project).serializable_hash[:data][:attributes]
  end

  def create
    project = Project.new(project_params)
    current_user.projects << project
    if project.save
      render json: { 
        project: ProjectSerializer.new(project).serializable_hash[:data][:attributes],
        message: 'Project created successfully'
      }, status: :created
    else
      render json: { error: project.errors.messages }, status: 422
    end
  end

  def update
    if @project.update(project_params)
      render json: {
        project: ProjectSerializer.new(@project).serializable_hash[:data][:attributes],
        message: 'Project updated successfully'
      }
    else
      render json: { error: project.errors.messages }, status: 422
    end
  end

  def destroy
    if @project.destroy
      render json: { message: 'Project deleted successfully' }
    else
      render json: { error: project.errors.messages }, status: 422
    end
  end

  def assign_user
    user = User.find_by(id: params[:user_id])
    project = Project.find_by(id: params[:id])
    
    
    unless user && project
      render json: { error: 'User or project not found' }, status: :not_found
      return
    end
  
    if project.users.exists?(user.id)
      render json: { error: 'User is already assigned to the project' }, status: :unprocessable_entity
      return
    end
  
    project.users << user
    render json: { message: 'User assigned successfully' }
    ProjectMailer.with(user: user, project: project).notify_user_assignment.deliver_later
  end
  
  

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def find_project
    @project = Project.find_by(id: params[:id])
    unless @project
      render json: { error: 'Project not found' }, status: :not_found
    end
  end

end
