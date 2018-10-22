class MainDrivingStuffsController < ApplicationController

  layout "home"
  before_action :employee_name_colums,only: [:new_head,:new_line]

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
    @main_wage = ProductionStuffWage.new
  end

  def create_line
    if params[:name].present?
      @name = params[:name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name"].include?(key) || (value =="")}
      @main_stuff = MainDrivingStuff.new(:name => @name, :formula => @params_hash)
      if @main_stuff.save
        flash[:notice] = "项目新增成功！"
        redirect_to main_driving_stuffs_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "main_driving_stuffs/new_line"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "main_driving_stuffs/new_line"
    end
  end

  def edit_line
    @main_stuff = MainDrivingStuff.find(params[:id])
  end

  def update_line
    @main_stuff = MainDrivingStuff.find(params[:id])
    @name = params[:name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
       if @main_stuff.update(:name => @name, :formula => @params_hash)
        redirect_to main_driving_stuffs_path
        flash[:notice] = "项目名及筛选条件更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "main_driving_stuffs/new_line"
      end
    elsif @name.present? && @params_hash.blank?
      if @main_stuff.update(:name => @name)

        redirect_to main_driving_stuffs_path
        flash[:notice] = "项目名更新成功！"
      else
        flash[:warning] = "项目名称不能重复！"
        render "main_driving_stuffs/new_line"
      end
    elsif @name.blank? && @params_hash.present?
      @main_stuff.update(:formula => @params_hash)
      redirect_to main_driving_stuffs_path
      flash[:notice] = "筛选条件更新成功！"
    elsif @name.blank? && @params_hash.blank?
      redirect_to main_driving_stuffs_path
    end
  end

  def delete_line
    @main_stuff = MainDrivingStuff.find(params[:id])
    name  =  @main_stuff.name
    @main_stuff.delete
    flash[:notice] = "已删除'#{name}'!"
    redirect_to main_driving_stuffs_path
  end

  def new_head
   @main_stuff_head = "col"+(MainDrivingStuffHead.count+1).to_s
  end

  def new_head_wage
    @main_stuff_head = "col"+(MainDrivingStuffHead.count+1).to_s
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
      main_head_name= params[:main_head_name]
      @name = params[:head_name]
      @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","main_head_name","_method"].include?(key) || (value =="")}
      @main_stuff_head = MainDrivingStuffHead.new(:head_name => @name, :main_head_name => main_head_name,:formula => @params_hash)
      if @main_stuff_head.save
        redirect_to main_driving_stuffs_path
      else
        flash[:warning] = "项目名称不能重复！"
        render "main_driving_stuffs/new_head"
      end
    else
      flash[:warning] = "项目名称不能为空!"
      render "main_driving_stuffs/new_head"
    end
  end

  def edit_head
   @main_stuff_head = MainDrivingStuffHead.find(params[:id])

  end

  def update_head
    @main_stuff_head = MainDrivingStuffHead.find(params[:id])
    @name = params[:head_name]
    @params_hash = params.delete_if{|key,value| ["utf8","authenticity_token","commit","controller","action","head_name","main_head_name","id","_method"].include?(key) || (value =="")}
    if @name.present? && @params_hash.present?
      @main_stuff_head.update(:head_name => @name ,:formula => @params_hash)
      redirect_to main_driving_stuffs_path
      flash[:notice] = "成功更新表头及公式！"
    elsif @name.present? && @params_hash.blank?
      @main_stuff_head.update(:head_name => @name )
      redirect_to main_driving_stuffs_path
      flash[:notice] = "成功更新表头！"
    elsif @name.blank? && @params_hash.present?
      @main_stuff_head.update(:formula => @params_hash)
      redirect_to main_driving_stuffs_path
      flash[:notice] = "成功更新公式！"
    else
      redirect_to main_driving_stuffs_path
    end
  end

  def delete_head
    @main_stuff_head = MainDrivingStuffHead.find(params[:id])
    @main_stuff_heads = MainDrivingStuffHead.all
    name = @main_stuff_head.head_name
    main_head_id = (@main_stuff_head.main_head_name.split("l")[1]).to_i
    head_count = MainDrivingStuffHead.count - 1
    @main_stuff_head.delete

    (main_head_id..head_count).each do |main_head|

        @main_stuff_heads[main_head-1].update(:main_head_name => ("col" + main_head.to_s))
    end

    flash[:notice] = "已删除'#{name}'!"
    redirect_to main_driving_stuffs_path
  end
end
