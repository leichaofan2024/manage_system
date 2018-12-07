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
    if employee.working_years <= 10
       5
    elsif employee.working_years >= 11 && employee.working_years <= 20
       10
    elsif employee.working_years >= 21
       15
    end
  end

  def group_holiday_day(employee)
    AnnualHoliday.where(employee_id: employee.id, year: Time.now.year).sum(:holiday_days)
  end


end
