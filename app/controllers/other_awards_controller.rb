class OtherAwardsController < ApplicationController
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
        @month = OtherAward.where(:upload_year => params[:year]).pluck(:upload_month).map{|x| x.to_i}.uniq
      end
    else
      @year = Time.now.year
      @month = [Time.now.month]
    end
    @years = OtherAward.pluck(:upload_year).map{|x| x.to_i}.uniq
    @months = OtherAward.pluck(:upload_month).map{|x| x.to_i}.uniq
    if (current_user.has_role? :organsadmin) || (current_user.has_role? :workshopadmin)
      @other_awards = OtherAward.where(:upload_year => @year,:upload_month => @month,:车间 => current_user.name).group_by{|x| x.工资号}
      @export_other_awards = OtherAward.where(:upload_year => @year,:upload_month => @month,:车间 => current_user.name).group_by{|x| x.工资号}
    else
      @other_awards = OtherAward.where(:upload_year => @year,:upload_month => @month).group_by{|x| x.工资号}
      @export_other_awards = OtherAward.where(:upload_year => @year,:upload_month => @month).group_by{|x| x.工资号}
    end
    respond_to do |format|
      format.html
      format.csv { send_data @export_other_awards.to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="其他返奖明细表.xls"'}
    end
  end

  def import

    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    elsif !params[:upload_time].present?
      flash[:alert] = "您还没有选择日期哦"
    else
      @import_message = OtherAward.import_form(params[:file],params[:upload_time])
      if @import_message[:head].present?
        flash[:alert] = @import_message[:head]
      elsif @import_message[:year_month].present?
        flash[:alert] = @import_message[:year_month]
      else
        flash[:notice] = "上传成功"
      end
    end
    redirect_to other_awards_path
  end


  def show_modal
    respond_to do |format|
      format.js
    end
  end

  def delete_other_awards
    @year = params[:year]
    @month = params[:month]
    OtherAward.where(:upload_year => @year,:upload_month => @month).delete_all
    flash[:notice] = "#{@year}年#{@month}月其他返奖明细表已成功删除！"
    redirect_to other_awards_path
  end

end
