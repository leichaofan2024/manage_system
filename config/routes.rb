Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  resources :employees do
    collection do
      post :import_table
      get  :search
      get :age_filter
      post :update_employee_info
      get  :organization_structure
      get :age_statistical_analysis
      get :education_statistical_analysis
      get :working_years_statistical_analysis
      get :rali_years_statistical_analysis
      get :statistical_analysis_data
    end
  end
end
