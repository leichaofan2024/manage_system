class AttendancesController < ApplicationController
layout 'home'

	##班组页面--开始
	def group
		@employees = Employee.where(:workshop => "2")
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
	end
	##班组页面--结束

	##弹窗内选择假期的表单功能--开始
	def create_attendance
		#选择假期确定后存入attendance表中--开始
		#根据表单传来的employee_id参数，找到要更新的考勤数据
		@attendance = Attendance.find_by(:employee_id => params[:employee_id])
		#把记录考勤的字符串分割成数组，赋值给attendance_ary
		attendance_ary = @attendance.month_attendances.split('')
		#day参数表示修改的是哪一天(由于数组index从0开始，所以在传参数之前就减了1)，code参数表示用户在表单上选择的什么假期，把这两个替换
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
		attendance_hash.each do |i|
			@attendance_count = AttendanceCount.find_by(:employee_id => params[:employee_id], :vacation_code => i[0])
			@attendance_count ||= AttendanceCount.new
			group_id = Employee.find(params[:employee_id]).group
			workshop_id = Employee.find(params[:employee_id]).workshop
			@attendance_count.update(:employee_id => params[:employee_id], :vacation_code => i[0], :count => i[1], :group_id => group_id, :workshop_id => workshop_id)
		end
		#每次更新考勤数据，都更新一次总数(attendance_count)--结束
		name = current_user.name.split("-")
		@group = Group.find_by(:name => name[1])
		if !AttendanceStatus.find_by(:workshop_id => @group.workshop.id).present?
			AttendanceStatus.create(:workshop_id => @group.workshop.id, :status => "班组填写中")
		end
		redirect_to group_attendances_path
	end
	##弹窗内选择假期的表单功能--结束

	##使用ajax动态呼叫弹框功能--开始
	def show_modal
		@day_number = params[:day_number]
		@categories = VacationCategory.all
		@employee_id = params[:employee_id]
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
		respond_to do |format|
			format.js
		end
	end
	##使用ajax动态呼叫弹框功能--结束

    ##车间页面--开始
	def workshop
		#为展示组织架构的树状图配置数据
		@workshop = Workshop.find_by(:name => current_user.name)
		@groups = @workshop.groups	
		#根据用户点击组织架构树状图来筛选展示的现员--开始
		if params[:group].present?
			#根据用户点击组织架构树状图捞出该班组的审核状态，用于展示
			@status = AttendanceStatus.find_by(:group_id => params[:group]).status
			@employees = Employee.where(:workshop => params[:workshop], :group => params[:group])
		else
			@employees = Employee.where(:workshop => @workshop)
		end
		#根据用户点击组织架构树状图来筛选展示的现员--结束
		#为了使审核按钮知道当前哪个班组在被审核，将用户点击组织架构树状图产生的参数重新传入views页面，供审核按钮使用
		@click_group = params[:group]
		#配置页面上统计考勤的表格数据
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
	end
	##车间页面--结束

	##审核功能--开始
	def verify
		@workshop = Workshop.find_by(:name => current_user.name)
		@attendance_status = AttendanceStatus.find_by(:workshop_id => @workshop) || AttendanceStatus.new
		@attendance_status.update(:status => "车间已审核", :workshop_id => @workshop.id)
		redirect_back(fallback_location: workshop_attendances_path)
	end
	##审核功能--结束

	##段管理员页面--开始
	def duan
		@workshops = Workshop.all
		if params[:workshop].present?
			@employees = Employee.where(:workshop => params[:workshop])
		else
			@employees = Employee.where(:workshop => "1")
		end

		@vacation_names = VacationCategory.pluck("vacation_name").uniq
		@categories = VacationCategory.all
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
	end
	##段管理员页面--结束

	def annual_statistic
		@workshops = Workshop.all
		@count = {}
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
	end
end
