Rails.application.routes.draw do
  resources :projects do
    resources :tasks
  end

  resources :example_projects, only: :create

  root 'projects#index'
end
