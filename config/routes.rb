Rails.application.routes.draw do
  devise_for :users
  root "home#index"

  resources :employees do
    collection do
      post :import
      get :organization_structure
      get :statistical_analysis
      get :age_analysis_data
      get :education_background_analysis_data
    end 
  end
end
