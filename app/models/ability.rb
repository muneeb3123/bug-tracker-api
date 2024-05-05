# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.manager?
      can :create, Project
      can :read, Bug
      can [:edit, :destroy, :read], Project, id: user.projects.pluck(:id)
      can [:assign_user, :remove_user ], Project, id: user.projects.pluck(:id)
    elsif user.developer?
      can [:assign_bug_or_feature, :read], Bug, project_id: user.projects.pluck(:id)
      can :mark_resolved_or_completed, Bug, user_id: user.id
    elsif user.qa?
      can :read, Project
      can :create, Bug
    end
  end
end
