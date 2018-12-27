module AnnualHolidaysHelper
 



  def group_holiday_fulfill(employee)
    (1..12).each do |month|
    holiday = AnnualHoliday.find_by(month: month, year: Time.now.year, employee_id: employee.id)
        if holiday.present?
          holiday.holiday_days
        else
            ""
        end
    end
  end

  def group_holiday_year(employee)
    if employee.working_time.present? 
      working_years = ((Time.now - employee.working_time.to_time)/60/60/24/365).to_i
    else 
      working_years = 0
    end 
    should_holiday = 0
    if working_years <= 10
       should_holiday = 5
    elsif working_years >= 11 && working_years <= 20
       should_holiday = 10
    elsif working_years >= 21
       should_holiday = 15
    end
    return should_holiday
  end

  def group_holiday_day(employee)
    AnnualHoliday.where(employee_id: employee.id, year: Time.now.year).sum(:holiday_days)
  end

  def holiday_work_type(work_type,employee)
    if work_type == "全部职工"
      if [nil,""].include?(employee.grade)
        "工人"
      else
        "干部"
      end 
    elsif work_type == "干部"
      "干部"
    elsif work_type == "工人"
      "工人"
    elsif work_type == "其中：主要工种"
      employee.duty
    elsif work_type == "接触网工"
      "接触网工"
    elsif work_type == "电力工"
      "电力工"
    elsif work_type == "轨道车司机"
      "轨道车司机"
    end 
  end 

end
