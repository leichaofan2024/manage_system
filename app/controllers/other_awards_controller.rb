class OtherAwardsController < ApplicationController
  layout 'home'

  def index
    @other_awards = OtherAward.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      OtherAward.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to other_awards_path
  end

end
