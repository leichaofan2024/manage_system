class OtherAwardTotalsController < ApplicationController
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
        @month = OtherAwardTotal.where(:upload_year => params[:year]).pluck(:upload_month).map{|x| x.to_i}.uniq
      end
    else
      @year = Time.now.year
      @month = [Time.now.month]
    end
    @years = OtherAwardTotal.pluck(:upload_year).map{|x| x.to_i}.uniq
    @months = OtherAwardTotal.pluck(:upload_month).map{|x| x.to_i}.uniq
    @other_award_totals_heads = OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month)
    @head_hash = @other_award_totals_heads.pluck(:name,:col_name).uniq.to_h
    @other_award_totals = OtherAwardTotal.where(:upload_year => @year,:upload_month => @month).group_by{|x| x.科室车间}
    @export_other_award_totals = OtherAwardTotal.where(:upload_year => @year,:upload_month => @month).group_by{|x| x.科室车间}
    respond_to do |format|
      format.html
      format.csv { send_data @export_other_award_totals.to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="其他单项总明细表.xls"'}
    end
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    elsif !params[:upload_time].present?
      flash[:alert] = "您还没有选择日期哦"
    else
      @import_message = OtherAwardTotal.import_form(params[:file],params[:upload_time])
      if @import_message[:head].present?
        flash[:alert] = @import_message[:head]
      elsif @import_message[:year_month].present?
        flash[:alert] = @import_message[:year_month]
      else
        flash[:notice] = "上传成功"
      end
    end
    redirect_to other_award_totals_path
  end

  def show_modal
    respond_to do |format|
      format.js
    end
  end

  def edit_head
    @year = params[:year]
    @month = params[:month]
    @name = params[:name]
    respond_to do |format|
      format.js
    end
  end

  def update_head
    @year = params[:year]
    @month = params[:month]
    @old_name = params[:old_name]
    @name = params[:name]
    # 旧名字所在的月份：
    old_year_months = OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month,:name => @old_name).pluck(:year,:month)
    old_year_months.each do |year_month|
      already_have_head = OtherAwardTotalsHead.where(:upload_year => year_month[0],:upload_month => year_month[1],:name => @name)
      if already_have_head.present?
        flash[:alert] = "修改失败！#{year_month[1]}月已有单项奖#{@name}，同一月份单项奖名不可重复！"
        redirect_to other_award_totals_path(:year => @year,:month => @month)
      end
    end

    # 旧名字或新名字在以前已经存在：
    all_old_names = OtherAwardTotalsHead.where.not(:upload_year => @year,:upload_month => @month).pluck(:name).uniq
    all_new_names = OtherAwardTotalsHead.all.pluck(:name).uniq
    head_hash = OtherAwardTotalsHead.pluck(:name,:col_name).uniq.to_h
    if all_old_names.include?(@old_name) && all_new_names.include?(@name)
       OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month,:name => @old_name).update(:name => @name,:col_name => head_hash[@name])
       OtherAwardTotal.where(:upload_year => @year,:upload_month => @month).each do |other_award|
         
       end
    OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month,:name => @old_name).update(:name => @name)
    flash[:notice] = "#{@month}月单项奖【#{@old_name}】成功修改为【#{@name}】 !"
    redirect_to other_award_totals_path(:year => @year,:month => @month)
  end

  def delete_other_award_totals
    @year = params[:year]
    @month = params[:month]
    OtherAwardTotal.where(:upload_year => @year,:upload_month => @month).delete_all
    OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month).delete_all
    flash[:notice] = "#{@year}年#{@month}月其他单项总明细表已成功删除！"
    redirect_to other_award_totals_path
  end
end
