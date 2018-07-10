class TeamleaderAwardsController < ApplicationController
  layout 'home'

  def index
    @teamleader_awards = TeamleaderAward.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      TeamleaderAward.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to teamleader_awards_path
  end


end
