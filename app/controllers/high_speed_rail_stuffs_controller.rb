class HighSpeedRailStuffsController < ApplicationController

  layout "home"


  def index
    if params[:year].present? && params[:month].present?
			@year = params[:year]
			@month = params[:month]
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
    @high_speed_stuff = HighSpeedRailStuff.new
  end

  def create_line
    if params[:name].present?
      @name = params[:name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name"].include?(key) || (value =="")}
      @high_speed_stuff = HighSpeedRailStuff.new(:name => @name, :formula => @params_hash)
      if @high_speed_stuff.save
        flash[:notice] = "项目新增成功！"
        redirect_to high_speed_rail_stuffs_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_line"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "high_speed_rail_stuffs/new_line"
    end
  end

  def edit_line
    @high_speed_stuff = HighSpeedRailStuff.find(params[:id])
  end

  def update_line
    @high_speed_stuff = HighSpeedRailStuff.find(params[:id])
    @name = params[:name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
       if @high_speed_stuff.update(:name => @name, :formula => @params_hash)
        redirect_to high_speed_rail_stuffs_path
        flash[:notice] = "项目名及筛选条件更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_line"
      end
    elsif @name.present? && @params_hash.blank?
      if @high_speed_stuff.update(:name => @name)

        redirect_to high_speed_rail_stuffs_path
        flash[:notice] = "项目名更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_line"
      end
    elsif @name.blank? && @params_hash.present?
      @high_speed_stuff.update(:formula => @params_hash)
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "筛选条件更新成功！"
    elsif @name.blank? && @params_hash.blank?
      redirect_to high_speed_rail_stuffs_path
    end
  end

  def delete_line
    @high_speed_stuff = HighSpeedRailStuff.find(params[:id])
    name  =  @high_speed_stuff.name
    @high_speed_stuff.delete
    flash[:notice] = "已删除'#{name}'!"
    redirect_to high_speed_rail_stuffs_path
  end

  def new_head
    @high_speed_stuff = "col"+(HighSpeedRailStuffHead.count+1).to_s
    @employee_columns = Employee.column_names - ["id","created_at","updated_at","avatar","group_id","workshop_id","name"]
    employee_array = []
    employee_key = []
    @employee_columns.each do |column|
      employee_array << [column,Employee.pluck(column).uniq]
      employee_key << Employee.head_transfer[column]
    end
    gon.employee_key = employee_key
    gon.employee_array = employee_array
  end

  def new_head_wage
    @high_speed_stuff = "col"+(HighSpeedRailStuffHead.count+1).to_s
    @wages = Wage.head_transfer.keys - ["col1","col2","col3","col4","col5","col6","col7","col8","col9","col10","col11","col12"]
    wage_arry_string = []
    wage_arry = []

    @wages.each do |wage|
      wage_arry_string <<  Wage.head_transfer[wage]
      wage_arry << wage
    end


    gon.wage_arry = wage_arry_string
    gon.wages = wage_arry
  end

  def create_head
    if params[:head_name].present?
      high_head_name= params[:high_head_name]
      @name = params[:head_name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","high_head_name","_method"].include?(key) || (value =="")}
      @high_speed_stuff_head = HighSpeedRailStuffHead.new(:head_name => @name, :high_head_name => high_head_name,:formula => @params_hash)
      @employee_columns = Employee.column_names - ["id","created_at","updated_at","avatar","group_id","workshop_id","name"]
      if @high_speed_stuff_head.save
        redirect_to high_speed_rail_stuffs_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "high_speed_rail_stuffs/new_head"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "high_speed_rail_stuffs/new_head"
    end
  end

  def edit_head
   @high_speed_stuff_head = HighSpeedRailStuffHead.find(params[:id])
  end

  def update_head
    @high_speed_stuff_head = HighSpeedRailStuffHead.find(params[:id])
    @name = params[:head_name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","high_head_name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
      @high_speed_stuff_head.update(:head_name => @name ,:formula => @params_hash)
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "成功更新表头及公式！"
    elsif @name.present? && @params_hash.blank?
      @high_speed_stuff_head.update(:head_name => @name )
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "成功更新表头！"
    elsif @name.blank? && @params_hash.present?
      @high_speed_stuff_head.update(:formula => @params_hash)
      redirect_to high_speed_rail_stuffs_path
      flash[:notice] = "成功更新公式！"
    else
      redirect_to high_speed_rail_stuffs_path
    end
  end

  def delete_head
    @high_speed_stuff_head = HighSpeedRailStuffHead.find(params[:id])
    @high_speed_stuff_heads = HighSpeedRailStuffHead.all
    name = @high_speed_stuff_head.head_name
    high_head_id = (@high_speed_stuff_head.high_head_name.split("l")[1]).to_i
    head_count = HighSpeedRailStuffHead.count - 1
    @high_speed_stuff_head.delete

    (high_head_id..head_count).each do |high_head|

        @high_speed_stuff_heads[high_head-1].update(:high_head_name => ("col" + high_head.to_s))
    end

    flash[:notice] = "已删除'#{name}'!"
    redirect_to high_speed_rail_stuffs_path
  end
end
