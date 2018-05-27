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

  resources :attendances do
    collection do
      get :group
      get :workshop
      get :duan
      get :duan_detail
      get :processbar_detail
      get :setting
      post :create_setting
      get :show_modal
      get :group_current_time_info
      post :create_attendance
      post :verify
      post :batch_verify
      get :annual_statistic
      get :filter
      post :create_application
      get :show_application
      get :show_application_detail
      post :update_application
      get :show_record
      get :caiwu
    end
  end

  resources :annual_holidays do
    collection do
      get :holiday_modal
      post :create_holiday
      get :duan_holiday_plan
      get :workshop_holiday_plan
      get :holiday_plan
      get :holiday_modal
      post :create_holiday_plan
    end
  end
end
