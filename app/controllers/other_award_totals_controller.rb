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
    old_year_months = OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month,:name => @old_name).pluck(:upload_year,:upload_month)
    already_have_head = Array.new
    old_year_months.each do |year_month|
      new_other_award_totals_heads = OtherAwardTotalsHead.where(:upload_year => year_month[0],:upload_month => year_month[1],:name => @name)
      if new_other_award_totals_heads.present?
        already_have_head << year_month[1]
      end
    end

    # 旧名字或新名字在以前已经存在：
    all_old_names = OtherAwardTotalsHead.where.not("upload_year = ? and upload_month in (?)",@year,@month).pluck(:name).uniq
    all_new_names = OtherAwardTotalsHead.all.pluck(:name).uniq
    head_hash = OtherAwardTotalsHead.pluck(:name,:col_name).uniq.to_h
    # 车间科室本月是否已上传单项奖明细表：

    workshop_single_award  = WorkshopSingleAward.where(:upload_year => @year,:upload_month => @month)
    if workshop_single_award.present?
      flash[:alert] = "修改失败！车间科室#{@month}月已上传单项奖明细表，您不能再修改单项奖名称！"
    elsif already_have_head.present?
      flash[:alert] = "修改失败！#{already_have_head[0]}月已有单项奖#{@name}，同一月份单项奖名不可重复！"
    elsif all_new_names.include?(@name)
       OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month,:name => @old_name).update(:name => @name,:col_name => head_hash[@name])
       OtherAwardTotal.where(:upload_year => @year,:upload_month => @month).each do |other_award|
         column_value = other_award.send(head_hash[@old_name])
         other_award.update(head_hash[@old_name] => 0,head_hash[@name] => column_value)
       end
       flash[:notice] = "#{@month}月单项奖【#{@old_name}】成功修改为【#{@name}】 !"
    elsif all_old_names.include?(@old_name) && !all_new_names.include?(@name)
      new_col_name = "col"+(head_hash.count+1).to_s
      head_hash[@name] = new_col_name
      OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month,:name => @old_name).update(:name => @name,:col_name => head_hash[@name])
      OtherAwardTotal.where(:upload_year => @year,:upload_month => @month).each do |other_award|
        column_value = other_award.send(head_hash[@old_name])
        other_award.update(head_hash[@old_name] => 0,head_hash[@name] => column_value)
      end
      flash[:notice] = "旧有新无"
    elsif !all_old_names.include?(@old_name) && !all_new_names.include?(@name)
      OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month,:name => @old_name).update(:name => @name)
      flash[:notice] = "都是新的 !"
    end
    redirect_to other_award_totals_path(:year => @year,:month => @month)
  end

  def delete_other_award_totals
    @year = params[:year]
    @month = params[:month]
    OtherAwardTotal.where(:upload_year => @year,:upload_month => @month).delete_all
    OtherAwardTotalsHead.where(:upload_year => @year,:upload_month => @month).delete_all
    WorkshopSingleAward.where(:upload_year => @year,:upload_month => @month).delete_all
    flash[:notice] = "#{@year}年#{@month}月其他单项总明细表以及车间、科室上传的单项奖表均已同步删除！"
    redirect_to other_award_totals_path
  end
end
