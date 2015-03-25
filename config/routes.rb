Rails.application.routes.draw do
  resources :projects do
    resources :tasks
    resources :task_imports
  end

  resources :example_projects, only: :create

  root 'projects#index'
end
