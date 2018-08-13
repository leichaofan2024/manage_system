class AttendancesController < ApplicationController
  layout 'home'

	##班组页面--开始
	def group
    if (current_user.has_role? :groupadmin) || (current_user.has_role? :wgadmin)
       if Time.now.day >= 4
         @time_range = (Time.now.day - 3)..(Time.now.day)
       else
         @time_range = 1..(Time.now.day)
       end
    elsif current_user.has_role? :organsadmin
       if Time.now.day >= 8
         @time_range = (Time.now.day - 7)..(Time.now.day)
       else
         @time_range = 1..(Time.now.day)
       end
    end
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		group = Group.current.find(current_user.group_id)
		@employees = Employee.current.where(:group => group.id)
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
		# 导出考勤表
		respond_to do |format|
	      format.html
	      format.csv { send_data @employees.to_csv }
	      format.xls
	    end
	end
  #班组个人考勤统计
  def group_employee_detail
    @employee = Employee.current.find(params[:id])
    @group = Group.current.find(@employee.group)
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h


    # @yi_jian = Hash.new
    if params[:year].present? && params[:month].present?
      @attendance = Attendance.find_by(employee_id: @employee.id, month: params[:month], year: params[:year])
      @attendance_count = AttendanceCount.where(employee_id: @employee.id, month: params[:month], year: params[:year])
    else
      @attendance = Attendance.find_by( employee_id: @employee.id, month: Time.now.month, year: Time.now.year)
      @attendance_count = AttendanceCount.where( employee_id: @employee.id, month: Time.now.month, year: Time.now.year)
      # if @yi_jian.present?
      #
      #   @employees = Employee.current.where(:group => @group.id)
      #   @day = @yi_jian["day"].to_i
      #   @name = @yi_jian["name"]
      #   @employees.each do |employee|
      #     month_attendances =
      #   end
      #
      #
      #
      # end
    end
    @attendance_statistics = Hash.new
    @vacation_name_hash.keys.each do |name|
      if @attendance_count.find_by(:vacation_code => name ).present?
        @attendance_statistics[@vacation_name_hash[name]] = @attendance_count.find_by(:vacation_code => name ).count
      else
        @attendance_statistics[@vacation_name_hash[name]] = 0
      end
    end

  end

  #班组一键填写考勤：
  def group_yijian_create
      @group = Group.current.find(current_user.group_id)
      @employees = Employee.current.where(:group => @group.id)
      @attendances = Attendance.where(:employee_id => @employees.pluck(:id), :month => params[:month], :year => params[:year])
      @vacation_name_hash = VacationCategory.pluck("vacation_name","vacation_code").to_h
      @attendances.each do |attendance|
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
        sum = 0
        attendance_hash.each do |i|
          @attendance_count = AttendanceCount.find_by(:employee_id => attendance.employee_id, :vacation_code => i[0], :month => params[:month], :year => params[:year])
          @attendance_count ||= AttendanceCount.new
          @attendance_count.update(:employee_id =>attendance.employee_id, :vacation_code => i[0], :count => i[1], :group_id => params[:group_id], :workshop_id => params[:workshop_id], :month => params[:month], :year => params[:year])
          @attendance_count.save
          if (i[0] == "f") && (i[1] > 0)
            sum += i[1]
          end
          if (i[0] == "g") && (i[1] > 0)
            sum += i[1]
          end
          annual_holiday = AnnualHoliday.find_by(employee_id: attendance.employee_id, month: params[:month], year: params[:year]) || AnnualHoliday.new
          annual_holiday.update(employee_id: attendance.employee_id, month: params[:month], year: params[:year], holiday_days: sum)
        end

      end


      if current_user.has_role? :groupadmin
        @group = Group.current.find(current_user.group_id)
        if !AttendanceStatus.find_by(:group_id => @group.id).present?
          AttendanceStatus.create(:group_id => @group.id, :status => "班组/科室填写中")
        end
      elsif current_user.has_role? :organsadmin
        @group = Group.current.find(current_user.group_id)
        if !AttendanceStatus.find_by(:group_id => @group.id).present?
            AttendanceStatus.create(:group_id => @group.id, :status => "班组/科室填写中", :workshop_id => @group.workshop.id)
        end
      end

      if (current_user.has_role? :groupadmin) or (current_user.has_role? :organsadmin) or (current_user.has_role? :wgadmin)
        redirect_back(fallback_location: group_attendances_path)
      elsif (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin) || (current_user.has_role? :superadmin)
        redirect_back(fallback_location: group_current_time_info_attendances_path)
      end
  end

  #班组考勤统计
  def group_statistics
    @years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		group = Group.current.find(current_user.group_id)
		@employees = Employee.current.where(:group => group.id)
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
  end
	##班组页面--结束

	def create_default_attendance
		Employee.pluck("id").uniq.each do |i|
			if Time.now.month == 12
				attendance = Attendance.where(employee_id: i, year: Time.now.year + 1, month: 1)
				if !attendance.present?
					Attendance.create(employee_id: i, group_id: Employee.find(i).group, year: Time.now.year + 1, month: 1)
					attendance_status = AttendanceStatus.find_by(group_id: Employee.find(i).group) || AttendanceStatus.new
					attendance_status.update(group_id: Employee.find(i).group, status: "班组/科室填写中")
				end
			else
				attendance = Attendance.where(employee_id: i, year: Time.now.year, month: Time.now.month)
				if !attendance.present?
					Attendance.create(employee_id: i, group_id: Employee.find(i).group, year: Time.now.year, month: Time.now.month)
					# attendance_status = AttendanceStatus.find_by(group_id: Employee.find(i).group) || AttendanceStatus.new
					# attendance_status.update(group_id: Employee.find(i).group, status: "班组/科室填写中")
				end
			end
			flash[:notice] = "下月考勤表新增成功"
		end
		redirect_back(fallback_location: duan_attendances_path)
	end

	##弹窗内选择假期的表单功能--开始
	def create_attendance
		#选择假期确定后存入attendance表中--开始
		#根据表单传来的employee_id参数，找到要更新的考勤数据
		if !params[:code].present?
			flash[:alert] = "请先选择考勤"
			if (current_user.has_role? :groupadmin) or (current_user.has_role? :organsadmin)
				redirect_back(fallback_location: group_attendances_path)
			elsif (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin) || (current_user.has_role? :superadmin)
				redirect_back(fallback_location: group_current_time_info_attendances_path)
			end
		else
			@attendance = Attendance.find_by(:employee_id => params[:employee_id], :month => params[:month], :year => params[:year])
			#把记录考勤的字符串分割成数组，赋值给attendance_ary
			attendance_ary = @attendance.month_attendances.split('')
			#day参数表示修改的是哪一天(由于数组index从0开始，所以在传参数之前就减了1)，code参数表示用户在表单上选择的什么假期，把这两个替换
			#若当前用户是考勤管理员时，则存下修改记录--开始
			if (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin)
				AttendanceRecord.create(edit_before: attendance_ary[params[:day].to_i], edit_after: params[:code], modify_person: current_user.name, day: (params[:day].to_i + 1), attendance_id: @attendance.id)
			end
			#若当前用户是考勤管理员时，则存下修改记录--结束
			if current_user.has_role? :workshopadmin
				Message.create(user_id: "3", message_type: "修改考勤", have_read: "0", remind_time: Time.now, message: "#{current_user.name}修改了#{Employee.find(params[:employee_id]).name}#{params[:year]}年#{params[:month]}月#{params[:day].to_i+1}的考勤数据")
			end
			attendance_ary[params[:day].to_i] = params[:code]
			#将替换过的新的数组变成字符串，赋值给attendance_string
			attendance_string = attendance_ary.join('')
			@attendance.update(:month_attendances => attendance_string)
			@attendance.save
			#选择假期确定后存入attendance表中--结束
			#每次更新考勤数据，都更新一次总数(attendance_count)--开始
			#将上面更新过的表示考勤的数组赋值给attendance_ary_after
			attendance_ary_after = @attendance.month_attendances.split("")
			#定义下面需要使用的空hash
			@vacation = {}
			attendance_hash= {}
			#做出一个所有的假期缩写和假期code对应的hash，供下面使用--开始
			@categories = VacationCategory.all
			@categories.each do |category|
				@vacation[category.vacation_shortening] = category.vacation_code
			end
			#做出一个所有的假期缩写和假期code对应的hash，供下面使用--结束
			#通过将所有的假期code和attendance_ary_after这个数组比对，做出一个所有的假期code和其出现次数的hash
			@vacation.values.each do |code|
				attendance_hash[code] = attendance_ary_after.map{|x| x if x==code}.compact.count
			end
			#将上面得到的attendance_hash存入数据库
			sum = 0
			attendance_hash.each do |i|
				@attendance_count = AttendanceCount.find_by(:employee_id => params[:employee_id], :vacation_code => i[0], :month => params[:month], :year => params[:year])
				@attendance_count ||= AttendanceCount.new
				group_id = Employee.current.find(params[:employee_id]).group
				workshop_id = Employee.current.find(params[:employee_id]).workshop
				@attendance_count.update(:employee_id => params[:employee_id], :vacation_code => i[0], :count => i[1], :group_id => group_id, :workshop_id => workshop_id, :month => params[:month], :year => params[:year])

				if (i[0] == "f") && (i[1] > 0)
					sum += i[1]
				end
				if (i[0] == "g") && (i[1] > 0)
					sum += i[1]
				end
			end
			annual_holiday = AnnualHoliday.find_by(employee_id: params[:employee_id], month: params[:month], year: params[:year]) || AnnualHoliday.new
			annual_holiday.update(employee_id: params[:employee_id], month: params[:month], year: params[:year], holiday_days: sum)
			#每次更新考勤数据，都更新一次总数(attendance_count)--结束

			#每次更新考勤数据，都更新一次年休假总数(annual_holiday)--开始

			#每次更新考勤数据，都更新一次年休假总数(annual_holiday)--结束
      if current_user.has_role? :groupadmin
        @group = Group.current.find(current_user.group_id)
        if !AttendanceStatus.find_by(:group_id => @group.id).present?
          AttendanceStatus.create(:group_id => @group.id, :status => "班组/科室填写中")
        end
      elsif current_user.has_role? :organsadmin
        @group = Group.current.find(current_user.group_id)
        if !AttendanceStatus.find_by(:group_id => @group.id).present?
            AttendanceStatus.create(:group_id => @group.id, :status => "班组/科室填写中", :workshop_id => @group.workshop.id)
        end
      end

			if (current_user.has_role? :groupadmin) or (current_user.has_role? :organsadmin) or (current_user.has_role? :wgadmin)
				redirect_back(fallback_location: group_attendances_path)
			elsif (current_user.has_role? :attendance_admin) || (current_user.has_role? :workshopadmin) || (current_user.has_role? :superadmin)
				redirect_back(fallback_location: group_current_time_info_attendances_path)
			end
		end
	end
	##弹窗内选择假期的表单功能--结束

	##使用ajax动态呼叫弹框功能--开始
	def show_modal
		@day_number = params[:day_number]
		@employee_id = params[:employee_id]
		@year = params[:year]
		@month = params[:month]
		@type = params[:type]
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
    if (current_user.has_role? :groupadmin) || (current_user.has_role? :wgadmin)
       if Time.now.day >= 4
         @time_range = (Time.now.day - 3)..(Time.now.day)
       else
         @time_range = 1..(Time.now.day)
       end
    elsif current_user.has_role? :organsadmin
       if Time.now.day >= 8
         @time_range = (Time.now.day - 7)..(Time.now.day)
       else
         @time_range = 1..(Time.now.day)
       end
    end
		@year = params[:year]
		@month = params[:month]
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
    @vacation_code_hash = VacationCategory.pluck("vacation_code","vacation_shortening").to_h
    @vacation_name_hash = VacationCategory.pluck("vacation_code","vacation_name").to_h
		if params[:type] == "group"
			group = Group.current.find(current_user.group_id)

			@leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)
			transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: group.id).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: group.id).pluck("employee_id")
			@employees = Employee.where(id: transfer_employees) | Employee.current.where(:group => group.id)
			render action: "group"
		elsif params[:type] == "workshop"
			@workshop = Workshop.current.find(current_user.workshop_id)
			@groups = @workshop.groups

			@leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)
			transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_workshop: @workshop.id).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_workshop: @workshop.id).pluck("employee_id")
			@employees = Employee.where(id: transfer_employees) | Employee.current.where(:workshop => @workshop.id)
			render action: "workshop"
		elsif params[:type] == "duan"
			if Time.now.year == params[:year].to_i && Time.now.month == params[:month].to_i
				status_workshop = AttendanceStatus.pluck("workshop_id").uniq
				if status_workshop.all?{|x| x.nil?}
					@workshops = []
				else
					@workshops = Workshop.current.find(status_workshop)
				end
			else
				@workshops = Workshop.current
			end
			render action: "duan"
		end
	end

    ##车间页面--开始
	def workshop
		#为展示组织架构的树状图配置数据
		if current_user.has_role? :workshopadmin
			@workshop = Workshop.current.find(current_user.workshop_id)
			@groups = @workshop.groups
		else
			@workshop = Group.current.find(current_user.group_id)
			@groups = @workshop
		end
		#根据用户点击组织架构树状图来筛选展示的现员--开始
		@choose_group = params[:group]
		@choose_workshop = params[:workshop]
		if params[:group].present?
			@leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)
			transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: params[:group]).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: params[:group]).pluck("employee_id")
			@employees = Employee.where(id: transfer_employees) | Employee.current.where(:workshop => params[:workshop], :group => params[:group])
		else
			@leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)
			transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_workshop: @workshop).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_workshop: @workshop).pluck("employee_id")
			@employees = Employee.where(id: transfer_employees) | Employee.current.where(:workshop => @workshop)
		end

			#根据用户点击组织架构树状图捞出该班组的审核状态，用于展示
			if AttendanceStatus.find_by(:group_id => params[:group]).present?
				@status = AttendanceStatus.find_by(:group_id => params[:group]).status
			end

		#根据用户点击组织架构树状图来筛选展示的现员--结束
		#为了使审核按钮知道当前哪个班组在被审核，将用户点击组织架构树状图产生的参数重新传入views页面，供审核按钮使用
		@click_group = params[:group]
		#配置页面上统计考勤的表格数据
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
	end
	##车间页面--结束

	##审核功能--开始
	def verify
    @year = params[:year]
    @month = params[:month]
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
		if params[:authority] == "workshop"
			#通过获取树形结构图的group参数，将其对应的attendance_status数据状态更新为"车间已审核"--开始
			@workshop = Workshop.current.find(current_user.workshop_id)
			AttendanceStatus.find_by(:month => params[:month],:year => params[:year],:group_id => params[:group_id]).update(:status => "车间已审核")
			flash[:notice] = "审核完成"
			#通过获取树形结构图的group参数，将其对应的attendance_status数据状态更新为"车间已审核"--结束
			#每次更新之后都判断是不是全部班组都已通过审核，若是，则插入车间id，表示整个车间已通过审核--开始
			result = []
			@groups = Group.current.where(:workshop_id => @workshop.id)
			@groups.each do |group|
        attendance_status = AttendanceStatus.find_by(:group_id => group.id)
				if attendance_status.present?
					if attendance_status.status == "车间已审核"
						result << 1
					else
						result << 0
					end
				end
			end
			if result.count(1) == @groups.count
        AttendanceStatus.where(:group_id => @groups.ids,:year => params[:year], :month => params[:month]).update(:workshop_id => @workshop.id)
			end
			#每次更新之后都判断是不是全部班组都已通过审核，若是，则插入车间id，表示整个车间已通过审核--结束
		elsif params[:authority] == "duan"
      AttendanceStatus.find_by(:month => params[:month],:year => params[:year],:group_id => params[:group_id]).update(:status => "段已审核")
			flash[:notice] = "审核完成"
		end
	end
	##审核功能--结束

    ##一键审核功能--开始
	def batch_verify
		if params[:authority] == "workshop"
			@workshop = Workshop.current.find(current_user.workshop_id)
			@groups = Group.current.where(:workshop_id => @workshop.id)
			AttendanceStatus.where(:group_id => @groups.ids,:year => params[:year],:month => params[:month]).update(:status => "车间已审核", :workshop_id => @workshop.id)
			flash[:notice] = "审核完毕"
			redirect_back(fallback_location: group_current_time_info_attendances_path)
		elsif params[:authority] == "duan"
			@workshop = Workshop.current.find(params[:workshop_id])
			@groups = Group.current.where(:workshop_id => @workshop.id)
      AttendanceStatus.where(:group_id => @groups.ids,:year => params[:year],:month => params[:month]).update(:status => "段已审核", :workshop_id => @workshop.id)
			flash[:notice] = "审核完毕"
			redirect_back(fallback_location: group_current_time_info_attendances_path)
		end
	end
	##一键审核功能--结束

	##段管理员页面--开始
	def duan
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		if (@year.nil? && @month.nil?) or (@year.to_i == Time.now.year && @month.to_i == Time.now.month)
			status_workshop = AttendanceStatus.pluck("workshop_id").uniq
			if status_workshop.all?{|x| x.nil?}
				@workshops = []
			else
				@workshops = Workshop.current.find(status_workshop)
			end
		else
			@workshops = Workshop.current
		end
		@duan = params[:duan]
		@workshop = params[:workshop]
		@group = params[:group]
		@month = params[:month]
		@year = params[:year]
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		#配置班组的现员数据（当前人员+调动人员）
		@leaving_employees = Employee.transfer_search("#{params[:year]}-#{params[:month]}-01".to_datetime.beginning_of_month, "#{params[:year]}-#{params[:month]}-01".to_datetime.end_of_month)
		transfer_employees = LeavingEmployee.where(id: @leaving_employees["to"]).where(transfer_to_group: @group).pluck("employee_id") + LeavingEmployee.where(id: @leaving_employees["from"]).where(transfer_from_group: @group).pluck("employee_id")
		@employees = Employee.where(id: transfer_employees) | Employee.current.where(:group => params[:group])
	end
	##段管理员页面--结束

	##点击段页面的表格数字后显示的详情页面--开始
	def duan_detail
		@duan_detail = {}
		attendance_counts = AttendanceCount.where(:vacation_code => params[:code], :group_id => params[:group], month: params[:month], year: params[:year])
		attendance_counts.each do |attendance_count|
			employee_name = Employee.current.find_by(:id => attendance_count.employee_id).name
			employee_count = AttendanceCount.find_by(:employee_id => attendance_count.employee_id, :vacation_code => params[:code], month: params[:month], year: params[:year]).count
			@duan_detail[employee_name] = employee_count
		end
	end
	##点击段页面的表格数字后显示的详情页面--结束

	##使用ajax呼叫modal弹框的方法--开始
	def processbar_detail
		@workshops = params[:workshops]
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

 	def create_application
		if !Employee.find_by(:group => params[:group], :name => params[:person]).present?
			flash[:alert] = "您填写的名字不在这个班组"
		else
	 		employee_id = Employee.find_by(:group => params[:group], :name => params[:person]).id
	 		Application.create(:group_id => params[:group], :employee_id => employee_id, :year => params[:year], :month => params[:month], :day => params[:day], :cause => params[:cause], :apply_person => params[:apply_person], :status => params[:status])
			flash[:notice] = "已发起申请"
		end
 		redirect_back(fallback_location: group_attendances_path)
 	end

 	def show_application
 		@applications = params[:applications]
 	end

 	def update_application
 		application = Application.find(params[:application_id])
 		application.update(:status => params[:status])
		flash[:notice] = "已通过申请"
 		redirect_back(fallback_location: show_application_attendances_path)
 	end

 	def show_application_detail
 		@application = params[:application]
 		respond_to do |format|
			format.js
		end
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

    @group = params[:group]
		@workshop = params[:workshop]
    @duan = params[:duan]
    @vacation_codes = VacationCategory.pluck("vacation_code").uniq
		status_workshop = AttendanceStatus.where(:year => @shenhe_year,:month => @shenhe_month).pluck("workshop_id").uniq
		if status_workshop.all?{|x| x.nil?}
			@workshops = []
		else
			@workshops = Workshop.current.find(status_workshop)
		end
    @workshops_not_varify = Workshop.current.where.not(id: status_workshop)

    if current_user.has_role? :attendance_admin
      group_ids = Group.current.pluck(:id)
      if AttendanceStatus.where(:year => @shenhe_year, :month => @shenhe_month,:status => "段已审核",:group_id => group_ids).count < group_ids.count
        @attendance_marquee = 1
      end
    elsif current_user.has_role? :workshopadmin
      group_ids = Group.current.where(:workshop_id => current_user.workshop_id).pluck(:id)
      if AttendanceStatus.where(:group_id => group_ids,:year => @shenhe_year, :month => @shenhe_month,:status => "车间已审核").count < group_ids.count
        @attendance_marquee = 1
      end
    end


		if params[:workshop].present?
      group_ids = Group.current.where(:workshop_id => params[:workshop]).pluck(:id)
      group_ids.each do |group_id|
        if AttendanceStatus.find_by(:year => Time.now.year, :month => Time.now.month,:group_id => group_id).blank?
          AttendanceStatus.create(:year => Time.now.year, :month => Time.now.month,:group_id => group_id,:status => "班组/科室填写中")
        end
        if AttendanceStatus.find_by(:year => @shenhe_year, :month => @shenhe_month,:group_id => group_id).blank?
          AttendanceStatus.create(:year => @shenhe_year, :month => @shenhe_month,:group_id => group_id,:status => "班组/科室填写中")
        end
      end
      if params[:year].present? && (params[:year].to_i ==@shenhe_year) && (params[:month].to_i == @shenhe_month)
        if AttendanceStatus.where(:year => params[:year], :month => params[:month],:group_id => group_ids).where.not(:status => "班组/科室填写中").count == group_ids.count
          @duan_yijian_permission = 1
        end
      end
			   @employees = Employee.current.where(:workshop => params[:workshop]).order('employees.group ASC')
		elsif params[:group].present?
			@employees = Employee.current.where(:group => params[:group]).order('employees.group ASC')
		else
      if (current_user.has_role? :attendance_admin) || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin)
        if @workshops_not_varify.present?
      	  @employees = Employee.current.where(:workshop => @workshops_not_varify.first.id).order('employees.group ASC')
        else
          @employees = Employee.current.where(:workshop => Workshop.first.id).order('employees.group ASC')
        end
      elsif current_user.has_role? :workshopadmin
        group_ids = Group.current.where(:workshop_id => current_user.workshop_id).pluck(:id)

        group_ids.each do |group_id|
          if AttendanceStatus.find_by(:year => Time.now.year, :month => Time.now.month,:group_id => group_id).blank?
            AttendanceStatus.create(:year => Time.now.year, :month => Time.now.month,:group_id => group_id,:status => "班组/科室填写中")
          end
          if AttendanceStatus.find_by(:year => @shenhe_year, :month => @shenhe_month,:group_id => group_id).blank?
            AttendanceStatus.create(:year => @shenhe_year, :month => @shenhe_month,:group_id => group_id,:status => "班组/科室填写中")
          end
        end
				@employees = Employee.current.where(:workshop => Workshop.current.find_by(:name => current_user.name).id).order('employees.group ASC')
      end
		end


	end

	def caiwu
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		@vacation_codes = ["d","e","h","i","n","m","j","k","q", "r"]
		@employees = Employee.page(params[:page]).per(20)

		# 导出考勤表
		@export_employees = Employee.all
		respond_to do |format|
	      format.html
	      format.csv { send_data @export_employees.to_csv }
	      format.xls
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
		@employees = Employee.current.order('id ASC').page(params[:page]).per(20)
		@export_employees = Employee.current
		# 导出考勤表
		respond_to do |format|
	      format.html
	      format.csv { send_data @export_employees.to_csv }
	      format.xls
	    end
	end
end
