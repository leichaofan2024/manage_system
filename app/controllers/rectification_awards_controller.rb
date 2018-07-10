class RectificationAwardsController < ApplicationController
  layout 'home'


  def index
    @rectifications = RectificationAward.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      RectificationAward.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to rectification_awards_path
  end
end
