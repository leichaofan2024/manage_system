module ChargeDetailsHelper
  def current_user_info
    ChargeDetail.find_by(:科室车间 => Workshop.current.find(current_user.workshop_id).name )
  end
end
