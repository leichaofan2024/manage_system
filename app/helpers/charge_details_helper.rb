module ChargeDetailsHelper
  def current_user_info
    ChargeDetail.find_by(:科室车间 => current_user.name)
  end
end
