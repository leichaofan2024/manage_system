class AttendancesController < ApplicationController
  layout 'home'

	##班组页面--开始
	def group
    @group = Group.find_by(:id => current_user.group_id)
    @workshop = Workshop.find_by(:id => @group.workshop_id)
    @applications = Application.where(group_id: current_user.group_id)
    if params[:year].present? && params[:month].present?
      @year = params[:year].to_i
      @month = params[:month].to_i
    else
      @year = Time.now.year
      @month = Time.now.month
    end
    @shenhe_year = if Time.now.month == 1
                    (Time.now.year) - 1
                  else
                    Time.now.year
                  end

    @shenhe_month = if Time.now.month ==1
                      12
                    else
                      (Time.now.month) -1
                    end
    if (@year == @shenhe_year) && (@month == @shenhe_month) && (Time.now.day > 15)
      redirect_to group_attendances_path
      flash[:alert] = "当月15号前可查看上月考勤，当前为#{Time.now.day}号，不能查看！"
    end
    @shenhe_attdendance_status = AttendanceStatus.find_by(:year => @shenhe_year , :month => @shenhe_month,:group_id => @group.id)
    if (Time.now.day >3) && @shenhe_attdendance_status.present? && (@shenhe_attdendance_status.status == "班组/科室填写中")
      if @group.workshop_id == 1
        @shenhe_attdendance_status.update(:status => "科室已上报",:workshop_id => 1)
      else
        @shenhe_attdendance_status.update(:status => "班组已上报",:workshop_id => @group.workshop_id)
      end
    end
    @attendance_status = AttendanceStatus.find_by(:year => @year , :month => @month,:group_id => @group.id)
    if @attendance_status.blank?
      @attendance_status = AttendanceStatus.create(:year => @year , :month => @month,:group_id => @group.id,:workshop_id => @group.workshop_id,:status => "班组/科室填写中")
    end
    #提醒班组导出考勤表
    if (@shenhe_attdendance_status.status == "段已审核") && (Time.now.day < 16)
      @group_export_permission = 1
    else
      @group_export_permission = 0
    end
    #什么时候可以导出考勤：
    if params[:format] == "xls"
      if @attendance_status.status != "段已审核"
        redirect_to group_attendances_path
        flash[:alert] = "本月考勤还未被段管理员审核，不能导出，请等待段管理员审核完成后，再进行导出！"
      end
    end

#班组能填写考勤的时间段：
    if @attendance_status.status == "班组/科室填写中"
      if (@year == Time.now.year) && (@month == Time.now.month)
        if Time.now.day >= 8
          @time_range = (Time.now.day - 7)..(Time.now.day)
        else
          @time_range = 1..(Time.now.day)
        end
      elsif (@year == @shenhe_year) && (@month == @shenhe_month)
        if Time.now.day < 8
          day_end = "#{@year}-#{@month}-15".to_time.end_of_month.day
          day_begin = day_end - (7 - Time.now.day)
          @time_range = (day_begin..day_end)
        else
          @time_range = (0..0)
        end
      else
        @time_range = (0..0)
      end
    else
      if (@year == Time.now.year) && (@month == Time.now.month)
        if Time.now.day >= 8
          @time_range = (Time.now.day - 7)..(Time.now.day)
        else
          @time_range = 1..(Time.now.day)
        end
      else
        @time_range = (0..0)
      end
    end
# 结束

		@employees = Employee.current.where(:group => @group.id)
    @employees.each do |employee|
      if Time.now.month == 12
				attendance_next_month = Attendance.where(employee_id: employee.id, year: (Time.now.year + 1), month: 1)
        if !attendance_next_month.present?
					Attendance.create(employee_id: employee.id, group_id: employee.group, year: (Time.now.year + 1), month: 1)
        end
      else
        attendance_next_month = Attendance.where(employee_id: employee.id, year: (Time.now.year), month: (Time.now.month + 1))
        if !attendance_next_month.present?
					Attendance.create(employee_id: employee.id, group_id: employee.group, year: (Time.now.year), month: (Time.now.month + 1))
        end
      end
      attendance_this_month = Attendance.where(employee_id: employee.id, year: @year, month: @month)
      attendance_count_this_month = AttendanceCount.find_by(employee_id: employee.id, year: @year, month: @month)
      if !attendance_count_this_month.present?
        AttendanceCount.create(employee_id: employee.id, group_id: employee.group,:workshop_id =>employee.workshop , year: @year, month: @month)
      end
      if !attendance_this_month.present?
        Attendance.create(employee_id: employee.id, group_id: employee.group, year: @year, month: @month)
      end
    end
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h

		# 导出考勤表
		respond_to do |format|
	      format.html
	      format.csv { send_data @employees.to_csv }
	      format.xls { headers["Content-Disposition"] = 'attachment; filename="考勤表.xls"'}
	    end
	end
  #班组个人考勤统计
  def group_employee_detail
    @employee = Employee.current.find(params[:id])
    @group = Group.current.find(@employee.group)
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    if params[:year].present? && params[:month].present?
      @year = params[:year]
      @month = params[:month]
    else
      @year = Time.now.year
      @month = Time.now.month
    end
    @attendance = Attendance.find_by(employee_id: @employee.id, month: @month, year: @year)
    @attendance_count = AttendanceCount.find_by(employee_id: @employee.id, month: @month, year: @year)
    @attendance_statistics = Hash.new
    @attendance_count.attributes.each do |key,value|
      if value.present?
        @attendance_statistics[@vacation_name_hash[key]] = value
      else
        @attendance_statistics[@vacation_name_hash[key]] = 0
      end
    end
    if @attendance_statistics["加班"].present?
      @attendance_statistics["加班"] += @attendance.add_overtime.to_i
    elsif @attendance.add_overtime.to_i > 0
      @attendance_statistics["加班"] = @attendance.add_overtime.to_i
    end
  end

  #便捷填写考勤：
  def simple_input_attendance
    @group = Group.find_by(:id => params[:group_id])
    @employees = Employee.current.where(:group => params[:group_id])
    @vacation_short_code_hash = VacationCategory.pluck(:vacation_shortening,:vacation_code).to_h
  end
  #便捷填写考勤结束
  #班组一键填写考勤：
  def group_yijian_create

      @group = Group.find(params[:group_id])
      @year = params[:year].to_i
      @month = params[:month].to_i
      @day = params[:day].to_i
      @workshop = Workshop.find(@group.workshop_id)
      @vacation_name_hash = VacationCategory.pluck("vacation_shortening","vacation_code").to_h
      if params[:code].present?
        @employees = Employee.current.where(:group => @group.id)
        @attendances = Attendance.where(:employee_id => @employees.pluck(:id), :month => params[:month], :year => params[:year])
        @attendances.each do |attendance|
          employee = Employee.find_by(:id => attendance.employee_id)
          month_attendances = attendance.month_attendances
          month_attendances[params[:day].to_i] = @vacation_name_hash[params[:code]]
          attendance.update(:month_attendances => month_attendances)
          attendance_ary_after = attendance.month_attendances.split("")
          attendance_hash= {}
          #通过将所有的假期code和attendance_ary_after这个数组比对，做出一个所有的假期code和其出现次数的hash
          @vacation_name_hash.values.each do |code|
            attendance_hash[code] = attendance_ary_after.map{|x| x if x==code}.compact.count
          end
          #每次更新考勤数据，都更新一次总数(attendance_count)--开始
          #每次更新考勤数据，都更新一次年休假总数(annual_holiday)--开始
          @attendance_count = AttendanceCount.find_by(:employee_id => employee.id,  :month => @month, :year => @year)
          if !@attendance_count.present?
             AttendanceCount.create(:employee_id => employee.id, :group_id => @group.id, :workshop_id => @workshop.id, :month => @month, :year => @year)
          end
          @attendance_count.update(attendance_hash)
          annual_holiday = AnnualHoliday.find_by(employee_id: employee.id, month: @month, year: @year) || AnnualHoliday.new
          annual_holiday.update(employee_id: employee.id, month: @month, year: @year, holiday_days: ((@attendance_count.attributes["f"].to_i) +(@attendance_count.attributes["g"].to_i)))
        end
      else
        @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","_method","group_id","year","month","day"].include?(key) || (value =="")}
        @employees = Employee.current.where(:id => @params_hash.keys)
        @employees.each do |employee|
          attendance = Attendance.find_by(:employee_id => employee.id,:year => @year,:month => @month)
          month_attendances = attendance.month_attendances
          month_attendances[@day] = @params_hash[(employee.id).to_s]
          attendance.update!(:month_attendances => month_attendances)
          attendance_ary_after = attendance.month_attendances.split("")
          attendance_hash= {}
          @vacation_name_hash.values.each do |code|
            attendance_hash[code] = attendance_ary_after.map{|x| x if x==code}.compact.count
          end

          @attendance_count = AttendanceCount.find_by(:employee_id => employee.id,  :month => @month, :year => @year)
          if !@attendance_count.present?
             @attendance_count = AttendanceCount.create(:employee_id => employee.id, :group_id => @group.id, :workshop_id => @workshop.id, :month => @month, :year => @year)
          end
          @attendance_count.update(attendance_hash)
          annual_holiday = AnnualHoliday.find_by(employee_id: employee.id, month: @month, year: @year) || AnnualHoliday.new
          annual_holiday.update(employee_id: employee.id, month: @month, year: @year, holiday_days: ((@attendance_count.attributes["f"].to_i) + (@attendance_count.attributes["g"].to_i)))
        end
      end
      flash[:notice] = "一键考勤填写成功！"
      if !AttendanceStatus.find_by(:group_id => @group.id,:year => @year,:month => @month).present?
        AttendanceStatus.create(:group_id => @group.id,:workshop_id => @group.workshop_id,:year => @year,:month => @month, :status => "班组/科室填写中")
      end


      if (current_user.has_role? :groupadmin) or (current_user.has_role? :organsadmin) or (current_user.has_role? :wgadmin)
        redirect_to group_attendances_path(:year => @year,:month => @month)
      elsif (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin) || (current_user.has_role? :superadmin)
        redirect_to group_current_time_info_attendances_path(:group => @group.id,:year => @year,:month => @month)
      end
  end

  #班组考勤统计
  def group_statistics
    @year = params[:year].to_i
    @month = params[:month].to_i
    @shenhe_year = if Time.now.month == 1
                    (Time.now.year) - 1
                  else
                    Time.now.year
                  end

    @shenhe_month = if Time.now.month ==1
                      12
                    else
                      (Time.now.month) -1
                    end
    if (@year == @shenhe_year) && (@month == @shenhe_month) && (Time.now.day > 15)
      redirect_to group_statistics_attendances_path(:year => Time.now.year,:month => Time.now.month)
      flash[:alert] = "当月15号前可查看上月考勤统计，当前为#{Time.now.day}号，不能查看！"
    end
		group = Group.current.find(current_user.group_id)
		@employees = Employee.current.where(:group => group.id)
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
  end
	##班组页面--结束


  # 班组申请页面
  def group_application
    @year = params[:year]
    @month = params[:month]
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_hash = VacationCategory.pluck("vacation_name","vacation_code").to_h
    @group = Group.find_by(:id => params[:group_id])
    if @group.present?
      @employees = Employee.current.where(:group=> @group.id).order("employees.id ASC")
      @attendance_status = AttendanceStatus.find_by(:group_id => @group,:year => @year,:month => @month)
    end
    if (current_user.has_role? :groupadmin) || (current_user.has_role? :wgadmin)
      if (@attendance_status.status == "车间已审核") || (@attendance_status.status == "段已审核")
        redirect_to group_attendances_path(:year => @year,:month => @month)
        flash[:alert] = "#{@month}月考勤#{@attendance_status.status}，不能再申请修改，如有问题请联系车间！"
      end
    elsif current_user.has_role? :workshopadmin
      if !@group.present?
        redirect_to group_current_time_info_attendances_path(:year => @year,:month => @month)
        flash[:alert] = "必须选择一个班组进行考勤修改申请！"
      elsif (!@attendance_status.present?) || (@attendance_status.status == "班组/科室填写中") || (@attendance_status.status == "班组已上报")
        redirect_to group_current_time_info_attendances_path(:group => @group,:year => @year,:month => @month)
        flash[:warning] = "本月考勤尚未上报到段管理员，您可以直接修改考勤！无需申请！"
      end
    end
  end
  # 班组申请页面结束

  # 班组提交申请
  def group_application_form
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
    @year = params[:year].to_i
    @month = params[:month].to_i
    @day = params[:day].to_i
    @group_id = params[:group_id]
    if params[:type] == "更新"
      @employee = Employee.find(params[:employee_id])
      @month_attendances = Attendance.find_by(:employee_id => @employee.id, :month => @month, :year => @year)
      if @month_attendances.present?
        @month_attendances = @month_attendances.month_attendances
      else
        @month_attendances = []
      end
      @application = Application.where(:employee_id => @employee.id, :month => @month, :year => @year,:day => @day+1).last
    elsif params[:type] == "一键申请"
      @group = Group.find(params[:group_id])
      @employees = Employee.current.where(:group => @group.id)
      @employee_ids = []
      @employees.each do |employee|
        application = Application.where(:employee_id => employee.id, :month => @month, :year => @year,:day => @day+1).last
        if !application.present?
          @employee_ids << employee.id
        end
      end
      @employees_yijian = Employee.where(:id => @employee_ids)
    else
      @employee = Employee.find(params[:employee_id])
      @month_attendances = Attendance.find_by(:employee_id => @employee.id, :month => @month, :year => @year)
      if @month_attendances.present?
        @month_attendances = @month_attendances.month_attendances
      else
        @month_attendances = []
      end
    end

  end
  # 班组提交申请结束

  def create_application
    # 申请未被审核前，班组重复申请时：
    if params[:type] == "更新"
      @application = Application.find(params[:application_id])
      employee = Employee.find_by(:id => @application.employee_id)
      @application.update( :cause => params[:cause],:application_after => params[:application_after])
      flash[:notice] = "#{employee.name}#{@application.month}月#{@application.day}日考勤修改申请已重新发出！"
    elsif params[:type] == "一键申请"
      @group = Group.find(params[:group_id])
      @employees = Employee.current.where(:group => @group.id)
      yijian_array = []
      @employees.each do |employee|
        application = Application.where(:employee_id => employee.id, :month => params[:month], :year => params[:year],:day => params[:day])
        @month_attendances = Attendance.find_by(:employee_id => employee.id, :month => params[:month], :year => params[:year])
        if !application.present?
          Application.create(:group_id => params[:group_id], :employee_id => employee.id, :year => params[:year], :month => params[:month], :day => params[:day], :cause => params[:cause],
                             :apply_person => params[:apply_person], :status => params[:status],:application_before => @month_attendances[(params[:day].to_i - 1)],:application_after => params[:application_after])
          yijian_array << "true"
        end
      end
      if !yijian_array.include?("true")
        flash[:alert] = "#{params[:month]}月#{params[:day]}日所有人均已发送过申请，无法使用一键功能，如需修改，请逐一申请！"
      else
        flash[:notice] = "#{@group.name}于#{params[:month]}月#{params[:day]}日成功为所有人发起考勤修改申请！"
      end
    else
      employee = Employee.find_by(:id => params[:employee_id])
   		Application.create(:group_id => params[:group_id], :employee_id => params[:employee_id], :year => params[:year], :month => params[:month], :day => params[:day], :cause => params[:cause],
                         :apply_person => params[:apply_person], :status => params[:status],:application_before => params[:application_before],:application_after => params[:application_after])
      flash[:notice] = "#{employee.name}#{params[:month]}月#{params[:day]}日考勤修改申请已成功发出！"
    end

 		redirect_to group_application_attendances_path(:year => params[:year],:month => params[:month],:group_id => params[:group_id] )
 	end

  def update_application
    # 申请未被审核前，班组重复申请时：
    if params[:type] == "duan"
      if params[:yijian] == "duan"
        @applications = Application.where(:status => ["科室发起申请","车间发起申请"])
        @applications.update(:status => params[:status],application_pass: 1)
        @applications.each do |application|
          if application.application_after.present?
            employee = Employee.find_by(:id => application.employee_id)
            attendance = Attendance.find_by(:employee_id => application.employee_id,:year => application.year, :month => application.month)
            month_attendances = attendance.month_attendances
            month_attendances[(application.day - 1)] = application.application_after
            attendance.update(:month_attendances => month_attendances)
            attendance_count_after = AttendanceCount.find_by(employee_id: application.employee_id,:year => application.year, :month => application.month)
            if attendance_count_after.present?
              attendance_count_after.update(application.application_after => ((attendance_count_after.attributes[application.application_after].to_i) +1))
            else
              AttendanceCount.create(employee_id: application.employee_id,:year => application.year, :month => application.month,:group_id => employee.group,:workshop_id => employee.workshop,application.application_after => 1)
            end
          end
          if application.application_before.present? && (application.application_before != "x")
            attendance_count_before = AttendanceCount.find_by(employee_id: application.employee_id,:year => application.year, :month => application.month)
            if attendance_count_before.present?
              attendance_count_before.update(application.application_before => ((attendance_count_before.attributes[application.application_before].to_i) -1))
            end
          end
        end
        flash[:notice] = "已成功一键通过所有申请!"
      else
        @application = Application.find(params[:application_id])
     		@application.update(:status => params[:status],application_pass: 1)
        if @application.application_after.present?
          employee = Employee.find_by(:id => @application.employee_id)
          attendance = Attendance.find_by(:employee_id => @application.employee_id,:year => @application.year, :month => @application.month)
          month_attendances = attendance.month_attendances
          month_attendances[(@application.day - 1)] = @application.application_after
          attendance.update(:month_attendances => month_attendances)
          attendance_count_after = AttendanceCount.find_by(employee_id: @application.employee_id,:year => @application.year, :month => @application.month)
          if attendance_count_after.present?
            attendance_count_after.update(@application.application_after => ((attendance_count_after.attributes[@application.application_after].to_i) +1))
          else
            AttendanceCount.create(employee_id: @application.employee_id,:year => @application.year, :month => @application.month,:workshop_id => employee.workshop,:group_id =>employee.group ,@application.application_after => 1)
          end
        end
        if @application.application_before.present? && (@application.application_before != "x")
          attendance_count_before = AttendanceCount.find_by(employee_id: @application.employee_id,:year => @application.year, :month => @application.month)
          if attendance_count_before.present?
            attendance_count_before.update(@application.application_before => ((attendance_count_before.attributes[@application.application_before].to_i) -1))
          end
        end
        flash[:notice] = "关于#{employee.name}的考勤修改申请已通过!"
      end
    else
      if params[:yijian] == "workshop"
        groups = Group.current.where(:workshop_id => params[:type])
        @applications = Application.where(:group_id => groups.ids,:status => "班组发起申请")
        @applications.update(:status => params[:status],application_pass: 1)
        @applications.each do |application|
          if application.application_after.present?
            employee = Employee.find_by(:id => application.employee_id)
            attendance = Attendance.find_by(:employee_id => application.employee_id,:year => application.year, :month => application.month)
            month_attendances = attendance.month_attendances
            month_attendances[(application.day - 1)] = application.application_after
            attendance.update(:month_attendances => month_attendances)
            attendance_count_after = AttendanceCount.find_by(employee_id: application.employee_id,:year => application.year, :month => application.month)
            if attendance_count_after.present?
              attendance_count_after.update(application.application_after => ((attendance_count_after.attributes[application.application_after].to_i) +1))
            else
              AttendanceCount.create(employee_id: application.employee_id,:year => application.year, :month => application.month,:group_id => employee.group,:workshop_id => employee.workshop,application.application_after => 1)
            end
          end
          if application.application_before.present? && (application.application_before != "x")
            attendance_count_before = AttendanceCount.find_by(employee_id: application.employee_id,:year => application.year, :month => application.month)
            if attendance_count_before.present?
              attendance_count_before.update(application.application_before => ((attendance_count_before.attributes[application.application_before].to_i) -1))
            end
          end
        end
        flash[:notice] = "已成功一键通过所有申请!"
      else
        @application = Application.find_by(:id => params[:application_id])
     		@application.update(:status => params[:status],application_pass: 1)
        if @application.application_after.present?
          employee = Employee.find_by(:id => @application.employee_id)
          attendance = Attendance.find_by(:employee_id => @application.employee_id,:year => @application.year, :month => @application.month)
          month_attendances = attendance.month_attendances
          month_attendances[(@application.day - 1)] = @application.application_after
          attendance.update(:month_attendances => month_attendances)
          attendance_count_after = AttendanceCount.find_by(employee_id: @application.employee_id,:year => @application.year, :month => @application.month)
          if attendance_count_after.present?
            attendance_count_after.update(@application.application_after => ((attendance_count_after.attributes[@application.application_after].to_i) +1))
          else
            AttendanceCount.create(employee_id: @application.employee_id,:year => @application.year, :month => @application.month,:workshop_id => employee.workshop,:group_id =>employee.group ,@application.application_after => 1)
          end
        end
        if @application.application_before.present? && (@application.application_before != "x")
          attendance_count_before = AttendanceCount.find_by(employee_id: @application.employee_id,:year => @application.year, :month => @application.month)
          if attendance_count_before.present?
            attendance_count_before.update(@application.application_before => ((attendance_count_before.attributes[@application.application_before].to_i) -1))
          end
        end
        flash[:notice] = "关于#{employee.name}的考勤修改申请已通过!"
      end
    end

 		redirect_back(fallback_location: show_application_attendances_path)
 	end

 	def show_application

    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
    if current_user.has_role? :attendance_admin
      @applications = Application.where(:status => ["车间发起申请","科室发起申请"]).order("created_at DESC")
      if @applications.blank?
        @applications = Application.where(:status => "段通过申请").order("created_at DESC")
      end
    elsif current_user.has_role? :workshopadmin
      groups = Group.current.where(:workshop_id => current_user.workshop_id)
      @applications = Application.where(:group_id => groups.ids,:status => "班组发起申请").order("created_at DESC")
      if @applications.blank?
        @applications = Application.where(:group_id => groups.ids,:status => "车间通过申请").order("created_at DESC")
      end
    elsif (current_user.has_role? :groupadmin) || (current_user.has_role? :organsadmin) || (current_user.has_role? :wgadmin)
      @applications = Application.where(:group_id => current_user.group_id,:status => "班组发起申请").order("created_at DESC")
      if @applications.blank?
        @applications = Application.where(:group_id => current_user.group_id).order("created_at DESC")
      end
    end

 	end



 	def show_application_detail
 		@application = params[:application]
 		respond_to do |format|
			format.js
		end
 	end


	def create_default_attendance
		# Employee.pluck("id").uniq.each do |i|
		# 	if Time.now.month == 12
		# 		attendance = Attendance.where(employee_id: i, year: Time.now.year + 1, month: 1)
		# 		if !attendance.present?
		# 			Attendance.create(employee_id: i, group_id: Employee.find(i).group, year: Time.now.year + 1, month: 1)
		# 			attendance_status = AttendanceStatus.find_by(group_id: Employee.find(i).group) || AttendanceStatus.new
		# 			attendance_status.update(group_id: Employee.find(i).group, status: "班组/科室填写中")
		# 		end
		# 	else
		# 		attendance = Attendance.where(employee_id: i, year: Time.now.year, month: Time.now.month + 1)
		# 		if !attendance.present?
		# 			Attendance.create(employee_id: i, group_id: Employee.find(i).group, year: Time.now.year, month: Time.now.month+1)
					# attendance_status = AttendanceStatus.find_by(group_id: Employee.find(i).group) || AttendanceStatus.new
					# attendance_status.update(group_id: Employee.find(i).group, status: "班组/科室填写中")
		# 		end
		# 	end
		# 	flash[:notice] = "下月考勤表新增成功"
		# end
		redirect_back(fallback_location: duan_attendances_path)
	end

	##弹窗内选择假期的表单功能--开始
	def create_attendance
		#选择假期确定后存入attendance表中--开始
		#根据表单传来的employee_id参数，找到要更新的考勤数据
    if params[:overtime].present?
      @employee = Employee.find(params[:employee_id])
      @attendance = Attendance.find_by(:employee_id => params[:employee_id], :month => params[:month], :year => params[:year])
      @attendance.update(:add_overtime => params[:overtime])
      flash[:notice] = "#{@employee.name}#{params[:year]}年#{params[:month]}月额外加班数更新成功！"
      if (current_user.has_role? :groupadmin) or (current_user.has_role? :organsadmin) or (current_user.has_role? :wgadmin)
        group_id = @employee.group
				redirect_to group_attendances_path(:year => params[:year],:month => params[:month],:group => group_id)
			elsif (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin) || (current_user.has_role? :superadmin)
        group_id = Employee.current.find_by(:id => params[:employee_id]).group
				redirect_to group_current_time_info_attendances_path(:year => params[:year],:month => params[:month],:group => group_id )
			end
		elsif !params[:code].present?
			flash[:alert] = "请先选择考勤"
			if (current_user.has_role? :groupadmin) || (current_user.has_role? :organsadmin) || (current_user.has_role? :wgadmin)
				redirect_back(fallback_location: group_attendances_path)
			elsif (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin) || (current_user.has_role? :superadmin)
				redirect_back(fallback_location: group_current_time_info_attendances_path)
			end
		else
			@attendance = Attendance.find_by(:employee_id => params[:employee_id], :month => params[:month], :year => params[:year])
			if (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin)
				AttendanceRecord.create(edit_before: @attendance.month_attendances[params[:day].to_i], edit_after: params[:code], modify_person: current_user.name, day: (params[:day].to_i + 1), attendance_id: @attendance.id)
			end
			#若当前用户是考勤管理员时，则存下修改记录--结束
			if current_user.has_role? :workshopadmin
				Message.create(user_id: "3", message_type: "修改考勤", have_read: "0", remind_time: Time.now, message: "#{current_user.name}修改了#{Employee.find(params[:employee_id]).name}#{params[:year]}年#{params[:month]}月#{params[:day].to_i+1}的考勤数据")
			end
      @month_attendances_before = Attendance.find_by(:employee_id => params[:employee_id], :month => params[:month], :year => params[:year]).month_attendances
      @month_attendances_after = Attendance.find_by(:employee_id => params[:employee_id], :month => params[:month], :year => params[:year]).month_attendances
      @month_attendances_after[params[:day].to_i] = params[:code]

			attendance_ary_after = @month_attendances_after.split("")

      employee = Employee.find_by(:id => params[:employee_id])

			@attendance_count = AttendanceCount.find_by(:employee_id => params[:employee_id], :month => params[:month], :year => params[:year])

      if @attendance_count.present?
        @attendance_count_attributes = @attendance_count.attributes
        if @month_attendances_before[params[:day].to_i] == "x"
          @attendance_count.update(params[:code] => ((@attendance_count_attributes[params[:code]].to_i) +1))
          @attendance_count.save
        else
          @attendance_count.update(params[:code] => ((@attendance_count_attributes[params[:code]].to_i) +1))
          @attendance_count.save
          @attendance_count_attributes = @attendance_count.attributes
          @attendance_count.update(@month_attendances_before[params[:day].to_i] => ((@attendance_count_attributes[@month_attendances_before[params[:day].to_i]].to_i) -1))
          @attendance_count.save
        end

      else
				@attendance_count = AttendanceCount.create(:employee_id => params[:employee_id], params[:code] => 1, :group_id => employee.group, :workshop_id => employee.workshop, :month => params[:month], :year => params[:year],params[:code] => 1)
      end
      @attendance.update(:month_attendances => @month_attendances_after)
      @attendance.save
      attendance_count_attributes = @attendance_count.attributes
			annual_holiday = AnnualHoliday.find_by(employee_id: params[:employee_id], month: params[:month], year: params[:year]) || AnnualHoliday.new
			annual_holiday.update(employee_id: params[:employee_id], month: params[:month], year: params[:year], holiday_days: ((attendance_count_attributes["f"].to_i) + (attendance_count_attributes["g"].to_i)))

      group_id = Employee.current.find_by(:id => params[:employee_id]).group
      flash[:notice] = "考勤修改成功！"
			if (current_user.has_role? :groupadmin) or (current_user.has_role? :organsadmin) or (current_user.has_role? :wgadmin)

				redirect_to group_attendances_path(:year => params[:year],:month => params[:month],:group => group_id)
			elsif (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin) || (current_user.has_role? :superadmin)
        group_id = Employee.current.find_by(:id => params[:employee_id]).group
				redirect_to group_current_time_info_attendances_path(:year => params[:year],:month => params[:month],:group => group_id )
			end
		end
	end

	##使用ajax动态呼叫弹框功能--开始
	def show_modal
		@day_number = params[:day_number]
		@employee_id = params[:employee_id]
		@year = params[:year]
		@month = params[:month]
		@type = params[:type]
    @overtime = params[:overtime]
		@categories = VacationCategory.all
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
		respond_to do |format|
			format.js
		end
	end
	##使用ajax动态呼叫弹框功能--结束

	def filter
    if Time.now.day >= 8
      @time_range = (Time.now.day - 7)..(Time.now.day)
    else
      @time_range = 1..(Time.now.day)
    end

		@year = params[:year]
		@month = params[:month]
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
		if params[:type] == "group"
			@group = Group.current.find(current_user.group_id)

			@leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)
			transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: @group.id).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: @group.id).pluck("employee_id")
			@employees = Employee.where(id: transfer_employees) | Employee.current.where(:group => @group.id)
			render action: "group"
		elsif params[:type] == "workshop"
			@workshop = Workshop.current.find(current_user.workshop_id)
			@groups = Group.current.where(:workshop_id => @workshop.id)
      @choose_group = params[:group]
  		@choose_workshop = params[:workshop]
			@leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)
			transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_workshop: @workshop.id).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_workshop: @workshop.id).pluck("employee_id")
			@employees = Employee.where(id: transfer_employees) | Employee.current.where(:workshop => @workshop.id)
			render action: "workshop"
		elsif params[:type] == "duan"
			@workshops = Workshop.current
      @duan = params[:duan]
      @workshop = params[:workshop]
      @group = params[:workshop]
      @leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)

  		@employees = Employee.current.where(id: transfer_employees) | Employee.current.where(:group => params[:group])
      if params[:workshop].present?
        transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_workshop: params[:workshop]).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_workshop: params[:workshop]).pluck("employee_id")
        @employees = Employee.current.where(id: transfer_employees) | Employee.current.where(:workshop => params[:workshop])
      elsif params[:group].present?
        transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: @group).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: @group).pluck("employee_id")
        @employees = Employee.current.where(id: transfer_employees) | Employee.current.where(:group => params[:group])
      else
        transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: 593).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: 593).pluck("employee_id")
        @employees = Employee.current.where(group: 593)
      end
			render action: "duan"
		end
	end

    ##车间页面--开始
	def workshop
		#为展示组织架构的树状图配置数据
    if params[:year].present? && params[:month].present?
      @year = params[:year].to_i
      @month = params[:month].to_i
    else
      @year = Time.now.year
      @month = Time.now.month
    end
		if current_user.has_role? :workshopadmin
			@workshop = Workshop.current.find(current_user.workshop_id)
			@groups = Group.current.where(workshop_id: @workshop.id)
		else
			@workshop = Group.current.find(current_user.group_id)
			@groups = @workshop
		end
		#根据用户点击组织架构树状图来筛选展示的现员--开始
		@choose_group = params[:group]
		@choose_workshop = params[:workshop]
		if params[:group].present?
			@employees = Employee.current.where(:workshop => params[:workshop], :group => params[:group])
		else
			@employees =Employee.current.where(:workshop => @workshop)
		end

			#根据用户点击组织架构树状图捞出该班组的审核状态，用于展示
			if AttendanceStatus.find_by(:group_id => params[:group]).present?
				@status = AttendanceStatus.find_by(:group_id => params[:group]).status
			end

		#根据用户点击组织架构树状图来筛选展示的现员--结束
		#为了使审核按钮知道当前哪个班组在被审核，将用户点击组织架构树状图产生的参数重新传入views页面，供审核按钮使用
		@click_group = params[:group]
		#配置页面上统计考勤的表格数据
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
	end
	##车间页面--结束

	##审核功能--开始
	def verify
    @year = params[:year].to_i
    @month = params[:month].to_i
    @employee = Employee.where(:group => params[:group_id]).last
    @group_id = params[:group_id]
    @shenhe_year = if Time.now.month == 1
                    (Time.now.year) - 1
                  else
                    Time.now.year
                  end

    @shenhe_month = if Time.now.month ==1
                      12
                    else
                      (Time.now.month) -1
                    end
    if  params[:authority] == "group"
      @group = Group.find_by(:id => @group_id)
      @employees = Employee.where(:group => @group_id)
      last_day_of_month = "#{@year}-#{@month}-15".to_time.end_of_month.day
      day_range = (1..last_day_of_month)
      @message = Hash.new
      @employees.each do |employee|
        attendance = Attendance.find_by(:year => @year,:month => @month,:group_id => @group_id)
        month_attendances = attendance.month_attendances
        (0..(last_day_of_month-1)).each do |day|
          if month_attendances[day] == "x"
            @message[employee.name] = day + 1
          end
        end
      end
      if @message.present?
        flash[:alert] = "您本月尚有未完成考勤，不能上报！如：#{@message.first[0]}，第#{@message.first[1]}天未填写..."
      else
        @attendance_status = AttendanceStatus.find_by(:year => @year,:month => @month,:group_id => @group_id)
        if @attendance_status.present?
          if (@attendance_status.status != "班组/科室填写中")
            flash[:warning] = "#{@group.name}#{@year}年#{@month}月考勤已上报，不可重复上报！"
          elsif @group.workshop_id == 1
            @attendance_status.update(:status => "科室已上报")
            flash[:notice] = "#{@group.name}#{@year}年#{@month}月考勤上报成功！"
          else
            @attendance_status.update(:status => "班组已上报")
            flash[:notice] = "#{@group.name}#{@year}年#{@month}月考勤上报成功！"
          end
        else
          if @group.workshop_id == 1
            AttendanceStatus.create(:year => @year,:month => @month,:group_id => @group_id,:workshop_id => @group.workshop_id,:status => "科室已上报")
          else
            AttendanceStatus.create(:year => @year,:month => @month,:group_id => @group_id,:workshop_id => @group.workshop_id,:status => "班组已上报")
          end
          flash[:notice] = "#{@group.name}#{@year}年#{@month}月考勤上报成功！"
        end

      end
      redirect_to group_attendances_path(:year => @year,:month => @month)
		elsif  params[:authority] == "workshop"
      if (Time.now.month == 2) || (Time.now.month == 10)
        @shenhe_day = 1..8
      else
        @shenhe_day = 1..6
      end
			@workshop = Workshop.find(current_user.workshop_id)
      group = Group.find_by(:id => params[:group_id])
      application = Application.where(:month => @shenhe_month,:year => @shenhe_year,:group_id => params[:group_id]).pluck(:application_pass)
      if @shenhe_day === Time.now.day
        if application.include?(0)
          flash[:warning] = "#{group.name}还有考勤修改申请未通过，请先处理完申请后再审核！"
        else
    			AttendanceStatus.find_by(:month => @shenhe_month,:year => @shenhe_year,:group_id => params[:group_id]).update(:status => "车间已审核",:workshop_id => @workshop.id)
    			flash[:notice] = "#{group.name}审核完成!"
        end
      else
        flash[:alert] = "您已过了考勤审核时间，审核时间为：#{@shenhe_day.first}～#{@shenhe_day.last}号"
      end
      redirect_to workshop_verify_index_attendances_path(:group_id => group.id)

		elsif params[:authority] == "duan"
      group = Group.find_by(:id => params[:group_id])
      application = Application.where(:month => @shenhe_month,:year => @shenhe_year,:group_id => params[:group_id]).pluck(:application_pass)
      if application.include?(0)
        flash[:warning] = "#{group.name}还有考勤修改申请未通过，请先处理完申请后再审核！"
      else
        AttendanceStatus.find_by(:month => @shenhe_month,:year => @shenhe_year,:group_id => params[:group_id]).update(:status => "段已审核")
		  	flash[:notice] = "#{group.name}审核完成!"
      end
      redirect_to workshop_verify_index_attendances_path(:group_id => group.id)
		end
	end
	##审核功能--结束

    ##一键审核功能--开始
	def batch_verify
    @shenhe_year = if Time.now.month == 1
                    (Time.now.year) - 1
                  else
                    Time.now.year
                  end

    @shenhe_month = if Time.now.month ==1
                      12
                    else
                      (Time.now.month) -1
                    end
		if params[:authority] == "workshop"
			@workshop = Workshop.find(current_user.workshop_id)
			@groups = Group.current.where(:workshop_id => @workshop.id)
      application = Application.where(:month => @shenhe_month,:year => @shenhe_year,:group_id => @groups.ids).pluck(:application_pass)
      if application.include?(0)
        flash[:warning] = "#{@workshop.name}还有考勤修改申请未通过，请先处理完申请后再审核！"
        redirect_to workshop_verify_index_attendances_path
      else
	      AttendanceStatus.where(:group_id => @groups.ids,:year => @shenhe_year,:month => @shenhe_month,:status => "班组已上报").update(:status => "车间已审核", :workshop_id => @workshop.id)
        flash[:notice] = "#{@workshop.name}一键审核完毕"
        redirect_to workshop_verify_index_attendances_path
      end
		elsif params[:authority] == "duan"
			@workshop = Workshop.find(params[:workshop_id])
			@groups = Group.current.where(:workshop_id => @workshop.id)
      application = Application.where(:month => @shenhe_month,:year => @shenhe_year,:group_id => @groups.ids).pluck(:application_pass)
      if application.include?(0)
        flash[:warning] = "#{@workshop.name}还有考勤修改申请未通过，请先处理完申请后再审核！"
        redirect_to workshop_verify_index_attendances_path
      else
        if @workshop.id == 1
          AttendanceStatus.where(:group_id => @groups.ids,:year => @shenhe_year,:month => @shenhe_month,:status => "科室已上报").update(:status => "段已审核", :workshop_id => @workshop.id)
        else
          AttendanceStatus.where(:group_id => @groups.ids,:year => @shenhe_year,:month => @shenhe_month,:status => "车间已审核").update(:status => "段已审核", :workshop_id => @workshop.id)
        end
        flash[:notice] = "#{@workshop.name}一键审核完毕"
        redirect_to workshop_verify_index_attendances_path(:group_id => @groups.first.id)
      end
		end
	end
	##一键审核功能--结束

	##段管理员页面--开始
	def duan
    if params[:year].present? && params[:month].present?
      @year = params[:year].to_i
      @month = params[:month].to_i
    else
      @year = Time.now.year
      @month = Time.now.month
    end
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
    @workshops = Workshop.current
    @leaving_employees = Employee.transfer_search("#{@year}-#{@month}-01".to_datetime.beginning_of_month, "#{@year}-#{@month}-01".to_datetime.end_of_month)
    if params[:workshop].present?
      transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_workshop: params[:workshop]).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_workshop: params[:workshop]).pluck("employee_id")
      @employees = Employee.current.where(id: transfer_employees) | Employee.current.where(:workshop => params[:workshop])
    elsif params[:group].present?
      transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: @group).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: @group).pluck("employee_id")
      @employees = Employee.current.where(id: transfer_employees) | Employee.current.where(:group => params[:group])
    else
      transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: 593).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: 593).pluck("employee_id")
      @employees = Employee.current.where(group: 593)
    end

    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
	end
	##段管理员页面--结束

	##点击段页面的表格数字后显示的详情页面--开始
	def duan_detail
		@duan_detail = {}
		attendance_counts = AttendanceCount.where(:group_id => params[:group], month: params[:month], year: params[:year])
		attendance_counts.each do |attendance_count|
			employee_name = Employee.current.find_by(:id => attendance_count.employee_id).name
			employee_count = attendance_count.attributes[params[:code]]
			@duan_detail[employee_name] = employee_count
		end
	end
	##点击段页面的表格数字后显示的详情页面--结束

	##使用ajax呼叫modal弹框的方法--开始
	def processbar_detail

		@workshops_varified = Workshop.find(params[:workshops])
    @workshops_not_varified = Workshop.where.not(:id => @workshops_varified.pluck(:id))
		respond_to do |format|
			format.js
		end
	end
	##使用ajax呼叫modal弹框的方法--结束

	##段管理员看到的年考勤统计页面--开始
	def annual_statistic
		@workshops = Workshop.current
		@count = {}
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
	end
	##段管理员看到的年考勤统计页面--结束

	def create_setting
		attendance_setting = AttendanceSetting.find_by(:vacation => params[:vacation]) || AttendanceSetting.new
		attendance_setting.update(:vacation => params[:vacation], :count => params[:count])
		flash[:notice] = "已增加此权限"
		redirect_to setting_attendances_path
 	end



	def group_current_time_info

    @shenhe_year = if Time.now.month == 1
                    (Time.now.year) - 1
                  else
                    Time.now.year
                  end

    @shenhe_month = if Time.now.month ==1
                      12
                    else
                      (Time.now.month) -1
                    end
    if params[:year].present? && params[:month].present?
      @year = params[:year].to_i
      @month = params[:month].to_i
    else
      @year = Time.now.year
      @month = Time.now.month
    end
    @group = params[:group]
		@workshop = params[:workshop]
    @duan = params[:duan]
    @vacation_codes = VacationCategory.pluck("vacation_code").uniq
		status_workshop = AttendanceStatus.where(:year => @shenhe_year,:month => @shenhe_month,:status => ["科室已上报","车间已审核"]).pluck("workshop_id").uniq
		if status_workshop.all?{|x| x.nil?}
			@workshops = []
		else
			@workshops = Workshop.current.find(status_workshop)
		end
    workshops_not_varify = Workshop.current.where.not(id: status_workshop)
    workshops_all_varified = []
    workshops_not_varify.each do |workshop|
      group_ids = Group.current.where(:workshop_id => workshop.id).ids
      if AttendanceStatus.where(:group_id => group_ids,:year => @shenhe_year,:month => @shenhe_month,:status => "段已审核").count == group_ids.count
        workshops_all_varified << workshop.id
      end
    end
    @workshops_all_varified = Workshop.current.where(id: workshops_all_varified)
    @workshops_not_varify = Workshop.current.where.not(id: (status_workshop + workshops_all_varified))

    if (current_user.has_role? :attendance_admin) || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin)
      if (Time.now.month == 2) || (Time.now.month == 10)
        @shenhe_day = 1..31
      else
        @shenhe_day = 1..31
      end
      if AttendanceStatus.where(:year => @shenhe_year, :month => @shenhe_month,:status => ["车间已审核","科室已上报"]).present?
        @attendance_marquee = 1
      end
      groups = Group.current.where(:workshop_id => 1)
      @shenhe_attdendance_status = AttendanceStatus.where(:year => @shenhe_year , :month => @shenhe_month,:group_id => groups.ids,:status => "班组/科室填写中")
      if (Time.now.day >3) && @shenhe_attdendance_status.present?
          @shenhe_attdendance_status.update(:status => "科室已上报",:workshop_id => 1)
      end
      @applications = Application.where(:status => ["车间发起申请","科室发起申请"])
    elsif current_user.has_role? :workshopadmin
      if (Time.now.month == 2) || (Time.now.month == 10)
        @shenhe_day = 1..8
      else
        @shenhe_day = 1..6
      end
      groups = Group.current.where(:workshop_id => current_user.workshop_id)
      @shenhe_attdendance_status = AttendanceStatus.where(:year => @shenhe_year , :month => @shenhe_month,:group_id => groups.ids,:status => "班组/科室填写中")
      if (Time.now.day >3) && @shenhe_attdendance_status.present?
          @shenhe_attdendance_status.update(:status => "班组已上报")
      end
      if AttendanceStatus.where(:year => @shenhe_year, :month => @shenhe_month,:group_id => groups.ids,:status => "班组已上报").present? && (@shenhe_day === Time.now.day)
        @attendance_marquee = 1
      end
      @applications = Application.where(:group_id => groups.ids,:status => "班组发起申请")
    end


		if params[:workshop].present?
      @select_workshop = params[:workshop].to_i
      @groups = Group.current.where(:workshop_id => params[:workshop])
      if (@year ==@shenhe_year) && (@month == @shenhe_month)
        if current_user.has_role? :attendance_admin
          if AttendanceStatus.where(:year => @year, :month => @month,:group_id => @groups.ids,:status => ["车间已审核","科室已上报"]).present?
            @duan_yijian_permission = 1
          end
        elsif current_user.has_role? :workshopadmin
          if AttendanceStatus.where(:year => @year, :month => @month,:group_id => @groups.ids,:status => "班组已上报").present?
            @duan_yijian_permission = 1
          end
        end
      end
			   @employees = Employee.current.where(:workshop => params[:workshop]).order('employees.group ASC,employees.id ASC')
		elsif params[:group].present?
      group = Group.find(params[:group])
      @select_workshop = group.workshop_id
      if AttendanceStatus.where(:year => @year, :month => @month,:group_id => params[:group]).blank?
        AttendanceStatus.create(:year => @year, :month => @month,:group_id => params[:group],:workshop_id => group.workshop_id,:status => "班组/科室填写中")
      end
			@employees = Employee.current.where(:group => params[:group]).order('employees.group ASC,employees.id ASC')
      @employees.each do |employee|
        attendance_this_month = Attendance.where(employee_id: employee.id, year: @year, month: @month)
        attendance_count_this_month = AttendanceCount.find_by(employee_id: employee.id, year: @year, month: @month)
        if !attendance_count_this_month.present?
          AttendanceCount.create(employee_id: employee.id, group_id: employee.group,:workshop_id =>employee.workshop , year: @year, month: @month)
        end
        if !attendance_this_month.present?
          Attendance.create(employee_id: employee.id, group_id: employee.group, year: @year, month: @month)
        end
      end
		else
      if (current_user.has_role? :attendance_admin) || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin)
        @group = 593
        @select_workshop = 1
        @employees = Employee.current.where(:group => @group).order('employees.group ASC,employees.id ASC')
      elsif current_user.has_role? :workshopadmin
        @groups = Group.current.where(:workshop_id => current_user.workshop_id)
        @group = @groups.first.id
        if (@year ==@shenhe_year) && (@month == @shenhe_month)
          if AttendanceStatus.where(:year => @year, :month => @month,:group_id => @groups.ids,:status => "班组已上报").present? && (@shenhe_day === Time.now.day)
            @workshop_yijian_permission = 1
          end
        end
				@employees = Employee.current.where(:group => @group).order('employees.group ASC,employees.id ASC')
      end
		end


	end

	def caiwu
    if params[:year].present? && params[:month].present?
      @year = params[:year].to_i
      @month = params[:month].to_i
    else
      @year = Time.now.year
      @month = Time.now.month
    end
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		@vacation_codes = ["e","f","i","j","o","n","k","l","s","r"]

		@employees = Employee.current.order('employees.workshop ASC,employees.group ASC').page(params[:page]).per(20)

		# 导出考勤表

		@export_employees = Employee.current.order("employees.workshop ASC,employees.group ASC")
		respond_to do |format|
	      format.html
	      format.csv { send_data @export_employees.to_csv }
	      format.xls { headers["Content-Disposition"] = 'attachment; filename="给财务的表-1.xls"'}
	    end
	end

	def create_holiday_time
		if Employee.current.find_by(:sal_number => params[:sal_number]).nil?
			flash[:alert] = "工资号不存在"
		else
			if Employee.current.find_by(:sal_number => params[:sal_number]).name == params[:name]
				holiday_start_time = HolidayStartTime.find_by(sal_number: params[:sal_number], vacation: params[:vacation], start_time: params[:start_time]) || HolidayStartTime.new
				holiday_start_time.update(sal_number: params[:sal_number], vacation: params[:vacation], start_time: params[:start_time], name: params[:name])
				flash[:notice] = "设置成功"

				if (holiday_start_time.vacation == "病假") or (holiday_start_time.vacation == "育儿假")
					Message.create(user_id: "3", message_type: "休假提醒", have_read: "0", remind_time: "#{holiday_start_time.start_time + 10368000}", message: "#{holiday_start_time.name}的#{holiday_start_time.vacation}还有两个月到期哦")
					Message.create(user_id: "3", message_type: "休假提醒", have_read: "0", remind_time: "#{holiday_start_time.start_time + 12860000}", message: "#{holiday_start_time.name}的#{holiday_start_time.vacation}还有一个月到期哦")
				elsif holiday_start_time.vacation == "产假(顺产)"
					Message.create(user_id: "3", message_type: "休假提醒", have_read: "0", remind_time: "#{holiday_start_time.start_time + 16243200}", message: "#{holiday_start_time.name}的#{holiday_start_time.vacation}还有两个月到期哦")
					Message.create(user_id: "3", message_type: "休假提醒", have_read: "0", remind_time: "#{holiday_start_time.start_time + 18835200}", message: "#{holiday_start_time.name}的#{holiday_start_time.vacation}还有一个月到期哦")
				elsif holiday_start_time.vacation == "产假(剖腹)"
					Message.create(user_id: "3", message_type: "休假提醒", have_read: "0", remind_time: "#{holiday_start_time.start_time + 17539200}", message: "#{holiday_start_time.name}的#{holiday_start_time.vacation}还有两个月到期哦")
					Message.create(user_id: "3", message_type: "休假提醒", have_read: "0", remind_time: "#{holiday_start_time.start_time + 20131200}", message: "#{holiday_start_time.name}的#{holiday_start_time.vacation}还有一个月到期哦")
				end
			else
				flash[:alert] = "姓名和工资号不匹配，请检查"
			end
		end
		redirect_back(fallback_location: set_holiday_start_time_attendances_path)
	end

	def caiwu2
    if params[:year].present? && params[:month].present?
      @year = params[:year].to_i
      @month = params[:month].to_i
    else
      @year = Time.now.year
      @month = Time.now.month
    end
    @years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		@employees = Employee.current.order("employees.workshop ASC,employees.group ASC").page(params[:page]).per(20)
		@export_employees = Employee.current.order("employees.workshop ASC,employees.group ASC")
		# 导出考勤表
		respond_to do |format|
	      format.html
	      format.csv { send_data @export_employees.to_csv }
	      format.xls { headers["Content-Disposition"] = 'attachment; filename="给财务的表-2.xls"'}
	    end
	end

  def show_record
    @category_name_hash = VacationCategory.pluck(:vacation_code, :vacation_name).to_h
  end

#一键计算所有当月所有考勤统计
  def attendance_count_compute
    @employees = Employee.current
    @vacation_name_hash = VacationCategory.pluck("vacation_shortening","vacation_code").to_h
    @employees.each do |employee|
      @attendance_count = AttendanceCount.find_by(:employee_id => employee.id, :year => params[:year],:month => params[:month])
      @attendance = Attendance.find_by(:employee_id => employee.id, :year => params[:year],:month => params[:month])
      if @attendance.present?
        month_attendances =  @attendance.month_attendances
        attendance_ary_after = month_attendances.split("")
        attendance_hash= {}
        #通过将所有的假期code和attendance_ary_after这个数组比对，做出一个所有的假期code和其出现次数的hash
        @vacation_name_hash.values.each do |code|
          attendance_hash[code] = attendance_ary_after.map{|x| x if x==code}.compact.count
        end
        if !@attendance_count.present?
          @attendance_count =AttendanceCount.create(:employee_id => employee.id, :year => params[:year],:month => params[:month],:group_id => employee.group,:workshop_id => employee.workshop)
        end
        @attendance_count.update(attendance_hash)
      end
    end
  end


  # 段审核首页
  def duan_verify_index
    @shenhe_year = if Time.now.month == 1
                    (Time.now.year) - 1
                  else
                    Time.now.year
                  end

    @shenhe_month = if Time.now.month ==1
                      12
                    else
                      (Time.now.month) -1
                    end

    @vacation_codes = VacationCategory.pluck("vacation_code").uniq
		can_verified_workshop_id = AttendanceStatus.where(:year => @shenhe_year,:month => @shenhe_month,:status => ["科室已上报","车间已审核"]).pluck("workshop_id").uniq
		if can_verified_workshop_id.all?{|x| x.nil?}
			@duan_can_varify = []
		else
			@duan_can_varify = Workshop.current.where(:id => can_verified_workshop_id)
		end
    workshop_all_verify = []
    @duan_can_varify.each do |workshop|
      group_ids = Group.current.where(:workshop_id => workshop.id).ids
      if AttendanceStatus.where(:group_id => group_ids,:year => @shenhe_year,:month => @shenhe_month,:status => ["车间已审核","科室已上报"]).count == group_ids.count
         workshop_all_verify << workshop.id
      end
    end
    @workshop_all_verify = Workshop.current.where(:id => workshop_all_verify)
    if @duan_can_varify.present?
      @workshop_partial_verify = @duan_can_varify.where.not(:id => @workshop_all_verify.pluck(:id))
    else
      @workshop_partial_verify = []
    end
    duan_cannot_varify = Workshop.current.where.not(id: can_verified_workshop_id)
    duan_all_varified = []
    duan_cannot_varify.each do |workshop|
      group_ids = Group.current.where(:workshop_id => workshop.id).ids
      if AttendanceStatus.where(:group_id => group_ids,:year => @shenhe_year,:month => @shenhe_month,:status => "段已审核").count == group_ids.count
        duan_all_varified << workshop.id
      end
    end
    # 段完全审核完的
    @duan_all_varified = Workshop.current.where(id: duan_all_varified)
    # 车间还没开始审核的
    @workshops_no_varify = Workshop.current.where.not(id: (can_verified_workshop_id + duan_all_varified))
    @applications = Application.where(:status => ["车间发起申请","科室发起申请"])
  end

  # 车间审核首页
  def workshop_verify_index
    @shenhe_year = if Time.now.month == 1
                    (Time.now.year) - 1
                  else
                    Time.now.year
                  end

    @shenhe_month = if Time.now.month ==1
                      12
                    else
                      (Time.now.month) -1
                    end
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    if params[:group_id].present?
      @group = Group.find(params[:group_id])
      @employees = Employee.current.where(:group => @group.id)
      @workshop = Workshop.find_by(:id => @group.workshop_id)
    elsif params[:workshop_id].present?
      @workshop = Workshop.find(params[:workshop_id])
      @employees = Employee.current.where(:workshop => @workshop.id)
      @group = Group.current.find_by(:workshop => @workshop.id)
    end

    if (current_user.has_role? :attendance_admin) || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin)
      @groups = Group.current.where(:workshop_id => @workshop.id)
      @shenhe_day = 1..31
      if AttendanceStatus.where(:year => @shenhe_year, :month => @shenhe_month,:status => ["车间已审核","科室已上报"]).present?
        @attendance_marquee = 1
      end
      @shenhe_attdendance_status = AttendanceStatus.where(:year => @shenhe_year , :month => @shenhe_month,:group_id => @groups.ids,:status => "班组/科室填写中")
      if (Time.now.day >3) && @shenhe_attdendance_status.present?
          @shenhe_attdendance_status.update(:status => "科室已上报",:workshop_id => 1)
      end
      if AttendanceStatus.where(:year => @shenhe_year, :month => @shenhe_month,:group_id => @groups.ids,:status => ["车间已审核","科室已上报"]).present?
        @duan_yijian_permission = 1
      end
      @applications = Application.where(:status => ["车间发起申请","科室发起申请"])
      attendance_statuses = AttendanceStatus.where(:group_id => @groups.ids,:year => @shenhe_year, :month => @shenhe_month)
      @groups_can = @groups.where(:id => attendance_statuses.where(:status => ["车间已审核","科室已上报"]).pluck(:group_id))
      @groups_already = @groups.where(:id => attendance_statuses.where(:status => "段已审核").pluck(:group_id))
      @groups_cannot = @groups.where.not(:id => (@groups_can.pluck(:id) + @groups_already.pluck(:id)) )
    elsif current_user.has_role? :workshopadmin
      if params[:group_id].blank? && params[:workshop_id].blank?
        @workshop = Workshop.find_by(:id => current_user.workshop_id)
        @group = Group.current.find_by(:workshop_id => @workshop.id)
        @employees = Employee.current.where(:group => @group.id)
      end
      @groups = Group.current.where(:workshop_id => @workshop.id)
      if (Time.now.month == 2) || (Time.now.month == 10)
        @shenhe_day = 1..8
      else
        @shenhe_day = 1..6
      end
      @shenhe_attdendance_status = AttendanceStatus.where(:year => @shenhe_year , :month => @shenhe_month,:group_id => @groups.ids,:status => "班组/科室填写中")
      if (Time.now.day >3) && @shenhe_attdendance_status.present?
          @shenhe_attdendance_status.update(:status => "班组已上报")
      end
      if AttendanceStatus.where(:year => @shenhe_year, :month => @shenhe_month,:group_id => @groups.ids,:status => "班组已上报").present?
        @duan_yijian_permission = 1
      end
      if AttendanceStatus.where(:year => @shenhe_year, :month => @shenhe_month,:group_id => @groups.ids,:status => "班组已上报").present? && (@shenhe_day === Time.now.day)
        @attendance_marquee = 1
      end
      @applications = Application.where(:group_id => @groups.ids,:status => "班组发起申请")
      attendance_statuses = AttendanceStatus.where(:group_id => @groups.ids,:year => @shenhe_year, :month => @shenhe_month)
      @groups_can = @groups.where(:id => attendance_statuses.where(:status => "班组已上报").pluck(:group_id))
      @groups_already = @groups.where(:id => attendance_statuses.where(:status => "车间已审核").pluck(:group_id))
      @groups_cannot = @groups.where.not(:id => (@groups_can.pluck(:id) + @groups_already.pluck(:id)) )
    end
    @attendance_status = AttendanceStatus.find_by(:group_id => @group.id,:year => @shenhe_year,:month => @shenhe_month)
  end

end
