class ExaminationAwardsController < ApplicationController
  layout 'home'

  def index
    @examinations = ExaminationAward.page(params[:page]).per(15)
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
      render :new
    else
      ExaminationAward.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
      redirect_to examination_awards_path
    end
  end

  def new
    @examination = ExaminationAward.new
  end

  def create
    @examination = ExaminationAward.new
    if @examination.save!
      flash[:notice] = "上传成功"
      redirect_to examination_awards_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end


end
