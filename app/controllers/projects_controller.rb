class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_project, only: [:show, :update, :destroy, :users_and_bugs_by_project ]
  load_and_authorize_resource

  def index
    if current_user.developer?
      projects = current_user.projects
      if projects.empty?
        render json: { error: 'No projects found for the current user' }, status: :unprocessable_entity
        return
      else
        render json: ProjectSerializer.new(projects).serializable_hash[:data].map { |item| item[:attributes] }
        return
      end
    end
  
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
    render json: { message: 'User assigned successfully' , user: user }
    ProjectMailer.with(user: user, project: project).notify_user_assignment.deliver_later
  end

  def remove_user
    user = User.find_by(id: params[:user_id])
    project = Project.find_by(id: params[:id])
      
      unless user && project
        render json: { error: 'User or project not found' }, status: :not_found
        return
      end
    
      unless project.users.exists?(user.id)
        render json: { error: 'User is not assigned to the project' }, status: :unprocessable_entity
        return
      end
    
      project.users.delete(user)
      bugs_to_remove = project.bugs.where(developer_id: user.id)
      bugs_to_remove.destroy_all
      render json: { message: 'User removed successfully', user: user }
      ProjectMailer.with(user: user, project: project).notify_user_removal.deliver_later
  end
  
  def users_and_bugs_by_project
    puts @project.name
    users = UserSerializer.new(@project.users).serializable_hash[:data].map { |item| item[:attributes] }
    bugs =  BugSerializer.new(@project.bugs).serializable_hash[:data].map { |item| item[:attributes] }

    render json: {collaborators: users, bugs: bugs}
  end

  
  # def search
  #   if params[:query].present?
  #     query = params[:query].strip.downcase
  
  #     if query.length == 1
  #       projects = Project.where("name ILIKE ?", "%#{query}%")
  #     elsif query.length == 2
  #       projects = Project.where("name ILIKE ?", "#{query[0]}%#{query[1]}%")
  #     else
  #       projects = Project.where("name ILIKE ?", "#{query}%")
  #     end
  
  #     render json: projects.pluck(:name)
  #   else
  #     render json: { error: 'No search query provided' }, status: :unprocessable_entity
  #   end
  # end  

  def search
    if params[:query].present?
      query = params[:query].strip.downcase
  
      if query.present?
        if query.length == 1
          projects = Project.where("name ILIKE ?", "%#{query}%")
        elsif query.length == 2
          projects = Project.where("name ILIKE ?", "#{query[0]}%#{query[1]}%")
        else
          projects = Project.where("name ILIKE ?", "#{query}%")
        end
  
        if projects.empty?
          render json: { error: 'No projects found' }, status: :not_found
        else
          render json: projects.pluck(:name)
        end
      else
        render json: { error: 'Empty search query' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'No search query provided' }, status: :unprocessable_entity
    end
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
