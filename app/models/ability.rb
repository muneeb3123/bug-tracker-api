# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.manager?
      can :create, Project
      can [:edit, :destroy], Project, user_id: user.id
      can [:add_developer, :remove_developer, :add_qa, :remove_qa], Project, user_id: user.id
    elsif user.developer?
      can [:assign_bug, :read], Bug, project_id: user.projects.pluck(:id)
      can :mark_resolved, Bug, user_id: user.id
    elsif user.qa?
      can :read, Project
      can :create, Bug
    end
  end
end
