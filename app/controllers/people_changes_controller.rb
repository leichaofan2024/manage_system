class PeopleChangesController < ApplicationController
  layout 'home'

  def index
    @changes = PeopleChange.all
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    else
      PeopleChange.import(params[:file])
      flash[:notice] = "上传成功"
    end
    redirect_to people_changes_path
  end

end
