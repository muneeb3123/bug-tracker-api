class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.manager?
      can [:create, :users_and_bugs_by_project, :search], Project
      can [:developers, :qas],  User
      can :read, Bug
      can [:update, :destroy, :read], Project, id: user.projects.pluck(:id)
      can [:assign_user, :remove_user ], Project, id: user.projects.pluck(:id)
    elsif user.developer?
      can :users_and_bugs_by_project, Project
      can :read, Project, id: user.projects.pluck(:id)
      can [:assign_bug_or_feature, :read], Bug, project_id: user.projects.pluck(:id)
      can :mark_resolved_or_completed, Bug, developer_id: user.id
    elsif user.qa?
      can [:read,:users_and_bugs_by_project , :search], Project
      can [:create ,:read, :update, :destroy], Bug
    end
  end
end
