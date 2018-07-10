class MiddleAwardsController < ApplicationController
  layout 'home'

  def index
    @middle_awards = MiddleAward.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      MiddleAward.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to middle_awards_path
  end

end
