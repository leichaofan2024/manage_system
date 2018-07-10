class ExaminationAwardsController < ApplicationController
  layout 'home'

  def index
    @examinations = ExaminationAward.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      ExaminationAward.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to examination_awards_path
  end


end
