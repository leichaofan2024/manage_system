class AttendancesController < ApplicationController
layout 'home'

	##班组页面--开始
	def group
		group_name = current_user.name.split("-")[1]
		group = Group.find_by(:name => group_name, :workshop_id => Workshop.find_by(:name => current_user.name.split("-")[0]).id)
		@employees = Employee.where(:group => group.id)
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		@years = Attendance.pluck("year").uniq
		@months = Attendance.pluck("month").uniq.reverse
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
		if !AttendanceStatus.find_by(:group_id => @group.id).present?
			AttendanceStatus.create(:group_id => @group.id, :status => "班组填写中")
		end
		redirect_to group_attendances_path
	end
	##弹窗内选择假期的表单功能--结束

	##使用ajax动态呼叫弹框功能--开始
	def show_modal
		@day_number = params[:day_number]
		@employee_id = params[:employee_id]
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
		group_name = current_user.name.split("-")[1]
		group = Group.find_by(:name => group_name, :workshop_id => Workshop.find_by(:name => current_user.name.split("-")[0]).id)
		@employees = Employee.where(:group => group.id)
		render action: "group"
	end

    ##车间页面--开始
	def workshop
		#为展示组织架构的树状图配置数据
		@workshop = Workshop.find_by(:name => current_user.name)
		@groups = @workshop.groups	
		#根据用户点击组织架构树状图来筛选展示的现员--开始
		if params[:group].present?
			@employees = Employee.where(:workshop => params[:workshop], :group => params[:group])
		else
			@employees = Employee.where(:workshop => @workshop)
		end
		if AttendanceStatus.find_by(:group_id => params[:group]).present?
			#根据用户点击组织架构树状图捞出该班组的审核状态，用于展示
			@status = AttendanceStatus.find_by(:group_id => params[:group]).status
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
				if AttendanceStatus.find_by(:group_id => group.id).status == "车间已审核"
					result << 1
				else
					result << 0
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
		status_workshop = AttendanceStatus.pluck("workshop_id").uniq
		@workshops = Workshop.find(status_workshop)
		@duan = params[:duan]
		@workshop = params[:workshop]
		@group = params[:group]
		@vacation_codes = VacationCategory.pluck("vacation_code").uniq
		@a = Workshop.all.count
	end
	##段管理员页面--结束

	##点击段页面的表格数字后显示的详情页面--开始
	def duan_detail
		@duan_detail = {}
		attendance_counts = AttendanceCount.where(:vacation_code => params[:code], :group_id => params[:group])
		attendance_counts.each do |attendance_count|
			employee_name = Employee.find_by(:id => attendance_count.employee_id).name
			employee_count = AttendanceCount.find_by(:employee_id => attendance_count.employee_id, :vacation_code => params[:code]).count
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
end
