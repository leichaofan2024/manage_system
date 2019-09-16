module ApplicationHelper
	def working_years(employee)
		if employee.working_time.present? 
	      working_years = ((Time.now - employee.working_time.to_time)/60/60/24/365).to_i
	    else 
	      working_years = 0
	    end 
	    return working_years
    end 

    def rali_years(employee)
    	if employee.railway_time.present? 
	      rali_years = ((Time.now - employee.railway_time.to_time)/60/60/24/365).to_i
	    else 
	      rali_years = 0
	    end 
	    return rali_years
    end 

    def current_age(employee)
    	age = Time.now.year - (employee.birth_date[0..3]).to_i
    	return age 
    end 

    def render_year_month_of_lastmonth
      result = {}
      this_year = Time.now.year
      this_month = Time.now.month
      if this_month == 1
        result[:year] = this_year - 1
        result[:month] = 12
      else
        result[:year] = this_year
        result[:month] = this_month - 1
      end
      return result
    end
end
