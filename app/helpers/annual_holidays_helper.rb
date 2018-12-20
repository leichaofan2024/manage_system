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
    if !employee.working_years.present? || employee.working_years.to_i <= 10
       5
    elsif employee.working_years.to_i >= 11 && employee.working_years.to_i <= 20
       10
    elsif employee.working_years.to_i >= 21
       15
    end
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
