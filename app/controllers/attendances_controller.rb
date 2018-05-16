class AttendancesController < ApplicationController
layout 'home'

	##班组页面--开始
	def group
		@employees = Employee.all
		@vacation_names = VacationCategory.pluck("vacation_name").uniq
		@categories = VacationCategory.all
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
	end
	##班组页面--结束

	##弹窗内选择假期的表单功能--开始
	def create_attendance
		@attendance = Attendance.find_by(:employee_id => params[:employee_id])
		a = @attendance.month_attendances.split('')
		a[params[:day].to_i] = params[:code]
		b = a.join('')
		@attendance.update(:month_attendances => b)
		@attendance.save
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
			@status = AttendanceStatus.find_by(:group_id => params[:group])
			@employees = Employee.where(:workshop => params[:workshop], :group => params[:group])
		else
			@employees = Employee.where(:workshop => @workshop)
		end
		#根据用户点击组织架构树状图来筛选展示的现员--结束
		#为了使审核按钮知道当前哪个班组在被审核，将用户点击组织架构树状图产生的参数重新传入views页面，供审核按钮使用
		@click_group = params[:group]
		#配置页面上统计考勤的表格数据
		@vacation_names = VacationCategory.pluck("vacation_name").uniq
		@categories = VacationCategory.all
		@vacation = {}
		@categories.each do |category|
			@vacation[category.vacation_shortening] = category.vacation_code
		end
	end
	##车间页面--结束

	##审核功能--开始
	def verify
		@attendance_status = AttendanceStatus.find_by(:group_id => params[:click_group])
		@attendance_status.update(:status => "车间已审核")
		redirect_back(fallback_location: workshop_attendances_path)
	end
	##审核功能--结束

	##段管理员页面--开始
	def duan
		@employees = Employee.where(:id => 1..12)
	end
	##段管理员页面--结束

end
