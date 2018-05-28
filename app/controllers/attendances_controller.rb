class AttendancesController < ApplicationController
layout 'home'

	##班组页面--开始
	def group
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		if current_user.has_role? :groupadmin
			group_name = current_user.name.split("-")[1]
			group = Group.find_by(:name => group_name, :workshop_id => Workshop.find_by(:name => current_user.name.split("-")[0]).id)
			@employees = Employee.where(:group => group.id)
			@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		elsif current_user.has_role? :organsadmin
			group = Group.find_by(:name => current_user.name)
			@employees = Employee.where(:group => group.id)
			@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		end

		# 导出考勤表 
		respond_to do |format|
      format.html
      format.csv { send_data @employees.to_csv }
      format.xls
    end
	end
	##班组页面--结束

	##弹窗内选择假期的表单功能--开始
	def create_attendance
		#选择假期确定后存入attendance表中--开始
		#根据表单传来的employee_id参数，找到要更新的考勤数据
		@attendance = Attendance.find_by(:employee_id => params[:employee_id], :month => params[:month], :year => params[:year])
		#把记录考勤的字符串分割成数组，赋值给attendance_ary
		attendance_ary = @attendance.month_attendances.split('')
		#day参数表示修改的是哪一天(由于数组index从0开始，所以在传参数之前就减了1)，code参数表示用户在表单上选择的什么假期，把这两个替换
		#若当前用户是考勤管理员时，则存下修改记录--开始
		if current_user.has_role? :attendance_admin
			AttendanceRecord.create(edit_before: attendance_ary[params[:day].to_i], edit_after: params[:code], modify_person: current_user.name, day: (params[:day].to_i + 1), attendance_id: @attendance.id)
		end
		#若当前用户是考勤管理员时，则存下修改记录--结束
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
			@attendance_count = AttendanceCount.find_by(:employee_id => params[:employee_id], :vacation_code => i[0])
			@attendance_count ||= AttendanceCount.new
			group_id = Employee.find(params[:employee_id]).group
			workshop_id = Employee.find(params[:employee_id]).workshop
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
			name = current_user.name.split("-")
			@group = Group.find_by(:name => name[1])
			if !AttendanceStatus.find_by(:group_id => @group.id).present?
				AttendanceStatus.create(:group_id => @group.id, :status => "班组填写中")
			end
		elsif current_user.has_role? :organsadmin
			name = current_user.name
			@group = Group.find_by(:name => name)
			if !AttendanceStatus.find_by(:group_id => @group.id).present?
				if current_user.has_role? :groupadmin
					AttendanceStatus.create(:group_id => @group.id, :status => "班组填写中")
				elsif current_user.has_role? :organsadmin
					AttendanceStatus.create(:group_id => @group.id, :status => "班组填写中", :workshop_id => @group.wokkshop.id)
				end
			end
		end

		if (current_user.has_role? :groupadmin) or (current_user.has_role? :organsadmin)
			redirect_back(fallback_location: group_attendances_path)
		elsif current_user.has_role? :attendance_admin
			redirect_back(fallback_location: group_current_time_info_attendances_path)
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
		@year = params[:year]
		@month = params[:month]
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		if params[:type] == "group"
			group_name = current_user.name.split("-")[1]
			group = Group.find_by(:name => group_name, :workshop_id => Workshop.find_by(:name => current_user.name.split("-")[0]).id)
			@employees = Employee.where(:group => group.id)
			render action: "group"
		elsif params[:type] == "workshop"
			@workshop = Workshop.find_by(:name => current_user.name)
			@groups = @workshop.groups
			@employees = Employee.where(:workshop => @workshop.id)
			render action: "workshop"
		elsif params[:type] == "duan"
			if Time.now.year == params[:year].to_i && Time.now.month == params[:month].to_i
				status_workshop = AttendanceStatus.pluck("workshop_id").uniq
				if status_workshop.all?{|x| x.nil?}
					@workshops = []
				else
					@workshops = Workshop.find(status_workshop)
				end
			else
				@workshops = Workshop.all
			end
			render action: "duan"
		end
	end

    ##车间页面--开始
	def workshop
		#为展示组织架构的树状图配置数据
		if current_user.has_role? :workshopadmin
			@workshop = Workshop.find_by(:name => current_user.name)
			@groups = @workshop.groups
		else
			@workshop = Group.find_by(:name => current_user.name)
			@groups = @workshop
		end
		#根据用户点击组织架构树状图来筛选展示的现员--开始
		if params[:group].present?
			@employees = Employee.where(:workshop => params[:workshop], :group => params[:group])
		else
			@employees = Employee.where(:workshop => @workshop)
		end
		
			#根据用户点击组织架构树状图捞出该班组的审核状态，用于展示
			if params[:group].present?
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
		if params[:authority] == "workshop"
			#通过获取树形结构图的group参数，将其对应的attendance_status数据状态更新为"车间已审核"--开始
			@workshop = Workshop.find_by(:name => current_user.name)
			AttendanceStatus.find_by(:group_id => params[:group]).update(:status => "车间已审核", :group_id => params[:group])
			redirect_back(fallback_location: workshop_attendances_path)
			#通过获取树形结构图的group参数，将其对应的attendance_status数据状态更新为"车间已审核"--结束
			#每次更新之后都判断是不是全部班组都已通过审核，若是，则插入车间id，表示整个车间已通过审核--开始
			result = []
			@groups = @workshop.groups
			@groups.each do |group|
				if AttendanceStatus.find_by(:group_id => group.id).present?
					if AttendanceStatus.find_by(:group_id => group.id).status == "车间已审核"
						result << 1
					else
						result << 0
					end
				end
			end
			if result.count(1) == @groups.count
				@groups.each do |group|

					AttendanceStatus.find_by(:group_id => group.id).update(:workshop_id => @workshop.id)
				end
			end
			#每次更新之后都判断是不是全部班组都已通过审核，若是，则插入车间id，表示整个车间已通过审核--结束
		elsif params[:authority] == "duan"
			AttendanceStatus.where(:workshop_id => params[:workshop]).update(:status => "段已审核")
		end
	end
	##审核功能--结束

    ##一键审核功能--开始
	def batch_verify
		if params[:authority] == "workshop"
			@workshop = Workshop.find_by(:name => current_user.name)
			@groups = @workshop.groups
			@groups.each do |group|
				AttendanceStatus.find_by(:group_id => group.id).update(:status => "车间已审核", :workshop_id => @workshop.id)
			end
		elsif params[:authority] == "duan"
			status_workshop = AttendanceStatus.pluck("workshop_id").uniq
			@workshops = Workshop.find(status_workshop)
			@workshops.each do |workshop|
				AttendanceStatus.where(:workshop_id => workshop.id).update(:status => "段已审核")
			end 
		end
	end
	##一键审核功能--结束

	##段管理员页面--开始
	def duan
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		status_workshop = AttendanceStatus.pluck("workshop_id").uniq
		if (@year.nil? && @month.nil?) or (@year.to_i == Time.now.year && @month.to_i == Time.now.month)
			status_workshop = AttendanceStatus.pluck("workshop_id").uniq
			if status_workshop.all?{|x| x.nil?}
				@workshops = []
			else
				@workshops = Workshop.find(status_workshop)
			end
		else
			@workshops = Workshop.all
		end
		@duan = params[:duan]
		@workshop = params[:workshop]
		@group = params[:group]
		@month = params[:month]
		@year = params[:year]
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		@a = Workshop.all.count
	end
	##段管理员页面--结束

	##点击段页面的表格数字后显示的详情页面--开始
	def duan_detail
		@duan_detail = {}
		attendance_counts = AttendanceCount.where(:vacation_code => params[:code], :group_id => params[:group], month: params[:month], year: params[:year])
		attendance_counts.each do |attendance_count|
			employee_name = Employee.find_by(:id => attendance_count.employee_id).name
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
		@workshops = Workshop.all
		@count = {}
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
	end
	##段管理员看到的年考勤统计页面--结束

	def create_setting
		attendance_setting = AttendanceSetting.find_by(:vacation => params[:vacation]) || AttendanceSetting.new
		attendance_setting.update(:vacation => params[:vacation], :count => params[:count])
		redirect_to setting_attendances_path
 	end

 	def create_application
 		employee_id = Employee.find_by(:group => params[:group], :name => params[:person]).id
 		Application.create(:group_id => params[:group], :employee_id => employee_id, :year => params[:year], :month => params[:month], :day => params[:day], :cause => params[:cause], :apply_person => params[:apply_person], :status => params[:status])
 		redirect_back(fallback_location: group_attendances_path)
 	end

 	def show_application
 		@applications = params[:applications]
 	end

 	def update_application
 		application = Application.find(params[:application_id])
 		application.update(:status => params[:status])
 		redirect_back(fallback_location: show_application_attendances_path)
 	end

 	def show_application_detail
 		@application = params[:application]
 		respond_to do |format|
			format.js
		end
 	end

	def group_current_time_info
		if current_user.has_role? :workshopadmin
			@employees = Employee.where(:workshop => Workshop.find_by(:name => current_user.name).id).page(params[:page]).per(10)
		elsif (current_user.has_role? :superadmin) || (current_user.has_role? :attendance_admin)
			@employees = Employee.order('id ASC').page(params[:page]).per(10)
		end
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
	end

	def caiwu
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
		@vacation_codes = ["d","e","h","i","n","m","j","k"]
		@workshops = Workshop.all
	end

	def create_holiday_time
		if Employee.find_by(:sal_number => params[:sal_number]).nil?
			flash[:alert] = "工资号不存在"
		else
			if Employee.find_by(:sal_number => params[:sal_number]).name == params[:name]
				holiday_start_time = HolidayStartTime.find_by(sal_number: params[:sal_number], vacation: params[:vacation], start_time: params[:start_time]) || HolidayStartTime.new
				holiday_start_time.update(sal_number: params[:sal_number], vacation: params[:vacation], start_time: params[:start_time], name: params[:name])
				flash[:notice] = "设置成功"
			else
				flash[:alert] = "姓名和工资号不匹配，请检查"
			end
		end
		redirect_back(fallback_location: set_holiday_start_time_attendances_path)
	end

	def caiwu2
		@employees = Employee.all
	end
end
