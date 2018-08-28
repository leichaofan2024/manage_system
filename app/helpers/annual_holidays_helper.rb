module AnnualHolidaysHelper
  def holiday_plan_column(workshop,workshops,type,column)
    number = 0
    if workshop.present?
      holiday(workshop,type,column)
      return number
    else
      workshops.each do |workshop|
        holiday(workshop,type,column)
      end
      return number
    end
  end

  def holiday(workshop,type,column)
    holiday = AnnualHolidayPlan.find_by(workshop_id: workshop, year: Time.now.year, work_type: type)
    holiday_attribute = holiday.attributes
    if holiday.present? && holiday_attribute[column].present?
      number += holiday_attribute[column]
    else
      0
    end
  end

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

  def holiday_params_year(i,params_year)
    holiday = AnnualHoliday.find_by(month: i, year: params_year, employee_id: employee.id)
    if holiday.present?
      holiday.holiday_days
    end
  end

end
