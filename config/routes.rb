Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "users/registrations", :sessions => "users/sessions"}
  get "home/notfound"
  root "home#index"
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
      post :insert_attendance_cate
      #搜索功能
      get :search
    end
  end

  resources :attendances do
    collection do
      post :attendance_count_compute
      get :group
      get :group_statistics
      get :group_employee_detail
      get :group_application
      get :group_application_form
      post :create_application
      post :update_application
      get :show_application
      get :show_application_detail
      post :group_yijian_create
      get :simple_input_attendance
      get :add_overtime_form
      get :workshop
      get :duan
      get :duan_detail
      get :processbar_detail
      get :setting
      post :create_setting
      get :show_modal
      get :group_current_time_info
      post :create_attendance
      post :create_default_attendance
      post :verify
      post :batch_verify
      get :annual_statistic
      get :filter
      get :duan_verify_index
      get :workshop_verify_index
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

  # 奖惩模块
  resources :relative_salers do
    collection { post :import }
  end

  resources :charge_details do
    collection { post :import }
    collection { post :upload }
  end


  resources :announcements do
    collection do
      get :download_table_template
      get :download_charge_details_table_template
      get :download_rectification_awards_table_template
      get :download_middle_awards_table_template
      get :download_teamleader_awards_table_template
      get :download_other_awards_table_template
      get :download_emp_table_template
      get :download_examination_awards_table_template
      get :download_people_change_table_template
      get :download_examination_charges_table_template
      get :download_red_middle_charges_table_template
      get :download_relative_salers_total_table_template
      get :download_standard_award_total_table_template
      get :download_standard_group_table_template
      get :download_star_award_table_template
      get :download_other_award_total_table_template
    end
  end

  resources :rectification_awards do
    collection { post :import}
  end

  resources :other_awards do
    collection { post :import}
  end

  resources :middle_awards do
    collection { post :import}
  end

  resources :teamleader_awards do
    collection { post :import}
  end

  resources :examination_awards do
    collection { post :import}
  end

  resources :examination_charges do
    collection { post :import}
  end

  resources :red_middle_charges do
    collection { post :import}
  end

  resources :people_changes do
    collection { post :import}
  end

  resources :relative_salers_totals do
    collection {post :import}
  end

  resources :standard_award_totals do
    collection {post :import}
  end

  resources :standard_groups do
    collection {post :import}
  end

  resources :star_awards do
    collection {post :import}
  end

  resources :other_award_totals do
    collection {post :import}
  end

  resources :users


  resources :wages do
    collection do
      post :import_table
      get :import_wage
      delete :delete_wage
      post :create_header
      post :edit_header
      post :create_kuaizhao
      get :kuaizhao_index
      get :employees_wage_show
      get :divide_level_wage
      get :production_stuff_wage
      get :high_speed_rail_stuff
      get :main_driving_stuff
      get :edit_header_formula
      post :update_header_formula
      get :income
    end
  end

  resources :djwages do
    collection do
      post :import_table
      get :import_djwage
      delete :delete_djwage
      post :create_header
      post :edit_header
      get :employees_djwage_show
      get :edit_header_formula
      post :update_header_formula
    end
  end

  resources :bonus do
    collection do
      post :import_table
      get :import_bonus
      delete :delete_bonus
      post :create_header
      post :edit_header
      get :edit_header_formula
      post :update_header_formula
    end
  end

  resources :djbonus do
    collection do
      post :import_table
      get :import_djbonus
      delete :delete_djbonus
      post :create_header
      post :edit_header
      get :edit_header_formula
      post :update_header_formula
    end
  end

  resources :divide_level_wages do
    collection do
      get :new_line
      post :create_line
      patch :update_line
      get :edit_line
      delete :delete_line

      get :new_head
      post :create_head
      get :edit_head
      patch :update_head
      delete :delete_head
    end
  end

  resources :production_stuff_wages do
    collection do
      get :new_line
      post :create_line
      patch :update_line
      get :edit_line
      delete :delete_line

      get :new_head
      post :create_head
      get :edit_head
      patch :update_head
      delete :delete_head
    end
  end

  resources :main_driving_stuffs do
    collection do
      get :new_line
      post :create_line
      patch :update_line
      get :edit_line
      delete :delete_line

      get :new_head
      get :new_head_wage
      post :create_head
      get :edit_head
      patch :update_head
      delete :delete_head
    end
  end

  resources :high_speed_rail_stuffs do
    collection do
      get :new_line
      post :create_line
      patch :update_line
      get :edit_line
      delete :delete_line

      get :new_head
      get :new_head_wage
      post :create_head
      get :edit_head
      patch :update_head
      delete :delete_head
    end
  end

end
