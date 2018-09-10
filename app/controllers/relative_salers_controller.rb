class RelativeSalersController < ApplicationController
  layout 'home'
  def index
    if (current_user.has_role? :awardadmin) || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :depudy_leaderadmin)
      @relative_salers = RelativeSaler.page(params[:page]).per(20)
    else
      @relative_salers = RelativeSaler.where(:科室车间 => Workshop.find(current_user.workshop_id).name ).page(params[:page]).per(20)
    end
    respond_to do |format|
      format.html
      format.csv { send_data @relative_salers.to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="工挂工资明细表.xls"'}
    end
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
      render :new
    else
      RelativeSaler.import(params[:file], params[:upload_time])
      flash[:notice] = "上传成功"
      redirect_to relative_salers_path
    end
  end

  def new
    @relative_saler = RelativeSaler.new
  end

  def create
    @relative_saler = RelativeSaler.new(charge_params)
    if @relative_saler.save!
      flash[:notice] = "上传成功"
      redirect_to relative_salers_path
    else
      flash[:notice] = "上传失败"
      render :new
    end
  end


end
