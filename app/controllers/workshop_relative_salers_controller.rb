class WorkshopRelativeSalersController < ApplicationController
  layout 'home'
  def index
    if params[:year].present?
      @year = params[:year].to_i
      @month = Array.new
      if params[:month].present?
        params[:month].each do |month|
          @month << month.to_i
        end
      else
        @month = WorkshopRelativeSaler.where(:upload_year => params[:year]).pluck(:upload_month).map{|x| x.to_i}.uniq
      end
    else
      @year = Time.now.year
      @month = [Time.now.month]
    end
    @other_award_totals_heads = OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month)
    @head_hash = @other_award_totals_heads.pluck(:name,:col_name).uniq.to_h
    @years = WorkshopRelativeSaler.pluck(:upload_year).map{|x| x.to_i}.uniq
    @months = WorkshopRelativeSaler.pluck(:upload_month).map{|x| x.to_i}.uniq
    if (current_user.name == "计划财务科") || (current_user.has_role? :superadmin) || (current_user.has_role? :leaderadmin) || (current_user.has_role? :awardadmin)
      @workshop_relative_salers = WorkshopRelativeSaler.where(:upload_year => @year,:upload_month => @month).group_by{|x| x.工资号}
      @export_workshop_relative_salers = WorkshopRelativeSaler.where(:upload_year => @year,:upload_month => @month).group_by{|x| x.工资号}
    elsif (current_user.has_role? :organsadmin) || (current_user.has_role? :workshopadmin)
      @workshop_relative_salers = WorkshopRelativeSaler.where(:upload_year => @year,:upload_month => @month,:科室车间 => current_user.name).group_by{|x| x.工资号}
      @export_workshop_relative_salers = WorkshopRelativeSaler.where(:upload_year => @year,:upload_month => @month,:科室车间 => current_user.name).group_by{|x| x.工资号}
    end
    respond_to do |format|
      format.html
      format.csv { send_data @export_workshop_relative_salers.to_csv }
      format.xls { headers["Content-Disposition"] = 'attachment; filename="工效挂钩工资明细表.xls"'}
    end
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    elsif !params[:upload_time].present?
      flash[:alert] = "您还没有选择日期哦"
    else
      @import_message = WorkshopRelativeSaler.import_form(params[:file],params[:upload_time])
      if @import_message[:head].present?
        flash[:alert] = @import_message[:head]
      elsif @import_message[:no_workshop_relative_saler].present?
        flash[:alert] = @import_message[:no_workshop_relative_saler]
			elsif @import_message[:year_month].present?
				flash[:alert] = @import_message[:year_month]
      elsif @import_message[:after_total].present?
				flash[:alert] = @import_message[:after_total]
      elsif @import_message[:workshop_name].present?
				flash[:alert] = @import_message[:workshop_name]
      elsif @import_message[:value_match].present?
        flash[:alert] = "#{@import_message[:value_match]}这几项的合计值与劳资上传的工挂工资汇总表有出入，请核对后再上传！"
			else
				flash[:notice] = "上传成功"
			end
    end
    redirect_to workshop_relative_salers_path
  end

  def show_modal
    respond_to do |format|
			format.js
		end
  end

  def delete_workshop_relative_salers
    @year = params[:year]
    @month = params[:month]
    workshop_name = current_user.name
    WorkshopRelativeSaler.where(:upload_year => @year,:upload_month => @month,:科室车间 => workshop_name).delete_all
    WorkshopSingleAward.where(:upload_year => @year,:upload_month => @month,:科室车间 => workshop_name).delete_all
    WorkshopStandartStarAward.where(:upload_year => @year,:upload_month => @month,:科室车间 => workshop_name).delete_all
    flash[:notice] = "#{workshop_name}#{@year}年#{@month}月工效挂钩明细表及同期单项奖表均已成功删除！"
    redirect_to workshop_relative_salers_path
  end


  def single_award_import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    elsif !params[:upload_time].present?
      flash[:alert] = "您还没有选择日期哦"
    else
      @import_message = WorkshopSingleAward.import_form(params[:file],params[:upload_time],params[:name])
      if @import_message[:head].present?
        flash[:alert] = @import_message[:head]
      elsif @import_message[:workshop_name].present?
				flash[:alert] = @import_message[:workshop_name]
      elsif @import_message[:value_match].present?
        flash[:alert] = "#{@import_message[:value_match]}这几项的合计值与劳资上传的单项奖汇总表有出入，请核对后再上传！"
      else
        flash[:notice] = "单项奖明细表#{params[:name]}上传成功"
      end
    end
    redirect_to workshop_relative_salers_path
  end

  def standard_star_award_import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    elsif !params[:upload_time].present?
      flash[:alert] = "您还没有选择日期哦"
    else
      @import_message = WorkshopStandartStarAward.import_form(params[:file],params[:upload_time],params[:name])
      if @import_message[:head].present?
        flash[:alert] = @import_message[:head]
      elsif @import_message[:year_month].present?
        flash[:alert] = @import_message[:year_month]
      elsif @import_message[:after_total].present?
        flash[:alert] = @import_message[:after_total]
      elsif @import_message[:workshop_name].present?
        flash[:alert] = @import_message[:workshop_name]
      elsif @import_message[:value_match].present?
        flash[:alert] = "#{@import_message[:value_match]}这几项的合计值与劳资上传的#{params[:name]}汇总表有出入，请核对后再上传！"
      else
        flash[:notice] = "单项奖明细表#{params[:name]}上传成功"
      end
    end
    redirect_to workshop_relative_salers_path
  end

  def single_award_upload
    @name = params[:name]
    respond_to do |format|
      format.js
    end
  end

end
