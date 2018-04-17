Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  resources :employees do
    collection do
      post :import_table
      get  :search
    end
  end
end
