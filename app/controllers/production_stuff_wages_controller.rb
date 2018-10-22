class ProductionStuffWagesController < ApplicationController
  layout "home"


  def index
    if params[:year].present? && params[:month].present?
			@year = params[:year].to_i
			@month = params[:month].to_i
		else
			wage_year_month_array = Wage.pluck(:year,:month).uniq.last
			if wage_year_month_array.present?
				@year = wage_year_month_array[0]
				@month = wage_year_month_array[1]
			end
		end
    @years = Wage.pluck("year").uniq
    @months = [["选择月份"]]

    if @years.present?
      @years.each do |year|
        @months<< Wage.where(:year => year).pluck("month").uniq.compact
      end
    end
    gon.month = @months
  end

  def new_line
    @production_wage = ProductionStuffWage.new
  end

  def create_line
    if params[:name].present?
      @name = params[:name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name"].include?(key) || (value =="")}
      @production_wage = ProductionStuffWage.new(:name => @name, :formula => @params_hash)
      if @production_wage.save
        flash[:notice] = "项目新增成功！"
        redirect_to production_stuff_wages_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "production_stuff_wages/new_line"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "production_stuff_wages/new_line"
    end
  end

  def edit_line
    @production_wage = ProductionStuffWage.find(params[:id])
  end

  def update_line
    @production_wage = ProductionStuffWage.find(params[:id])
    @name = params[:name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
       if @production_wage.update(:name => @name, :formula => @params_hash)
        redirect_to production_stuff_wages_path
        flash[:notice] = "项目名及筛选条件更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "production_stuff_wages/new_line"
      end
    elsif @name.present? && @params_hash.blank?
      if @production_wage.update(:name => @name)

        redirect_to production_stuff_wages_path
        flash[:notice] = "项目名更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "production_stuff_wages/new_line"
      end
    elsif @name.blank? && @params_hash.present?
      @production_wage.update(:formula => @params_hash)
      redirect_to production_stuff_wages_path
      flash[:notice] = "筛选条件更新成功！"
    elsif @name.blank? && @params_hash.blank?
      redirect_to production_stuff_wages_path
    end
  end

  def delete_line
    @production_wage = ProductionStuffWage.find(params[:id])
    name  =  @production_wage.name
    @production_wage.delete
    flash[:notice] = "已删除'#{name}'!"
    redirect_to production_stuff_wages_path
  end

  def new_head
   @production_wage_head = "col"+(ProductionStuffWageHead.count+1).to_s
   @employee_columns = Employee.attribute_names - ["id","created_at","updated_at","avatar","group_id","workshop_id","name"]
   productions_arry = []
   productions_key = []
    @employee_columns.each do |key|
      productions_arry << [key, Employee.pluck(key).uniq]
      productions_key << Employee.head_transfer[key]
    end
    gon.production_arry = productions_arry
    gon.production_key = productions_key
  end

  def create_head
    if params[:head_name].present?
      production_head_name= params[:production_head_name]
      @name = params[:head_name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","production_head_name","_method"].include?(key) || (value =="")}
      @production_wage_head = ProductionStuffWageHead.new(:head_name => @name, :production_head_name => production_head_name,:formula => @params_hash)
      if @production_wage_head.save
        redirect_to production_stuff_wages_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "production_stuff_wages/new_head"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "production_stuff_wages/new_head"
    end
  end

  def edit_head
   @production_wage_head = ProductionStuffWageHead.find(params[:id])

  end

  def update_head
    @production_wage_head = ProductionStuffWageHead.find(params[:id])
    @name = params[:head_name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","production_head_name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
      @production_wage_head.update(:head_name => @name ,:formula => @params_hash)
      redirect_to production_stuff_wages_path
      flash[:notice] = "成功更新表头及公式！"
    elsif @name.present? && @params_hash.blank?
      @production_wage_head.update(:head_name => @name )
      redirect_to production_stuff_wages_path
      flash[:notice] = "成功更新表头！"
    elsif @name.blank? && @params_hash.present?
      @production_wage_head.update(:formula => @params_hash)
      redirect_to production_stuff_wages_path
      flash[:notice] = "成功更新公式！"
    else
      redirect_to production_stuff_wages_path
    end
  end

  def delete_head
    @production_wage_head = ProductionStuffWageHead.find(params[:id])
    @production_wage_heads = ProductionStuffWageHead.all
    name = @production_wage_head.head_name
    production_head_id = (@production_wage_head.production_head_name.split("l")[1]).to_i
    head_count = ProductionStuffWageHead.count - 1
    @production_wage_head.delete

    (production_head_id..head_count).each do |production_head|

        @production_wage_heads[production_head-1].update(:production_head_name => ("col" + production_head.to_s))
    end

    flash[:notice] = "已删除'#{name}'!"
    redirect_to production_stuff_wages_path
  end
end
