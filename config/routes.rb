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

  resources :users do
    collection do
      get :developers
      get :qas
    end
  end

  resources :projects do
    member do
      post 'assign_user/:user_id', action: :assign_user
      delete 'remove_user/:user_id', action: :remove_user
      get 'users_and_bugs_by_project'
    end
    collection do
      get 'search'
    end
  end

  resources :bugs do
    member do
      put :assign_bug_or_feature
      put :mark_resolved_or_completed
    end
  end

  get '/current_user', to: 'current_users#index'
end
