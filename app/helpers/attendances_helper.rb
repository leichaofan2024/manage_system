module AttendancesHelper
  def workshop_checked(shenhe_day,groups,shenhe_year,shenhe_month,status)
    if shenhe_day === Time.now.day
      if AttendanceStatus.where(:group_id => groups.ids,:year => shenhe_year, :month => shenhe_month,:status => status).present?
        "有班组待审核"
      else
        "暂时没有可以审核的班组"
      end
    end
  end

  def groups_checked(shenhe_day,group,year,month)
    if shenhe_day === Time.now.day
        if AttendanceStatus.where(group_id: group, year: year, month: month).present?
          AttendanceStatus.find_by(group_id: group, year: year, month: month).status
        end
    end
  end
end
