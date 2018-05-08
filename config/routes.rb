Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users/registrations", :sessions => "users/sessions"}
  root "home#index"
  resources :employees do
    collection do
      #上传
      post :import_table
      #搜索和筛选
      get  :search
      get :filter
      #一键更新路径
      post :update_employee_info
      #组织架构
      get  :organization_structure
      #统计分析
      get :age_statistical_analysis
      get :education_statistical_analysis
      get :working_years_statistical_analysis
      get :rali_years_statistical_analysis
      #图表点击后路径
      get :statistical_analysis_data
    end
  end
end
