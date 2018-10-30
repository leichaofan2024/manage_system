class CompanyRelativeSalersController < ApplicationController
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
        @month = CompanyRelativeSaler.where(:upload_year => params[:year]).pluck(:upload_month).map{|x| x.to_i}.uniq
      end
    else
      @year = Time.now.year
      @month = [Time.now.month]
    end
    @years = CompanyRelativeSaler.pluck(:upload_year).map{|x| x.to_i}.uniq
    @months = CompanyRelativeSaler.pluck(:upload_month).map{|x| x.to_i}.uniq
    @company_relative_salers = CompanyRelativeSaler.where(:upload_year => @year,:upload_month => @month).page(params[:page]).per(20)
    @export_company_relative_salers = CompanyRelativeSaler.where(:upload_year => @year,:upload_month => @month)
    respond_to do |format|
      format.html
      format.csv { send_data @export_company_relative_salers.to_csv}
      format.xls { headers["Content-Disposition"] = 'attachment; filename="考核扣款明细表.xls"'}
    end
  end

  def import
    if !params[:file].present?
      flash[:alert] = "您还没有选择文件哦"
    elsif !params[:upload_time].present?
      flash[:alert] = "您还没有选择日期哦"
    else
      @import_message = CompanyRelativeSaler.import_form(params[:file],params[:upload_time])
      if @import_message[:head].present?
        flash[:alert] = @import_message[:head]
			elsif @import_message[:year_month].present?
				flash[:alert] = @import_message[:year_month]
			else
				flash[:notice] = "上传成功"
			end
    end
    redirect_to company_relative_salers_path
  end

  def show_modal
    respond_to do |format|
      format.js
    end
  end

  def delete_company_relative_salers
    @year = params[:year]
    @month = params[:month]
    @export_relative_salers = CompanyRelativeSaler.where(:upload_year => @year,:upload_month => @month).delete_all
    flash[:notice] = "#{@year}年#{@month}月考核扣款明细表已成功删除！"
    redirect_to company_relative_salers_path
  end
end
