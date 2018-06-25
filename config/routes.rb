Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users/registrations", :sessions => "users/sessions"}
  root "employees#index"
  resources :employees do
    collection do
      #上传
      post :import_table
      #搜索和筛选
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
      # 综合分析
      get :compsite_statistical_analysis
      #工种分析
      get :worktype_statistical_analysis
      #图表点击后路径
      get :statistical_analysis_data
      post :create_workshop
      post :create_group
      post :merge_workshop
      post :merge_group
      post :delete_organization
      post :edit_workshop
      post :edit_group
      get :show_leaving_employee_modal
      post :create_leaving
      get :employee_detail
      post :update_holiday_information
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
      get :caiwu2
      get :set_holiday_start_time
      post :create_holiday_time

    end
  end

  resources :annual_holidays do
    collection do
      #年休假计划
      get :holiday_modal
      post :create_holiday_plan
      get :duan_holiday_plan
      get :workshop_holiday_plan
      #年休假落实
      get :holiday_fulfill
      get :group_holiday_fulfill
      #年休假情况
      get :holiday_fulfill_detail
      #年休假完成率
      get :holiday_fulfillment_rate
      get :filter

    end
  end

  resources :messages do
    member do
      post :update_have_read
    end
  end
end
