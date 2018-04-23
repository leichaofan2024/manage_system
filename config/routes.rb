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
      get  :age_analysis_data
      get  :education_background_analysis_data
      get :age_analysis_data_bar
      get :education_background_analysis_data_bar
    end
  end
end
