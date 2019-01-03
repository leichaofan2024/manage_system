class AnnualHolidaysController < ApplicationController
	layout 'home'
    before_action :confirm_year
	def index

		if (current_user.has_role? :workshopadmin) or (current_user.has_role? :organsadmin)
			@employees = @employees.where(workshop: "#{current_user.workshop_id}")
		elsif (current_user.has_role? :attendance_admin) or (current_user.has_role? :superadmin)
			@employees = @employees.order("id ASC").page(params[:page]).per(20)
		end
	end

	def holiday_modal
		@work_type = params[:work_type]
		@number = params[:number]
		@workshop = params[:workshop]
		@id = params[:id]
		respond_to do |format|
			format.js
		end
	end


	def create_holiday_plan
		if params[:number].present?
			if current_user.has_role? :workshopadmin
			  holiday = AnnualHolidayPlan.find_by(:workshop_id => params[:workshop], :year => @year, :work_type => params[:work_type]) || AnnualHolidayPlan.new
			  holiday.update(:workshop_id => params[:workshop].to_i, :year => @year, :work_type => params[:work_type], params[:input_name] => params[:number])
			elsif (current_user.has_role? :organsadmin)
			  holiday = AnnualHolidayPlan.find_by(:orgnization_id => params[:workshop], :year => @year, :work_type => params[:work_type]) || AnnualHolidayPlan.new
			  holiday.update(:orgnization_id => params[:workshop].to_i, :year => @year, :work_type => params[:work_type], params[:input_name] => params[:number])
		    end 
		end
		if params[:status].present?
			if current_user.has_role? :workshopadmin
				hoiday_plans = AnnualHolidayPlan.where(:workshop_id => current_user.workshop_id,:year => @year)
			elsif (current_user.has_role? :organsadmin)
				hoiday_plans = AnnualHolidayPlan.where(:orgnization_id => current_user.group_id,:year => @year)
			end 
			if hoiday_plans.present?
				message_array = Array.new 
				hoiday_plans.each do |holiday| 
					if (holiday.this_year_people_number.to_i == holiday.five_days.to_i + holiday.ten_days.to_i + holiday.fifteen_days.to_i) && (holiday.this_year_people_number.to_i == holiday.January_plan_number.to_i + holiday.February_plan_number.to_i + holiday.March_plan_number.to_i + holiday.April_plan_number.to_i + holiday.May_plan_number.to_i + holiday.June_plan_number.to_i + holiday.July_plan_number.to_i + holiday.August_plan_number.to_i + holiday.September_plan_number.to_i + holiday.October_plan_number.to_i + holiday.November_plan_number.to_i + holiday.December_plan_number.to_i) && (holiday.holiday_days.to_i == holiday.January_plan_days.to_i + holiday.February_plan_days.to_i + holiday.March_plan_days.to_i + holiday.April_plan_days.to_i + holiday.May_plan_days.to_i + holiday.June_plan_days.to_i + holiday.July_plan_days.to_i + holiday.August_plan_days.to_i + holiday.September_plan_days.to_i + holiday.October_plan_days.to_i + holiday.November_plan_days.to_i + holiday.December_plan_days.to_i)
					else
						if AnnualHolidayWorkType.find_by(:id => holiday.work_type).present?
						  work_type = AnnualHolidayWorkType.find_by(:id => holiday.work_type).work_type
						  message_array << work_type
					    end 
					end
				end 
				if message_array.present?
				  flash[:alert] = "上报失败！#{message_array}项总数核对有误，请检查！"
				else 
				  hoiday_plans.update(:status => "yes")
				  flash[:notice] = "#{Time.now.year}年年休假计划上报成功！"
				end 
			else
				flash[:alert] = "没有数据，请填写完成后再上报！"
			end
		end
		redirect_back(fallback_location: annual_holidays_path)
	end

	def workshop_holiday_plan
		@years = [@year-1,@year,@year+1]
		if current_user.has_role? :workshopadmin
		  @annual_holiday_plan = AnnualHolidayPlan.find_by(:year => @year,:workshop_id => current_user.workshop_id)
		elsif current_user.has_role? :organsadmin
		  @annual_holiday_plan = AnnualHolidayPlan.find_by(:year => @year,:orgnization_id => current_user.group_id)
		end 
		if @annual_holiday_plan.present? and @annual_holiday_plan.status == "yes"
		  @if_reported = 1 
		else 
		  @if_reported = 0
		end 
	end

	def upload_holiday_form
		if  params[:workshop_id].present? 
        	annual_holiday_plans = AnnualHolidayPlan.where(:status => "yes",:year => params[:year],:workshop_id => params[:workshop_id])
        elsif params[:group_id].present?
        	annual_holiday_plans = AnnualHolidayPlan.where(:status => "yes",:year => params[:year],:orgnization_id => params[:group_id])
        end 
        if annual_holiday_plans.present?
        	flash[:alert] = "#{@year}年年休假计划已上报，已不能再上传！"
		elsif params[:file].present? 
			if params[:workshop_id].present? 
              message = AnnualHolidayPlan.import_table(params[:year],params[:file],"workshop",params[:workshop_id])
            elsif params[:group_id].present? 
              message = AnnualHolidayPlan.import_table(params[:year],params[:file],"group",params[:group_id])
            end 
            if message[:wrong_heads].present? 
               flash[:alert] = "表头#{message[:wrong_heads]}与系统不匹配，请核对后再上传！"
 
            elsif message[:work_type_wrong].present? 
            	flash[:alert] = message[:work_type_wrong]
            else 
           	   flash[:notice] = "#{params[:year]}年年休假计划表上传成功！"
            end 
		end 
		redirect_back :fallback_location => workshop_holiday_plan_annual_holidays_path
	end  

	def duan_holiday_plan
		@years = AnnualHolidayPlan.pluck(:year).uniq.sort{|a,b| b<=>a}
		useless_columns = ["id", "workshop_id","orgnization_id", "work_type","created_at", "updated_at", "year", "status"]
		@columns = AnnualHolidayPlan.column_names - useless_columns
		@workshops = Workshop.current.where(:id => AnnualHolidayPlan.where(:status => "yes",:year => @year).pluck("workshop_id"))
		@organizations = Group.current.where(:id => AnnualHolidayPlan.where(:status => "yes",:year => @year).pluck("orgnization_id"))
		@worktypes = AnnualHolidayWorkType.all
		if params[:workshop].present?
			@name = Workshop.find_by(:id => params[:workshop]).name
			@annual_holidays = AnnualHolidayPlan.where(:workshop_id => params[:workshop],:year => @year,:status => "yes")
		elsif params[:organization].present? 
			@name = Group.find_by(:id => params[:organization]).name
			@annual_holidays = AnnualHolidayPlan.where(:orgnization_id => params[:organization],:year => @year,:status => "yes")
		else 
			@name = "供电段"
			@annual_holidays = AnnualHolidayPlan.where(:year => @year,:status => "yes")
		end
	end

	def update_holiday
		attendance_counts = AttendanceCount.where(:year => Time.now.year, vacation_code: ["f", "g"])
		attendance_counts.pluck("employee_id").uniq.each do |employee|
			(1..12).each do |month|
				if attendance_counts.find_by(employee_id: employee,:year => @year, month: month).present?
					sum = attendance_counts.find_by(employee_id: employee,:year => @year, month: month, vacation_code: "f").count + attendance_counts.find_by(employee_id: employee,:year => @year, month: month, vacation_code: "g").count
				end
				annual_holiday = AnnualHoliday.find_by(employee_id: employee, month: month, year: @year) || AnnualHoliday.new
				annual_holiday.update(employee_id: employee, month: month, year: @year, holiday_days: sum)
			end
		end
		flash["notice"] = "休假更新成功"
		redirect_back(fallback_location: holiday_fulfill_detail_annual_holidays_path)
	end

	def holiday_fulfill_detail
		@employees = @employees.page(params[:page]).per(20)
		workshop = Workshop.current.pluck("name")
	    @group = [["--选择省份--"]]
	    workshop.each do |name|
	      @group << Group.current.where(:workshop_id => Workshop.current.find_by(:name => name).id).pluck("name","id")
	    end
	    gon.group_name = @group
		@years = AnnualHoliday.pluck("year").uniq.sort{|a,b| b<=>a}
		@workshop_names = Workshop.current.pluck("name","id")
	end

	def filter
		@workshops = Workshop.current
		@workshop_names = @workshops.pluck("name","id")
		@group = [[]]
	    @workshops.each do |workshop|
	      @group << Group.current.where(:workshop_id => workshop.id).pluck("name","id")
	    end
	    gon.group_name = @group
		@years = AnnualHoliday.pluck("year").uniq
		
		if params[:group].present?
			employees = @employees.where(:group => params[:group])
		elsif  params[:workshop].present?
			employees = @employees.where(:workshop => params[:workshop])
		else 
			employees = @employees
		end 
		@employees = employees.page(params[:page]).per(20)
        render action: "holiday_fulfill_detail"
		

	end

	def holiday_fulfillment_rate
		@quarter_hash = {1 => [[1,2,3],["January_plan_number", "February_plan_number", "March_plan_number"],["January_plan_days", "February_plan_days", "March_plan_days"]],2 => [[4,5,6],["April_plan_number", "May_plan_number", "June_plan_number"],["April_plan_days", "May_plan_days", "June_plan_days"]],3 => [[7,8,9],["July_plan_number", "August_plan_number", "Semptember_plan_number"],["July_plan_days", "August_plan_days", "Semptember_plan_days"]],4 => [[10,11,12],["October_plan_number", "November_plan_number", "December_plan_number"],["October_plan_days", "November_plan_days", "December_plan_days"]]}
		organizations_ids = Group.current.where(:workshop_id => 1).pluck(:id)
		organizations_hash = Hash.new 
        organizations_ids.each do |gorup| 
        	organizations_hash[gorup] = "group"
        end 
		workshop_ids = Workshop.current.pluck(:id) - [1]
		workshops_hash = Hash.new 
		workshop_ids.each do |workshop| 
			workshops_hash[workshop] = "workshop"
		end 
        @workshops = organizations_hash.merge(workshops_hash)
	end

	def group_holiday_fulfill
		@employees = @employees.where(:group => current_user.group_id)
	end

	def holiday_fulfill
		@dutys = ["接触网工","电力工","轨道车司机"]

	end 

	def workshop_employees
		if (current_user.has_role? :attendance_admin) || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin) 
            @employees = @employees
            @name = "供电段"
            if params[:workshop].present? 
              @name = Workshop.find_by(:id => params[:workshop]).name
	    	  @employees = @employees.where(:workshop => params[:workshop])
		    elsif params[:organization].present?
		      @name = Group.find_by(:id => params[:organization]).name 
		      @employees = @employees.where(:group => params[:organization])
		    end 
	    elsif current_user.has_role? :workshopadmin
	        @employees = @employees.where(:workshop => current_user.workshop_id)
	        @name = Workshop.find_by(:id => current_user.workshop_id).name
	    elsif current_user.has_role? :organsadmin
	    	@employees = @employees.where(:group => current_user.group_id)
	    	@name = Group.find_by(:id => current_user.group_id).name
	    end 
        
        @dutys = ["接触网工","电力工","轨道车司机"]

		if params[:work_type] == "全部职工"
			@employees = @employees
		elsif params[:work_type] == "干部"
			@employees = @employees.where.not(:grade => [nil,""])
	    elsif params[:work_type] == "工人"
	    	@employees = @employees.where(:grade => [nil,""])
	    elsif params[:work_type] == "其中：主要工种"
	    	@employees = @employees.where(:duty => @dutys)
	    elsif params[:work_type] == "接触网工"
	    	@employees = @employees.where(:duty => "接触网工")
	    elsif params[:work_type] == "电力工"
	    	@employees = @employees.where(:duty => "电力工")
	    elsif params[:work_type] == "轨道车司机"
	    	@employees = @employees.where(:duty => "轨道车司机")
		end 
	end 
    
    def reback_status
      if params[:orgnization_id].present? 
      	@name = Group.find_by(:id => params[:orgnization_id]).name
      	AnnualHolidayPlan.where(:orgnization_id => params[:orgnization_id],:year => @year).update(:status => nil)
      elsif params[:workshop_id].present?
      	@name = Workshop.find_by(:id => params[:workshop_id]).name
      	AnnualHolidayPlan.where(:workshop_id => params[:workshop_id],:year => @year).update(:status => nil)
      end 
      flash[:notice] = "《#{@name}》#{@year}年年休假计划表，已成功退回到上报前状态！" 
      redirect_to duan_holiday_plan_annual_holidays_path
    end 

	def confirm_year

		if params[:year].present? 
			@year = params[:year].to_i
		elsif Time.now.month>10
			@year = Time.now.year + 1 
		elsif Time.now.month < 3
			@year = Time.now.year
		end
		@employees = Employee.current
	end 



end
