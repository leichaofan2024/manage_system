Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  resources :employees do
    collection do
      post :import_table
      get  :search
      post :update_employee_info
      get  :organization_structure
      get  :statistical_analysis
      get :statistical_analysis_data
    end
  end
end
