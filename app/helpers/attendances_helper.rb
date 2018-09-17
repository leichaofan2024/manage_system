module AttendancesHelper
  def workshop_checked(shenhe_day,groups,shenhe_year,shenhe_month,status)
    if AttendanceStatus.where(:group_id => groups.ids,:year => shenhe_year, :month => shenhe_month,:status => status).present? && shenhe_day === Time.now.day
      "有班组待审核"
    else
      "暂时没有可以审核的班组"
    end
  end

  def groups_checked(group,year,month)
    if AttendanceStatus.where(group_id: group, year: year, month: month).present?
      AttendanceStatus.find_by(group_id: group, year: year, month: month).status
    end
  end
end
