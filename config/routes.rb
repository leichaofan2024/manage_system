Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :employees do
    collection do
      post :import
      get :organization_structure
      get :statistical_analysis
    end 
  end
end
