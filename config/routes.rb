Rails.application.routes.draw do
  devise_for :users, path:'', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  resources :projects do
    post 'assign_user/:user_id', action: :assign_user, on: :member
  end

  resources :bugs do
    member do
      post :assign_bug_or_feature
      post :mark_resolved_or_completed
    end
  end

end
